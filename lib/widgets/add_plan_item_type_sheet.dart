import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Shared card used by the plan-item selection bottom sheets
/// ([AddPlanItemTypeSheet], [AddFixedCostFrequencySheet],
/// [AddIncomeFrequencySheet]).
///
/// Renders an icon, title, and subtitle with a coloured left accent strip.
/// Tapping fires [onTap].
class PlanItemSelectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const PlanItemSelectionCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(width: 3, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 26),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet that asks the user what type of plan item they want to add.
/// Tapping a card pops the sheet and fires the corresponding callback.
class AddPlanItemTypeSheet extends StatelessWidget {
  final VoidCallback onIncomeSelected;
  final VoidCallback onFixedCostSelected;

  const AddPlanItemTypeSheet({
    super.key,
    required this.onIncomeSelected,
    required this.onFixedCostSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.typePickerTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            PlanItemSelectionCard(
              icon: Icons.savings,
              color: AppColors.income,
              title: l10n.typeIncome,
              subtitle: l10n.typeIncomeSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                onIncomeSelected();
              },
            ),
            const SizedBox(height: 10),
            PlanItemSelectionCard(
              icon: Icons.lock_outline,
              color: AppColors.textMuted,
              title: l10n.typeFixedCost,
              subtitle: l10n.typeFixedCostSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                onFixedCostSelected();
              },
            ),
          ],
        ),
      ),
    );
  }
}
