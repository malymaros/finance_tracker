import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import 'add_plan_item_type_sheet.dart';

/// Bottom sheet shown after the user selects "Fixed Cost" in
/// [AddPlanItemTypeSheet]. Asks whether the fixed cost recurs monthly or yearly.
/// Tapping a card pops the sheet and fires the corresponding callback.
class AddFixedCostFrequencySheet extends StatelessWidget {
  final VoidCallback onMonthlySelected;
  final VoidCallback onYearlySelected;

  const AddFixedCostFrequencySheet({
    super.key,
    required this.onMonthlySelected,
    required this.onYearlySelected,
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
              l10n.frequencyPickerFixed,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            PlanItemSelectionCard(
              icon: Icons.repeat,
              color: AppColors.navy,
              title: l10n.frequencyMonthly,
              subtitle: l10n.frequencyMonthlyFixedSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                onMonthlySelected();
              },
            ),
            const SizedBox(height: 10),
            PlanItemSelectionCard(
              icon: Icons.event_repeat,
              color: AppColors.navy,
              title: l10n.frequencyYearly,
              subtitle: l10n.frequencyYearlyFixedSubtitle,
              onTap: () {
                Navigator.of(context).pop();
                onYearlySelected();
              },
            ),
          ],
        ),
      ),
    );
  }
}
