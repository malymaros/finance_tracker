import 'package:flutter/material.dart';

import '../models/financial_type.dart';
import '../models/monthly_overview_summary.dart';
import '../models/year_month.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// A single row in the Reports → Overview tab.
///
/// Shows a background track (full width = earned reference) with a
/// proportional foreground bar (assets left in green, consumption right in red).
/// When allocated > earned the bar fills the track completely, signalling a
/// deficit — confirmed by the result number on the right.
class OverviewMonthRow extends StatelessWidget {
  final MonthlyOverviewSummary summary;
  final VoidCallback onTap;

  const OverviewMonthRow({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diff = summary.result;
    final diffColor = diff >= 0 ? AppColors.income : AppColors.expense;
    final symbol = CurrencyFormatter.currencySymbol;
    final diffText = diff >= 0
        ? '+${diff.toStringAsFixed(0)} $symbol'
        : '${diff.toStringAsFixed(0)} $symbol';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                YearMonth.monthAbbreviations[summary.period.month],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (summary.earned > 0) _buildBar(),
                  const SizedBox(height: 4),
                  _buildNumbers(),
                ],
              ),
            ),
            const SizedBox(width: 12),
            summary.hasData
                ? Text(
                    diffText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: diffColor,
                    ),
                  )
                : const Text(
                    '—',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
          ],
        ),
      ),
    );
  }

  /// Background track = earned (full width). Foreground bar = allocated,
  /// proportional to earned. Assets (green) on left, consumption (red) on right.
  Widget _buildBar() {
    final widthFactor = (summary.allocated / summary.earned).clamp(0.0, 1.0);

    return SizedBox(
      height: 6,
      child: Stack(
        children: [
          // Earned reference track — full width.
          Container(
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Allocated bar — proportional to earned.
          if (summary.allocated > 0)
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: _buildAllocatedBar(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAllocatedBar() {
    if (summary.consumptionPct == 0) {
      return Container(color: AppColors.income);
    }
    if (summary.assetPct == 0) {
      return Container(color: AppColors.expense);
    }
    return Row(
      children: [
        Expanded(
          flex: (summary.assetPct * 100).round(),
          child: Container(color: AppColors.income),
        ),
        Expanded(
          flex: (summary.consumptionPct * 100).round(),
          child: Container(color: AppColors.expense),
        ),
      ],
    );
  }

  Widget _buildNumbers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FinancialType.asset.icon,
                size: 11, color: AppColors.income),
            const SizedBox(width: 3),
            Text(
              '${summary.assets.toStringAsFixed(0)} ${CurrencyFormatter.currencySymbol}',
              style: const TextStyle(fontSize: 11, color: AppColors.income),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FinancialType.consumption.icon,
                size: 11, color: AppColors.expense),
            const SizedBox(width: 3),
            Text(
              '${summary.consumption.toStringAsFixed(0)} ${CurrencyFormatter.currencySymbol}',
              style: const TextStyle(fontSize: 11, color: AppColors.expense),
            ),
          ],
        ),
        Text(
          'Earned: ${summary.earned.toStringAsFixed(0)} ${CurrencyFormatter.currencySymbol}',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
