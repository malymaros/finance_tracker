import 'package:flutter/material.dart';
import '../models/financial_type.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class FinancialTypeRatioRow extends StatelessWidget {
  final FinancialType type;
  final double? pct;
  final double amount;

  const FinancialTypeRatioRow({
    super.key,
    required this.type,
    required this.pct,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final color = type.color;
    final ringValue = pct == null ? 0.0 : (pct! / 100).clamp(0.0, 1.0);
    final label = pct == null ? '—' : '${pct!.toStringAsFixed(0)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(type.icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.displayName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  CurrencyFormatter.format(amount),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ringValue,
                  strokeWidth: 5,
                  backgroundColor: color.withAlpha(40),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: pct == null ? 16 : 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
