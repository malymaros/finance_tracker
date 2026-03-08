import 'package:flutter/material.dart';

import '../models/plan_item.dart';
import '../models/year_month.dart';
import 'swipeable_tile.dart';

class PlanItemTile extends StatelessWidget {
  final PlanItem item;

  /// Pre-computed display amount (monthly normalized or yearly cash-flow).
  final double displayAmount;

  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PlanItemTile({
    super.key,
    required this.item,
    required this.displayAmount,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';

    return SwipeableTile(
      itemId: item.id,
      onDelete: onDelete,
      onEdit: onEdit,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            isIncome ? Icons.trending_up : Icons.payments_outlined,
            color: color,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${_frequencyLabel(item.frequency)} · from ${_formatYearMonth(item.validFrom)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Text(
          '$sign${displayAmount.toStringAsFixed(2)} €',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  static String _frequencyLabel(PlanFrequency freq) => switch (freq) {
        PlanFrequency.monthly => 'Monthly',
        PlanFrequency.yearly => 'Yearly',
        PlanFrequency.oneTime => 'One-time',
      };

  static String _formatYearMonth(YearMonth ym) =>
      '${ym.year}-${ym.month.toString().padLeft(2, '0')}';
}
