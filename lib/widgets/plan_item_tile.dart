import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../theme/app_theme.dart';
import 'guard_status_icon.dart';
import 'swipeable_tile.dart';

class PlanItemTile extends StatelessWidget {
  final PlanItem item;

  /// Pre-computed display amount (monthly or yearly normalized contribution).
  final double displayAmount;

  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  /// When set, adds a GUARD option to the long-press action sheet.
  /// Should only be provided for fixed cost items.
  final VoidCallback? onGuard;

  /// GUARD state for the currently viewed period. Defaults to [GuardState.none].
  final GuardState guardState;

  /// When true, renders a gold background tint to draw attention to this item.
  final bool isHighlighted;

  const PlanItemTile({
    super.key,
    required this.item,
    required this.displayAmount,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
    this.onGuard,
    this.guardState = GuardState.none,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final sign = isIncome ? '+' : '-';

    // For fixed cost items use the category colour/icon; fall back to
    // ExpenseCategory.other when the field is not set (legacy data).
    final category = isIncome ? null : (item.category ?? ExpenseCategory.other);
    final leadingColor = isIncome ? AppColors.income : category!.color;
    final leadingIcon = isIncome ? Icons.savings : category!.icon;
    final financialType = isIncome ? null : item.financialType;
    final amountColor = isIncome
        ? AppColors.income
        : (financialType == FinancialType.consumption
            ? AppColors.expense
            : financialType?.color ?? AppColors.expense);

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
      onGuard: onGuard,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? AppColors.gold.withAlpha(30)
              : financialType?.tintColor,
          border: isHighlighted
              ? Border.all(color: AppColors.gold.withAlpha(100))
              : financialType != null &&
                      financialType != FinancialType.consumption
                  ? Border(
                      left: BorderSide(width: 3, color: financialType.color),
                    )
                  : null,
        ),
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: leadingColor.withAlpha(30),
            child: Icon(leadingIcon, color: leadingColor, size: 20),
          ),
          title: Row(
            children: [
              Expanded(child: Text(item.name)),
              if (guardState != GuardState.none) ...[
                const SizedBox(width: 6),
                GuardStatusIcon(guardState: guardState),
              ],
            ],
          ),
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
