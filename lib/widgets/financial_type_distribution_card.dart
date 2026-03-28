import 'package:flutter/material.dart';
import '../models/financial_type.dart';
import '../models/financial_type_income_ratio.dart';
import '../theme/app_theme.dart';
import 'financial_type_ratio_row.dart';

class FinancialTypeDistributionCard extends StatelessWidget {
  final FinancialTypeIncomeRatio ratio;
  final bool isMonthly;

  const FinancialTypeDistributionCard({
    super.key,
    required this.ratio,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final overspend = ratio.overspendAmount;
    final periodLabel = isMonthly ? 'month' : 'year';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending vs Income',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            FinancialTypeRatioRow(type: FinancialType.consumption, pct: ratio.consumptionPct, amount: ratio.consumptionAmount),
            FinancialTypeRatioRow(type: FinancialType.asset, pct: ratio.assetPct, amount: ratio.assetAmount),
            FinancialTypeRatioRow(type: FinancialType.insurance, pct: ratio.insurancePct, amount: ratio.insuranceAmount),
            if (overspend != null) ...[
              const Divider(height: 16),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                        children: [
                          TextSpan(text: 'This $periodLabel you spent '),
                          TextSpan(
                            text: '${overspend.toStringAsFixed(2)} €',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' more than you earned!'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
