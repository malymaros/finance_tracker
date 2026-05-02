import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Wraps a list tile so that a long press reveals an action sheet with
/// Edit (optional) and Delete options.
///
/// The swipe-based Dismissible was removed to eliminate gesture conflicts with
/// full-screen horizontal swipe tab navigation.
class SwipeableTile extends StatelessWidget {
  final String itemId;
  final Widget child;
  final VoidCallback onDelete;

  /// Pass null to suppress the Edit action in the bottom sheet.
  final VoidCallback? onEdit;

  /// Pass null to suppress the GUARD action in the bottom sheet.
  final VoidCallback? onGuard;

  const SwipeableTile({
    super.key,
    required this.itemId,
    required this.child,
    required this.onDelete,
    this.onEdit,
    this.onGuard,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => showActionSheet(
        context,
        onEdit: onEdit,
        onDelete: onDelete,
        onGuard: onGuard,
      ),
      child: child,
    );
  }

  static void showActionSheet(
    BuildContext context, {
    VoidCallback? onEdit,
    required VoidCallback onDelete,
    VoidCallback? onGuard,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (onGuard != null)
              ListTile(
                leading: const Icon(Icons.pets, color: AppColors.gold),
                title: Text(
                  sheetContext.l10n.menuGuard,
                  style: const TextStyle(color: AppColors.gold),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onGuard();
                },
              ),
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(sheetContext.l10n.actionEdit),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEdit();
                },
              ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.expense),
              title: Text(
                sheetContext.l10n.actionDelete,
                style: const TextStyle(color: AppColors.expense),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
