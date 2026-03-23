import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../models/year_month.dart';
import '../theme/app_theme.dart';
import 'swipeable_tile.dart';

class SaveSlotTile extends StatelessWidget {
  final SaveSlot slot;
  final VoidCallback onLoad;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const SaveSlotTile({
    super.key,
    required this.slot,
    required this.onLoad,
    required this.onDelete,
    this.onTap,
  });

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = YearMonth.monthAbbreviations[dt.month];
    return '$day $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SwipeableTile(
      itemId: slot.id,
      onDelete: onDelete,
      child: slot.isDamaged
          ? _buildDamagedTile()
          : _buildNormalTile(context),
    );
  }

  Widget _buildNormalTile(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final subtitle =
        '${_formatDate(slot.createdAt)} · ${slot.expenseCount} expenses · ${slot.planItemCount} plan items';
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: primary.withAlpha(20),
        child: Icon(Icons.save_outlined, color: primary),
      ),
      title: Text(slot.name,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
      trailing: TextButton(
        onPressed: onLoad,
        child: const Text('Load'),
      ),
    );
  }

  Widget _buildDamagedTile() {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.warning.withAlpha(25),
        child: const Icon(Icons.warning_amber_outlined,
            color: AppColors.warning),
      ),
      title: Text(
        slot.name,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontStyle: FontStyle.italic,
        ),
      ),
      subtitle: const Text(
        'File is damaged and cannot be loaded',
        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
