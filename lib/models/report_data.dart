import 'category_total.dart';

/// Bundles the results of a single report assembly pass.
///
/// Produced by [ReportAggregator.buildReportData] and consumed by
/// [ReportScreen] and PDF export. Never persisted.
class ReportData {
  /// All category totals, sorted descending by amount. Used for the row list.
  final List<CategoryTotal> listTotals;

  /// Category totals with small slices collapsed into "Other" at the
  /// configured threshold. Used for the pie chart.
  final List<CategoryTotal> chartTotals;

  /// Sum of all [listTotals] amounts.
  final double grandTotal;

  const ReportData({
    required this.listTotals,
    required this.chartTotals,
    required this.grandTotal,
  });
}
