import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const ExpenseListTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        child: Icon(categoryIcon(expense.category), size: 20),
      ),
      title: Text(expense.category),
      subtitle: Text(expense.note != null ? '${expense.note} · $formattedDate' : formattedDate),
      trailing: Text(
        '${expense.amount.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}