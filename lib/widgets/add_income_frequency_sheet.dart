import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'add_plan_item_type_sheet.dart';

/// Bottom sheet shown after the user selects "Income" in
/// [AddPlanItemTypeSheet]. Asks whether the income recurs monthly, yearly,
/// or is a one-time payment.
/// Tapping a card pops the sheet and fires the corresponding callback.
class AddIncomeFrequencySheet extends StatelessWidget {
  final VoidCallback onMonthlySelected;
  final VoidCallback onYearlySelected;
  final VoidCallback onOneTimeSelected;

  const AddIncomeFrequencySheet({
    super.key,
    required this.onMonthlySelected,
    required this.onYearlySelected,
    required this.onOneTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How often do you receive it?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            PlanItemSelectionCard(
              icon: Icons.repeat,
              color: AppColors.navy,
              title: 'Monthly',
              subtitle: 'Salary, regular monthly income',
              onTap: () {
                Navigator.of(context).pop();
                onMonthlySelected();
              },
            ),
            const SizedBox(height: 10),
            PlanItemSelectionCard(
              icon: Icons.event_repeat,
              color: AppColors.navy,
              title: 'Yearly',
              subtitle: 'Annual bonus, yearly income',
              onTap: () {
                Navigator.of(context).pop();
                onYearlySelected();
              },
            ),
            const SizedBox(height: 10),
            PlanItemSelectionCard(
              icon: Icons.looks_one_outlined,
              color: AppColors.navy,
              title: 'One-time',
              subtitle: 'Single payment, one-off income',
              onTap: () {
                Navigator.of(context).pop();
                onOneTimeSelected();
              },
            ),
          ],
        ),
      ),
    );
  }
}
