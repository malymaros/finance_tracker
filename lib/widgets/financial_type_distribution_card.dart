import 'package:flutter/material.dart';
import '../models/financial_type.dart';
import '../models/financial_type_income_ratio.dart';
import 'financial_type_ratio_row.dart';

class FinancialTypeDistributionCard extends StatelessWidget {
  final FinancialTypeIncomeRatio ratio;

  const FinancialTypeDistributionCard({
    super.key,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
      ),
    );
  }
}
