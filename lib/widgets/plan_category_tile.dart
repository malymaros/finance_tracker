import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../theme/app_theme.dart';

class PlanCategoryTile extends StatelessWidget {
  final ExpenseCategory category;
  final double total;
  final int count;
  final VoidCallback onTap;

  const PlanCategoryTile({
    super.key,
    required this.category,
    required this.total,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: category.color.withAlpha(30),
        child: Icon(category.icon, color: category.color, size: 20),
      ),
      title: Text(category.displayName),
      subtitle: Text('$count ${count == 1 ? 'item' : 'items'}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${total.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: AppColors.expense,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
      onTap: onTap,
    );
  }
}
