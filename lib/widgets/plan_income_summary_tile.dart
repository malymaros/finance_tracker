import 'package:flutter/material.dart';

import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class PlanIncomeSummaryTile extends StatelessWidget {
  final double total;
  final int count;
  final bool isExpanded;

  /// Null when there are no income items (tile becomes non-tappable).
  final VoidCallback? onTap;

  const PlanIncomeSummaryTile({
    super.key,
    required this.total,
    required this.count,
    required this.isExpanded,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = count > 0;
    return InkWell(
      onTap: hasItems ? onTap : null,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          children: [
            const Icon(Icons.savings, color: AppColors.income, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Income',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasItems
                        ? '$count ${count == 1 ? 'item' : 'items'}'
                        : 'No income planned',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                color: AppColors.income,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (hasItems) ...[
              const SizedBox(width: 4),
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
