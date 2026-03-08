import 'package:flutter/material.dart';

import '../models/budget_status.dart';

/// Compact past-month budget result card.
/// Shows whether the user saved money or went over budget.
class MonthBudgetSummary extends StatelessWidget {
  final BudgetStatus status;

  const MonthBudgetSummary({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isOver = status.isOverBudget;
    final diff = status.remaining.abs();

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOver
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: isOver ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOver
                      ? 'Over budget by ${diff.toStringAsFixed(2)} €'
                      : 'Saved ${diff.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isOver ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${status.actualSpent.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Budget: ${status.spendableBudget.toStringAsFixed(2)} €',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
