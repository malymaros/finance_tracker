import 'dart:convert';

import '../models/category_budget.dart';
import '../models/expense.dart';
import '../models/plan_item.dart';
import 'category_budget_repository.dart';
import 'finance_repository.dart';
import 'plan_repository.dart';

/// Pure static service for exporting and importing all app data as a
/// portable JSON file.
///
/// Export produces a self-contained snapshot of expenses, plan items, and
/// category budgets. Import restores all three repositories.
///
/// The `categoryBudgets` key is optional on import for backward compatibility
/// with files exported before the budget feature was added.
class DataPortabilityService {
  DataPortabilityService._();

  /// Serializes all data to a JSON string.
  ///
  /// Loads all years before serializing to ensure no data is missing when
  /// only a subset of years is currently in memory.
  static Future<String> exportData(
    FinanceRepository repo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
  ) async {
    await repo.loadAllYears();
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'expenses': repo.expenses.map((e) => e.toJson()).toList(),
      'planItems': planRepo.items.map((i) => i.toJson()).toList(),
      'categoryBudgets':
          budgetRepo.budgets.map((b) => b.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  /// Parses [jsonString] and restores all repositories.
  ///
  /// Throws [FormatException] if the file is missing the `version` field or
  /// cannot be parsed. The `categoryBudgets` key defaults to empty for files
  /// created before the budget feature existed.
  static Future<void> importData(
    String jsonString,
    FinanceRepository repo,
    PlanRepository planRepo,
    CategoryBudgetRepository budgetRepo,
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

    final categoryBudgets = (map['categoryBudgets'] as List? ?? [])
        .map((b) => CategoryBudget.fromJson(b as Map<String, dynamic>))
        .toList();

    await repo.restoreFromSnapshot(expenses);
    await planRepo.restoreFromSnapshot(planItems);
    await budgetRepo.restoreFromSnapshot(categoryBudgets);
  }
}
