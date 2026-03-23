import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
import '../services/save_load_service.dart';
import '../theme/app_theme.dart';
import '../widgets/save_slot_tile.dart';

class SavesScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;

  const SavesScreen({
    super.key,
    required this.repository,
    required this.planRepository,
  });

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  List<SaveSlot> _saves = [];
  bool _loading = true;

  static const _maxSaves = 5;

  static const _monthAbbr = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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

  String _defaultSaveName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = _monthAbbr[now.month];
    return 'Backup – $day $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saves'), scrolledUnderElevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildSlots(),
    );
  }

  Widget _buildSlots() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (int i = 0; i < _maxSaves; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildSlot(i),
          ],
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    if (index < _saves.length) {
      final slot = _saves[index];
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
    return _EmptySlotCard(onTap: _showSaveDialog);
  }

  Future<void> _confirmOverwrite(SaveSlot slot) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _SaveNameDialog(
        title: "Overwrite '${slot.name}'?",
        initialName: _defaultSaveName(),
      ),
    );

    if (name != null && mounted) {
      await SaveLoadService.deleteSave(slot.id);
      await SaveLoadService.createSave(
        name,
        widget.repository,
        widget.planRepository,
      );
      await _loadList();
    }
  }

  Future<void> _showSaveDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _SaveNameDialog(initialName: _defaultSaveName()),
    );

    if (name != null && mounted) {
      await SaveLoadService.createSave(
        name,
        widget.repository,
        widget.planRepository,
      );
      await _loadList();
    }
  }

  Future<void> _confirmLoad(SaveSlot slot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Load '${slot.name}'?"),
        content: const Text(
            'This will replace all current data with this saved snapshot.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Load'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final success = await SaveLoadService.loadSave(
      slot.id,
      widget.repository,
      widget.planRepository,
    );

    if (success) {
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("'${slot.name}' loaded.")),
      );
    }
  }

  Future<void> _confirmDelete(SaveSlot slot) async {
    final title =
        slot.isDamaged ? 'Delete damaged save?' : "Delete '${slot.name}'?";

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text('This save will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
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

// ── Save name dialog ──────────────────────────────────────────────────────────

class _SaveNameDialog extends StatefulWidget {
  final String title;
  final String initialName;

  const _SaveNameDialog({
    this.title = 'Save current data',
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
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        maxLength: 50,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Save name',
          errorText: _showError ? 'Name cannot be empty' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) {
              setState(() => _showError = true);
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
