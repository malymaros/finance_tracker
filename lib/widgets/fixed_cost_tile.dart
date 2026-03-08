import 'package:flutter/material.dart';

import '../models/expense_category.dart';
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
        backgroundColor: cost.category.color.withAlpha(30),
        child:
            Icon(cost.category.icon, size: 20, color: cost.category.color),
      ),
      title: Text(cost.name),
      subtitle: Text(
          '$recurrenceLabel · ${cost.category.displayName} · from $startLabel'),
      trailing: Text(
        '${cost.amount.toStringAsFixed(2)} €',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
