import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: expense.category.color.withAlpha(30),
        child: Icon(expense.category.icon,
            size: 20, color: expense.category.color),
      ),
      title: Text(expense.category.displayName),
      subtitle: Text(expense.note != null
          ? '${expense.note} · $formattedDate'
          : formattedDate),
      trailing: Text(
        '${expense.amount.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
