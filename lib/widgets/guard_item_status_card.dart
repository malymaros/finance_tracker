import 'package:flutter/material.dart';

import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../services/guard_repository.dart';
import '../theme/app_theme.dart';

/// A self-contained card that shows the GUARD status for a single [item] in a
/// specific [period] and provides all available actions:
///   - Mark as Paid
///   - Silence
///   - Mark as Unpaid (revoke a previous confirmation)
///
/// Used in both [PlanItemDetailScreen] and [GuardScreen].
///
/// When [showIfScheduled] is false (default) the widget renders nothing for
/// [GuardState.scheduled] (period not yet due). Set to true in management
/// contexts where all configured guards should be visible regardless of due
/// date.
///
/// When [onChangeDueDay] is provided a "Change day" button is appended inside
/// the card, allowing due-day edits without navigating to the item form.
class GuardItemStatusCard extends StatefulWidget {
  final PlanItem item;
  final YearMonth period;
  final GuardRepository guardRepository;
  final VoidCallback? onChangeDueDay;
  final VoidCallback? onDeleteGuard;
  final bool showIfScheduled;

  const GuardItemStatusCard({
    super.key,
    required this.item,
    required this.period,
    required this.guardRepository,
    this.onChangeDueDay,
    this.onDeleteGuard,
    this.showIfScheduled = false,
  });

  @override
  State<GuardItemStatusCard> createState() => _GuardItemStatusCardState();
}

class _GuardItemStatusCardState extends State<GuardItemStatusCard> {
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

  // ── Labels ────────────────────────────────────────────────────────────────

  String get _periodLabel =>
      '${YearMonth.monthNames[widget.period.month]} ${widget.period.year}';

  String get _amountLabel {
    final suffix = switch (widget.item.frequency) {
      PlanFrequency.monthly => '/ month',
      PlanFrequency.yearly => '/ year',
      PlanFrequency.oneTime => '',
    };
    return '${widget.item.amount.toStringAsFixed(2)} € $suffix'.trim();
  }

  String get _dueDateLabel {
    final rawDueDay = widget.item.guardDueDay ?? 1;
    final daysInMonth =
        DateTime(widget.period.year, widget.period.month + 1, 0).day;
    final effectiveDueDay = rawDueDay.clamp(1, daysInMonth);
    return 'Due ${YearMonth.monthNames[widget.period.month]} '
        '$effectiveDueDay, ${widget.period.year}';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

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

  Future<void> _confirmAndDeleteGuard() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove GUARD?'),
        content: Text(
          'GUARD will be disabled for "${widget.item.name}". '
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
    if (confirmed == true && mounted) {
      widget.onDeleteGuard?.call();
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state =
        widget.guardRepository.itemStateForPeriod(widget.item, widget.period);

    if (state == GuardState.none) return const SizedBox.shrink();
    if (state == GuardState.scheduled && !widget.showIfScheduled) {
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
              widget.item.name,
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
            const SizedBox(height: 12),
            _buildStateContent(state),
            if (widget.onChangeDueDay != null ||
                widget.onDeleteGuard != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.onChangeDueDay != null)
                    TextButton.icon(
                      onPressed: widget.onChangeDueDay,
                      icon: const Icon(Icons.event, size: 16),
                      label: const Text('Change day'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.gold,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  if (widget.onDeleteGuard != null)
                    TextButton.icon(
                      onPressed: _confirmAndDeleteGuard,
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
            const SizedBox(height: 2),
            Text(
              _dueDateLabel,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
        final record = widget.guardRepository.payments
            .where((p) =>
                p.planItemSeriesId == widget.item.seriesId &&
                p.period == widget.period &&
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
