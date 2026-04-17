import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/save_slot.dart';
import '../services/app_repositories.dart';
import '../services/save_load_service.dart';
import '../theme/app_theme.dart';
import 'save_action_dialog.dart';
import 'save_slot_tile.dart';

class AutoBackupTile extends StatefulWidget {
  final AppRepositories repositories;
  final VoidCallback onRestored;

  const AutoBackupTile({
    super.key,
    required this.repositories,
    required this.onRestored,
  });

  @override
  State<AutoBackupTile> createState() => _AutoBackupTileState();
}

class _AutoBackupTileState extends State<AutoBackupTile> {
  bool _expanded = false;
  bool _loading = true;
  List<SaveSlot> _slots = [];

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await SaveLoadService.listAutoSaves();
    if (!mounted) return;
    setState(() {
      _slots = slots;
      _loading = false;
    });
  }

  String _subtitle(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) return l10n.loadingLabel;
    if (_slots.isEmpty) return l10n.autoBackupNoBackupYet;
    return _expanded
        ? l10n.autoBackupSubtitleCollapse
        : l10n.autoBackupSubtitleExpand;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            _buildSlots(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: _slots.isNotEmpty
          ? () => setState(() => _expanded = !_expanded)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined,
                  color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.autoBackupTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(context),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            if (_loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_slots.isNotEmpty)
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }

  String _slotDisplayName(BuildContext context, SaveSlot slot) {
    final l10n = context.l10n;
    if (slot.id == 'autosave_0') return l10n.autoBackupPrimary;
    if (slot.id == 'autosave_1') return l10n.autoBackupSecondary;
    return slot.name;
  }

  Widget _buildSlots() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _slots.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          SaveSlotTile(
            slot: _slots[i],
            nameOverride: _slotDisplayName(context, _slots[i]),
            onLoad: () => _confirmRestore(_slots[i]),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmRestore(SaveSlot slot) async {
    if (!mounted) return;
    final l10n = context.l10n;
    final date = _formatDate(slot.createdAt, context);
    final confirmed = await SaveActionDialog.show(
      context,
      icon: Icons.history,
      iconColor: AppColors.gold,
      actionLabel: l10n.actionRestoreAllCaps,
      targetName: '${_slotDisplayName(context, slot)} · $date',
      description: l10n.autoBackupRestoreDescription,
      confirmLabel: l10n.actionRestore,
      confirmForeground: const Color(0xFF1A1A1A),
    );

    if (!confirmed || !mounted) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final restoredMsg = l10n.autoBackupRestored(date);
    final failedMsg = l10n.autoBackupRestoreFailed;

    final success = await SaveLoadService.loadAutoSave(
      slot.id,
      widget.repositories,
    );

    if (success) {
      widget.onRestored();
      navigator.pop();
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(restoredMsg)));
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(failedMsg)));
    }
  }

  String _formatDate(DateTime dt, BuildContext context) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = context.l10n.monthAbbr(dt.month);
    return '$day $month ${dt.year}';
  }
}
