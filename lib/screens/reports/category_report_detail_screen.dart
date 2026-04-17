import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/expense.dart';
import '../../models/expense_category.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/currency_formatter.dart';
import '../../services/finance_repository.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/expense_list_tile.dart';
import '../../widgets/plan_item_tile.dart';
import '../../widgets/swipeable_tile.dart';
import '../add_expense_screen.dart';
import '../expense_detail_screen.dart';
import '../plan/add_plan_item_screen.dart';
import '../plan/plan_item_detail_screen.dart';

/// Drill-down from the Reports tab for a single [category] and period.
///
/// Shows active fixed costs and actual expenses in separate sections.
/// Both source types are individually editable and navigable, consistent
/// with the rest of the app.
class CategoryReportDetailScreen extends StatefulWidget {
  final ExpenseCategory category;
  final int year;

  /// Month number (1–12) for monthly mode. Null for yearly mode.
  final int? month;

  final FinanceRepository repository;
  final PlanRepository planRepository;

  const CategoryReportDetailScreen({
    super.key,
    required this.category,
    required this.year,
    this.month,
    required this.repository,
    required this.planRepository,
  });

  @override
  State<CategoryReportDetailScreen> createState() =>
      _CategoryReportDetailScreenState();
}

class _CategoryReportDetailScreenState
    extends State<CategoryReportDetailScreen> {
  bool get _isYearly => widget.month == null;

  String get _periodLabel => _isYearly
      ? '${widget.year}'
      : '${context.l10n.monthName(widget.month!)} ${widget.year}';

  // ── Data helpers ──────────────────────────────────────────────────────────

  List<PlanItem> _fixedCosts() {
    final all = widget.planRepository.items;
    final items = _isYearly
        ? BudgetCalculator.activeItemsForYear(all, widget.year)
        : BudgetCalculator.activeItemsForMonth(all, widget.year, widget.month!);
    return items
        .where((i) =>
            i.type == PlanItemType.fixedCost &&
            (i.category ?? ExpenseCategory.other) == widget.category)
        .toList();
  }

  double _fixedCostAmount(PlanItem item) {
    final all = widget.planRepository.items;
    return _isYearly
        ? BudgetCalculator.itemYearlyContribution(item, all, widget.year)
        : BudgetCalculator.itemMonthlyContribution(
            item, widget.year, widget.month!);
  }

  List<Expense> _expenses() {
    final raw = _isYearly
        ? widget.repository.expensesForYear(widget.year)
        : widget.repository.expensesForMonth(widget.year, widget.month!);
    return raw
        .where((e) => e.category == widget.category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.categoryName(widget.category)),
            Text(
              _periodLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: AppColors.gold,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable:
            Listenable.merge([widget.repository, widget.planRepository]),
        builder: (context, _) {
          final fixedCosts = _fixedCosts();
          final expenses = _expenses();

          final fixedCostTotal =
              fixedCosts.fold(0.0, (s, i) => s + _fixedCostAmount(i));
          final expenseTotal =
              expenses.fold(0.0, (s, e) => s + e.amount);
          final grandTotal = fixedCostTotal + expenseTotal;
          final itemCount = fixedCosts.length + expenses.length;

          return Column(
            children: [
              _buildHeader(grandTotal, itemCount, fixedCosts.length),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionHeader(context.l10n.reportSectionFixedCosts),
                    if (fixedCosts.isEmpty)
                      _buildEmptySectionRow()
                    else
                      ...fixedCosts.map(
                        (item) => _buildFixedCostItem(context, item),
                      ),
                    const Divider(height: 1),
                    _buildSectionHeader(
                      context.l10n.reportSectionExpenses,
                      trailing: expenses.isEmpty
                          ? null
                          : '${expenses.length} · '
                              '${CurrencyFormatter.format(expenseTotal)}',
                    ),
                    if (expenses.isEmpty)
                      _buildEmptySectionRow()
                    else
                      ...expenses.map(
                        (expense) => _buildExpenseItem(context, expense),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(double total, int itemCount, int fixedCostCount) {
    final expenseCount = itemCount - fixedCostCount;
    final parts = <String>[
      if (fixedCostCount > 0) context.l10n.fixedCostCount(fixedCostCount),
      if (expenseCount > 0) context.l10n.expenseCount(expenseCount),
    ];
    final subtitle =
        parts.isEmpty ? context.l10n.noItemsInPeriod : parts.join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: widget.category.color.withAlpha(30),
            child: Icon(
              widget.category.icon,
              size: 20,
              color: widget.category.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section headers ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String label, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptySectionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        context.l10n.noneInPeriod,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 14,
        ),
      ),
    );
  }

  // ── Fixed cost items ──────────────────────────────────────────────────────

  Widget _buildFixedCostItem(BuildContext context, PlanItem item) {
    // PlanItemTile already wraps SwipeableTile internally — do not double-wrap.
    return PlanItemTile(
      item: item,
      displayAmount: _fixedCostAmount(item),
      onDelete: () => widget.planRepository.removePlanItem(item.id),
      onEdit: () => _navigateToPlanItemEdit(context, item),
      onTap: () => _openPlanItemDetail(context, item),
    );
  }

  void _openPlanItemDetail(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => PlanItemDetailScreen(
        item: item,
        period: YearMonth(widget.year, widget.month ?? 1),
        onEdit: () {
          Navigator.of(routeContext).pop();
          _navigateToPlanItemEdit(context, item);
        },
        onDelete: () {
          Navigator.of(routeContext).pop();
          widget.planRepository.removePlanItem(item.id);
        },
      ),
    ));
  }

  void _navigateToPlanItemEdit(BuildContext context, PlanItem item) {
    final validFrom = widget.month != null
        ? YearMonth(widget.year, widget.month!)
        : YearMonth(widget.year, DateTime.now().month);

    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.planRepository,
        existing: item,
        initialValidFrom: validFrom,
      ),
    ));
  }

  // ── Expense items ─────────────────────────────────────────────────────────

  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    return SwipeableTile(
      itemId: expense.id,
      onDelete: () => widget.repository.removeExpense(expense.id),
      onEdit: () => _navigateToExpenseEdit(context, expense),
      child: ExpenseListTile(
        expense: expense,
        onTap: () => _openExpenseDetail(context, expense),
      ),
    );
  }

  void _openExpenseDetail(BuildContext context, Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => ExpenseDetailScreen(
        expense: expense,
        onEdit: () {
          Navigator.of(routeContext).pop();
          _navigateToExpenseEdit(context, expense);
        },
        onDelete: () {
          Navigator.of(routeContext).pop();
          widget.repository.removeExpense(expense.id);
        },
      ),
    ));
  }

  void _navigateToExpenseEdit(BuildContext context, Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddExpenseScreen(
        repository: widget.repository,
        existing: expense,
      ),
    ));
  }
}
