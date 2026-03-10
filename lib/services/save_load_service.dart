import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/income_entry.dart';
import '../models/plan_item.dart';
import '../models/save_slot.dart';
import 'finance_repository.dart';
import 'plan_repository.dart';

class SaveLoadService {
  static const _maxSaves = 5;

  static Future<Directory> _savesDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/saves');
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
          incomeCount: 0,
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
  ) async {
    final existing = await listSaves();
    final nonDamaged = existing.where((s) => !s.isDamaged).length;
    if (nonDamaged >= _maxSaves) return 'cap';

    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final slot = SaveSlot(
        id: id,
        name: name,
        createdAt: DateTime.now(),
        expenseCount: financeRepo.expenses.length,
        incomeCount: financeRepo.income.length,
        planItemCount: planRepo.items.length,
      );

      final data = {
        ...slot.toJson(),
        'expenses': financeRepo.expenses.map((e) => e.toJson()).toList(),
        'income': financeRepo.income.map((e) => e.toJson()).toList(),
        'planItems': planRepo.items.map((e) => e.toJson()).toList(),
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
  ) async {
    try {
      final dir = await _savesDir();
      final file = File('${dir.path}/save_$saveId.json');
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final expenses = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      final income = (json['income'] as List? ?? [])
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      final planItems = (json['planItems'] as List? ?? [])
          .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
          .toList();

      await financeRepo.restoreFromSnapshot(expenses, income);
      await planRepo.restoreFromSnapshot(planItems);
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
}
