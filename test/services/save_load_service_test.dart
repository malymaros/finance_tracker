import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';
import 'package:finance_tracker/services/save_load_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

late Directory _tempDir;

FinanceRepository _financeRepo() => FinanceRepository(persist: false);
PlanRepository _planRepo() => PlanRepository(persist: false);
CategoryBudgetRepository _budgetRepo() => CategoryBudgetRepository(persist: false);

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
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final saves = await SaveLoadService.listSaves();
      final validIds = saves.where((s) => !s.isDamaged).map((s) => s.id).toSet();
      // Both valid saves must survive (only 2 non-damaged, under cap of 3)
      expect(validIds, containsAll(['v1', 'v2']));
    });

    test('deletes oldest non-damaged saves when over cap', () async {
      // 4 non-damaged saves; after trim only newest 3 should remain
      await _writeSaveFile('s1', DateTime(2024, 6, 1)); // newest
      await _writeSaveFile('s2', DateTime(2024, 5, 1));
      await _writeSaveFile('s3', DateTime(2024, 4, 1));
      await _writeSaveFile('s4', DateTime(2024, 3, 1)); // oldest → deleted

      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final saves = await SaveLoadService.listSaves();
      final ids = saves.where((s) => !s.isDamaged).map((s) => s.id).toSet();
      expect(ids, containsAll(['s1', 's2', 's3']));
      expect(ids, isNot(contains('s4')));
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
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

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
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      // Force a second rotation by clearing the meta file
      await File('${_tempDir.path}/autosave_meta.json').delete();
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

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
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      expect(await File('${_tempDir.path}/autosave_0.json').exists(), true);
      expect(await File('${_tempDir.path}/autosave_meta.json').exists(), true);
    });

    test('is idempotent — does not re-write when called again same day', () async {
      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final file = File('${_tempDir.path}/autosave_0.json');
      final statBefore = await file.lastModified();

      // Small delay then call again same day
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final statAfter = await file.lastModified();
      expect(statAfter, equals(statBefore));
    });

    test('rotates slot 0 → slot 1 when called on a new day', () async {
      final financeRepo = _financeRepo();

      // First run (today)
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());
      final slot0Content = await File('${_tempDir.path}/autosave_0.json').readAsString();

      // Simulate new day by removing/replacing meta with yesterday's date
      await _writeMetaFile('2000-01-01');

      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final slot1Content = await File('${_tempDir.path}/autosave_1.json').readAsString();
      // slot 1 should have what slot 0 had before the rotation
      expect(slot1Content, equals(slot0Content));
    });

    test('updates meta date after rotation', () async {
      await _writeMetaFile('2000-01-01');
      final financeRepo = _financeRepo();
      await SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo());

      final today = _todayString();
      expect(await _readMetaDate(), equals(today));
    });

    test('does not throw when data is empty', () async {
      final financeRepo = _financeRepo();
      expect(
        () => SaveLoadService.checkAndRotate(financeRepo, _planRepo(), _budgetRepo()),
        returnsNormally,
      );
    });
  });

  // ── loadAutoSave ───────────────────────────────────────────────────────────

  group('loadAutoSave', () {
    test('returns false for invalid slotId', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_foo',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
      );
      expect(result, false);
    });

    test('returns false for non-numeric suffix in slotId', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
      );
      expect(result, false);
    });

    test('returns false when autosave file does not exist', () async {
      final result = await SaveLoadService.loadAutoSave(
        'autosave_0',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
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
      await SaveLoadService.checkAndRotate(writeRepo, _planRepo(), _budgetRepo());

      final readRepo = _financeRepo();
      final result = await SaveLoadService.loadAutoSave(
        'autosave_0',
        readRepo,
        _planRepo(),
        _budgetRepo(),
      );

      expect(result, true);
      expect(readRepo.expenses.length, 1);
      expect(readRepo.expenses.first.id, 'e99');
    });
  });

  // ── createSave / deleteSave ────────────────────────────────────────────────

  group('createSave', () {
    test('returns null on success', () async {
      final result = await SaveLoadService.createSave(
        'My Save',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
      );
      expect(result, isNull);
    });

    test('returns cap when max saves reached', () async {
      for (int i = 0; i < 3; i++) {
        await SaveLoadService.createSave('Save $i', _financeRepo(), _planRepo(), _budgetRepo());
      }
      final result = await SaveLoadService.createSave(
        'One more',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
      );
      expect(result, 'cap');
    });

    test('damaged saves do not count toward cap', () async {
      // 3 valid saves
      for (int i = 0; i < 3; i++) {
        await SaveLoadService.createSave('Save $i', _financeRepo(), _planRepo(), _budgetRepo());
      }
      // Add a damaged file manually
      await _writeDamagedSaveFile('damaged');

      // createSave should still return 'cap' (3 non-damaged is at cap)
      final result = await SaveLoadService.createSave(
        'Should fail',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
      );
      expect(result, 'cap');
    });
  });

  group('deleteSave', () {
    test('removes the save file', () async {
      await SaveLoadService.createSave('To Delete', _financeRepo(), _planRepo(), _budgetRepo());
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
      await SaveLoadService.createSave('snap', writeRepo, _planRepo(), _budgetRepo());

      final saves = await SaveLoadService.listSaves();
      final readRepo = _financeRepo();
      final ok = await SaveLoadService.loadSave(
        saves.first.id,
        readRepo,
        _planRepo(),
        _budgetRepo(),
      );

      expect(ok, true);
      expect(readRepo.expenses.length, 1);
      expect(readRepo.expenses.first.amount, 55.0);
    });

    test('returns false for missing save file', () async {
      final ok = await SaveLoadService.loadSave(
        'nonexistent',
        _financeRepo(),
        _planRepo(),
        _budgetRepo(),
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

