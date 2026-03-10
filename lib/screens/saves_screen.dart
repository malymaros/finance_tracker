import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
import '../services/save_load_service.dart';
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

  int get _nonDamagedCount => _saves.where((s) => !s.isDamaged).length;

  bool get _capReached => _nonDamagedCount >= _maxSaves;

  String _defaultSaveName() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = _monthAbbr[now.month];
    return 'Backup – $day $month ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saves')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _saves.isEmpty
              ? _buildEmptyState()
              : _buildSavesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabTapped,
        tooltip: 'Save current data',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.save_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No saves yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap the button below to save current data.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSavesList() {
    return Column(
      children: [
        if (_capReached) _buildCapBanner(),
        Expanded(
          child: ListView.separated(
            itemCount: _saves.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (_, i) => SaveSlotTile(
              slot: _saves[i],
              onLoad: () => _confirmLoad(_saves[i]),
              onDelete: () => _confirmDelete(_saves[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapBanner() {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Save limit reached (5). Delete a save to create a new one.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _onFabTapped() {
    if (_capReached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save limit reached (5/5). Delete a save first.'),
        ),
      );
      return;
    }
    _showSaveDialog();
  }

  Future<void> _showSaveDialog() async {
    final controller = TextEditingController(text: _defaultSaveName());
    final formKey = GlobalKey<FormState>();
    String? nameToSave;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save current data'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLength: 50,
            decoration: const InputDecoration(labelText: 'Save name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name cannot be empty' : null,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              nameToSave = controller.text.trim();
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (nameToSave != null && mounted) {
      await SaveLoadService.createSave(
        nameToSave!,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
