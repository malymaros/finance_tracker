import 'package:flutter/material.dart';

import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../services/guard_repository.dart';
import '../theme/app_theme.dart';

/// A card showing the GUARD status for a single [item] in a specific [period].
///
/// Layout: a small "🐾 GUARD" identity chip at the top, then a two-column row
/// (item info on the left, state-driven action controls on the right), followed
/// by optional Next/Last reminder labels and management actions (change day,
/// remove GUARD).
///
/// Used in both [GuardScreen] and [PlanItemDetailScreen].
///
/// When [showIfScheduled] is false (default) the widget renders nothing for
/// [GuardState.scheduled]. Set to true in management contexts where all
/// configured guards should be visible.
///
/// When [onChangeDueDay] / [onDeleteGuard] are provided they appear below a
/// Divider at the bottom of the card.
class GuardItemStatusCard extends StatelessWidget {
  final PlanItem item;
  final YearMonth period;
  final GuardState state;
  final GuardRepository guardRepository;
  final VoidCallback? onChangeDueDay;
  final VoidCallback? onDeleteGuard;
  final bool showIfScheduled;

  /// Displayed as "Next: <label>" below the item info when non-null.
  final String? nextReminderLabel;

  /// Displayed as "Last: <label>" below the item info when non-null.
  final String? lastReminderLabel;

  const GuardItemStatusCard({
    super.key,
    required this.item,
    required this.period,
    required this.state,
    required this.guardRepository,
    this.onChangeDueDay,
    this.onDeleteGuard,
    this.showIfScheduled = false,
    this.nextReminderLabel,
    this.lastReminderLabel,
  });

  // ── Labels ────────────────────────────────────────────────────────────────

  String get _amountLabel {
    final suffix = switch (item.frequency) {
      PlanFrequency.monthly => '/ month',
      PlanFrequency.yearly => '/ year',
      PlanFrequency.oneTime => '',
    };
    return '${item.amount.toStringAsFixed(2)} € $suffix'.trim();
  }

  String get _dueDateLabel {
    final rawDueDay = item.guardDueDay ?? 1;
    final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
    final effectiveDueDay = rawDueDay.clamp(1, daysInMonth);
    return 'Due ${YearMonth.monthNames[period.month]} '
        '$effectiveDueDay, ${period.year}';
  }

  DateTime? get _paidDate => guardRepository.payments
      .where((p) =>
          p.planItemSeriesId == item.seriesId &&
          p.period == period &&
          p.paidAt != null)
      .firstOrNull
      ?.paidAt;

  static String _formatDate(DateTime dt) =>
      '${dt.day} ${YearMonth.monthNames[dt.month]} ${dt.year}';

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _confirmAndMarkPaid(BuildContext context) async {
    await guardRepository.confirmPayment(item.seriesId, period);
  }

  Future<void> _confirmAndSilence(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silence this reminder?'),
        content: Text(
          'The ${YearMonth.monthNames[period.month]} ${period.year} payment '
          'will still be shown as unconfirmed. '
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
    if (confirmed == true && context.mounted) {
      await guardRepository.silencePayment(item.seriesId, period);
    }
  }

  Future<void> _confirmAndRevoke(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as unpaid?'),
        content: Text(
          'This will remove the payment confirmation for '
          '${YearMonth.monthNames[period.month]} ${period.year}.',
        ),
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
    if (confirmed == true && context.mounted) {
      await guardRepository.revokePayment(item.seriesId, period);
    }
  }

  Future<void> _confirmAndDeleteGuard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove GUARD?'),
        content: Text(
          'GUARD will be disabled for "${item.name}". '
          'Existing payment records are kept but no new reminders will fire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onDeleteGuard?.call();
    }
  }

  /// Opens a date picker constrained to the period's month (capped at today).
  Future<void> _editPaidDate(BuildContext context) async {
    final paidDate = _paidDate;
    if (paidDate == null) return;

    final firstDate = DateTime(period.year, period.month, 1);
    final lastDayOfMonth = DateTime(period.year, period.month + 1, 0);
    final today = DateTime.now();
    final lastDate = lastDayOfMonth.isAfter(today)
        ? DateTime(today.year, today.month, today.day)
        : lastDayOfMonth;

    // Abort silently if the entire period is still in the future.
    if (lastDate.isBefore(firstDate)) return;

    final safeInitial = paidDate.isBefore(firstDate)
        ? firstDate
        : (paidDate.isAfter(lastDate)
            ? lastDate
            : DateTime(paidDate.year, paidDate.month, paidDate.day));

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select paid date',
    );
    if (picked != null && context.mounted) {
      await guardRepository.updatePaidDate(item.seriesId, period, picked);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (state == GuardState.none) return const SizedBox.shrink();
    if (state == GuardState.scheduled && !showIfScheduled) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Identity chip ────────────────────────────────────────────
            const Row(
              children: [
                Icon(Icons.pets, color: AppColors.gold, size: 14),
                SizedBox(width: 6),
                Text(
                  'GUARD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Two-column body ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildLeftColumn()),
                const SizedBox(width: 12),
                _buildRightColumn(context),
              ],
            ),
            // ── Next / Last reminder labels ──────────────────────────────
            if (nextReminderLabel != null || lastReminderLabel != null) ...[
              const SizedBox(height: 8),
              if (nextReminderLabel != null)
                Text(
                  'Next: $nextReminderLabel',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
              if (lastReminderLabel != null)
                Text(
                  'Last: $lastReminderLabel',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
            ],
            // ── Management actions ───────────────────────────────────────
            if (onChangeDueDay != null || onDeleteGuard != null) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onChangeDueDay != null)
                    TextButton.icon(
                      onPressed: onChangeDueDay,
                      icon: const Icon(Icons.event, size: 16),
                      label: const Text('Change day'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  if (onDeleteGuard != null)
                    TextButton.icon(
                      onPressed: () => _confirmAndDeleteGuard(context),
                      icon: const Icon(Icons.remove_circle_outline, size: 16),
                      label: const Text('Remove GUARD'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Column builders ───────────────────────────────────────────────────────

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.guardItemText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _amountLabel,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        if (state != GuardState.paid) ...[
          const SizedBox(height: 2),
          Text(
            _dueDateLabel,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
        if (state == GuardState.scheduled) ...[
          const SizedBox(height: 2),
          const Text(
            'Not yet due',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    switch (state) {
      case GuardState.unpaidActive:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _markAsPaidButton(context),
            TextButton(
              onPressed: () => _confirmAndSilence(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Silence', style: TextStyle(fontSize: 12)),
            ),
          ],
        );

      case GuardState.silenced:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            _markAsPaidButton(context),
            const SizedBox(height: 4),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_off,
                    size: 12, color: AppColors.textMuted),
                SizedBox(width: 4),
                Text(
                  'Silenced',
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        );

      case GuardState.paid:
        final paidDate = _paidDate;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _editPaidDate(context),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        size: 14, color: AppColors.income),
                    const SizedBox(width: 4),
                    Text(
                      paidDate != null
                          ? 'Paid ${_formatDate(paidDate)}'
                          : 'Paid',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.income),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 11, color: AppColors.income),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () => _confirmAndRevoke(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: const Text('Mark as Unpaid',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        );

      case GuardState.scheduled:
        return const Text(
          'Scheduled',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        );

      case GuardState.none:
        return const SizedBox.shrink();
    }
  }

  Widget _markAsPaidButton(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _confirmAndMarkPaid(context),
      icon: const Icon(Icons.check, size: 14),
      label: const Text('Mark as Paid'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
