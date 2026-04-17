import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// A compact link strip shown in the Expense tab when unpaid active guarded
/// payments exist. Tapping switches to the Plan tab where the GuardBanner
/// shows the full detail.
///
/// Only renders when [unpaidCount] > 0.
class GuardExpenseStrip extends StatelessWidget {
  final int unpaidCount;
  final VoidCallback onTap;

  const GuardExpenseStrip({
    super.key,
    required this.unpaidCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.guardExpenseStripPending(unpaidCount);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: const BoxDecoration(
          color: AppColors.guardBannerBackground,
          border: Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.pets, size: 15, color: AppColors.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: AppColors.gold,
            ),
          ],
        ),
      ),
    );
  }
}
