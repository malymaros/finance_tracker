import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense_category.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

class PlanCategoryTile extends StatelessWidget {
  final ExpenseCategory category;
  final double total;
  final int count;
  final VoidCallback onTap;

  /// When non-null, the tile is in accordion mode and shows an expand/collapse
  /// chevron. When null (default), shows a navigation chevron_right.
  final bool? isExpanded;

  const PlanCategoryTile({
    super.key,
    required this.category,
    required this.total,
    required this.count,
    required this.onTap,
    this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final trailingIcon = isExpanded != null
        ? Icon(
            isExpanded! ? Icons.expand_less : Icons.expand_more,
            color: AppColors.textMuted,
          )
        : const Icon(Icons.chevron_right, color: AppColors.textMuted);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color.withAlpha(30),
        child: Icon(category.icon, color: category.color, size: 20),
      ),
      title: Text(context.l10n.categoryName(category)),
      subtitle: Text(context.l10n.itemCount(count)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              color: AppColors.expense,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          trailingIcon,
        ],
      ),
      onTap: onTap,
    );
  }
}
