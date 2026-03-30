import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/guard_state.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/guard_repository.dart';
import '../../theme/app_theme.dart';

class PlanItemDetailScreen extends StatelessWidget {
  final PlanItem item;

  /// The period currently viewed — used to derive the GUARD state.
  final YearMonth period;

  /// Called when the user taps Edit in the AppBar.
  final VoidCallback? onEdit;

  /// Called when the user taps Delete in the AppBar.
  final VoidCallback? onDelete;

  /// Optional — when set, the GUARD section is shown for guarded items.
  final GuardRepository? guardRepository;

  const PlanItemDetailScreen({
    super.key,
    required this.item,
    required this.period,
    this.onEdit,
    this.onDelete,
    this.guardRepository,
  });

  String _formatYearMonth(YearMonth ym) => '${YearMonth.monthNames[ym.month]} ${ym.year}';

  static String _frequencyLabel(PlanFrequency freq) => switch (freq) {
        PlanFrequency.monthly => 'Monthly',
        PlanFrequency.yearly => 'Yearly',
        PlanFrequency.oneTime => 'One-time',
      };

  @override
  Widget build(BuildContext context) {
    final isIncome = item.type == PlanItemType.income;
    final showGuard =
        item.isGuarded && guardRepository != null && !isIncome;

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
          if (showGuard) ...[
            const SizedBox(height: 16),
            _GuardStatusSection(
              item: item,
              period: period,
              guardRepository: guardRepository!,
            ),
          ],
        ],
      ),
    );
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
            value: '${item.amount.toStringAsFixed(2)} € $amountSuffix',
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
            value: _formatYearMonth(item.validFrom),
          ),
          if (item.frequency != PlanFrequency.oneTime) ...[
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.event_outlined,
              iconColor: AppColors.textMuted,
              label: 'Active until',
              value: item.validTo != null
                  ? _formatYearMonth(item.validTo!)
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

// ── GUARD status section ──────────────────────────────────────────────────────

/// Stateful sub-widget so it can rebuild on guardRepository changes.
class _GuardStatusSection extends StatefulWidget {
  final PlanItem item;
  final YearMonth period;
  final GuardRepository guardRepository;

  const _GuardStatusSection({
    required this.item,
    required this.period,
    required this.guardRepository,
  });

  @override
  State<_GuardStatusSection> createState() => _GuardStatusSectionState();
}

class _GuardStatusSectionState extends State<_GuardStatusSection> {
  @override
  void initState() {
    super.initState();
    widget.guardRepository.addListener(_onGuardChanged);
  }

  @override
  void dispose() {
    widget.guardRepository.removeListener(_onGuardChanged);
    super.dispose();
  }

  void _onGuardChanged() => setState(() {});

  String get _periodLabel =>
      '${YearMonth.monthNames[widget.period.month]} ${widget.period.year}';

  Future<void> _confirmAndMarkPaid() async {
    await widget.guardRepository
        .confirmPayment(widget.item.seriesId, widget.period);
  }

  Future<void> _confirmAndRevoke() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as unpaid?'),
        content: Text(
            'This will remove the payment confirmation for $_periodLabel.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mark as Unpaid'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.guardRepository
          .revokePayment(widget.item.seriesId, widget.period);
    }
  }

  Future<void> _confirmAndSilence() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silence this reminder?'),
        content: Text(
          'The $_periodLabel payment will still be shown as unconfirmed. '
          'You can mark it as paid at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes, Silence'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.guardRepository
          .silencePayment(widget.item.seriesId, widget.period);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.guardRepository
        .itemStateForPeriod(widget.item, widget.period);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets, color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                Text(
                  'GUARD — $_periodLabel',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStateContent(state),
          ],
        ),
      ),
    );
  }

  Widget _buildStateContent(GuardState state) {
    switch (state) {
      case GuardState.unpaidActive:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment not confirmed',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _confirmAndMarkPaid,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark as Paid'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _confirmAndSilence,
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted),
                  child: const Text('Silence'),
                ),
              ],
            ),
          ],
        );

      case GuardState.silenced:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_off,
                    size: 14, color: AppColors.textMuted),
                SizedBox(width: 6),
                Text(
                  'Silenced — payment not confirmed',
                  style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _confirmAndMarkPaid,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark as Paid'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.gold),
            ),
          ],
        );

      case GuardState.paid:
        final record = widget.guardRepository.payments.where((p) =>
            p.planItemSeriesId == widget.item.seriesId &&
            p.period == widget.period &&
            p.paidAt != null).firstOrNull;
        final paidLabel = record != null
            ? _formatDate(record.paidAt!)
            : 'confirmed';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.income),
                const SizedBox(width: 6),
                Text(
                  'Paid $paidLabel',
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.income),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _confirmAndRevoke,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    visualDensity: VisualDensity.compact),
                child: const Text('Mark as Unpaid',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        );

      case GuardState.none:
        return const SizedBox.shrink();
    }
  }

  static String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
