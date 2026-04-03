import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/services/save_load_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

late Directory _tempDir;

FinanceRepository _financeRepo() => FinanceRepository(persist: false);
PlanRepository _planRepo() => PlanRepository(persist: false);
CategoryBudgetRepository _budgetRepo() => CategoryBudgetRepository(persist: false);
GuardRepository _guardRepo() => GuardRepository(persist: false);

AppRepositories _repos({FinanceRepository? finance}) => AppRepositories(
      finance: finance ?? _financeRepo(),
      plan: _planRepo(),
      budget: _budgetRepo(),
      guard: _guardRepo(),
    );

/// Writes a minimal valid save file directly into the saves/ subdirectory.
Future<void> _writeSaveFile(String id, DateTime createdAt) async {
  final dir = Directory('${_tempDir.path}/saves');
  await dir.create(recursive: true);
  final file = File('${dir.path}/save_$id.json');
  await file.writeAsString(jsonEncode({
    'id': id,
    'name': 'Save $id',
    'createdAt': createdAt.toIso8601String(),
    'expenseCount': 1,
    'planItemCount': 0,
    'expenses': [
      {
        'id': 'e1',
        'amount': 10.0,
        'category': 'groceries',
        'financialType': 'consumption',
        'date': '2024-01-01T00:00:00.000',
      }
    ],
    'planItems': [],
    'categoryBudgets': [],
  }));
}

/// Writes a damaged (invalid JSON) save file.
Future<void> _writeDamagedSaveFile(String id) async {
  final dir = Directory('${_tempDir.path}/saves');
  await dir.create(recursive: true);
  final file = File('${dir.path}/save_$id.json');
  await file.writeAsString('NOT VALID JSON {{{{');
}

/// Writes an autosave meta file with the given date string.
Future<void> _writeMetaFile(String dateString) async {
  final file = File('${_tempDir.path}/autosave_meta.json');
  await file.writeAsString(jsonEncode({'lastSavedDate': dateString}));
}

/// Reads the autosave meta file and returns lastSavedDate.
Future<String?> _readMetaDate() async {
  final file = File('${_tempDir.path}/autosave_meta.json');
  if (!await file.exists()) return null;
  final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  return json['lastSavedDate'] as String?;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() async {
    _tempDir = await Directory.systemTemp.createTemp('save_load_test_');
    SaveLoadService.testBaseDirOverride = _tempDir.path;
  });

  tearDown(() async {
    SaveLoadService.testBaseDirOverride = null;
    await _tempDir.delete(recursive: true);
  });

  // ── listSaves ──────────────────────────────────────────────────────────────

  group('listSaves', () {
    test('returns empty list when saves/ directory is empty', () async {
      final saves = await SaveLoadService.listSaves();
      expect(saves, isEmpty);
    });

    test('returns one slot for one valid save file', () async {
      await _writeSaveFile('abc', DateTime(2024, 3, 1));
      final saves = await SaveLoadService.listSaves();
      expect(saves.length, 1);
      expect(saves.first.id, 'abc');
      expect(saves.first.isDamaged, false);
    });

    test('marks corrupted file as damaged', () async {
      await _writeDamagedSaveFile('broken');
      final saves = await SaveLoadService.listSaves();
      expect(saves.length, 1);
      expect(saves.first.isDamaged, true);
    });

    test('sorted newest-first', () async {
      await _writeSaveFile('old', DateTime(2024, 1, 1));
      await _writeSaveFile('new', DateTime(2024, 6, 1));
      final saves = await SaveLoadService.listSaves();
      expect(saves.first.id, 'new');
      expect(saves.last.id, 'old');
    });
  });

  // ── _trimSavesToMax (tested via createSave + direct file writes) ───────────

  group('_trimSavesToMax (via checkAndRotate)', () {
    test('does not delete damaged saves to satisfy the cap', () async {
      // 2 valid saves + 2 damaged = 4 total; cap = 3 non-damaged
      // trim must NOT delete the valid saves
      await _writeSaveFile('v1', DateTime(2024, 6, 1));
      await _writeSaveFile('v2', DateTime(2024, 5, 1));
      await _writeDamagedSaveFile('d1');
      await _writeDamagedSaveFile('d2');

      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final saves = await SaveLoadService.listSaves();
      final validIds = saves.where((s) => !s.isDamaged).map((s) => s.id).toSet();
      // Both valid saves must survive (only 2 non-damaged, under cap of 3)
      expect(validIds, containsAll(['v1', 'v2']));
    });

    test('does not delete existing saves when over UI cap', () async {
      // checkAndRotate no longer trims manual saves — existing saves are
      // preserved even if they exceed the 3-slot UI cap. Deletion only happens
      // when the user explicitly creates new saves (createSave enforces the cap).
      await _writeSaveFile('s1', DateTime(2024, 6, 1));
      await _writeSaveFile('s2', DateTime(2024, 5, 1));
      await _writeSaveFile('s3', DateTime(2024, 4, 1));
      await _writeSaveFile('s4', DateTime(2024, 3, 1));

      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final saves = await SaveLoadService.listSaves();
      final ids = saves.where((s) => !s.isDamaged).map((s) => s.id).toSet();
      // All 4 saves must survive — checkAndRotate does not delete any.
      expect(ids, containsAll(['s1', 's2', 's3', 's4']));
    });
  });

  // ── listAutoSaves ──────────────────────────────────────────────────────────

  group('listAutoSaves', () {
    test('returns empty list when no autosave files exist', () async {
      final slots = await SaveLoadService.listAutoSaves();
      expect(slots, isEmpty);
    });

    test('returns one slot when only autosave_0 exists', () async {
      // checkAndRotate writes autosave_0
      final financeRepo = _financeRepo();
      await financeRepo.addExpense(Expense(
        id: 'e1',
        amount: 42.0,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
        date: DateTime(2024, 1, 1),
      ));
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final slots = await SaveLoadService.listAutoSaves();
      expect(slots.length, 1);
      expect(slots.first.id, 'autosave_0');
      expect(slots.first.isAuto, true);
      expect(slots.first.isDamaged, false);
      expect(slots.first.expenseCount, 1);
    });

    test('returns two slots after two rotations', () async {
      final financeRepo = _financeRepo();

      // First rotation (simulated yesterday)
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      // Force a second rotation by clearing the meta file
      await File('${_tempDir.path}/autosave_meta.json').delete();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final slots = await SaveLoadService.listAutoSaves();
      expect(slots.length, 2);
      expect(slots.any((s) => s.id == 'autosave_0'), true);
      expect(slots.any((s) => s.id == 'autosave_1'), true);
    });

    test('marks corrupted autosave as damaged', () async {
      await File('${_tempDir.path}/autosave_0.json').writeAsString('INVALID');
      final slots = await SaveLoadService.listAutoSaves();
      expect(slots.length, 1);
      expect(slots.first.isDamaged, true);
      expect(slots.first.isAuto, true);
    });
  });

  // ── checkAndRotate ─────────────────────────────────────────────────────────

  group('checkAndRotate', () {
    test('writes autosave_0 and meta on first run', () async {
      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      expect(await File('${_tempDir.path}/autosave_0.json').exists(), true);
      expect(await File('${_tempDir.path}/autosave_meta.json').exists(), true);
    });

    test('is idempotent — does not re-write when called again same day', () async {
      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final file = File('${_tempDir.path}/autosave_0.json');
      final statBefore = await file.lastModified();

      // Small delay then call again same day
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final statAfter = await file.lastModified();
      expect(statAfter, equals(statBefore));
    });

    test('rotates slot 0 → slot 1 when called on a new day', () async {
      final financeRepo = _financeRepo();

      // First run (today)
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));
      final slot0Content = await File('${_tempDir.path}/autosave_0.json').readAsString();

      // Simulate new day by removing/replacing meta with yesterday's date
      await _writeMetaFile('2000-01-01');

      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final slot1Content = await File('${_tempDir.path}/autosave_1.json').readAsString();
      // slot 1 should have what slot 0 had before the rotation
      expect(slot1Content, equals(slot0Content));
    });

    test('updates meta date after rotation', () async {
      await _writeMetaFile('2000-01-01');
      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(_repos(finance: financeRepo));

      final today = _todayString();
      expect(await _readMetaDate(), equals(today));
    });

    test('does not throw when data is empty', () async {
      expect(
        () => SaveLoadService.checkAndRotate(_repos()),
        returnsNormally,
      );
    });

    test('autosave_0 contains guardPayments key', () async {
      await SaveLoadService.checkAndRotate(_repos());
      final content = await File('${_tempDir.path}/autosave_0.json').readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      expect(map.containsKey('guardPayments'), true);
    });
  });

  // ── loadAutoSave ───────────────────────────────────────────────────────────

  group('loadAutoSave', () {
    test('returns false for invalid slotId', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_foo',
        _repos(),
      );
      expect(result, false);
    });

    test('returns false for non-numeric suffix in slotId', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_',
        _repos(),
      );
      expect(result, false);
    });

    test('returns false when autosave file does not exist', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_0',
        _repos(),
      );
      expect(result, false);
    });

    test('returns true and restores data from autosave_0', () async {
      final writeRepo = _financeRepo();
      await writeRepo.addExpense(Expense(
        id: 'e99',
        amount: 99.0,
        category: ExpenseCategory.transport,
        financialType: FinancialType.consumption,
        date: DateTime(2024, 3, 1),
      ));
      await SaveLoadService.checkAndRotate(_repos(finance: writeRepo));

      final readRepo = _financeRepo();
      final result = await SaveLoadService.loadAutoSave(
        'autosave_0',
        _repos(finance: readRepo),
      );

      expect(result, true);
      expect(readRepo.expenses.length, 1);
      expect(readRepo.expenses.first.id, 'e99');
    });

    test('loadAutoSave restores guardPayments from autosave_0', () async {
      // Write an autosave that contains a guard payment.
      final guardPaymentJson = jsonEncode({
        'id': 'autosave_0',
        'name': 'Test',
        'createdAt': DateTime(2024, 1, 1).toIso8601String(),
        'expenseCount': 0,
        'planItemCount': 0,
        'isAuto': true,
        'expenses': <dynamic>[],
        'planItems': <dynamic>[],
        'categoryBudgets': <dynamic>[],
        'guardPayments': [
          {
            'id': 'gp1',
            'planItemSeriesId': 'series1',
            'period': {'year': 2024, 'month': 3},
            'paidAt': '2024-03-15T10:00:00.000',
          }
        ],
      });
      await File('${_tempDir.path}/autosave_0.json')
          .writeAsString(guardPaymentJson);

      final guardRepo = _guardRepo();
      final result = await SaveLoadService.loadAutoSave(
        'autosave_0',
        AppRepositories(
          finance: _financeRepo(),
          plan: _planRepo(),
          budget: _budgetRepo(),
          guard: guardRepo,
        ),
      );

      expect(result, true);
      expect(guardRepo.payments.length, 1);
      expect(guardRepo.payments.first.id, 'gp1');
      expect(guardRepo.payments.first.paidAt, isNotNull);
    });
  });

  // ── createSave / deleteSave ────────────────────────────────────────────────

  group('createSave', () {
    test('returns null on success', () async {
      final result = await SaveLoadService.createSave('My Save', _repos());
      expect(result, isNull);
    });

    test('returns cap when max saves reached', () async {
      for (int i = 0; i < 3; i++) {
        await SaveLoadService.createSave('Save $i', _repos());
      }
      final result = await SaveLoadService.createSave('One more', _repos());
      expect(result, 'cap');
    });

    test('damaged saves do not count toward cap', () async {
      // 3 valid saves
      for (int i = 0; i < 3; i++) {
        await SaveLoadService.createSave('Save $i', _repos());
      }
      // Add a damaged file manually
      await _writeDamagedSaveFile('damaged');

      // createSave should still return 'cap' (3 non-damaged is at cap)
      final result = await SaveLoadService.createSave('Should fail', _repos());
      expect(result, 'cap');
    });
  });

  group('deleteSave', () {
    test('removes the save file', () async {
      await SaveLoadService.createSave('To Delete', _repos());
      final saves = await SaveLoadService.listSaves();
      expect(saves.length, 1);

      await SaveLoadService.deleteSave(saves.first.id);
      expect(await SaveLoadService.listSaves(), isEmpty);
    });

    test('does not throw if file does not exist', () async {
      expect(
        () => SaveLoadService.deleteSave('nonexistent'),
        returnsNormally,
      );
    });
  });

  // ── loadSave ──────────────────────────────────────────────────────────────

  group('loadSave', () {
    test('restores expenses from saved snapshot', () async {
      final writeRepo = _financeRepo();
      await writeRepo.addExpense(Expense(
        id: 'e1',
        amount: 55.0,
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
        date: DateTime(2024, 2, 1),
      ));
      await SaveLoadService.createSave('snap', _repos(finance: writeRepo));

      final saves = await SaveLoadService.listSaves();
      final readRepo = _financeRepo();
      final ok = await SaveLoadService.loadSave(
        saves.first.id,
        _repos(finance: readRepo),
      );

      expect(ok, true);
      expect(readRepo.expenses.length, 1);
      expect(readRepo.expenses.first.amount, 55.0);
    });

    test('returns false for missing save file', () async {
      final ok = await SaveLoadService.loadSave(
        'nonexistent',
        _repos(),
      );
      expect(ok, false);
    });
  });
}

// ── Helper matching service's internal today string ───────────────────────────

String _todayString() {
  final now = DateTime.now();
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

