import 'category_total.dart';
import 'expense_category.dart';
import 'monthly_summary.dart';

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

  const YearlyPdfData({
    required this.year,
    required this.categoryTotals,
    required this.grandTotal,
    required this.monthlySummaries,
    required this.isPartialYear,
    required this.categoryMonthlyAmounts,
  });
}
