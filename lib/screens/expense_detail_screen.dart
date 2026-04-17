import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  /// Called when the user taps Edit in the AppBar.
  /// The caller is responsible for popping this screen before navigating.
  final VoidCallback? onEdit;

  /// Called when the user taps Delete in the AppBar.
  /// The caller is responsible for popping this screen before deleting.
  final VoidCallback? onDelete;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime dt, BuildContext context) {
    final day = dt.day.toString().padLeft(2, '0');
    return '$day ${context.l10n.monthName(dt.month)} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.expenseDetailTitle),
        scrolledUnderElevation: 0,
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.actionEdit,
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.actionDelete,
              color: AppColors.expense,
              onPressed: onDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAmountCard(context),
          const SizedBox(height: 16),
          _buildDetailsCard(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    final tint = Theme.of(context).colorScheme.primary.withAlpha(12);
    return Card(
      color: tint,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Center(
          child: Text(
            CurrencyFormatter.format(expense.amount),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildDetailRow(
            icon: expense.category.icon,
            iconColor: expense.category.color,
            label: context.l10n.labelCategory,
            value: context.l10n.categoryName(expense.category),
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: expense.financialType.icon,
            iconColor: expense.financialType.color,
            label: context.l10n.labelFinancialType,
            value: context.l10n.financialTypeName(expense.financialType),
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.textMuted,
            label: context.l10n.labelDate,
            value: _formatDate(expense.date, context),
          ),
          if (expense.group != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.folder_outlined,
              iconColor: AppColors.textMuted,
              label: context.l10n.labelGroup,
              value: expense.group!,
            ),
          ],
          if (expense.note != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              iconColor: AppColors.textMuted,
              label: context.l10n.labelNote,
              value: expense.note!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
