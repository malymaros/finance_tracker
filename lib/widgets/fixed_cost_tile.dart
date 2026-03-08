import 'package:flutter/material.dart';

import '../models/fixed_cost.dart';

class FixedCostTile extends StatelessWidget {
  final FixedCost cost;

  const FixedCostTile({super.key, required this.cost});

  @override
  Widget build(BuildContext context) {
    final isMonthly = cost.recurrence == Recurrence.monthly;
    final recurrenceLabel = isMonthly ? 'Monthly' : 'Yearly';
    final startLabel =
        '${cost.startYear}-${cost.startMonth.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          isMonthly ? Icons.repeat : Icons.event_repeat,
          size: 20,
        ),
      ),
      title: Text(cost.name),
      subtitle: Text('$recurrenceLabel · from $startLabel'),
      trailing: Text(
        '${cost.amount.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
