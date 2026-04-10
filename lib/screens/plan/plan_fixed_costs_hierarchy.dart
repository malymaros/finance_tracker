import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/guard_state.dart';
import '../../models/plan_item.dart';
import '../../models/plan_snapshot.dart';
import '../../services/budget_calculator.dart';
import '../../widgets/plan_category_tile.dart';
import '../../widgets/plan_financial_type_tile.dart';
import '../../widgets/plan_item_tile.dart';

/// Renders the fixed-costs accordion hierarchy: financial-type groups →
/// (for Consumption) category sub-groups → individual plan-item tiles.
///
/// All state (which type/category is expanded, which item is highlighted) is
/// owned by [PlanScreen] and passed in as constructor parameters.
/// This widget contains no business logic — it only renders data.
class PlanFixedCostsHierarchy extends StatelessWidget {
  final PlanSnapshot snapshot;
  final List<PlanItem> allItems;

  /// Precomputed yearly amounts for all items (empty in monthly mode).
  final Map<String, double> yearlyAmounts;

  final FinancialType? expandedFinancialType;
  final ExpenseCategory? expandedCategory;
  final String? highlightedSeriesId;
  final GlobalKey highlightKey;

  /// Called with the new expanded type, or null to collapse.
  final void Function(FinancialType?) onTypeExpanded;

  /// Called with the new expanded category, or null to collapse.
  final void Function(ExpenseCategory?) onCategoryExpanded;

  final void Function(PlanItem) onTap;
  final void Function(PlanItem) onEdit;
  final void Function(PlanItem) onDelete;
  final void Function(PlanItem) onGuard;

  const PlanFixedCostsHierarchy({
    super.key,
    required this.snapshot,
    required this.allItems,
    required this.yearlyAmounts,
    required this.expandedFinancialType,
    required this.expandedCategory,
    required this.highlightedSeriesId,
    required this.highlightKey,
    required this.onTypeExpanded,
    required this.onCategoryExpanded,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onGuard,
  });

  double _displayAmount(PlanItem item) {
    if (!snapshot.isMonthly) return yearlyAmounts[item.id] ?? 0.0;
    return BudgetCalculator.itemMonthlyContribution(
        item, snapshot.period.year, snapshot.period.month);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildTypeRows(context),
    );
  }

  List<Widget> _buildTypeRows(BuildContext context) {
    final typeTotals = BudgetCalculator.planFinancialTypeTotals(
      snapshot.fixedCostItems,
      allItems,
      snapshot.period.year,
      snapshot.period.month,
      snapshot.isMonthly,
    );

    const typeOrder = [
      FinancialType.consumption,
      FinancialType.asset,
      FinancialType.insurance,
    ];

    final widgets = <Widget>[];
    for (final type in typeOrder) {
      if (!typeTotals.containsKey(type)) continue;
      final data = typeTotals[type]!;
      final isTypeExpanded = expandedFinancialType == type;

      widgets.add(PlanFinancialTypeTile(
        type: type,
        total: data.total,
        count: data.count,
        isExpanded: isTypeExpanded,
        onTap: () => onTypeExpanded(isTypeExpanded ? null : type),
      ));

      if (isTypeExpanded) {
        if (type == FinancialType.consumption) {
          widgets.addAll(_buildConsumptionCategories(context));
        } else {
          widgets.addAll(_buildTypeItems(context, type));
        }
      }
    }
    return widgets;
  }

  List<Widget> _buildConsumptionCategories(BuildContext context) {
    final categoryTotals = BudgetCalculator.planCategoryTotals(
      snapshot.fixedCostItems,
      allItems,
      snapshot.period.year,
      snapshot.period.month,
      snapshot.isMonthly,
      financialTypeFilter: FinancialType.consumption,
    );

    final widgets = <Widget>[];
    for (final entry in categoryTotals.entries) {
      final cat = entry.key;
      final data = entry.value;
      final isCatExpanded = expandedCategory == cat;

      widgets.add(PlanCategoryTile(
        category: cat,
        total: data.total,
        count: data.count,
        isExpanded: isCatExpanded,
        onTap: () => onCategoryExpanded(isCatExpanded ? null : cat),
      ));

      if (isCatExpanded) {
        final items = snapshot.fixedCostItems
            .where((i) =>
                i.category == cat &&
                (i.financialType ?? FinancialType.consumption) ==
                    FinancialType.consumption)
            .toList();
        for (final item in items) {
          final isHighlighted = item.seriesId == highlightedSeriesId;
          widgets.add(PlanItemTile(
            key: isHighlighted ? highlightKey : null,
            item: item,
            displayAmount: _displayAmount(item),
            guardState:
                snapshot.guardStateMap[item.seriesId] ?? GuardState.none,
            isHighlighted: isHighlighted,
            onTap: () => onTap(item),
            onEdit: () => onEdit(item),
            onDelete: () => onDelete(item),
            onGuard: () => onGuard(item),
          ));
        }
      }
    }
    return widgets;
  }

  List<Widget> _buildTypeItems(BuildContext context, FinancialType type) {
    final items = snapshot.fixedCostItems
        .where(
            (i) => (i.financialType ?? FinancialType.consumption) == type)
        .toList();
    return items.map((item) {
      final isHighlighted = item.seriesId == highlightedSeriesId;
      return PlanItemTile(
        key: isHighlighted ? highlightKey : null,
        item: item,
        displayAmount: _displayAmount(item),
        guardState: snapshot.guardStateMap[item.seriesId] ?? GuardState.none,
        isHighlighted: isHighlighted,
        onTap: () => onTap(item),
        onEdit: () => onEdit(item),
        onDelete: () => onDelete(item),
        onGuard: () => onGuard(item),
      );
    }).toList();
  }
}
