import 'package:flutter/material.dart';

import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../services/guard_repository.dart';
import '../theme/app_theme.dart';

/// A stateless card that shows the GUARD status for a single [item] in a
/// specific [period] and provides all available actions:
///   - Mark as Paid
///   - Silence
///   - Mark as Unpaid (revoke a previous confirmation)
///
/// Used in both [PlanItemDetailScreen] and [GuardScreen].
///
/// The caller is responsible for providing the current [state] and for
/// wrapping this widget in a [ListenableBuilder] when reactivity is needed.
///
/// When [showIfScheduled] is false (default) the widget renders nothing for
/// [GuardState.scheduled] (period not yet due). Set to true in management
/// contexts where all configured guards should be visible regardless of due
/// date.
///
/// When [onChangeDueDay] is provided a "Change day" button is appended inside
/// the card, allowing due-day edits without navigating to the item form.
class GuardItemStatusCard extends StatelessWidget {
  final PlanItem item;
  final YearMonth period;
  final GuardState state;
  final GuardRepository guardRepository;
  final VoidCallback? onChangeDueDay;
  final VoidCallback? onDeleteGuard;
  final bool showIfScheduled;

  /// When non-null, displayed as "Next: <label>" below the item info.
  final String? nextReminderLabel;

  /// When non-null, displayed as "Last: <label>" below the item info.
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

  String get _periodLabel =>
      '${YearMonth.monthNames[period.month]} ${period.year}';

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
    final daysInMonth =
        DateTime(period.year, period.month + 1, 0).day;
    final effectiveDueDay = rawDueDay.clamp(1, daysInMonth);
    return 'Due ${YearMonth.monthNames[period.month]} '
        '$effectiveDueDay, ${period.year}';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _confirmAndMarkPaid(BuildContext context) async {
    await guardRepository.confirmPayment(item.seriesId, period);
  }

  Future<void> _confirmAndRevoke(BuildContext context) async {
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
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.expense),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onDeleteGuard?.call();
    }
  }

  Future<void> _confirmAndSilence(BuildContext context) async {
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
    if (confirmed == true && context.mounted) {
      await guardRepository.silencePayment(item.seriesId, period);
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
            const Divider(height: 20),
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
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textMuted),
            ),
            if (nextReminderLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                'Next: $nextReminderLabel',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
            if (lastReminderLabel != null)
              Text(
                'Last: $lastReminderLabel',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            const SizedBox(height: 12),
            _buildStateContent(context, state),
            if (onChangeDueDay != null || onDeleteGuard != null) ...[
              const Divider(height: 24),
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

  Widget _buildStateContent(BuildContext context, GuardState state) {
    switch (state) {
      case GuardState.unpaidActive:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment not confirmed',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              _dueDateLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmAndMarkPaid(context),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark as Paid'),
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gold),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _confirmAndSilence(context),
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
            const SizedBox(height: 2),
            Text(
              _dueDateLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: () => _confirmAndMarkPaid(context),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Mark as Paid'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.gold),
            ),
          ],
        );

      case GuardState.paid:
        final record = guardRepository.payments
            .where((p) =>
                p.planItemSeriesId == item.seriesId &&
                p.period == period &&
                p.paidAt != null)
            .firstOrNull;
        final paidLabel =
            record != null ? _formatDate(record.paidAt!) : 'confirmed';
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
                  style: const TextStyle(fontSize: 14, color: AppColors.income),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _confirmAndRevoke(context),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    visualDensity: VisualDensity.compact),
                child: const Text('Mark as Unpaid',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        );

      case GuardState.scheduled:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dueDateLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 4),
            const Text(
              'Not yet due',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        );

      case GuardState.none:
        return const SizedBox.shrink();
    }
  }

  static String _formatDate(DateTime dt) =>
      '${dt.day} ${YearMonth.monthNames[dt.month]} ${dt.year}';
}
