import 'year_month.dart';

/// Pure view model for the Reports → Overview tab.
///
/// Represents the money-flow summary for a single month:
/// - [earned]      — normalized planned income
/// - [consumption] — all spending classified as consumption or insurance
/// - [assets]      — all spending classified as asset
/// - [result]      — earned minus all allocated money (positive = saved)
class MonthlyOverviewSummary {
  final YearMonth period;
  final double earned;
  final double consumption;
  final double assets;
  final double result;

  const MonthlyOverviewSummary({
    required this.period,
    required this.earned,
    required this.consumption,
    required this.assets,
    required this.result,
  });

  /// Total money allocated (consumption + assets). Does not include unspent money.
  double get allocated => consumption + assets;

  /// Consumption share of allocated money, 0–100.
  double get consumptionPct =>
      allocated > 0 ? (consumption / allocated) * 100 : 0;

  /// Asset share of allocated money, 0–100.
  double get assetPct => allocated > 0 ? (assets / allocated) * 100 : 0;

  /// True when this month has any meaningful data to display.
  bool get hasData => earned > 0 || allocated > 0;
}
