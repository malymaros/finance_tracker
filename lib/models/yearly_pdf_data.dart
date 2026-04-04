import 'category_total.dart';
import 'expense_category.dart';
import 'financial_type_income_ratio.dart';
import 'monthly_overview_summary.dart';
import 'monthly_summary.dart';
import 'plan_item.dart';

/// Data container passed to [PdfReportService] for generating a yearly PDF.
class YearlyPdfData {
  final int year;
  final List<CategoryTotal> categoryTotals;
  final double grandTotal;

  /// 12 monthly summaries (index 0 = January).
  final List<MonthlySummary> monthlySummaries;

  /// True when [year] is the current year and not all months have passed.
  final bool isPartialYear;

  /// Per-category monthly amounts. Outer key = category; inner list has 12
  /// entries (index 0 = January, 11 = December).
  final Map<ExpenseCategory, List<double>> categoryMonthlyAmounts;

  /// Pre-computed spending vs income ratios for the full year.
  final FinancialTypeIncomeRatio? typeRatio;

  /// Plan items active at any point during [year] (one per series, latest wins).
  /// Used for the Cash Flow Summary section.
  final List<PlanItem> activePlanItems;

  /// All plan items — needed to compute per-item yearly contributions correctly
  /// across mid-year series changes.
  final List<PlanItem> allPlanItems;

  /// 12 monthly overview summaries (index 0 = January) for the Yearly Overview page.
  final List<MonthlyOverviewSummary> overviewSummaries;

  const YearlyPdfData({
    required this.year,
    required this.categoryTotals,
    required this.grandTotal,
    required this.monthlySummaries,
    required this.isPartialYear,
    required this.categoryMonthlyAmounts,
    required this.typeRatio,
    required this.activePlanItems,
    required this.allPlanItems,
    required this.overviewSummaries,
  });
}
