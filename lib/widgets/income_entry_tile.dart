import 'package:flutter/material.dart';

import '../models/income_entry.dart';

class IncomeEntryTile extends StatelessWidget {
  final IncomeEntry entry;

  const IncomeEntryTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';

    final isMonthly = entry.type == IncomeType.monthly;
    final title = entry.description?.isNotEmpty == true
        ? entry.description!
        : (isMonthly ? 'Monthly income' : 'One-time income');

    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          isMonthly ? Icons.repeat : Icons.add_circle_outline,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(formattedDate),
      trailing: Text(
        '${entry.amount.toStringAsFixed(2)} €',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green,
        ),
      ),
    );
  }
}
