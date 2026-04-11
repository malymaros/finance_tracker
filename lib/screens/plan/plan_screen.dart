import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/period_bounds.dart';
import '../../models/plan_item.dart';
import '../../models/plan_snapshot.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/app_repositories.dart';
import '../../services/plan_snapshot_builder.dart';
import '../../theme/app_theme.dart';
import '../../widgets/financial_type_distribution_card.dart';
import '../../widgets/guard_banner.dart';
import '../../widgets/how_it_works_sheet.dart';
import '../../widgets/period_navigator.dart';
import 'guard_screen.dart';
import '../../widgets/plan_fixed_costs_summary_tile.dart';
import '../../widgets/plan_income_summary_tile.dart';
import '../../widgets/add_fixed_cost_frequency_sheet.dart';
import '../../widgets/add_income_frequency_sheet.dart';
import '../../widgets/add_plan_item_type_sheet.dart';
import '../../widgets/plan_item_tile.dart';
import 'add_plan_item_screen.dart';
import 'manage_budgets_screen.dart';
import '../../widgets/guard_setup_sheet.dart';
import 'plan_fixed_costs_hierarchy.dart';
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

  /// Manages the highlight-and-scroll animation when a GuardBanner item is tapped.
  final _highlight = _PlanHighlightManager();

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

  /// Expands the accordion tree to reveal [item], scrolls to it, and briefly
  /// highlights it. Uses [_PlanHighlightManager] to coordinate the animation.
  void _expandToItem(PlanItem item) {
    _highlight.trigger(
      item,
      onExpand: ({required FinancialType financialType,
          required ExpenseCategory? category}) {
        setState(() {
          _isMonthly = true;
          _fixedCostsExpanded = true;
          _expandedFinancialType = financialType;
          _expandedCategory = category;
        });
      },
      onClear: () {
        if (mounted) setState(() {});
      },
    );
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
        planRepository: widget.repositories.plan,
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
        listenable: Listenable.merge([
          widget.repositories.finance,
          widget.repositories.plan,
          widget.repositories.guard,
        ]),
        builder: (context, _) {
          final all = widget.repositories.plan.items;
          final now = YearMonth.now();
          final viewPeriod = widget.selectedPeriod.value;

          // Guard data requires live repositories and cannot be moved into
          // PlanSnapshotBuilder without coupling it to GuardRepository.
          final fixedCostCandidates = _isMonthly
              ? BudgetCalculator.activeItemsForMonth(all, _year, _month)
                  .where((i) => i.type == PlanItemType.fixedCost)
                  .toList()
              : BudgetCalculator.activeItemsForYear(all, _year)
                  .where((i) => i.type == PlanItemType.fixedCost)
                  .toList();
          final guardStateMap = {
            for (final item in fixedCostCandidates)
              item.seriesId:
                  widget.repositories.guard.itemStateForPeriod(item, viewPeriod)
          };
          final unpaidActive =
              widget.repositories.guard.unpaidActiveItems(all, now);
          final allUnresolved =
              widget.repositories.guard.allUnresolvedItems(all, now);
          final unpaidActiveKeys = {
            for (final p in unpaidActive) '${p.$1.seriesId}|${p.$2}'
          };
          final silenced = allUnresolved
              .where((pair) =>
                  !unpaidActiveKeys
                      .contains('${pair.$1.seriesId}|${pair.$2}'))
              .toList();

          final reportLines = _isMonthly
              ? widget.repositories.finance.reportLinesForMonth(_year, _month)
              : widget.repositories.finance.reportLinesForYear(_year);

          final snapshot = PlanSnapshotBuilder.build(
            allItems: all,
            reportLines: reportLines,
            period: viewPeriod,
            isMonthly: _isMonthly,
            guardStateMap: guardStateMap,
            unpaidActive: unpaidActive,
            silenced: silenced,
          );

          return Column(
            children: [
              _buildPeriodNavigator(),
              _buildModeToggle(),
              GuardBanner(
                unpaidActive: snapshot.unpaidActive,
                silenced: snapshot.silenced,
                onMarkPaid: (seriesId, period) =>
                    widget.repositories.guard.confirmPayment(seriesId, period),
                onSilence: _onSilenceRequested,
                onTapItem: (item, _) => _expandToItem(item),
              ),
              _buildSummaryCard(snapshot.spendable),
              const Divider(height: 1),
              Expanded(
                child: snapshot.incomeItems.isEmpty &&
                        snapshot.fixedCostItems.isEmpty
                    ? _buildEmptyState()
                    : _buildPlanHierarchy(context, snapshot, all),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        PeriodNavigator(
          selected: widget.selectedPeriod.value,
          yearOnly: !_isMonthly,
          min: bounds.min,
          max: bounds.max,
          onChanged: (ym) => setState(() {
            widget.selectedPeriod.value = ym;
          }),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'How it works',
              onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexPlan),
              style: IconButton.styleFrom(foregroundColor: AppColors.gold),
            ),
          ),
        ),
      ],
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('No plan items yet.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Tap + to add income or fixed costs.',
              style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexPlan),
            icon: const Icon(Icons.help_outline, size: 16),
            label: const Text('How it works?'),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHierarchy(
    BuildContext context,
    PlanSnapshot snapshot,
    List<PlanItem> allItems,
  ) {
    // Precompute yearly amounts once so itemYearlyContribution is not called
    // per tile during rendering. Empty in monthly mode.
    final yearlyAmounts = !_isMonthly
        ? {
            for (final item in [
              ...snapshot.incomeItems,
              ...snapshot.fixedCostItems
            ])
              item.id: BudgetCalculator.itemYearlyContribution(
                  item, allItems, _year)
          }
        : const <String, double>{};

    return ListView(
      children: [
        PlanIncomeSummaryTile(
          total: snapshot.totalIncome,
          count: snapshot.incomeItems.length,
          isExpanded: _incomeExpanded,
          onTap: snapshot.incomeItems.isNotEmpty
              ? () => setState(() => _incomeExpanded = !_incomeExpanded)
              : null,
        ),
        if (_incomeExpanded)
          ...snapshot.incomeItems.map((item) => PlanItemTile(
                item: item,
                displayAmount: _displayAmount(item, yearlyAmounts),
                onTap: () => _openDetail(context, item),
                onEdit: () => _navigateToEdit(context, item),
                onDelete: () => _confirmAndDelete(context, item),
              )),
        const Divider(height: 1),
        PlanFixedCostsSummaryTile(
          total: snapshot.totalFixedCosts,
          count: snapshot.fixedCostItems.length,
          isExpanded: _fixedCostsExpanded,
          onTap: snapshot.fixedCostItems.isNotEmpty
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
          PlanFixedCostsHierarchy(
            snapshot: snapshot,
            allItems: allItems,
            yearlyAmounts: yearlyAmounts,
            expandedFinancialType: _expandedFinancialType,
            expandedCategory: _expandedCategory,
            highlightedSeriesId: _highlight.highlightedSeriesId,
            highlightKey: _highlight.highlightKey,
            onTypeExpanded: (ft) => setState(() {
              _expandedFinancialType = ft;
              if (ft == null) _expandedCategory = null;
            }),
            onCategoryExpanded: (cat) =>
                setState(() => _expandedCategory = cat),
            onTap: (item) => _openDetail(context, item),
            onEdit: (item) => _navigateToEdit(context, item),
            onDelete: (item) => _confirmAndDelete(context, item),
            onGuard: (item) => GuardSetupSheet.show(
              context,
              item: item,
              planRepository: widget.repositories.plan,
            ),
          ),
        FinancialTypeDistributionCard(
            ratio: snapshot.financialTypeRatio, isMonthly: _isMonthly),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ── _PlanHighlightManager ──────────────────────────────────────────────────
//
// Coordinates the highlight-and-scroll animation for GuardBanner taps.
// Owned by _PlanScreenState as a plain field; not a widget.

class _PlanHighlightManager {
  /// The seriesId of the currently highlighted item, or null if none.
  String? highlightedSeriesId;

  /// Key assigned to the highlighted PlanItemTile, used to scroll to it.
  final GlobalKey highlightKey = GlobalKey();

  /// Marks [item] as highlighted, calls [onExpand] to open the accordion,
  /// schedules a scroll to the highlighted tile, and clears the highlight
  /// after 2 seconds by calling [onClear].
  void trigger(
    PlanItem item, {
    required void Function({
      required FinancialType financialType,
      required ExpenseCategory? category,
    }) onExpand,
    required VoidCallback onClear,
  }) {
    highlightedSeriesId = item.seriesId;
    final ft = item.financialType ?? FinancialType.consumption;
    onExpand(
      financialType: ft,
      category: ft == FinancialType.consumption ? item.category : null,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = highlightKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.3,
        );
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      highlightedSeriesId = null;
      onClear();
    });
  }
}
