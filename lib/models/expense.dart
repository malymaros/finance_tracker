import 'expense_category.dart';
import 'financial_type.dart';

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final FinancialType financialType;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.financialType = FinancialType.consumption,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'financialType': financialType.name,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: ExpenseCategoryX.fromJson(json['category'] as String),
        financialType: json['financialType'] != null
            ? FinancialType.values.byName(json['financialType'] as String)
            : FinancialType.consumption,
        date: DateTime.parse(json['date'] as String),
        note: json['note'] as String?,
      );
}
