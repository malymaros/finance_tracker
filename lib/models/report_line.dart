import 'expense_category.dart';
import 'financial_type.dart';

/// Lightweight aggregation unit produced by [FinanceRepository] from expense
/// transactions, and by [BudgetCalculator] from plan fixed-cost items, so that
/// [ReportAggregator] can process them uniformly.
class ReportLine {
  final ExpenseCategory category;
  final FinancialType financialType;
  final double amount;

  const ReportLine({
    required this.category,
    required this.financialType,
    required this.amount,
  });
}
