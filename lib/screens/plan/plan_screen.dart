import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type_income_ratio.dart';
import '../../models/period_bounds.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/finance_repository.dart';
import '../../services/plan_repository.dart';
import '../../services/report_aggregator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/financial_type_distribution_card.dart';
import '../../widgets/period_navigator.dart';
import '../../widgets/plan_category_tile.dart';
import '../../widgets/plan_fixed_costs_summary_tile.dart';
import '../../widgets/plan_income_summary_tile.dart';
import '../../widgets/plan_item_tile.dart';
import 'add_plan_item_screen.dart';
import 'plan_category_detail_screen.dart';
import 'plan_item_detail_screen.dart';

class PlanScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  const PlanScreen({
    super.key,
    required this.repository,
    required this.planRepository,
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

  void _onPeriodChanged() => setState(() {});

  double _displayAmount(PlanItem item) {
    final all = widget.planRepository.items;
    return _isMonthly
        ? BudgetCalculator.itemMonthlyContribution(item, _year, _month)
        : BudgetCalculator.itemYearlyContribution(item, all, _year);
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.planRepository,
        initialValidFrom: widget.selectedPeriod.value,
      ),
    ));
  }

  void _navigateToEdit(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.planRepository,
        existing: item,
        initialValidFrom: widget.selectedPeriod.value,
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
    final from = widget.selectedPeriod.value;
    final isFullDelete = item.validFrom == from;

    final String message;
    if (isFullDelete) {
      message = '"${item.name}" will be removed entirely.';
    } else {
      final fromLabel =
          '${YearMonth.monthNames[from.month]} ${from.year}';
      final prevMonth = from.addMonths(-1);
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
      widget.planRepository.removePlanItemFrom(item.id, from);
    }
  }

  void _navigateToCategoryDetail(
      BuildContext context, ExpenseCategory category) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PlanCategoryDetailScreen(
        title: category.displayName,
        categoryFilter: category,
        selectedPeriod: widget.selectedPeriod.value,
        isMonthly: _isMonthly,
        planRepository: widget.planRepository,
      ),
    ));
  }

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
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([widget.repository, widget.planRepository]),
        builder: (context, _) {
          final all = widget.planRepository.items;

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
          final categoryTotals = BudgetCalculator.planCategoryTotals(
            fixedCostItems, all, _year, _month, _isMonthly,
          );

          // Compute merged lines for financial type ratios.
          final mergedLines = _isMonthly
              ? ReportAggregator.mergedLines(
                  widget.repository.reportLinesForMonth(_year, _month),
                  BudgetCalculator.planFixedCostReportLinesForMonth(
                      all, _year, _month),
                )
              : ReportAggregator.mergedLines(
                  widget.repository.reportLinesForYear(_year),
                  BudgetCalculator.planFixedCostReportLinesForYear(all, _year),
                );
          final ratio = BudgetCalculator.financialTypeIncomeRatios(
              mergedLines, totalIncome);

          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              _buildSummaryCard(spendable),
              const Divider(height: 1),
              Expanded(
                child: displayItems.isEmpty
                    ? _buildEmptyState()
                    : _buildPlanHierarchy(
                        context,
                        incomeItems,
                        fixedCostItems,
                        categoryTotals,
                        totalIncome,
                        totalFixedCosts,
                        ratio,
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Opacity(
        opacity: 0.6,
        child: FloatingActionButton(
          onPressed: () => _navigateToAdd(context),
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
        onSelectionChanged: (s) => setState(() => _isMonthly = s.first),
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
    Map<ExpenseCategory, ({double total, int count})> categoryTotals,
    double totalIncome,
    double totalFixedCosts,
    FinancialTypeIncomeRatio ratio,
  ) {
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
                displayAmount: _displayAmount(item),
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
              ? () => setState(() => _fixedCostsExpanded = !_fixedCostsExpanded)
              : null,
        ),
        if (_fixedCostsExpanded)
          ...categoryTotals.entries.map((entry) => PlanCategoryTile(
                category: entry.key,
                total: entry.value.total,
                count: entry.value.count,
                onTap: () => _navigateToCategoryDetail(context, entry.key),
              )),
        FinancialTypeDistributionCard(ratio: ratio, isMonthly: _isMonthly),
        const SizedBox(height: 80),
      ],
    );
  }
}
