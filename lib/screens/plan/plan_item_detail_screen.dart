import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/currency_formatter.dart';
import '../../services/guard_repository.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/guard_item_status_card.dart';
import '../../widgets/guard_setup_sheet.dart';

class PlanItemDetailScreen extends StatelessWidget {
  final PlanItem item;

  /// The period currently viewed — used to derive the GUARD state.
  final YearMonth period;

  /// Called when the user taps Edit in the AppBar.
  final VoidCallback? onEdit;

  /// Called when the user taps Delete in the AppBar.
  final VoidCallback? onDelete;

  /// When set, the GUARD section is shown for fixed cost items.
  /// Allows enabling GUARD directly from the detail screen.
  final PlanRepository? planRepository;

  /// When set alongside [planRepository], shows the full GUARD status card
  /// for already-guarded items.
  final GuardRepository? guardRepository;

  const PlanItemDetailScreen({
    super.key,
    required this.item,
    required this.period,
    this.onEdit,
    this.onDelete,
    this.planRepository,
    this.guardRepository,
  });

  static String _frequencyLabel(PlanFrequency freq) => switch (freq) {
        PlanFrequency.monthly => 'Monthly',
        PlanFrequency.yearly => 'Yearly',
        PlanFrequency.oneTime => 'One-time',
      };

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final showGuardSection =
        !isIncome && planRepository != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Item'),
        scrolledUnderElevation: 0,
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              color: AppColors.expense,
              onPressed: onDelete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderCard(context, isIncome),
          const SizedBox(height: 16),
          _buildDetailsCard(isIncome),
          if (showGuardSection) ...[
            const SizedBox(height: 16),
            _buildGuardSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildGuardSection(BuildContext context) {
    final listenables = <Listenable>[planRepository!];
    if (guardRepository != null) listenables.add(guardRepository!);

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        // Always read the freshest version of the item from the repository so
        // the section reacts immediately after GUARD is enabled or disabled.
        final current = planRepository!.items
            .firstWhere((e) => e.id == item.id, orElse: () => item);

        if (current.isGuarded) {
          // Guard repo must be present to render the full status card.
          // Without it, hide the section rather than show a misleading state.
          if (guardRepository == null) return const SizedBox.shrink();
          return GuardItemStatusCard(
            item: current,
            period: period,
            state: guardRepository!.itemStateForPeriod(current, period),
            guardRepository: guardRepository!,
            onChangeDueDay: () => _pickDueDay(context, current),
            onDeleteGuard: () =>
                planRepository!.disableGuardForSeries(current.seriesId),
          );
        }

        // Not guarded — show an enable prompt.
        return Card(
          child: ListTile(
            leading: const Icon(Icons.pets, color: AppColors.gold),
            title: const Text(
              'GUARD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            subtitle: const Text('Not enabled'),
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textMuted, size: 20),
            onTap: () => GuardSetupSheet.show(
              context,
              item: current,
              planRepository: planRepository!,
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDueDay(BuildContext context, PlanItem current) async {
    final anchorMonth = current.validFrom.month;
    final daysInMonth =
        DateTime(current.validFrom.year, anchorMonth + 1, 0).day;
    final currentDay = (current.guardDueDay ?? 1).clamp(1, daysInMonth);
    int selected = currentDay;

    final title = current.frequency == PlanFrequency.monthly
        ? 'Due day (repeats monthly)'
        : 'Due day (repeats every ${YearMonth.monthNames[anchorMonth]})';

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(title),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            decoration: const InputDecoration(
              labelText: 'Day of month',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: List.generate(daysInMonth, (i) {
              final d = i + 1;
              return DropdownMenuItem(value: d, child: Text('$d'));
            }),
            onChanged: (v) {
              if (v != null) setInner(() => selected = v);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(selected),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await planRepository!
          .updateGuardConfigForSeries(current.seriesId, guardDueDay: picked);
    }
  }

  Widget _buildHeaderCard(BuildContext context, bool isIncome) {
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    return Card(
      color: typeColor.withAlpha(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              item.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: typeColor.withAlpha(60)),
              ),
              child: Text(
                isIncome ? 'Income' : 'Fixed Cost',
                style: TextStyle(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(bool isIncome) {
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    final amountSuffix = switch (item.frequency) {
      PlanFrequency.monthly => '/ month',
      PlanFrequency.yearly => '/ year',
      PlanFrequency.oneTime => '(one-time)',
    };

    return Card(
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.euro_outlined,
            iconColor: typeColor,
            label: 'Amount',
            value: '${CurrencyFormatter.format(item.amount)} $amountSuffix'.trim(),
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.repeat_outlined,
            iconColor: AppColors.textMuted,
            label: 'Frequency',
            value: _frequencyLabel(item.frequency),
          ),
          if (item.category != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.category!.icon,
              iconColor: item.category!.color,
              label: 'Category',
              value: item.category!.displayName,
            ),
          ],
          if (item.financialType != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.financialType!.icon,
              iconColor: item.financialType!.color,
              label: 'Financial type',
              value: item.financialType!.displayName,
            ),
          ],
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.textMuted,
            label: 'Active from',
            value: item.validFrom.label,
          ),
          if (item.frequency != PlanFrequency.oneTime) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.event_outlined,
              iconColor: AppColors.textMuted,
              label: 'Active until',
              value: item.validTo != null
                  ? item.validTo!.label
                  : isIncome
                      ? 'Ongoing'
                      : 'No end date',
            ),
          ],
          if (item.note != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              iconColor: AppColors.textMuted,
              label: 'Note',
              value: item.note!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
