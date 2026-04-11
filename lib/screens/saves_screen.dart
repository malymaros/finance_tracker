import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../services/app_repositories.dart';
import '../services/data_portability_service.dart';
import '../services/save_load_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auto_backup_tile.dart';
import '../widgets/save_action_dialog.dart';
import '../widgets/save_slot_tile.dart';

class SavesScreen extends StatefulWidget {
  final AppRepositories repositories;
  final VoidCallback onClearAll;

  const SavesScreen({
    super.key,
    required this.repositories,
    required this.onClearAll,
  });

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  List<SaveSlot> _saves = [];
  bool _loading = true;


  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    final saves = await SaveLoadService.listSaves();
    if (!mounted) return;
    setState(() {
      _saves = saves;
      _loading = false;
    });
  }

  String _defaultSaveName() =>
      'Backup – ${SaveLoadService.formatDateLabel(DateTime.now())}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saves'),
        scrolledUnderElevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Future<void> _exportData() async {
    try {
      final jsonString = await DataPortabilityService.exportData(
        widget.repositories,
      );
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await ShareService.shareJson(jsonString, 'finance_data_$date.json');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;

    final pickedFile = result.files.first;
    final bytes = pickedFile.bytes ??
        (pickedFile.path != null
            ? await _readFileBytes(pickedFile.path!)
            : null);
    if (bytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not read the selected file.')),
      );
      return;
    }

    final jsonString = utf8.decode(bytes);

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import data?'),
        content: const Text(
          'This will replace ALL current expenses and plan items with the '
          'contents of the file. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      await DataPortabilityService.importData(
        jsonString,
        widget.repositories,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data imported successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid file: $e')),
      );
    }
  }

  Future<List<int>?> _readFileBytes(String path) async {
    try {
      return await File(path).readAsBytes();
    } catch (_) {
      return null;
    }
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('AUTO BACKUP'),
          const SizedBox(height: 10),
          AutoBackupTile(
            repositories: widget.repositories,
            onRestored: _loadList,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('SAVES'),
          const SizedBox(height: 10),
          // Existing saves (could be more than SaveLoadService.maxSaves if user had more before cap reduction)
          for (final slot in _saves) ...[
            _buildSaveSlot(slot),
            const SizedBox(height: 10),
          ],
          // Empty slots up to the cap
          for (int i = _saves.length; i < SaveLoadService.maxSaves; i++) ...[
            _buildEmptySlot(),
            if (i < SaveLoadService.maxSaves - 1) const SizedBox(height: 10),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('DATA TRANSFER'),
          const SizedBox(height: 10),
          _buildActionButton(
            icon: Icons.upload_outlined,
            label: 'Export all data',
            onTap: _exportData,
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            icon: Icons.download_outlined,
            label: 'Import all data',
            onTap: _importData,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('DATA DELETION'),
          const SizedBox(height: 10),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Delete all data',
            onTap: widget.onClearAll,
            isDestructive: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.expense : AppColors.textMuted;
    final borderColor = isDestructive ? AppColors.expense : AppColors.border;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.expense.withAlpha(10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveSlot(SaveSlot slot) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: SaveSlotTile(
        slot: slot,
        onTap: () => _confirmOverwrite(slot),
        onLoad: () => _confirmLoad(slot),
        onDelete: () => _confirmDelete(slot),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return _EmptySlotCard(onTap: _showSaveDialog);
  }

  Future<void> _confirmOverwrite(SaveSlot slot) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _SaveNameDialog(
        isOverwrite: true,
        replacingName: slot.name,
        initialName: _defaultSaveName(),
      ),
    );

    if (name != null && mounted) {
      await SaveLoadService.deleteSave(slot.id);
      await SaveLoadService.createSave(name, widget.repositories);
      await _loadList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$name' saved.")),
        );
      }
    }
  }

  Future<void> _showSaveDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _SaveNameDialog(initialName: _defaultSaveName()),
    );

    if (name != null && mounted) {
      await SaveLoadService.createSave(name, widget.repositories);
      await _loadList();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$name' saved.")),
        );
      }
    }
  }

  Future<void> _confirmLoad(SaveSlot slot) async {
    final confirmed = await SaveActionDialog.show(
      context,
      icon: Icons.download_outlined,
      iconColor: AppColors.navy,
      actionLabel: 'LOAD',
      targetName: slot.name,
      description: 'All current data will be replaced with this saved snapshot.',
      confirmLabel: 'Load',
    );

    if (!confirmed) return;
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await SaveLoadService.loadSave(
      slot.id,
      widget.repositories,
    );

    if (success) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("'${slot.name}' loaded.")),
      );
    }
  }

  Future<void> _confirmDelete(SaveSlot slot) async {
    final confirmed = await SaveActionDialog.show(
      context,
      icon: slot.isDamaged ? Icons.warning_amber_outlined : Icons.delete_outline,
      iconColor: AppColors.expense,
      actionLabel: 'DELETE',
      targetName: slot.isDamaged ? 'Damaged save file' : slot.name,
      description: 'This saved snapshot will be permanently deleted.',
      confirmLabel: 'Delete',
    );

    if (confirmed) {
      await SaveLoadService.deleteSave(slot.id);
      await _loadList();
    }
  }
}

// ── Empty slot card ───────────────────────────────────────────────────────────

class _EmptySlotCard extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptySlotCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: const SizedBox(
          height: 76,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: AppColors.textMuted, size: 20),
              SizedBox(width: 8),
              Text(
                'Empty slot',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const radius = 12.0;
    const dashWidth = 5.0;
    const dashSpace = 4.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Save name dialog (SAVE / OVERWRITE) ──────────────────────────────────────

class _SaveNameDialog extends StatefulWidget {
  /// When true, the dialog is styled as OVERWRITE and shows [replacingName].
  final bool isOverwrite;

  /// The name of the slot being replaced — shown as a subtitle when [isOverwrite].
  final String? replacingName;

  final String initialName;

  const _SaveNameDialog({
    this.isOverwrite = false,
    this.replacingName,
    required this.initialName,
  });

  @override
  State<_SaveNameDialog> createState() => _SaveNameDialogState();
}

class _SaveNameDialogState extends State<_SaveNameDialog> {
  late final TextEditingController _controller;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOverwrite = widget.isOverwrite;
    final iconColor = isOverwrite ? AppColors.warning : AppColors.income;
    final iconData = isOverwrite ? Icons.swap_horiz : Icons.save_outlined;
    final actionLabel = isOverwrite ? 'OVERWRITE' : 'SAVE';
    final confirmLabel = isOverwrite ? 'Overwrite' : 'Save';
    final confirmForeground =
        isOverwrite ? const Color(0xFF1A1A1A) : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Icon ──────────────────────────────────────────────────────────
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 34),
            ),
            const SizedBox(height: 18),

            // ── Action label ──────────────────────────────────────────────────
            Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                letterSpacing: 2.5,
              ),
            ),

            // ── Replacing hint (overwrite only) ───────────────────────────────
            if (isOverwrite && widget.replacingName != null) ...[
              const SizedBox(height: 6),
              Text(
                'Replacing: ${widget.replacingName}',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),

            // ── Name input ────────────────────────────────────────────────────
            TextField(
              controller: _controller,
              maxLength: 50,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Save name',
                errorText: _showError ? 'Name cannot be empty' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Buttons ───────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final name = _controller.text.trim();
                      if (name.isEmpty) {
                        setState(() => _showError = true);
                        return;
                      }
                      Navigator.of(context).pop(name);
                    },
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
