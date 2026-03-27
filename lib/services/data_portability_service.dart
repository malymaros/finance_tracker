import 'dart:convert';

import '../models/expense.dart';
import '../models/plan_item.dart';
import 'finance_repository.dart';
import 'plan_repository.dart';

/// Pure static service for exporting and importing all app data as a
/// portable JSON file.
///
/// Export produces a self-contained snapshot of all expenses and plan items.
/// Import restores both repositories from a previously exported file.
class DataPortabilityService {
  DataPortabilityService._();

  /// Serializes all expenses and plan items to a JSON string.
  static String exportData(
    FinanceRepository repo,
    PlanRepository planRepo,
  ) {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': repo.expenses.map((e) => e.toJson()).toList(),
      'planItems': planRepo.items.map((i) => i.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  /// Parses [jsonString] and restores both repositories.
  ///
  /// Throws [FormatException] if the file is missing the `version` field or
  /// cannot be parsed. Other errors propagate as-is.
  static Future<void> importData(
    String jsonString,
    FinanceRepository repo,
    PlanRepository planRepo,
  ) async {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;

    if (!map.containsKey('version')) {
      throw const FormatException('Missing version field');
    }

    final expenses = (map['expenses'] as List? ?? [])
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();

    final planItems = (map['planItems'] as List? ?? [])
        .map((i) => PlanItem.fromJson(i as Map<String, dynamic>))
        .toList();

    await repo.restoreFromSnapshot(expenses);
    await planRepo.restoreFromSnapshot(planItems);
  }
}
