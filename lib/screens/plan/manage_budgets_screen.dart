import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/expense_category.dart';
import '../../models/year_month.dart';
import '../../services/category_budget_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_budget_tile.dart';
import '../../widgets/delete_option_card.dart';
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
      String seriesId, ExpenseCategory category) async {
    final l10n = context.l10n;
    final categoryName = l10n.categoryName(category);
    final from = _selectedPeriod;
    final versions = widget.budgetRepository.seriesVersions(seriesId);
    final earliest = versions.isNotEmpty ? versions.first.validFrom : from;
    final latest = versions.isNotEmpty ? versions.last.validTo : null;

    String fmt(YearMonth ym) => '${l10n.monthName(ym.month)} ${ym.year}';
    final rangeText = latest == null
        ? l10n.budgetRangePresent(fmt(earliest))
        : '${fmt(earliest)} – ${fmt(latest)}';
    final fromLabel = fmt(from);

    final isClosed = latest != null;

    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => _BudgetDeleteDialog(
        categoryName: categoryName,
        fromLabel: fromLabel,
        rangeText: rangeText,
        isClosed: isClosed,
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
        title: Text(context.l10n.categoryBudgetsTitle),
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
        tooltip: context.l10n.addBudgetTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthlyContent() {
    final activeBudgets =
        widget.budgetRepository.allActiveBudgetsForMonth(_selectedPeriod);

    if (activeBudgets.isEmpty) return _buildEmptyState();

    final l10n = context.l10n;
    final entries = activeBudgets.entries.toList()
      ..sort((a, b) {
        if (a.key == ExpenseCategory.other) return 1;
        if (b.key == ExpenseCategory.other) return -1;
        return l10n.categoryName(a.key).compareTo(l10n.categoryName(b.key));
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
              _confirmDelete(record.seriesId, category),
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
          Text(
            context.l10n.noCategoryBudgetsSet,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapPlusToAddOne,
            style: const TextStyle(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Budget delete dialog ──────────────────────────────────────────────────────

class _BudgetDeleteDialog extends StatelessWidget {
  final String categoryName;
  final String fromLabel;
  final String rangeText;
  final bool isClosed;

  const _BudgetDeleteDialog({
    required this.categoryName,
    required this.fromLabel,
    required this.rangeText,
    required this.isClosed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.expense.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.remove_circle_outline,
                  color: AppColors.expense, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.removeBudgetAllCaps,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              categoryName,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (!isClosed) ...[
              DeleteOptionCard(
                showChevron: false,
                icon: Icons.content_cut,
                title: l10n.endBudgetFromTitle(fromLabel),
                subtitle: l10n.endBudgetFromDescription(fromLabel),
                onTap: () => Navigator.of(context).pop(_DeleteChoice.endFromNow),
              ),
              const SizedBox(height: 8),
            ],
            DeleteOptionCard(
              showChevron: false,
              icon: Icons.delete_sweep_outlined,
              title: l10n.deleteBudgetSeriesTitle,
              subtitle: l10n.deleteBudgetSeriesDescription(rangeText),
              onTap: () => Navigator.of(context).pop(_DeleteChoice.deleteAll),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(_DeleteChoice.cancel),
                child: Text(l10n.actionCancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

