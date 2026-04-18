import 'package:flutter/material.dart';

import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/period_bounds.dart';
import '../models/year_month.dart';
import '../services/app_repositories.dart';
import '../services/budget_calculator.dart';
import '../services/import_export_service.dart';
import '../services/share_service.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/category_budget_warning_card.dart';
import '../widgets/guard_expense_strip.dart';
import '../widgets/expense_category_group.dart';
import '../widgets/expense_group_tile.dart';
import '../widgets/expense_list_tile.dart';
import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/how_groups_work_sheet.dart';
import '../widgets/how_it_works_sheet.dart';
import '../widgets/month_budget_summary.dart';
import '../widgets/period_navigator.dart';
import '../widgets/export_date_range_dialog.dart';
import '../widgets/swipeable_tile.dart';
import 'add_expense_screen.dart';
import 'import_screen.dart';
import 'category_expense_list_screen.dart';
import 'expense_detail_screen.dart';
import 'group_expense_list_screen.dart';
enum _ViewMode { items, byCategory, byGroup }

class ExpenseListScreen extends StatefulWidget {
  final AppRepositories repositories;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  /// Called when the user taps the GUARD strip to switch to the Plan tab.
  final VoidCallback? onSwitchToPlanTab;

  const ExpenseListScreen({
    super.key,
    required this.repositories,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onClearAll,
    required this.onOpenSaves,
    this.onSwitchToPlanTab,
  });

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int get _year => widget.selectedPeriod.value.year;
  int get _month => widget.selectedPeriod.value.month;
  _ViewMode _mode = _ViewMode.items;

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

  /// Computes the budget status for [monthExpenses] against the active plan
  /// for the current [_year]/[_month]. Returns null when no income is planned.
  BudgetStatus? _computeBudgetStatus(List<Expense> monthExpenses) {
    final actualSpent =
        monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    return BudgetCalculator.budgetStatus(
      widget.repositories.plan.items,
      actualSpent,
      _year,
      _month,
    );
  }

  bool _isCurrentMonth(DateTime now) =>
      _year == now.year && _month == now.month;

  bool _isPastMonth(DateTime now) =>
      DateTime(_year, _month).isBefore(DateTime(now.year, now.month));

  /// Returns today for the current month, last day of the selected month for past months.
  DateTime _addExpenseInitialDate(DateTime now) {
    if (_isCurrentMonth(now)) return now;
    return DateTime(_year, _month + 1, 0); // last day of _month
  }

  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'import_expenses') _navigateToImport();
        if (value == 'export_expenses') _handleExport();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(value: 'import_expenses', child: Text(ctx.l10n.menuImportExpenses)),
        PopupMenuItem(value: 'export_expenses', child: Text(ctx.l10n.menuExportExpenses)),
      ],
    );
  }

  void _navigateToImport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImportScreen(repository: widget.repositories.finance),
      ),
    );
  }

  Future<void> _handleExport() async {
    final range = await ExportDateRangeDialog.show(context);
    if (range == null || !mounted) return;

    try {
      final bytes = await ImportExportService.exportExpenses(
        widget.repositories.finance.expenses,
        range.start,
        range.end,
      );

      final s = range.start;
      final e = range.end;
      final tag =
          '${s.year}${s.month.toString().padLeft(2, '0')}${s.day.toString().padLeft(2, '0')}'
          '_${e.year}${e.month.toString().padLeft(2, '0')}${e.day.toString().padLeft(2, '0')}';
      await ShareService.shareXlsx(bytes, 'expenses_$tag.xlsx');
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $err')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _isCurrentMonth(now);
    final isPastMonth = _isPastMonth(now);

    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.repositories.finance,
        widget.repositories.plan,
        widget.repositories.budget,
        widget.repositories.guard,
      ]),
      builder: (context, _) {
        final monthExpenses = widget.repositories.finance.expensesForMonth(_year, _month)
          ..sort((a, b) => b.date.compareTo(a.date));

        final budgetStatus = _computeBudgetStatus(monthExpenses);

        final unpaidGuardCount = widget.repositories.guard
            .unpaidActiveItems(widget.repositories.plan.items, YearMonth.now())
            .length;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.expenseListTitle),
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: context.l10n.savesTooltip,
              onPressed: widget.onOpenSaves,
            ),
            actions: [
              _buildOverflowMenu(),
            ],
          ),
          body: Column(
            children: [
              _buildMonthNavigatorRow(),
              _buildGuardStrip(unpaidGuardCount),
              _buildBudgetWidget(budgetStatus, isCurrentMonth, isPastMonth),
              _buildViewToggle(),
              const Divider(height: 1),
              if (_mode == _ViewMode.items)
                _buildCategoryBudgetWarning(monthExpenses),
              Expanded(
                child: _mode == _ViewMode.byGroup
                    ? _buildGroupList(monthExpenses)
                    : monthExpenses.isEmpty
                        ? _buildEmptyState()
                        : _mode == _ViewMode.items
                            ? _buildItemsList(context, monthExpenses)
                            : _buildCategoryList(monthExpenses),
              ),
            ],
          ),
          floatingActionButton: Opacity(
            opacity: 0.6,
            child: FloatingActionButton(
              onPressed: () =>
                  _navigateToAdd(context, _addExpenseInitialDate(now)),
              tooltip: 'Add Expense',
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  // ── Month navigator ────────────────────────────────────────────────────────

  /// Period navigator with the [?] help button overlaid on the right.
  Widget _buildMonthNavigatorRow() {
    final bounds = widget.periodBounds.value;
    return Stack(
      alignment: Alignment.center,
      children: [
        PeriodNavigator(
          selected: widget.selectedPeriod.value,
          yearOnly: false,
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
              tooltip: context.l10n.howItWorksTooltip,
              onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexExpenses),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.gold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── GUARD strip ───────────────────────────────────────────────────────────

  Widget _buildGuardStrip(int unpaidCount) {
    if (unpaidCount == 0) return const SizedBox.shrink();
    return GuardExpenseStrip(
      unpaidCount: unpaidCount,
      onTap: widget.onSwitchToPlanTab ?? () {},
    );
  }

  // ── Budget widget ──────────────────────────────────────────────────────────

  Widget _buildBudgetWidget(
      BudgetStatus? status, bool isCurrentMonth, bool isPastMonth) {
    if (isPastMonth) {
      return status != null
          ? MonthBudgetSummary(status: status)
          : _buildNoBudgetCard();
    }
    // current month or future
    return status != null
        ? BudgetProgressBar(status: status)
        : _buildNoBudgetCard();
  }

  Widget _buildNoBudgetCard() {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onSwitchToPlanTab,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.thisMonthsBudget,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.budgetNotSet,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.setIncomeInPlan,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.navy),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── View toggle ────────────────────────────────────────────────────────────

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SegmentedButton<_ViewMode>(
        segments: [
          ButtonSegment(
            value: _ViewMode.items,
            label: Text(context.l10n.viewModeItems),
            icon: const Icon(Icons.list),
          ),
          ButtonSegment(
            value: _ViewMode.byCategory,
            label: Text(context.l10n.viewModeByCategory),
            icon: const Icon(Icons.category_outlined),
          ),
          ButtonSegment(
            value: _ViewMode.byGroup,
            label: Text(context.l10n.viewModeByGroup),
            icon: const Icon(Icons.folder_outlined),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() => _mode = s.first),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExpensesInMonth(context.l10n.monthName(_month), _year),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapPlusToAddOne,
            style: const TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.fixedBillsHint,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexExpenses),
            icon: const Icon(Icons.help_outline, size: 16),
            label: Text(context.l10n.howItWorksQuestion),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }

  // ── Mode A: individual items ───────────────────────────────────────────────

  Widget _buildItemsList(BuildContext context, List<Expense> expenses) {
    return ListView.separated(
      itemCount: expenses.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final expense = expenses[i];
        return SwipeableTile(
          itemId: expense.id,
          onDelete: () => widget.repositories.finance.removeExpense(expense.id),
          onEdit: () => _navigateToEdit(context, expense),
          child: ExpenseListTile(
            expense: expense,
            onTap: () => _openDetail(context, expense),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => ExpenseDetailScreen(
        expense: expense,
        onEdit: () {
          Navigator.of(routeContext).pop();
          _navigateToEdit(context, expense);
        },
        onDelete: () {
          Navigator.of(routeContext).pop();
          widget.repositories.finance.removeExpense(expense.id);
        },
      ),
    ));
  }

  // ── Category budget warnings (items mode) ─────────────────────────────────

  Widget _buildCategoryBudgetWarning(List<Expense> monthExpenses) {
    final period = YearMonth(_year, _month);
    final budgets = widget.repositories.budget.allActiveBudgetsForMonth(period);
    final overages = BudgetCalculator.categoryOverages(monthExpenses, budgets);
    return CategoryBudgetWarningCard(overages: overages);
  }

  // ── Mode B: grouped by category ───────────────────────────────────────────

  static List<MapEntry<ExpenseCategory, List<Expense>>> _groupedByCategory(
      List<Expense> expenses) {
    final groups = <ExpenseCategory, List<Expense>>{};
    for (final e in expenses) {
      groups.putIfAbsent(e.category, () => []).add(e);
    }
    return groups.entries.toList()
      ..sort((a, b) {
        final ta = a.value.fold(0.0, (s, e) => s + e.amount);
        final tb = b.value.fold(0.0, (s, e) => s + e.amount);
        return tb.compareTo(ta);
      });
  }

  Widget _buildCategoryList(List<Expense> expenses) {
    final sorted = _groupedByCategory(expenses);
    final period = YearMonth(_year, _month);
    final budgets =
        widget.repositories.budget.allActiveBudgetsForMonth(period);

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => ExpenseCategoryGroup(
        category: sorted[i].key,
        expenses: sorted[i].value,
        budget: budgets[sorted[i].key],
        onTap: () => _navigateToCategoryDetail(context, sorted[i].key),
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _navigateToCategoryDetail(
      BuildContext context, ExpenseCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryExpenseListScreen(
          category: category,
          period: widget.selectedPeriod.value,
          repository: widget.repositories.finance,
        ),
      ),
    );
  }

  // ── Mode C: grouped by user-defined group ──────────────────────────────────

  Widget _buildGroupList(List<Expense> monthExpenses) {
    if (!monthExpenses.any((e) => e.group != null)) {
      return _buildNoGroupsState();
    }

    final summaries =
        widget.repositories.finance.groupSummariesForMonth(_year, _month);

    return ListView.separated(
      itemCount: summaries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => ExpenseGroupTile(
        groupName: summaries[i].key,
        expenses: summaries[i].value,
        onTap: () => _navigateToGroupDetail(summaries[i].key),
      ),
    );
  }

  Widget _buildNoGroupsState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            context.l10n.noGroupsThisMonth,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.addGroupHint,
            style: const TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => HowGroupsWorkSheet.show(context),
            icon: const Icon(Icons.folder_outlined, size: 16),
            label: Text(context.l10n.howGroupsWorkQuestion),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }


  void _navigateToGroupDetail(String groupName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupExpenseListScreen(
          groupName: groupName,
          repository: widget.repositories.finance,
        ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context, DateTime initialDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          repository: widget.repositories.finance,
          initialDate: initialDate,
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          repository: widget.repositories.finance,
          existing: expense,
        ),
      ),
    );
  }
}
