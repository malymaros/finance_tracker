import 'package:flutter/material.dart';

import '../models/save_slot.dart';
import 'swipeable_tile.dart';

class SaveSlotTile extends StatelessWidget {
  final SaveSlot slot;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  static const _monthAbbr = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  const SaveSlotTile({
    super.key,
    required this.slot,
    required this.onLoad,
    required this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthAbbr[dt.month];
    return '$day $month ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SwipeableTile(
      itemId: slot.id,
      onDelete: onDelete,
      onEdit: () {},
      child: slot.isDamaged ? _buildDamagedTile() : _buildNormalTile(),
    );
  }

  Widget _buildNormalTile() {
    final subtitle =
        '${_formatDate(slot.createdAt)} · ${slot.expenseCount} expenses · ${slot.planItemCount} plan items';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal.shade50,
        child: const Icon(Icons.save_outlined, color: Colors.teal),
      ),
      title: Text(slot.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: onLoad,
        child: const Text('Load'),
      ),
    );
  }

  Widget _buildDamagedTile() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.shade50,
        child: const Icon(Icons.warning_amber_outlined, color: Colors.orange),
      ),
      title: Text(
        slot.name,
        style: const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
      ),
      subtitle: const Text('File is damaged and cannot be loaded'),
    );
  }
}
