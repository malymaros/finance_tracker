import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/category_budget.dart';
import '../models/expense.dart';
import '../models/plan_item.dart';
import '../models/save_slot.dart';
import 'category_budget_repository.dart';
import 'finance_repository.dart';
import 'plan_repository.dart';

class SaveLoadService {
  static const _maxSaves = 3;

  /// Override base directory for tests. When set, [getApplicationDocumentsDirectory]
  /// is not called. Must be reset to null after each test.
  // ignore: prefer_final_fields
  static String? testBaseDirOverride;

  static Future<String> _baseDir() async {
    if (testBaseDirOverride != null) return testBaseDirOverride!;
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<Directory> _savesDir() async {
    final base = await _baseDir();
    final dir = Directory('$base/saves');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<SaveSlot>> listSaves() async {
    final dir = await _savesDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.split(Platform.pathSeparator).last.startsWith('save_') &&
            f.path.endsWith('.json'))
        .toList();

    final slots = <SaveSlot>[];
    for (final file in files) {
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        slots.add(SaveSlot.fromJson(json));
      } catch (_) {
        final filename = file.path.split(Platform.pathSeparator).last;
        slots.add(SaveSlot(
          id: filename.replaceAll('save_', '').replaceAll('.json', ''),
          name: filename,
          createdAt: file.lastModifiedSync(),
          expenseCount: 0,
          planItemCount: 0,
          isDamaged: true,
        ));
      }
    }

    slots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return slots;
  }

  /// Returns `null` on success, `'cap'` if limit reached, or an error string.
  static Future<String?> createSave(
    String name,
    FinanceRepository financeRepo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
  ) async {
    final existing = await listSaves();
    final nonDamaged = existing.where((s) => !s.isDamaged).length;
    if (nonDamaged >= _maxSaves) return 'cap';

    try {
      await financeRepo.loadAllYears();
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final slot = SaveSlot(
        id: id,
        name: name,
        createdAt: DateTime.now(),
        expenseCount: financeRepo.expenses.length,
        planItemCount: planRepo.items.length,
      );

      final data = {
        ...slot.toJson(),
        'expenses': financeRepo.expenses.map((e) => e.toJson()).toList(),
        'planItems': planRepo.items.map((e) => e.toJson()).toList(),
        'categoryBudgets':
            budgetRepo.budgets.map((b) => b.toJson()).toList(),
      };

      final dir = await _savesDir();
      final file = File('${dir.path}/save_$id.json');
      await file.writeAsString(jsonEncode(data));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<bool> loadSave(
    String saveId,
    FinanceRepository financeRepo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
  ) async {
    try {
      final dir = await _savesDir();
      final file = File('${dir.path}/save_$saveId.json');
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final expenses = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      final planItems = (json['planItems'] as List? ?? [])
          .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final categoryBudgets = (json['categoryBudgets'] as List? ?? [])
          .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
          .toList();

      await financeRepo.restoreFromSnapshot(expenses);
      await planRepo.restoreFromSnapshot(planItems);
      await budgetRepo.restoreFromSnapshot(categoryBudgets);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> deleteSave(String saveId) async {
    final dir = await _savesDir();
    final file = File('${dir.path}/save_$saveId.json');
    if (await file.exists()) await file.delete();
  }

  // ── Auto-backup ─────────────────────────────────────────────────────────────

  static Future<File> _autoSaveFile(int index) async {
    final base = await _baseDir();
    return File('$base/autosave_$index.json');
  }

  static Future<File> _autoSaveMetaFile() async {
    final base = await _baseDir();
    return File('$base/autosave_meta.json');
  }

  /// Deletes the oldest non-damaged saves beyond [_maxSaves]. Called on cold launch.
  /// Damaged saves are left for the user to remove manually, consistent with how
  /// [createSave] counts only non-damaged saves toward the cap.
  static Future<void> _trimSavesToMax() async {
    final saves = await listSaves();
    final nonDamaged = saves.where((s) => !s.isDamaged).toList();
    if (nonDamaged.length <= _maxSaves) return;
    // listSaves() is already sorted newest-first; delete oldest beyond the cap
    final toDelete = nonDamaged.skip(_maxSaves);
    for (final slot in toDelete) {
      await deleteSave(slot.id);
    }
  }

  /// Called once on cold launch. Rotates and writes a new auto-backup if the
  /// last one was not taken today.
  static Future<void> checkAndRotate(
    FinanceRepository financeRepo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
  ) async {
    try {
      await _trimSavesToMax();

      final metaFile = await _autoSaveMetaFile();
      final today = _todayString();

      if (await metaFile.exists()) {
        final meta = jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
        if (meta['lastSavedDate'] == today) return;
      }

      // Rotate: slot 0 → slot 1
      final slot0 = await _autoSaveFile(0);
      final slot1 = await _autoSaveFile(1);
      if (await slot0.exists()) {
        await slot0.copy(slot1.path);
      }

      // Write new snapshot to slot 0
      await financeRepo.loadAllYears();
      final now = DateTime.now();
      final slot = SaveSlot(
        id: 'autosave_0',
        name: _formatDateLabel(now),
        createdAt: now,
        expenseCount: financeRepo.expenses.length,
        planItemCount: planRepo.items.length,
        isAuto: true,
      );
      final data = {
        ...slot.toJson(),
        'expenses': financeRepo.expenses.map((e) => e.toJson()).toList(),
        'planItems': planRepo.items.map((e) => e.toJson()).toList(),
        'categoryBudgets': budgetRepo.budgets.map((b) => b.toJson()).toList(),
      };
      await slot0.writeAsString(jsonEncode(data));

      // Update meta
      await metaFile.writeAsString(jsonEncode({'lastSavedDate': today}));
    } catch (_) {
      // Auto-backup failure is silent — never block app startup
    }
  }

  /// Returns up to 2 auto-backup slots (slot 0 = latest, slot 1 = previous).
  static Future<List<SaveSlot>> listAutoSaves() async {
    final slots = <SaveSlot>[];
    final labels = ['Primary backup', 'Secondary backup'];

    for (int i = 0; i < 2; i++) {
      final file = await _autoSaveFile(i);
      if (!await file.exists()) continue;
      try {
        final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        slots.add(SaveSlot(
          id: 'autosave_$i',
          name: labels[i],
          createdAt: DateTime.parse(json['createdAt'] as String),
          expenseCount: json['expenseCount'] as int,
          planItemCount: json['planItemCount'] as int,
          isAuto: true,
        ));
      } catch (_) {
        slots.add(SaveSlot(
          id: 'autosave_$i',
          name: labels[i],
          createdAt: (await file.lastModified()),
          expenseCount: 0,
          planItemCount: 0,
          isDamaged: true,
          isAuto: true,
        ));
      }
    }
    return slots;
  }

  /// Restores data from an auto-backup slot identified by [slotId]
  /// ("autosave_0" or "autosave_1").
  static Future<bool> loadAutoSave(
    String slotId,
    FinanceRepository financeRepo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
  ) async {
    try {
      final index = int.tryParse(slotId.replaceFirst('autosave_', ''));
      if (index == null) return false;
      final file = await _autoSaveFile(index);
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final expenses = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      final planItems = (json['planItems'] as List? ?? [])
          .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
          .toList();
      final categoryBudgets = (json['categoryBudgets'] as List? ?? [])
          .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
          .toList();

      await financeRepo.restoreFromSnapshot(expenses);
      await planRepo.restoreFromSnapshot(planItems);
      await budgetRepo.restoreFromSnapshot(categoryBudgets);
      return true;
    } catch (_) {
      return false;
    }
  }

  static String _todayString() {
    final now = DateTime.now();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '${now.year}-$m-$d';
  }

  static String _formatDateLabel(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    return '$day ${months[dt.month]} ${dt.year}';
  }
}
