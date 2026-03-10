import 'package:flutter/material.dart';

import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/period_bounds.dart';
import '../models/year_month.dart';
import '../services/budget_calculator.dart';
import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/expense_category_group.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/month_budget_summary.dart';
import '../widgets/period_navigator.dart';
import '../widgets/swipeable_tile.dart';
import 'add_expense_screen.dart';

enum _ViewMode { items, byCategory }

class ExpenseListScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  const ExpenseListScreen({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onClearAll,
    required this.onOpenSaves,
  });

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

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
        if (value == 'saves') widget.onOpenSaves();
        if (value == 'clear_all') widget.onClearAll();
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'saves', child: Text('Saves')),
        PopupMenuItem(value: 'clear_all', child: Text('Delete all data')),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _isCurrentMonth(now);
    final isPastMonth = _isPastMonth(now);

    return ListenableBuilder(
      listenable: Listenable.merge([widget.repository, widget.planRepository]),
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
            actions: [_buildOverflowMenu()],
          ),
          body: Column(
            children: [
              _buildMonthNavigator(),
              _buildBudgetWidget(budgetStatus, isCurrentMonth, isPastMonth),
              _buildViewToggle(),
              const Divider(height: 1),
              Expanded(
                child: monthExpenses.isEmpty
                    ? _buildEmptyState()
                    : _mode == _ViewMode.items
                        ? _buildItemsList(context, monthExpenses)
                        : _buildCategoryList(monthExpenses),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                _navigateToAdd(context, _addExpenseInitialDate(now)),
            tooltip: 'Add Expense',
            child: const Icon(Icons.add),
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
          Icon(Icons.info_outline, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'No budget set for this month — add items in the Plan tab.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
            label: Text('By Category'),
            icon: Icon(Icons.category_outlined),
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
          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No expenses in ${_monthNames[_month]} $_year.',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to add one.',
            style: TextStyle(color: Colors.grey),
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
      itemBuilder: (_, i) => SwipeableTile(
        itemId: expenses[i].id,
        onDelete: () => widget.repository.removeExpense(expenses[i].id),
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(
              repository: widget.repository,
              existing: expenses[i],
            ),
          ),
        ),
        child: ExpenseListTile(expense: expenses[i]),
      ),
    );
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
    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => ExpenseCategoryGroup(
        category: sorted[i].key,
        expenses: sorted[i].value,
      ),
    );
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

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
}
