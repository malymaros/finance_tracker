import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/budget_status.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetStatus status;

  const BudgetProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final progress = (status.percentUsed / 100).clamp(0.0, 1.0);
    final Color barColor;
    if (status.isOverBudget) {
      barColor = AppColors.expense;
    } else if (status.percentUsed >= 75) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.income;
    }

    final isOver = status.isOverBudget;
    final remaining = status.remaining;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.thisMonthsBudget,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  isOver
                      ? context.l10n.overBudgetAmount(CurrencyFormatter.format(-remaining))
                      : context.l10n.underBudgetAmount(CurrencyFormatter.format(remaining)),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOver ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.spentLabel(CurrencyFormatter.format(status.actualSpent)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  context.l10n.budgetLabel(CurrencyFormatter.format(status.spendableBudget)),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
