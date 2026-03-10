import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../theme/app_theme.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  const ExpenseDetailScreen({super.key, required this.expense});

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    return '$day ${_monthNames[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense'),
        scrolledUnderElevation: 0,
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
            '${expense.amount.toStringAsFixed(2)} €',
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
            label: 'Category',
            value: expense.category.displayName,
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: expense.financialType.icon,
            iconColor: expense.financialType.color,
            label: 'Financial type',
            value: expense.financialType.displayName,
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.textMuted,
            label: 'Date',
            value: _formatDate(expense.date),
          ),
          if (expense.note != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              iconColor: AppColors.textMuted,
              label: 'Note',
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
