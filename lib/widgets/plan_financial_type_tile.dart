import 'package:flutter/material.dart';

import '../models/financial_type.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// Displays a single financial type group row inside the Fixed Costs accordion.
/// Shows the type icon, name, item count, total amount, and an expand/collapse
/// indicator.
class PlanFinancialTypeTile extends StatelessWidget {
  final FinancialType type;
  final double total;
  final int count;
  final bool isExpanded;
  final VoidCallback onTap;

  const PlanFinancialTypeTile({
    super.key,
    required this.type,
    required this.total,
    required this.count,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Consumption uses the semantic expense red; Asset and Insurance use their
    // own type color — consistent with PlanItemTile amount coloring.
    final amountColor = type == FinancialType.consumption
        ? AppColors.expense
        : type.color;

    // All three type group tiles get a left border in their type color.
    // Consumption uses a white background (no tint); Asset and Insurance
    // use their type tint.
    final tintColor = type == FinancialType.consumption
        ? Colors.transparent
        : type.tintColor;

    return Container(
      decoration: BoxDecoration(
        color: tintColor,
        border: Border(left: BorderSide(width: 3, color: type.color)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: type.color.withAlpha(30),
          child: Icon(type.icon, color: type.color, size: 20),
        ),
        title: Text(type.displayName),
        subtitle: Text('$count ${count == 1 ? 'item' : 'items'}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(total),
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textMuted,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
