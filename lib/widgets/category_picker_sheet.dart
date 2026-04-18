import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense_category.dart';
import '../screens/all_categories_screen.dart';
import '../theme/app_theme.dart';

class CategoryPickerSheet extends StatelessWidget {
  final Set<ExpenseCategory> visible;
  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onSelected;
  final ValueChanged<ExpenseCategory> onToggleFavorite;
  final bool Function(ExpenseCategory) isFavorite;

  const CategoryPickerSheet({
    super.key,
    required this.visible,
    this.selected,
    required this.onSelected,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  static const _kRowHeight = 56.0;
  static const _kMaxRows = 8; // 7 regular + Other

  List<ExpenseCategory> _sorted(BuildContext context) {
    final l10n = context.l10n;
    return visible.toList()
      ..sort((a, b) {
        if (a == ExpenseCategory.other) return 1;
        if (b == ExpenseCategory.other) return -1;
        return l10n.categoryName(a).compareTo(l10n.categoryName(b));
      });
  }

  Widget _buildRow(BuildContext context, ExpenseCategory cat) {
    final isSelected = cat == selected;
    return SizedBox(
      height: _kRowHeight,
      child: ListTile(
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: cat.color.withAlpha(30),
          child: Icon(cat.icon, size: 18, color: cat.color),
        ),
        title: Text(
          context.l10n.categoryName(cat),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.surface,
        onTap: () {
          onSelected(cat);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sorted = _sorted(context);
    final listHeight = min(sorted.length, _kMaxRows) * _kRowHeight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Handle ─────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // ── Title ──────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.selectCategoryTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const Divider(height: 1),

        // ── Category list (scrollable, capped at 8 rows) ───────────────────────
        Stack(
          children: [
            SizedBox(
              height: listHeight,
              child: ListView(
                children: [
                  for (final cat in sorted) _buildRow(context, cat),
                ],
              ),
            ),
            if (sorted.length > _kMaxRows)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 32,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withAlpha(0),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        const Divider(height: 1),

        // ── Show all categories (fixed) ────────────────────────────────────────
        ListTile(
          leading: const SizedBox(width: 32),
          title: Text(
            l10n.showAllCategories,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.primary,
          ),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AllCategoriesScreen(
                selected: selected,
                onSelected: (cat) {
                  onSelected(cat);
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
                onToggleFavorite: onToggleFavorite,
                isFavorite: isFavorite,
              ),
            ));
          },
        ),

        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }
}
