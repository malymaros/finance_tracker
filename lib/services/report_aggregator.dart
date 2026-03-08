import '../models/category_total.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/financial_type_breakdown.dart';
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

  /// Computes percentage breakdown by financial type across all [lines].
  static FinancialTypeBreakdown financialTypeBreakdown(List<ReportLine> lines) {
    if (lines.isEmpty) {
      return const FinancialTypeBreakdown(
          assetPct: 0, consumptionPct: 0, insurancePct: 0);
    }

    double asset = 0, consumption = 0, insurance = 0;
    for (final l in lines) {
      switch (l.financialType) {
        case FinancialType.asset:
          asset += l.amount;
        case FinancialType.consumption:
          consumption += l.amount;
        case FinancialType.insurance:
          insurance += l.amount;
      }
    }

    final total = asset + consumption + insurance;
    if (total == 0) {
      return const FinancialTypeBreakdown(
          assetPct: 0, consumptionPct: 0, insurancePct: 0);
    }

    return FinancialTypeBreakdown(
      assetPct: (asset / total) * 100,
      consumptionPct: (consumption / total) * 100,
      insurancePct: (insurance / total) * 100,
    );
  }
}
