import 'expense_category.dart';
import 'financial_type.dart';

enum Recurrence { monthly, yearly }

class FixedCost {
  final String id;
  final String name;
  final double amount;
  final Recurrence recurrence;
  final int startYear;
  final int startMonth;
  final ExpenseCategory category;
  final FinancialType financialType;

  FixedCost({
    required this.id,
    required this.name,
    required this.amount,
    required this.recurrence,
    required this.startYear,
    required this.startMonth,
    this.category = ExpenseCategory.other,
    this.financialType = FinancialType.consumption,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'recurrence': recurrence.name,
        'startYear': startYear,
        'startMonth': startMonth,
        'category': category.name,
        'financialType': financialType.name,
      };

  factory FixedCost.fromJson(Map<String, dynamic> json) => FixedCost(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        recurrence: Recurrence.values.byName(json['recurrence'] as String),
        startYear: json['startYear'] as int,
        startMonth: json['startMonth'] as int,
        category: json['category'] != null
            ? ExpenseCategoryX.fromJson(json['category'] as String)
            : ExpenseCategory.other,
        financialType: json['financialType'] != null
            ? FinancialType.values.byName(json['financialType'] as String)
            : FinancialType.consumption,
      );
}
