import 'budget_status.dart';
import 'category_total.dart';
import 'expense.dart';

/// Data container passed to [PdfReportService] for generating a monthly PDF.
class MonthlyPdfData {
  final int year;
  final int month;
  final List<CategoryTotal> categoryTotals;
  final double grandTotal;
  final BudgetStatus? budgetStatus;

  /// Groups visible in this month, each paired with their all-time expenses.
  final List<MapEntry<String, List<Expense>>> groupSummaries;

  /// All expenses for the month, sorted by date descending.
  final List<Expense> expenses;

  const MonthlyPdfData({
    required this.year,
    required this.month,
    required this.categoryTotals,
    required this.grandTotal,
    required this.budgetStatus,
    required this.groupSummaries,
    required this.expenses,
  });
}
