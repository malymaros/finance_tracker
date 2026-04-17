import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class PlanFixedCostsSummaryTile extends StatelessWidget {
  final double total;
  final int count;
  final bool isExpanded;

  /// Null when there are no fixed cost items (tile becomes non-tappable).
  final VoidCallback? onTap;

  const PlanFixedCostsSummaryTile({
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
            const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.sectionFixedCosts,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasItems
                        ? context.l10n.itemCount(count)
                        : context.l10n.noFixedCostsPlanned,
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
                color: AppColors.expense,
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
