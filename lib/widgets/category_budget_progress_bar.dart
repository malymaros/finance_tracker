import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// A progress bar showing spending against a category budget.
///
/// Color coding:
///   < 80 %   → green  (within budget)
///   80–100 % → amber  (approaching limit)
///   > 100 %  → red    (over budget)
class CategoryBudgetProgressBar extends StatelessWidget {
  final double spent;
  final double budget;

  const CategoryBudgetProgressBar({
    super.key,
    required this.spent,
    required this.budget,
  });

  Color get _barColor {
    if (budget <= 0) return AppColors.textMuted;
    final ratio = spent / budget;
    if (ratio > 1.0) return AppColors.expense;
    if (ratio >= 0.8) return AppColors.warning;
    return AppColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.progressBarLabel(
              CurrencyFormatter.format(spent),
              CurrencyFormatter.format(budget),
            ),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
