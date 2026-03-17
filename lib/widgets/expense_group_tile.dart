import 'package:flutter/material.dart';

import '../models/expense.dart';

/// Aggregate row for a single user-defined group in the By-Groups view.
/// Shows group name, item count, and total amount for the current period.
class ExpenseGroupTile extends StatelessWidget {
  final String groupName;
  final List<Expense> expenses;
  final VoidCallback? onTap;

  const ExpenseGroupTile({
    super.key,
    required this.groupName,
    required this.expenses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final count = expenses.length;
    final color = Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(30),
        child: Icon(Icons.folder_outlined, size: 20, color: color),
      ),
      title: Text(groupName),
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
