import 'package:flutter/material.dart';

import '../models/category_budget.dart';
import '../models/expense_category.dart';
import '../services/currency_formatter.dart';
import 'swipeable_tile.dart';

/// A list tile representing a single category budget in [ManageBudgetsScreen].
///
/// Long-press reveals an action sheet with Edit and Delete options via
/// [SwipeableTile]. Tapping the tile directly calls [onEdit].
class CategoryBudgetTile extends StatelessWidget {
  final CategoryBudget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryBudgetTile({
    super.key,
    required this.budget,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = budget.category;
    return SwipeableTile(
      itemId: budget.id,
      onEdit: onEdit,
      onDelete: onDelete,
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          backgroundColor: cat.color.withAlpha(30),
          child: Icon(cat.icon, size: 20, color: cat.color),
        ),
        title: Text(cat.displayName),
        trailing: Text(
          '${CurrencyFormatter.format(budget.amount)}/month',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
