import 'package:flutter/material.dart';

import '../models/budget_status.dart';

class BudgetProgressBar extends StatelessWidget {
  final BudgetStatus status;

  const BudgetProgressBar({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final progress = (status.percentUsed / 100).clamp(0.0, 1.0);
    final Color barColor;
    if (status.isOverBudget) {
      barColor = Colors.red;
    } else if (status.percentUsed >= 75) {
      barColor = Colors.orange;
    } else {
      barColor = Colors.green;
    }

    final isOver = status.isOverBudget;
    final remaining = status.remaining;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "This month's budget",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  isOver
                      ? '${(-remaining).toStringAsFixed(2)} € over'
                      : '${remaining.toStringAsFixed(2)} € left',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isOver ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
            const SizedBox(height: 8),
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
