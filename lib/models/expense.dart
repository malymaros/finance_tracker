import 'expense_category.dart';
import 'financial_type.dart';

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final FinancialType financialType;
  final DateTime date;
  final String? note;

  /// Optional user-defined group name (free text).
  /// Null means the expense is not assigned to any group.
  final String? group;

  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.financialType = FinancialType.consumption,
    this.note,
    this.group,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'financialType': financialType.name,
        'date': date.toIso8601String(),
        'note': note,
        'group': group,
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
        // 'group' is the current key; 'groupId' is the legacy key from a prior
        // implementation that stored entity IDs — treat any old values as null
        // since IDs are meaningless without the entity list.
        group: json['group'] as String?,
      );
}
