import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
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

  String _frequencyLabel(AppLocalizations l10n, PlanFrequency freq) =>
      switch (freq) {
        PlanFrequency.monthly => l10n.frequencyMonthly,
        PlanFrequency.yearly => l10n.frequencyYearly,
        PlanFrequency.oneTime => l10n.frequencyOneTime,
      };

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final showGuardSection =
        !isIncome && planRepository != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.planItemTitle),
        scrolledUnderElevation: 0,
        actions: [
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: context.l10n.actionEdit,
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: context.l10n.actionDelete,
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
          _buildDetailsCard(context, isIncome),
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
            subtitle: Text(context.l10n.guardNotEnabled),
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

    final l10n = context.l10n;
    final title = current.frequency == PlanFrequency.monthly
        ? l10n.dueDayMonthly
        : l10n.dueDayYearly(l10n.monthName(anchorMonth));

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(title),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            decoration: InputDecoration(
              labelText: ctx.l10n.labelDayOfMonth,
              border: const OutlineInputBorder(),
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
              child: Text(ctx.l10n.actionCancel),
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
    final l10n = context.l10n;
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
                isIncome ? l10n.typeIncome : l10n.typeFixedCost,
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

  Widget _buildDetailsCard(BuildContext context, bool isIncome) {
    final l10n = context.l10n;
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    final amountSuffix = switch (item.frequency) {
      PlanFrequency.monthly => l10n.perMonth,
      PlanFrequency.yearly => l10n.perYear,
      PlanFrequency.oneTime => l10n.oneTimeSuffix,
    };

    return Card(
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.euro_outlined,
            iconColor: typeColor,
            label: l10n.labelAmount,
            value: '${CurrencyFormatter.format(item.amount)} $amountSuffix'.trim(),
          ),
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.repeat_outlined,
            iconColor: AppColors.textMuted,
            label: l10n.labelFrequency,
            value: _frequencyLabel(l10n, item.frequency),
          ),
          if (item.category != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.category!.icon,
              iconColor: item.category!.color,
              label: l10n.labelCategory,
              value: l10n.categoryName(item.category!),
            ),
          ],
          if (item.financialType != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: item.financialType!.icon,
              iconColor: item.financialType!.color,
              label: l10n.labelFinancialType,
              value: l10n.financialTypeName(item.financialType!),
            ),
          ],
          const Divider(height: 1, indent: 56),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.textMuted,
            label: l10n.activeFrom,
            value: l10n.yearMonthLabel(item.validFrom),
          ),
          if (item.frequency != PlanFrequency.oneTime) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.event_outlined,
              iconColor: AppColors.textMuted,
              label: l10n.activeUntil,
              value: item.validTo != null
                  ? l10n.yearMonthLabel(item.validTo!)
                  : isIncome
                      ? l10n.ongoing
                      : l10n.noEndDate,
            ),
          ],
          if (item.note != null) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.notes_outlined,
              iconColor: AppColors.textMuted,
              label: l10n.labelNote,
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
