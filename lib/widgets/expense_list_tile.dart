import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;

  const ExpenseListTile({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        child: Text(expense.category[0].toUpperCase()),
      ),
      title: Text(expense.category),
      subtitle: Text(expense.note ?? formattedDate),
      trailing: Text(
        '\$${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}