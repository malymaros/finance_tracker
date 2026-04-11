import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Horizontal row of tappable pill buttons used as a sub-page indicator.
///
/// Each label gets equal width. The active label is filled navy; inactive
/// labels show a muted border. Used by [HowItWorksSheet] and
/// [HowGroupsWorkSheet].
class SubStepIndicator extends StatelessWidget {
  final int activeSubStep;
  final List<String> labels;
  final void Function(int)? onTap;

  const SubStepIndicator({
    super.key,
    required this.activeSubStep,
    required this.labels,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final isActive = i == activeSubStep;
        return Expanded(
          child: GestureDetector(
            onTap: onTap != null ? () => onTap!(i) : null,
            child: Container(
              margin: EdgeInsets.only(right: i < labels.length - 1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? AppColors.navy : Colors.transparent,
                border: Border.all(
                  color: isActive ? AppColors.navy : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
