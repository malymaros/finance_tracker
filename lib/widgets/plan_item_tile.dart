import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../theme/app_theme.dart';
import 'swipeable_tile.dart';

class PlanItemTile extends StatelessWidget {
  final PlanItem item;

  /// Pre-computed display amount (monthly or yearly normalized contribution).
  final double displayAmount;

  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const PlanItemTile({
    super.key,
    required this.item,
    required this.displayAmount,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final sign = isIncome ? '+' : '-';

    // For fixed cost items use the category colour/icon; fall back to
    // ExpenseCategory.other when the field is not set (legacy data).
    final category = isIncome ? null : (item.category ?? ExpenseCategory.other);
    final leadingColor = isIncome ? AppColors.income : category!.color;
    final leadingIcon = isIncome ? Icons.trending_up : category!.icon;
    final amountColor = isIncome ? AppColors.income : AppColors.expense;

    final subtitleParts = [
      _frequencyLabel(item.frequency),
      if (category != null) category.displayName,
      'from ${_formatYearMonth(item.validFrom)}',
      if (item.validTo != null) 'until ${_formatYearMonth(item.validTo!)}',
    ];

    return SwipeableTile(
      itemId: item.id,
      onDelete: onDelete,
      onEdit: onEdit,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: leadingColor.withAlpha(30),
          child: Icon(leadingIcon, color: leadingColor, size: 20),
        ),
        title: Text(item.name),
        subtitle: Text(
          subtitleParts.join(' · '),
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Text(
          '$sign${displayAmount.toStringAsFixed(2)} €',
          style: TextStyle(
            color: amountColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  static String _frequencyLabel(PlanFrequency freq) => switch (freq) {
        PlanFrequency.monthly => 'Monthly',
        PlanFrequency.yearly => 'Yearly',
        PlanFrequency.oneTime => 'One-time',
      };

  static String _formatYearMonth(YearMonth ym) =>
      '${ym.year}-${ym.month.toString().padLeft(2, '0')}';
}
