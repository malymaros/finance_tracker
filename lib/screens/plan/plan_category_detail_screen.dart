import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/plan_item_tile.dart';
import 'add_plan_item_screen.dart';
import 'plan_item_detail_screen.dart';

/// Drill-down screen showing the individual [PlanItem]s belonging to a single
/// income group or fixed-cost category for the selected period.
///
/// Filters are applied live from [planRepository] on every rebuild so that
/// edits and deletions made from within this screen are reflected immediately.
class PlanCategoryDetailScreen extends StatelessWidget {
  final String title;

  /// When set to [PlanItemType.income], shows all income items.
  /// Mutually exclusive with [categoryFilter].
  final PlanItemType? typeFilter;

  /// When set, shows fixed-cost items matching this category.
  /// Mutually exclusive with [typeFilter].
  final ExpenseCategory? categoryFilter;

  final YearMonth selectedPeriod;
  final bool isMonthly;
  final PlanRepository planRepository;

  const PlanCategoryDetailScreen({
    super.key,
    required this.title,
    this.typeFilter,
    this.categoryFilter,
    required this.selectedPeriod,
    required this.isMonthly,
    required this.planRepository,
  });

  int get _year => selectedPeriod.year;
  int get _month => selectedPeriod.month;

  List<PlanItem> _filteredItems(List<PlanItem> allItems) {
    final active = isMonthly
        ? BudgetCalculator.activeItemsForMonth(allItems, _year, _month)
        : BudgetCalculator.activeItemsForYear(allItems, _year);
    if (typeFilter == PlanItemType.income) {
      return active.where((i) => i.type == PlanItemType.income).toList();
    }
    if (categoryFilter != null) {
      return active
          .where((i) =>
              i.type == PlanItemType.fixedCost && i.category == categoryFilter)
          .toList();
    }
    return active;
  }

  double _displayAmount(PlanItem item) {
    return isMonthly
        ? BudgetCalculator.itemMonthlyContribution(item, _year, _month)
        : BudgetCalculator.itemYearlyContribution(
            item, planRepository.items, _year);
  }

  void _navigateToEdit(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: planRepository,
        existing: item,
        initialValidFrom: selectedPeriod,
      ),
    ));
  }

  void _openDetail(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => PlanItemDetailScreen(
        item: item,
        onEdit: () {
          Navigator.of(routeContext).pop();
          _navigateToEdit(context, item);
        },
        onDelete: () {
          Navigator.of(routeContext).pop();
          _confirmAndDelete(context, item);
        },
      ),
    ));
  }

  Future<void> _confirmAndDelete(BuildContext context, PlanItem item) async {
    final isFullDelete = item.validFrom == selectedPeriod;

    final String message;
    if (isFullDelete) {
      message = '"${item.name}" will be removed entirely.';
    } else {
      final fromLabel =
          '${YearMonth.monthNames[selectedPeriod.month]} ${selectedPeriod.year}';
      final prevMonth = selectedPeriod.addMonths(-1);
      final prevLabel =
          '${YearMonth.monthNames[prevMonth.month]} ${prevMonth.year}';
      message =
          '"${item.name}" will stop from $fromLabel onwards.\n$prevLabel and earlier will remain planned.';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove plan item'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      planRepository.removePlanItemFrom(item.id, selectedPeriod);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        scrolledUnderElevation: 0,
      ),
      body: ListenableBuilder(
        listenable: planRepository,
        builder: (context, _) {
          final items = _filteredItems(planRepository.items);
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text(
                    'No items for this period.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return PlanItemTile(
                item: item,
                displayAmount: _displayAmount(item),
                onTap: () => _openDetail(context, item),
                onEdit: () => _navigateToEdit(context, item),
                onDelete: () => _confirmAndDelete(context, item),
              );
            },
          );
        },
      ),
    );
  }
}
