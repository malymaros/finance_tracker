import 'package:flutter/material.dart';

import '../models/guard_state.dart';
import '../theme/app_theme.dart';

/// A small golden paw icon that shows the GUARD state of a plan item.
///
/// Renders nothing when [guardState] is [GuardState.none].
/// Opacity and overlay change based on the payment state.
class GuardStatusIcon extends StatelessWidget {
  final GuardState guardState;
  final double size;

  const GuardStatusIcon({
    super.key,
    required this.guardState,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    if (guardState == GuardState.none) return const SizedBox.shrink();

    final opacity = switch (guardState) {
      GuardState.unpaidActive => 1.0,
      GuardState.silenced => 0.5,
      GuardState.paid => 0.35,
      GuardState.none => 0.0,
    };

    final icon = Icon(Icons.pets, color: AppColors.gold, size: size);

    if (guardState == GuardState.silenced) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Opacity(opacity: opacity, child: icon),
          Positioned(
            right: -4,
            bottom: -4,
            child: Icon(
              Icons.notifications_off,
              size: size * 0.7,
              color: AppColors.textMuted,
            ),
          ),
        ],
      );
    }

    return Opacity(opacity: opacity, child: icon);
  }
}
