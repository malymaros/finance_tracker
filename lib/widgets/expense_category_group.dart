import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';

/// Aggregate row for a single category in the By-Category view.
/// Shows category icon, name, item count, and total amount.
class ExpenseCategoryGroup extends StatelessWidget {
  final ExpenseCategory category;
  final List<Expense> expenses;

  const ExpenseCategoryGroup({
    super.key,
    required this.category,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final count = expenses.length;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color.withAlpha(30),
        child: Icon(category.icon, size: 20, color: category.color),
      ),
      title: Text(category.displayName),
      subtitle: Text(
        '$count ${count == 1 ? 'item' : 'items'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        '${total.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
