import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense_category.dart';
import '../theme/app_theme.dart';

/// Full-screen list of all available categories.
///
/// Each row shows a gold heart icon that the user can tap to add or remove
/// the category from their default visible list. Tapping the row itself
/// selects the category and returns to the previous screens.
class AllCategoriesScreen extends StatefulWidget {
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onSelected;
  final ValueChanged<ExpenseCategory> onToggleFavorite;
  final bool Function(ExpenseCategory) isFavorite;

  const AllCategoriesScreen({
    super.key,
    this.selected,
    required this.onSelected,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  List<ExpenseCategory> _sorted() {
    final l10n = context.l10n;
    return ExpenseCategory.values.toList()
      ..sort((a, b) {
        if (a == ExpenseCategory.other) return 1;
        if (b == ExpenseCategory.other) return -1;
        return l10n.categoryName(a).compareTo(l10n.categoryName(b));
      });
  }

  Widget _buildRow(ExpenseCategory cat) {
    final l10n = context.l10n;
    final isOther = cat == ExpenseCategory.other;
    final isSelected = cat == widget.selected;
    final isFav = widget.isFavorite(cat);

    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: cat.color.withAlpha(30),
        child: Icon(cat.icon, size: 20, color: cat.color),
      ),
      title: Text(
        l10n.categoryName(cat),
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.surface,
      trailing: isOther
          ? const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.lock, size: 22, color: AppColors.gold),
            )
          : IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: isFav ? AppColors.gold : AppColors.textMuted,
              ),
              onPressed: () {
                widget.onToggleFavorite(cat);
                setState(() {});
              },
            ),
      onTap: () => widget.onSelected(cat),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted();
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(context.l10n.allCategoriesTitle),
      ),
      body: ListView.separated(
        itemCount: sorted.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (_, i) => _buildRow(sorted[i]),
      ),
    );
  }
}
