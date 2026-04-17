import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense_category.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// Displays over-budget warnings for expense categories.
///
/// Renders nothing when [overages] is empty. Otherwise shows one warning line
/// per category, sorted by overage amount descending.
class CategoryBudgetWarningCard extends StatelessWidget {
  /// Map of category → amount over budget (positive values only).
  final Map<ExpenseCategory, double> overages;

  const CategoryBudgetWarningCard({
    super.key,
    required this.overages,
  });

  @override
  Widget build(BuildContext context) {
    if (overages.isEmpty) return const SizedBox.shrink();

    final sorted = overages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withAlpha(90)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sorted.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.categoryBudgetOverBy(
                      context.l10n.categoryName(entry.key),
                      CurrencyFormatter.format(entry.value),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
