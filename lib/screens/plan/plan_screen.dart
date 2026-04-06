import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/financial_type_income_ratio.dart';
import '../../models/guard_state.dart';
import '../../models/period_bounds.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/app_repositories.dart';
import '../../services/report_aggregator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/financial_type_distribution_card.dart';
import '../../widgets/guard_banner.dart';
import '../../widgets/period_navigator.dart';
import 'guard_screen.dart';
import '../../widgets/plan_category_tile.dart';
import '../../widgets/plan_financial_type_tile.dart';
import '../../widgets/plan_fixed_costs_summary_tile.dart';
import '../../widgets/plan_income_summary_tile.dart';
import '../../widgets/add_fixed_cost_frequency_sheet.dart';
import '../../widgets/add_income_frequency_sheet.dart';
import '../../widgets/add_plan_item_type_sheet.dart';
import '../../widgets/plan_item_tile.dart';
import 'add_plan_item_screen.dart';
import 'manage_budgets_screen.dart';
import 'plan_item_detail_screen.dart';

enum _DeleteChoice { fromPeriod, wholeSeries }

class PlanScreen extends StatefulWidget {
  final AppRepositories repositories;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  const PlanScreen({
    super.key,
    required this.repositories,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onClearAll,
    required this.onOpenSaves,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _isMonthly = true;
  bool _incomeExpanded = false;
  bool _fixedCostsExpanded = false;

  /// Which financial type group is currently expanded within Fixed Costs.
  FinancialType? _expandedFinancialType;

  /// Which category is currently expanded within the Consumption group.
  ExpenseCategory? _expandedCategory;

  /// SeriesId of the item currently highlighted (from GuardBanner tap).
  String? _highlightedSeriesId;

  /// Key assigned to the highlighted PlanItemTile so we can scroll to it.
  final _highlightKey = GlobalKey();

  int get _year => widget.selectedPeriod.value.year;
  int get _month => widget.selectedPeriod.value.month;

  @override
  void initState() {
    super.initState();
    widget.selectedPeriod.addListener(_onPeriodChanged);
  }

  @override
  void dispose() {
    widget.selectedPeriod.removeListener(_onPeriodChanged);
    super.dispose();
  }

  void _onPeriodChanged() => setState(() {
        _expandedFinancialType = null;
        _expandedCategory = null;
      });

  /// Expands the tree to reveal [item], scrolls to it, and briefly highlights it.
  void _expandToItem(PlanItem item) {
    final ft = item.financialType ?? FinancialType.consumption;
    setState(() {
      _isMonthly = true;
      _fixedCostsExpanded = true;
      _expandedFinancialType = ft;
      _expandedCategory =
          ft == FinancialType.consumption ? item.category : null;
      _highlightedSeriesId = item.seriesId;
    });
    // Scroll after the tree has rebuilt.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _highlightKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.3,
        );
      }
    });
    // Clear highlight after 2 s.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlightedSeriesId = null);
    });
  }

  double _displayAmount(PlanItem item, Map<String, double> yearlyAmounts) {
    if (!_isMonthly) return yearlyAmounts[item.id] ?? 0.0;
    return BudgetCalculator.itemMonthlyContribution(item, _year, _month);
  }

  void _showTypeSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => AddPlanItemTypeSheet(
        onIncomeSelected: () {
          if (context.mounted) _showIncomeFrequencySheet(context);
        },
        onFixedCostSelected: () {
          if (context.mounted) _showFixedCostFrequencySheet(context);
        },
      ),
    );
  }

  void _showIncomeFrequencySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => AddIncomeFrequencySheet(
        onMonthlySelected: () {
          if (context.mounted) {
            _navigateToAdd(context, PlanItemType.income, PlanFrequency.monthly);
          }
        },
        onYearlySelected: () {
          if (context.mounted) {
            _navigateToAdd(context, PlanItemType.income, PlanFrequency.yearly);
          }
        },
        onOneTimeSelected: () {
          if (context.mounted) {
            _navigateToAdd(
                context, PlanItemType.income, PlanFrequency.oneTime);
          }
        },
      ),
    );
  }

  void _showFixedCostFrequencySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => AddFixedCostFrequencySheet(
        onMonthlySelected: () {
          if (context.mounted) {
            _navigateToAdd(
                context, PlanItemType.fixedCost, PlanFrequency.monthly);
          }
        },
        onYearlySelected: () {
          if (context.mounted) {
            _navigateToAdd(
                context, PlanItemType.fixedCost, PlanFrequency.yearly);
          }
        },
      ),
    );
  }

  void _navigateToAdd(
      BuildContext context, PlanItemType type, PlanFrequency frequency) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.repositories.plan,
        initialType: type,
        initialFrequency: frequency,
        initialValidFrom: widget.selectedPeriod.value,
      ),
    ));
  }

  void _navigateToEdit(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.repositories.plan,
        existing: item,
        initialValidFrom: widget.selectedPeriod.value,
      ),
    ));
  }

  void _openDetail(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => PlanItemDetailScreen(
        item: item,
        period: widget.selectedPeriod.value,
        guardRepository: widget.repositories.guard,
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
    if (item.type == PlanItemType.fixedCost) {
      await _confirmAndDeleteFixedCost(context, item);
    } else {
      // Income and one-time: single-action confirm with context-aware message.
      final from = widget.selectedPeriod.value;
      final isFullDelete = item.validFrom == from;
      final message = isFullDelete
          ? '"${item.name}" will be removed entirely.'
          : '"${item.name}" will stop from ${from.label} onwards. '
              '${from.addMonths(-1).label} and earlier will remain planned.';
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
        widget.repositories.plan.removePlanItemFrom(item.id, from);
      }
    }
  }

  Future<void> _confirmAndDeleteFixedCost(
      BuildContext context, PlanItem item) async {
    final selectedPeriod = widget.selectedPeriod.value;

    // Determine the cut point and descriptive labels for "from period onwards".
    final YearMonth deleteFrom;
    final String fromTitle;
    final String fromSubtitle;

    if (item.frequency == PlanFrequency.yearly) {
      final anchor = item.validFrom.month;
      final cycleStartYear = selectedPeriod.month >= anchor
          ? selectedPeriod.year
          : selectedPeriod.year - 1;
      final cycleStart = YearMonth(cycleStartYear, anchor);
      final cycleEnd = YearMonth(cycleStartYear + 1, anchor).addMonths(-1);
      deleteFrom = cycleStart;
      fromTitle = 'From ${cycleStart.label} onwards';
      fromSubtitle =
          'This cycle (${cycleStart.label} – ${cycleEnd.label}) '
          'and all future cycles are removed.';
    } else {
      deleteFrom = selectedPeriod;
      final prev = selectedPeriod.addMonths(-1);
      fromTitle = 'From ${selectedPeriod.label} onwards';
      fromSubtitle = 'History up to ${prev.label} is kept.';
    }

    // Find the earliest version to describe the whole-series start.
    final allVersions = widget.repositories.plan.items
        .where((i) => i.seriesId == item.seriesId)
        .toList()
      ..sort((a, b) => a.validFrom.compareTo(b.validFrom));
    final seriesStart = allVersions.first.validFrom;

    final result = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove "${item.name}"'),
        contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined,
                  color: AppColors.expense),
              title: const Text('Whole series',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle:
                  Text('All periods from ${seriesStart.label} are removed.'),
              onTap: () => Navigator.of(ctx).pop(_DeleteChoice.wholeSeries),
            ),
            const Divider(height: 1),
            ListTile(
              leading:
                  const Icon(Icons.content_cut, color: AppColors.expense),
              title: Text(fromTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(fromSubtitle),
              onTap: () => Navigator.of(ctx).pop(_DeleteChoice.fromPeriod),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (result == _DeleteChoice.wholeSeries) {
      widget.repositories.plan.removeEntireSeries(item.seriesId);
    } else if (result == _DeleteChoice.fromPeriod) {
      widget.repositories.plan.removePlanItemFrom(item.id, deleteFrom);
    }
  }

  Future<void> _onSilenceRequested(
      String seriesId, YearMonth period) async {
    final periodLabel = period.label;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silence this reminder?'),
        content: Text(
          'The $periodLabel payment will still be shown as unconfirmed. '
          'You can mark it as paid at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Silence'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.repositories.guard.silencePayment(seriesId, period);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan'),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.save_outlined),
          tooltip: 'Saves',
          onPressed: () => widget.onOpenSaves(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'manage_budgets') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ManageBudgetsScreen(
                    budgetRepository: widget.repositories.budget,
                  ),
                ));
              } else if (value == 'guard') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => GuardScreen(
                    planRepository: widget.repositories.plan,
                    guardRepository: widget.repositories.guard,
                  ),
                ));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'manage_budgets',
                child: Text('Manage Budgets'),
              ),
              const PopupMenuItem(
                value: 'guard',
                child: Row(
                  children: [
                    Text('GUARD settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge(
            [widget.repositories.finance, widget.repositories.plan, widget.repositories.guard]),
        builder: (context, _) {
          final all = widget.repositories.plan.items;
          final now = YearMonth.now();
          final viewPeriod = widget.selectedPeriod.value;

          final List<PlanItem> displayItems;
          final double totalIncome;
          final double totalFixedCosts;

          if (_isMonthly) {
            displayItems =
                BudgetCalculator.activeItemsForMonth(all, _year, _month);
            totalIncome =
                BudgetCalculator.normalizedMonthlyIncome(all, _year, _month);
            totalFixedCosts =
                BudgetCalculator.normalizedMonthlyFixedCosts(all, _year, _month);
          } else {
            displayItems = BudgetCalculator.activeItemsForYear(all, _year);
            totalIncome = BudgetCalculator.yearlyIncome(all, _year);
            totalFixedCosts = BudgetCalculator.yearlyFixedCosts(all, _year);
          }

          final spendable = totalIncome - totalFixedCosts;
          final incomeItems = displayItems
              .where((i) => i.type == PlanItemType.income)
              .toList();
          final fixedCostItems = displayItems
              .where((i) => i.type == PlanItemType.fixedCost)
              .toList();

          final mergedLines = _isMonthly
              ? ReportAggregator.mergedLines(
                  widget.repositories.finance.reportLinesForMonth(_year, _month),
                  BudgetCalculator.planFixedCostReportLinesForMonth(
                      all, _year, _month),
                )
              : ReportAggregator.mergedLines(
                  widget.repositories.finance.reportLinesForYear(_year),
                  BudgetCalculator.planFixedCostReportLinesForYear(all, _year),
                );
          final ratio = BudgetCalculator.financialTypeIncomeRatios(
              mergedLines, totalIncome);

          // Build guard state map for the viewed period (one lookup per item).
          final guardStateMap = <String, GuardState>{};
          for (final item in fixedCostItems) {
            guardStateMap[item.seriesId] =
                widget.repositories.guard.itemStateForPeriod(item, viewPeriod);
          }

          // Unresolved items for the banner (always based on "now", not viewed period).
          // Use unpaidActiveItems() + set subtraction to avoid double state lookups.
          final unpaidActive =
              widget.repositories.guard.unpaidActiveItems(all, now);
          final allUnresolved =
              widget.repositories.guard.allUnresolvedItems(all, now);
          final unpaidActiveKeys = {
            for (final p in unpaidActive) '${p.$1.seriesId}|${p.$2}'
          };
          final silencedItems = allUnresolved
              .where((pair) =>
                  !unpaidActiveKeys.contains('${pair.$1.seriesId}|${pair.$2}'))
              .toList();

          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              GuardBanner(
                unpaidActive: unpaidActive,
                silenced: silencedItems,
                onMarkPaid: (seriesId, period) =>
                    widget.repositories.guard.confirmPayment(seriesId, period),
                onSilence: _onSilenceRequested,
                onTapItem: (item, _) => _expandToItem(item),
              ),
              _buildSummaryCard(spendable),
              const Divider(height: 1),
              Expanded(
                child: displayItems.isEmpty
                    ? _buildEmptyState()
                    : _buildPlanHierarchy(
                        context,
                        incomeItems,
                        fixedCostItems,
                        all,
                        totalIncome,
                        totalFixedCosts,
                        ratio,
                        guardStateMap,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Opacity(
        opacity: 0.6,
        child: FloatingActionButton(
          onPressed: () => _showTypeSheet(context),
          tooltip: 'Add Plan Item',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: false,
            label: Text('Yearly'),
            icon: Icon(Icons.calendar_today),
          ),
        ],
        selected: {_isMonthly},
        onSelectionChanged: (s) => setState(() {
          _isMonthly = s.first;
          _expandedFinancialType = null;
          _expandedCategory = null;
        }),
      ),
    );
  }

  Widget _buildPeriodNavigator() {
    final bounds = widget.periodBounds.value;
    return PeriodNavigator(
      selected: widget.selectedPeriod.value,
      yearOnly: !_isMonthly,
      min: bounds.min,
      max: bounds.max,
      onChanged: (ym) => setState(() {
        widget.selectedPeriod.value = ym;
      }),
    );
  }

  Widget _buildSummaryCard(double spendable) {
    final isPositive = spendable >= 0;
    final spendableColor = isPositive ? AppColors.income : AppColors.expense;
    final periodLabel = _isMonthly ? 'this month' : 'this year';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spendable $periodLabel',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${spendable.toStringAsFixed(2)} €',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: spendableColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_outlined,
              size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text('No plan items yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap + to add income or fixed costs.',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPlanHierarchy(
    BuildContext context,
    List<PlanItem> incomeItems,
    List<PlanItem> fixedCostItems,
    List<PlanItem> allItems,
    double totalIncome,
    double totalFixedCosts,
    FinancialTypeIncomeRatio ratio,
    Map<String, GuardState> guardStateMap,
  ) {
    // Precompute yearly amounts once per build so itemYearlyContribution is not
    // called per tile during rendering.
    final yearlyAmounts = !_isMonthly
        ? {
            for (final item in [...incomeItems, ...fixedCostItems])
              item.id: BudgetCalculator.itemYearlyContribution(item, allItems, _year)
          }
        : const <String, double>{};

    return ListView(
      children: [
        PlanIncomeSummaryTile(
          total: totalIncome,
          count: incomeItems.length,
          isExpanded: _incomeExpanded,
          onTap: incomeItems.isNotEmpty
              ? () => setState(() => _incomeExpanded = !_incomeExpanded)
              : null,
        ),
        if (_incomeExpanded)
          ...incomeItems.map((item) => PlanItemTile(
                item: item,
                displayAmount: _displayAmount(item, yearlyAmounts),
                onTap: () => _openDetail(context, item),
                onEdit: () => _navigateToEdit(context, item),
                onDelete: () => _confirmAndDelete(context, item),
              )),
        const Divider(height: 1),
        PlanFixedCostsSummaryTile(
          total: totalFixedCosts,
          count: fixedCostItems.length,
          isExpanded: _fixedCostsExpanded,
          onTap: fixedCostItems.isNotEmpty
              ? () => setState(() {
                    _fixedCostsExpanded = !_fixedCostsExpanded;
                    if (!_fixedCostsExpanded) {
                      _expandedFinancialType = null;
                      _expandedCategory = null;
                    }
                  })
              : null,
        ),
        if (_fixedCostsExpanded)
          ..._buildFixedCostsSection(
              context, fixedCostItems, allItems, guardStateMap, yearlyAmounts),
        FinancialTypeDistributionCard(ratio: ratio, isMonthly: _isMonthly),
        const SizedBox(height: 80),
      ],
    );
  }

  // ── Fixed Costs inline accordion ──────────────────────────────────────────

  List<Widget> _buildFixedCostsSection(
    BuildContext context,
    List<PlanItem> fixedCostItems,
    List<PlanItem> allItems,
    Map<String, GuardState> guardStateMap,
    Map<String, double> yearlyAmounts,
  ) {
    final typeTotals = BudgetCalculator.planFinancialTypeTotals(
      fixedCostItems,
      allItems,
      _year,
      _month,
      _isMonthly,
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
      final isTypeExpanded = _expandedFinancialType == type;

      widgets.add(PlanFinancialTypeTile(
        type: type,
        total: data.total,
        count: data.count,
        isExpanded: isTypeExpanded,
        onTap: () => setState(() {
          if (_expandedFinancialType == type) {
            _expandedFinancialType = null;
            _expandedCategory = null;
          } else {
            _expandedFinancialType = type;
            _expandedCategory = null;
          }
        }),
      ));

      if (isTypeExpanded) {
        if (type == FinancialType.consumption) {
          widgets.addAll(_buildConsumptionCategories(
              context, fixedCostItems, allItems, guardStateMap, yearlyAmounts));
        } else {
          widgets.addAll(_buildTypeItems(
              context, fixedCostItems, type, guardStateMap, yearlyAmounts));
        }
      }
    }
    return widgets;
  }

  List<Widget> _buildConsumptionCategories(
    BuildContext context,
    List<PlanItem> fixedCostItems,
    List<PlanItem> allItems,
    Map<String, GuardState> guardStateMap,
    Map<String, double> yearlyAmounts,
  ) {
    final categoryTotals = BudgetCalculator.planCategoryTotals(
      fixedCostItems,
      allItems,
      _year,
      _month,
      _isMonthly,
      financialTypeFilter: FinancialType.consumption,
    );

    final widgets = <Widget>[];
    for (final entry in categoryTotals.entries) {
      final cat = entry.key;
      final data = entry.value;
      final isCatExpanded = _expandedCategory == cat;

      widgets.add(PlanCategoryTile(
        category: cat,
        total: data.total,
        count: data.count,
        isExpanded: isCatExpanded,
        onTap: () => setState(() {
          _expandedCategory = _expandedCategory == cat ? null : cat;
        }),
      ));

      if (isCatExpanded) {
        final items = fixedCostItems
            .where((i) =>
                i.category == cat &&
                (i.financialType ?? FinancialType.consumption) ==
                    FinancialType.consumption)
            .toList();
        for (final item in items) {
          final isHighlighted = item.seriesId == _highlightedSeriesId;
          widgets.add(PlanItemTile(
            key: isHighlighted ? _highlightKey : null,
            item: item,
            displayAmount: _displayAmount(item, yearlyAmounts),
            guardState: guardStateMap[item.seriesId] ?? GuardState.none,
            isHighlighted: isHighlighted,
            onTap: () => _openDetail(context, item),
            onEdit: () => _navigateToEdit(context, item),
            onDelete: () => _confirmAndDelete(context, item),
          ));
        }
      }
    }
    return widgets;
  }

  List<Widget> _buildTypeItems(
    BuildContext context,
    List<PlanItem> fixedCostItems,
    FinancialType type,
    Map<String, GuardState> guardStateMap,
    Map<String, double> yearlyAmounts,
  ) {
    final items = fixedCostItems
        .where(
            (i) => (i.financialType ?? FinancialType.consumption) == type)
        .toList();
    return items.map((item) {
      final isHighlighted = item.seriesId == _highlightedSeriesId;
      return PlanItemTile(
        key: isHighlighted ? _highlightKey : null,
        item: item,
        displayAmount: _displayAmount(item, yearlyAmounts),
        guardState: guardStateMap[item.seriesId] ?? GuardState.none,
        isHighlighted: isHighlighted,
        onTap: () => _openDetail(context, item),
        onEdit: () => _navigateToEdit(context, item),
        onDelete: () => _confirmAndDelete(context, item),
      );
    }).toList();
  }
}
