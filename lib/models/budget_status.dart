class BudgetStatus {
  final double spendableBudget;
  final double actualSpent;
  final double remaining;

  /// Raw percentage (can exceed 100 when over budget).
  final double percentUsed;

  const BudgetStatus({
    required this.spendableBudget,
    required this.actualSpent,
    required this.remaining,
    required this.percentUsed,
  });

  bool get isOverBudget => actualSpent > spendableBudget;
}
