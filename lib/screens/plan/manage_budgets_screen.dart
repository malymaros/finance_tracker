import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/year_month.dart';
import '../../services/category_budget_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_budget_tile.dart';
import '../../widgets/period_navigator.dart';
import 'add_category_budget_screen.dart';

class ManageBudgetsScreen extends StatefulWidget {
  final CategoryBudgetRepository budgetRepository;

  const ManageBudgetsScreen({
    super.key,
    required this.budgetRepository,
  });

  @override
  State<ManageBudgetsScreen> createState() => _ManageBudgetsScreenState();
}

class _ManageBudgetsScreenState extends State<ManageBudgetsScreen> {
  bool _isMonthly = true;
  late YearMonth _selectedPeriod;

  // Navigation bounds: ±2 years from today.
  late final YearMonth _min;
  late final YearMonth _max;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = YearMonth.now();
    final now = YearMonth.now();
    _min = YearMonth(now.year - 2, 1);
    _max = YearMonth(now.year + 2, 12);
  }

  void _navigateToAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCategoryBudgetScreen(
          budgetRepository: widget.budgetRepository,
          initialValidFrom: _selectedPeriod,
        ),
      ),
    );
  }

  void _navigateToEdit({
    required ExpenseCategory category,
    required String seriesId,
    required double currentAmount,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCategoryBudgetScreen(
          budgetRepository: widget.budgetRepository,
          initialCategory: category,
          initialAmount: currentAmount,
          initialValidFrom: YearMonth.now(),
          seriesId: seriesId,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      String seriesId, String categoryName) async {
    final now = YearMonth.now();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove budget'),
        content: Text(
          'The $categoryName budget will stop from '
          '${YearMonth.monthNames[now.month]} ${now.year} onwards. '
          'Earlier months will keep their historical budget.',
        ),
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

    if (confirmed == true && mounted) {
      await widget.budgetRepository.endCategoryBudget(seriesId, now);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Budgets'),
        scrolledUnderElevation: 0,
      ),
      body: ListenableBuilder(
        listenable: widget.budgetRepository,
        builder: (context, _) {
          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              const Divider(height: 1),
              Expanded(
                child: _isMonthly
                    ? _buildMonthlyContent()
                    : _buildYearlyContent(),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _isMonthly
          ? FloatingActionButton(
              onPressed: _navigateToAdd,
              tooltip: 'Add budget',
              child: const Icon(Icons.add),
            )
          : null,
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
    return PeriodNavigator(
      selected: _selectedPeriod,
      yearOnly: !_isMonthly,
      min: _min,
      max: _max,
      onChanged: (ym) => setState(() => _selectedPeriod = ym),
    );
  }

  Widget _buildMonthlyContent() {
    final activeBudgets =
        widget.budgetRepository.allActiveBudgetsForMonth(_selectedPeriod);

    if (activeBudgets.isEmpty) return _buildEmptyState();

    final entries = activeBudgets.entries.toList()
      ..sort((a, b) {
        if (a.key == ExpenseCategory.other) return 1;
        if (b.key == ExpenseCategory.other) return -1;
        return a.key.displayName.compareTo(b.key.displayName);
      });

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final category = entries[i].key;
        final amount = entries[i].value;
        final record = widget.budgetRepository
            .activeBudgetRecordForMonth(category, _selectedPeriod);
        if (record == null) return const SizedBox.shrink();
        return CategoryBudgetTile(
          budget: record,
          onEdit: () => _navigateToEdit(
            category: category,
            seriesId: record.seriesId,
            currentAmount: amount,
          ),
          onDelete: () =>
              _confirmDelete(record.seriesId, category.displayName),
        );
      },
    );
  }

  Widget _buildYearlyContent() {
    final yearlyTotals =
        widget.budgetRepository.allYearlyTotals(_selectedPeriod.year);

    if (yearlyTotals.isEmpty) return _buildEmptyState();

    final entries = yearlyTotals.entries.toList()
      ..sort((a, b) {
        if (a.key == ExpenseCategory.other) return 1;
        if (b.key == ExpenseCategory.other) return -1;
        return a.key.displayName.compareTo(b.key.displayName);
      });

    return ListView.separated(
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final cat = entries[i].key;
        final total = entries[i].value;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: cat.color.withAlpha(30),
            child: Icon(cat.icon, size: 20, color: cat.color),
          ),
          title: Text(cat.displayName),
          subtitle: const Text(
            'Switch to monthly view to edit',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          trailing: Text(
            '${total.toStringAsFixed(2)} € / year',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_outlined,
              size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'No category budgets set.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          if (_isMonthly) ...[
            const SizedBox(height: 8),
            const Text(
              'Tap + to add one.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
