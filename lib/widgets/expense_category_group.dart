import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/currency_formatter.dart';
import 'category_budget_progress_bar.dart';

/// Aggregate row for a single category in the By-Category view.
/// Shows category icon, name, item count, and total amount.
/// When [budget] is provided, a progress bar is shown below the tile.
class ExpenseCategoryGroup extends StatelessWidget {
  final ExpenseCategory category;
  final List<Expense> expenses;
  final VoidCallback? onTap;

  /// Monthly budget target for this category. When non-null, a progress bar
  /// is rendered below the tile showing spending vs budget.
  final double? budget;

  const ExpenseCategoryGroup({
    super.key,
    required this.category,
    required this.expenses,
    this.onTap,
    this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final count = expenses.length;

    final tile = ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: category.color.withAlpha(30),
        child: Icon(category.icon, size: 20, color: category.color),
      ),
      title: Text(context.l10n.categoryName(category)),
      subtitle: Text(
        context.l10n.itemCount(count),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Text(
        CurrencyFormatter.format(total),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );

    if (budget == null) return tile;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tile,
        CategoryBudgetProgressBar(spent: total, budget: budget!),
      ],
    );
  }
}
