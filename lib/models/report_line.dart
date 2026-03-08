import 'expense_category.dart';
import 'financial_type.dart';

/// Lightweight aggregation unit produced by [FinanceRepository] from both
/// [Expense] and [FixedCost] entries so that [ReportAggregator] can process
/// them uniformly without depending on the concrete model types.
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
