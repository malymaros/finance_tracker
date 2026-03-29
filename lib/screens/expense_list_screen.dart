import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/period_bounds.dart';
import '../models/year_month.dart';
import '../services/budget_calculator.dart';
import '../services/category_budget_repository.dart';
import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
import '../services/import_export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/category_budget_warning_card.dart';
import '../widgets/expense_category_group.dart';
import '../widgets/expense_group_tile.dart';
import '../widgets/expense_list_tile.dart';
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
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final CategoryBudgetRepository budgetRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  const ExpenseListScreen({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.budgetRepository,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onClearAll,
    required this.onOpenSaves,
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
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'import_expenses', child: Text('Import Expenses')),
        const PopupMenuItem(value: 'export_expenses', child: Text('Export Expenses')),
      ],
    );
  }

  void _navigateToImport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImportScreen(repository: widget.repository),
      ),
    );
  }

  Future<void> _handleExport() async {
    final range = await ExportDateRangeDialog.show(context);
    if (range == null || !mounted) return;

    try {
      final bytes = await ImportExportService.exportExpenses(
        widget.repository.expenses,
        range.start,
        range.end,
      );

      final dir = await getTemporaryDirectory();
      final s = range.start;
      final e = range.end;
      final tag =
          '${s.year}${s.month.toString().padLeft(2, '0')}${s.day.toString().padLeft(2, '0')}'
          '_${e.year}${e.month.toString().padLeft(2, '0')}${e.day.toString().padLeft(2, '0')}';
      final file = File('${dir.path}/expenses_$tag.xlsx');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: ImportExportService.xlsxMimeType)],
        subject: 'Expenses Export',
      );
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
      listenable: Listenable.merge(
          [widget.repository, widget.planRepository, widget.budgetRepository]),
      builder: (context, _) {
        final monthExpenses = widget.repository.expensesForMonth(_year, _month)
          ..sort((a, b) => b.date.compareTo(a.date));

        final actualSpent =
            monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

        final budgetStatus = BudgetCalculator.budgetStatus(
          widget.planRepository.items,
          actualSpent,
          _year,
          _month,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Expenses'),
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.save_outlined),
              tooltip: 'Saves',
              onPressed: widget.onOpenSaves,
            ),
            actions: [
              _buildOverflowMenu(),
            ],
          ),
          body: Column(
            children: [
              _buildMonthNavigator(),
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

  Widget _buildMonthNavigator() {
    final bounds = widget.periodBounds.value;
    return PeriodNavigator(
      selected: widget.selectedPeriod.value,
      yearOnly: false,
      min: bounds.min,
      max: bounds.max,
      onChanged: (ym) => setState(() {
        widget.selectedPeriod.value = ym;
      }),
    );
  }

  // ── Budget widget ──────────────────────────────────────────────────────────

  Widget _buildBudgetWidget(
      BudgetStatus? status, bool isCurrentMonth, bool isPastMonth) {
    if (!isPastMonth) {
      // current month or future: show progress bar if plan exists
      return status != null
          ? BudgetProgressBar(status: status)
          : const SizedBox.shrink();
    }
    // past month
    if (status != null) return MonthBudgetSummary(status: status);
    return _buildNoBudgetHint();
  }

  Widget _buildNoBudgetHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: const [
          Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'No budget set for this month — add items in the Plan tab.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ── View toggle ────────────────────────────────────────────────────────────

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SegmentedButton<_ViewMode>(
        segments: const [
          ButtonSegment(
            value: _ViewMode.items,
            label: Text('Items'),
            icon: Icon(Icons.list),
          ),
          ButtonSegment(
            value: _ViewMode.byCategory,
            label: Text('Category'),
            icon: Icon(Icons.category_outlined),
          ),
          ButtonSegment(
            value: _ViewMode.byGroup,
            label: Text('Groups'),
            icon: Icon(Icons.folder_outlined),
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
            'No expenses in ${YearMonth.monthNames[_month]} $_year.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add one.',
            style: TextStyle(color: AppColors.textMuted),
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
          onDelete: () => widget.repository.removeExpense(expense.id),
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
          widget.repository.removeExpense(expense.id);
        },
      ),
    ));
  }

  // ── Category budget warnings (items mode) ─────────────────────────────────

  Widget _buildCategoryBudgetWarning(List<Expense> monthExpenses) {
    final period = YearMonth(_year, _month);
    final budgets = widget.budgetRepository.allActiveBudgetsForMonth(period);
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
        widget.budgetRepository.allActiveBudgetsForMonth(period);

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
          repository: widget.repository,
        ),
      ),
    );
  }

  // ── Mode C: grouped by user-defined group ──────────────────────────────────

  Widget _buildGroupList(List<Expense> monthExpenses) {
    if (!monthExpenses.any((e) => e.group != null)) {
      final hasAnyGroups =
          widget.repository.expenses.any((e) => e.group != null);
      return hasAnyGroups ? _buildNoGroupExpensesState() : _buildNoGroupsState();
    }

    final summaries =
        widget.repository.groupSummariesForMonth(_year, _month);

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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_outlined, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No groups yet.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Add a group when creating\nor editing an expense.',
            style: TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoGroupExpensesState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No group expenses in\n${YearMonth.monthNames[_month]} $_year.',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            textAlign: TextAlign.center,
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
          repository: widget.repository,
        ),
      ),
    );
  }

  void _navigateToAdd(BuildContext context, DateTime initialDate) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          repository: widget.repository,
          initialDate: initialDate,
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          repository: widget.repository,
          existing: expense,
        ),
      ),
    );
  }
}
