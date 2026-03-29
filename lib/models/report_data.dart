import 'category_total.dart';

/// Bundles the results of a single report assembly pass.
///
/// Produced by [ReportAggregator.buildReportData] and consumed by
/// [ReportScreen] and PDF export. Never persisted.
class ReportData {
  /// All category totals, sorted descending by amount.
  /// Preserved for PDF export — not used for the main breakdown list.
  final List<CategoryTotal> listTotals;

  /// Category totals with small slices collapsed into "Other categories" at
  /// the configured threshold. Drives both the pie chart and the breakdown
  /// list.
  final List<CategoryTotal> chartTotals;

  /// The individual categories that were absorbed into the "Other categories"
  /// bucket, sorted descending by amount. Empty when no categories fell below
  /// the threshold and no real [ExpenseCategory.other] entries exist.
  ///
  /// Used by [ReportScreen] to populate the inline expansion of the
  /// "Other categories" row.
  final List<CategoryTotal> otherSubcategories;

  /// Sum of all [listTotals] amounts.
  final double grandTotal;

  const ReportData({
    required this.listTotals,
    required this.chartTotals,
    required this.grandTotal,
    this.otherSubcategories = const [],
  });
}
