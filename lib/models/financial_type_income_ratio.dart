class FinancialTypeIncomeRatio {
  final double? consumptionPct;
  final double? assetPct;
  final double? insurancePct;

  final double consumptionAmount;
  final double assetAmount;
  final double insuranceAmount;
  final double income;

  const FinancialTypeIncomeRatio({
    required this.consumptionPct,
    required this.assetPct,
    required this.insurancePct,
    required this.consumptionAmount,
    required this.assetAmount,
    required this.insuranceAmount,
    required this.income,
  });

  bool get hasIncome => consumptionPct != null;

  double get totalSpendingAmount =>
      consumptionAmount + assetAmount + insuranceAmount;

  /// Positive value means overspent. Null when income = 0 and no spending.
  double? get overspendAmount {
    final total = totalSpendingAmount;
    if (income <= 0 && total <= 0) return null;
    final diff = total - income;
    return diff > 0 ? diff : null;
  }
}
