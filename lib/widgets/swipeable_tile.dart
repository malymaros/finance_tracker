import 'package:flutter/material.dart';

class SwipeableTile extends StatelessWidget {
  final String itemId;
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const SwipeableTile({
    super.key,
    required this.itemId,
    required this.child,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(itemId),
      direction: DismissDirection.horizontal,
      background: _buildDeleteBackground(),
      secondaryBackground: _buildEditBackground(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onEdit();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: child,
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      color: Colors.red,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      child: const Icon(Icons.delete, color: Colors.white, size: 28),
    );
  }

  Widget _buildEditBackground() {
    return Container(
      color: Colors.green,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: const Icon(Icons.build, color: Colors.white, size: 28),
    );
  }
}
