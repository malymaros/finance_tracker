import 'expense_category.dart';

class CategoryTotal {
  final ExpenseCategory category;
  final double amount;
  final double percentage;

  const CategoryTotal({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}
