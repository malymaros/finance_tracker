import 'expense_category.dart';

/// Stores which categories are visible in the picker for each context
/// (Expenses and Plan) as a delta from the hard-coded defaults.
///
/// Only added and removed categories are persisted — new app defaults
/// automatically apply to users who have never customised that context.
class CategoryPreferences {
  final Set<ExpenseCategory> expensesAdded;
  final Set<ExpenseCategory> expensesRemoved;
  final Set<ExpenseCategory> planAdded;
  final Set<ExpenseCategory> planRemoved;

  static const Set<ExpenseCategory> defaultExpenses = {
    ExpenseCategory.groceries,
    ExpenseCategory.restaurants,
    ExpenseCategory.transport,
    ExpenseCategory.entertainment,
    ExpenseCategory.clothing,
    ExpenseCategory.gifts,
    ExpenseCategory.medications,
    ExpenseCategory.other,
  };

  static const Set<ExpenseCategory> defaultPlan = {
    ExpenseCategory.housing,
    ExpenseCategory.insurance,
    ExpenseCategory.utilities,
    ExpenseCategory.subscriptions,
    ExpenseCategory.investment,
    ExpenseCategory.taxes,
    ExpenseCategory.debt,
    ExpenseCategory.other,
  };

  const CategoryPreferences({
    required this.expensesAdded,
    required this.expensesRemoved,
    required this.planAdded,
    required this.planRemoved,
  });

  const CategoryPreferences.empty()
      : expensesAdded = const {},
        expensesRemoved = const {},
        planAdded = const {},
        planRemoved = const {};

  /// Computes the visible set for the Expenses picker.
  /// `other` is always included and cannot be removed.
  Set<ExpenseCategory> get visibleForExpenses {
    final result = <ExpenseCategory>{
      ...defaultExpenses,
      ...expensesAdded,
    }..removeAll(expensesRemoved);
    result.add(ExpenseCategory.other);
    return result;
  }

  /// Computes the visible set for the Plan picker.
  /// `other` is always included and cannot be removed.
  Set<ExpenseCategory> get visibleForPlan {
    final result = <ExpenseCategory>{
      ...defaultPlan,
      ...planAdded,
    }..removeAll(planRemoved);
    result.add(ExpenseCategory.other);
    return result;
  }

  CategoryPreferences copyWith({
    Set<ExpenseCategory>? expensesAdded,
    Set<ExpenseCategory>? expensesRemoved,
    Set<ExpenseCategory>? planAdded,
    Set<ExpenseCategory>? planRemoved,
  }) {
    return CategoryPreferences(
      expensesAdded: expensesAdded ?? this.expensesAdded,
      expensesRemoved: expensesRemoved ?? this.expensesRemoved,
      planAdded: planAdded ?? this.planAdded,
      planRemoved: planRemoved ?? this.planRemoved,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'expensesAdded': expensesAdded.map((c) => c.name).toList(),
        'expensesRemoved': expensesRemoved.map((c) => c.name).toList(),
        'planAdded': planAdded.map((c) => c.name).toList(),
        'planRemoved': planRemoved.map((c) => c.name).toList(),
      };

  factory CategoryPreferences.fromJson(Map<String, dynamic> json) {
    Set<ExpenseCategory> parseSet(String key) {
      final raw = json[key] as List?;
      if (raw == null) return {};
      return raw
          .map((e) => ExpenseCategoryX.fromJson(e as String))
          .toSet();
    }

    return CategoryPreferences(
      expensesAdded: parseSet('expensesAdded'),
      expensesRemoved: parseSet('expensesRemoved'),
      planAdded: parseSet('planAdded'),
      planRemoved: parseSet('planRemoved'),
    );
  }
}
