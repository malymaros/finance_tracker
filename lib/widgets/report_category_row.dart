import 'package:flutter/material.dart';

import '../models/category_total.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';

/// A single row in the report category breakdown.
///
/// [isSelected] highlights the row with a left accent bar when its
/// corresponding pie segment has been tapped.
///
/// [isInteractive] is false for rows that carry no tap action (reduced opacity,
/// no chevron). All rows are interactive in current usage.
///
/// [isOther] marks the aggregated "Other categories" bucket row. When true:
/// - the label is overridden to "Other categories"
/// - the trailing icon is an expand/collapse chevron driven by [isExpanded]
/// - [onTap] should toggle the expansion state, not navigate
///
/// [isExpanded] is only meaningful when [isOther] is true.
class ReportCategoryRow extends StatelessWidget {
  final CategoryTotal ct;
  final bool isSelected;
  final bool isInteractive;
  final bool isOther;
  final bool isExpanded;
  final VoidCallback? onTap;

  const ReportCategoryRow({
    super.key,
    required this.ct,
    required this.isSelected,
    required this.isInteractive,
    this.isOther = false,
    this.isExpanded = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = _buildRow();
    if (!isInteractive) {
      return Opacity(opacity: 0.45, child: row);
    }
    return row;
  }

  Widget _buildRow() {
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: ct.category.color.withAlpha(18),
              border: Border(
                left: BorderSide(color: ct.category.color, width: 4),
              ),
            )
          : null,
      child: InkWell(
        onTap: isInteractive ? onTap : null,
        child: Padding(
          padding: EdgeInsets.fromLTRB(isSelected ? 12 : 16, 10, 16, 10),
          child: Row(
            children: [
              _ColorDot(color: ct.category.color),
              const SizedBox(width: 8),
              Icon(
                ct.category.icon,
                size: 20,
                color: ct.category.color.withAlpha(180),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOther ? 'Other categories' : ct.category.displayName,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              Text(
                '${ct.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${ct.amount.toStringAsFixed(2)} €',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (isInteractive) ...[
                const SizedBox(width: 4),
                Icon(
                  isOther
                      ? (isExpanded ? Icons.expand_less : Icons.expand_more)
                      : Icons.chevron_right,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
