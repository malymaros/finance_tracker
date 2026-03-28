class FinancialTypeIncomeRatio {
  final double? consumptionPct;
  final double? assetPct;
  final double? insurancePct;

  final double consumptionAmount;
  final double assetAmount;
  final double insuranceAmount;

  const FinancialTypeIncomeRatio({
    required this.consumptionPct,
    required this.assetPct,
    required this.insurancePct,
    required this.consumptionAmount,
    required this.assetAmount,
    required this.insuranceAmount,
  });

  bool get hasIncome => consumptionPct != null;
}
