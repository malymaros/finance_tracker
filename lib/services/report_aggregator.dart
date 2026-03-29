import '../models/category_total.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/report_data.dart';
import '../models/report_line.dart';

/// Pure aggregation functions for the spending report.
/// All methods are static so they can be tested without a repository instance.
class ReportAggregator {
  /// Groups [lines] by category and returns totals sorted descending by amount.
  static List<CategoryTotal> categoryTotals(List<ReportLine> lines) {
    if (lines.isEmpty) return [];

    final totals = <ExpenseCategory, double>{};
    for (final l in lines) {
      totals[l.category] = (totals[l.category] ?? 0.0) + l.amount;
    }

    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    return totals.entries
        .map((e) => CategoryTotal(
              category: e.key,
              amount: e.value,
              percentage: grandTotal > 0 ? (e.value / grandTotal) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  /// Collapses any [CategoryTotal] whose percentage is below [thresholdPercent]
  /// — plus any entry already using [ExpenseCategory.other] — into a single
  /// trailing "Other" bucket.
  ///
  /// Returns the input list unchanged when no categories fall below the
  /// threshold and no real "other" entries exist.
  /// The returned list is sorted descending by amount; the aggregated bucket
  /// is always placed last.
  static List<CategoryTotal> applyThreshold(
      List<CategoryTotal> totals, double thresholdPercent) {
    if (totals.isEmpty) return totals;

    final big = <CategoryTotal>[];
    double smallAmount = 0;
    double smallPct = 0;

    for (final ct in totals) {
      if (ct.category != ExpenseCategory.other &&
          ct.percentage >= thresholdPercent) {
        big.add(ct);
      } else {
        smallAmount += ct.amount;
        smallPct += ct.percentage;
      }
    }

    if (smallAmount == 0) return totals;

    return [
      ...big,
      CategoryTotal(
        category: ExpenseCategory.other,
        amount: smallAmount,
        percentage: smallPct,
      ),
    ];
  }

  /// Merges expense report lines with plan fixed-cost report lines into a
  /// single list. Both sources are combined before passing to aggregators.
  static List<ReportLine> mergedLines(
    List<ReportLine> expenseLines,
    List<ReportLine> planFixedCostLines,
  ) =>
      [...expenseLines, ...planFixedCostLines];

  /// Returns [CategoryTotal]s for lines whose [financialType] matches [type],
  /// sorted descending by amount. Useful for financial-type drill-down (v2).
  static List<CategoryTotal> categoryTotalsForType(
      List<ReportLine> lines, FinancialType type) {
    return categoryTotals(
        lines.where((l) => l.financialType == type).toList());
  }

  /// Assembles a complete [ReportData] for a single period from pre-merged
  /// [lines]. Calls [categoryTotals] and [applyThreshold] internally so
  /// callers have a single entry point.
  static ReportData buildReportData(
      List<ReportLine> lines, double thresholdPct) {
    final listTotals = categoryTotals(lines);
    final chartTotals = applyThreshold(listTotals, thresholdPct);
    final grandTotal = listTotals.fold(0.0, (s, ct) => s + ct.amount);

    // Categories absorbed into the "Other categories" bucket: any entry below
    // the threshold plus any real ExpenseCategory.other entry (which
    // applyThreshold always absorbs regardless of size). Already sorted
    // descending by amount because listTotals is sorted.
    final otherSubcategories = listTotals
        .where((ct) =>
            ct.category == ExpenseCategory.other ||
            ct.percentage < thresholdPct)
        .toList();

    return ReportData(
      listTotals: listTotals,
      chartTotals: chartTotals,
      otherSubcategories: otherSubcategories,
      grandTotal: grandTotal,
    );
  }
}
