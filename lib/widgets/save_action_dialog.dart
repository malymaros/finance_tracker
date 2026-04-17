import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Premium confirmation dialog used for important save/data actions
/// (Load, Restore, Delete). Shows a large action icon, the action name
/// prominently, and the target name as a smaller subtitle so the user always
/// knows exactly what is about to happen before confirming.
class SaveActionDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  /// Short all-caps action label shown prominently, e.g. "LOAD" or "DELETE".
  final String actionLabel;

  /// Optional name of the item being acted on — shown as a muted subtitle.
  /// Omit for actions that have no specific target (e.g. delete all).
  final String? targetName;

  /// Explanatory sentence shown in the main description box.
  final String description;

  /// Optional note shown in a green-tinted box below the description.
  /// Use this to reassure the user about what will NOT be affected.
  final String? preservedNote;

  /// Label for the confirm button.
  final String confirmLabel;

  /// Foreground (text/icon) colour for the confirm button.
  /// Defaults to white; pass a dark colour when [iconColor] is light (e.g. gold).
  final Color confirmForeground;

  const SaveActionDialog({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    this.targetName,
    required this.description,
    this.preservedNote,
    required this.confirmLabel,
    this.confirmForeground = Colors.white,
  });

  /// Convenience helper — shows the dialog and returns true if confirmed.
  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String actionLabel,
    String? targetName,
    required String description,
    String? preservedNote,
    required String confirmLabel,
    Color confirmForeground = Colors.white,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => SaveActionDialog(
            icon: icon,
            iconColor: iconColor,
            actionLabel: actionLabel,
            targetName: targetName,
            description: description,
            preservedNote: preservedNote,
            confirmLabel: confirmLabel,
            confirmForeground: confirmForeground,
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ────────────────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 34),
            ),
            const SizedBox(height: 18),

            // ── Action label ─────────────────────────────────────────────────
            Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                letterSpacing: 2.5,
              ),
            ),

            // ── Target name (subtle, optional) ───────────────────────────────
            if (targetName != null) ...[
              const SizedBox(height: 6),
              Text(
                targetName!,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),

            // ── Description box ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                description,
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),

            // ── Preserved note (green tint, optional) ────────────────────────
            if (preservedNote != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.income.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.income.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 15, color: AppColors.income.withAlpha(200)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        preservedNote!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.income.withAlpha(220),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Buttons ──────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(context.l10n.actionCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: confirmForeground,
                    ),
                    child: Text(confirmLabel),
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
