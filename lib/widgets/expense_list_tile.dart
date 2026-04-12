import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;

  const ExpenseListTile({super.key, required this.expense, this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';

    final financialType = expense.financialType;
    final hasBorder = financialType != FinancialType.consumption;

    return Container(
      decoration: BoxDecoration(
        color: financialType.tintColor,
        border: hasBorder
            ? Border(
                left: BorderSide(width: 3, color: financialType.color),
              )
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: expense.category.color.withAlpha(30),
          child: Icon(expense.category.icon,
              size: 20, color: expense.category.color.withAlpha(180)),
        ),
        title: Text(expense.category.displayName),
        subtitle: Text(
          [
            if (expense.note != null) expense.note!,
            formattedDate,
            if (expense.group != null) expense.group!,
          ].join(' · '),
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Text(
          CurrencyFormatter.format(expense.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: financialType == FinancialType.consumption
                ? AppColors.expense
                : financialType.color,
          ),
        ),
      ),
    );
  }
}
