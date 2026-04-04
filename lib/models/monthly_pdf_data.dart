import 'budget_status.dart';
import 'category_total.dart';
import 'expense.dart';
import 'expense_category.dart';
import 'financial_type_income_ratio.dart';
import 'plan_item.dart';

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

  /// Active income + fixedCost plan items for this month.
  final List<PlanItem> activePlanItems;

  /// Active category budgets for this month (may be empty).
  /// Map of category → monthly budget amount.
  final Map<ExpenseCategory, double> categoryBudgets;

  /// Pre-computed spending vs income ratios (actual expenses + plan fixed costs
  /// merged, percentages relative to normalized plan income).
  final FinancialTypeIncomeRatio? typeRatio;

  const MonthlyPdfData({
    required this.year,
    required this.month,
    required this.categoryTotals,
    required this.grandTotal,
    required this.budgetStatus,
    required this.groupSummaries,
    required this.expenses,
    required this.activePlanItems,
    required this.categoryBudgets,
    required this.typeRatio,
  });
}
