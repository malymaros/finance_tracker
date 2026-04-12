import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/expense_category.dart';
import '../../models/year_month.dart';
import '../../services/category_budget_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_budget_tile.dart';
import '../../widgets/period_navigator.dart';
import 'add_category_budget_screen.dart';

enum _DeleteChoice { cancel, endFromNow, deleteAll }

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
    required YearMonth activeVersionValidFrom,
  }) {
    final versions = widget.budgetRepository.seriesVersions(seriesId);
    final minValidFrom =
        versions.isNotEmpty ? versions.first.validFrom : YearMonth.now();
    final isClosed =
        versions.isNotEmpty && versions.last.validTo != null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCategoryBudgetScreen(
          budgetRepository: widget.budgetRepository,
          initialCategory: category,
          initialAmount: currentAmount,
          initialValidFrom:
              isClosed ? activeVersionValidFrom : YearMonth.now(),
          seriesId: seriesId,
          minValidFrom: minValidFrom,
          validFromLocked: isClosed,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      String seriesId, String categoryName) async {
    final from = _selectedPeriod;
    final versions = widget.budgetRepository.seriesVersions(seriesId);
    final earliest = versions.isNotEmpty ? versions.first.validFrom : from;
    final latest = versions.isNotEmpty ? versions.last.validTo : null;

    String fmt(YearMonth ym) => '${YearMonth.monthNames[ym.month]} ${ym.year}';
    final rangeText = latest == null
        ? '${fmt(earliest)} – present'
        : '${fmt(earliest)} – ${fmt(latest)}';
    final fromLabel = fmt(from);

    final isClosed = latest != null;

    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $categoryName budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isClosed) ...[
              Text(
                'End from $fromLabel',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Stops the budget from $fromLabel onwards. '
                'Earlier months keep their historical budget.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Delete entire series',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isClosed ? null : AppColors.expense,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Permanently removes all records ($rangeText). '
              'No budget will appear for any month in this series. '
              'This cannot be undone.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),
            if (!isClosed)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(_DeleteChoice.endFromNow),
                  child: Text('End from $fromLabel'),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(_DeleteChoice.deleteAll),
                style: TextButton.styleFrom(
                    foregroundColor:
                        isClosed ? null : AppColors.expense),
                child: const Text('Delete all'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(_DeleteChoice.cancel),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );

    if (!mounted) return;
    if (choice == _DeleteChoice.endFromNow) {
      await widget.budgetRepository.endCategoryBudget(seriesId, from);
    } else if (choice == _DeleteChoice.deleteAll) {
      await widget.budgetRepository.deleteEntireSeries(seriesId);
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
              PeriodNavigator(
                selected: _selectedPeriod,
                yearOnly: false,
                min: _min,
                max: _max,
                onChanged: (ym) => setState(() => _selectedPeriod = ym),
              ),
              const Divider(height: 1),
              Expanded(child: _buildMonthlyContent()),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        tooltip: 'Add budget',
        child: const Icon(Icons.add),
      ),
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
            activeVersionValidFrom: record.validFrom,
          ),
          onDelete: () =>
              _confirmDelete(record.seriesId, category.displayName),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text(
            'No category budgets set.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapPlusToAddOne,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
