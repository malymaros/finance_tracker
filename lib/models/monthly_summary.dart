class MonthlySummary {
  final int year;
  final int month;

  /// Normalized planned income (yearly items divided by 12).
  final double plannedIncome;

  /// Normalized planned fixed costs (yearly items divided by 12).
  final double plannedFixedCosts;

  /// plannedIncome - plannedFixedCosts
  final double spendableBudget;

  /// Sum of actual Expense entries for this month.
  final double actualExpenses;

  /// spendableBudget - actualExpenses.
  /// Positive = under budget. Negative = over budget.
  final double difference;

  const MonthlySummary({
    required this.year,
    required this.month,
    required this.plannedIncome,
    required this.plannedFixedCosts,
    required this.spendableBudget,
    required this.actualExpenses,
    required this.difference,
  });
}
