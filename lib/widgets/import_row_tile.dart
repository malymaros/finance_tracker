import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/imported_expense.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// Compact tile showing one successfully parsed import row in the preview list.
/// Matches the style of [ExpenseListTile] used throughout the app.
class ImportRowTile extends StatelessWidget {
  final ImportedExpense expense;
  final VoidCallback? onTap;

  const ImportRowTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

    final subtitle = [
      if (expense.note != null) expense.note!,
      formattedDate,
      if (expense.group != null) expense.group!,
    ].join(' · ');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: expense.category.color.withAlpha(30),
        child: Icon(expense.category.icon,
            size: 20, color: expense.category.color.withAlpha(180)),
      ),
      title: Text(expense.category.displayName),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: Text(
        CurrencyFormatter.format(expense.amount),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: AppColors.expense,
        ),
      ),
    );
  }
}
