import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

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

    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.folder_outlined, color: AppColors.gold, size: 22),
      title: Text(groupName),
      subtitle: Text(
        '$count ${count == 1 ? 'item' : 'items'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        CurrencyFormatter.format(total),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
