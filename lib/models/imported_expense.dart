import 'expense_category.dart';
import 'financial_type.dart';

/// Intermediate value object produced by the import parser.
/// Converted to a full [Expense] (with a generated id) on import confirmation.
class ImportedExpense {
  final double amount;
  final ExpenseCategory category;
  final FinancialType financialType;
  final DateTime date;
  final String? note;
  final String? group;

  const ImportedExpense({
    required this.amount,
    required this.category,
    required this.financialType,
    required this.date,
    this.note,
    this.group,
  });
}
