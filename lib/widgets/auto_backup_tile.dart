import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../models/year_month.dart';
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

  String _subtitle() {
    if (_loading) return 'Loading…';
    if (_slots.isEmpty) return 'No backup yet';
    return 'Updated daily · tap to ${_expanded ? 'collapse' : 'expand'}';
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
          _buildHeader(),
          if (_expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            _buildSlots(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _slots.isNotEmpty ? () => setState(() => _expanded = !_expanded) : null,
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
              child: const Icon(Icons.shield_outlined, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto Backup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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

  Widget _buildSlots() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < _slots.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.border),
          SaveSlotTile(
            slot: _slots[i],
            onLoad: () => _confirmRestore(_slots[i]),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmRestore(SaveSlot slot) async {
    if (!mounted) return;
    final date = _formatDate(slot.createdAt);
    final confirmed = await SaveActionDialog.show(
      context,
      icon: Icons.history,
      iconColor: AppColors.gold,
      actionLabel: 'RESTORE',
      targetName: '${slot.name} · $date',
      description: 'All current data will be replaced with this auto-backup snapshot.',
      confirmLabel: 'Restore',
      confirmForeground: const Color(0xFF1A1A1A),
    );

    if (!confirmed || !mounted) return;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final success = await SaveLoadService.loadAutoSave(
      slot.id,
      widget.repositories,
    );

    if (success) {
      widget.onRestored();
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Restored auto backup from $date.')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Restore failed — backup file may be damaged.')),
      );
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = YearMonth.monthAbbreviations[dt.month];
    return '$day $month ${dt.year}';
  }
}
