import 'package:flutter/material.dart';

import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/guard_notification_service.dart';
import '../../services/guard_repository.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/guard_item_status_card.dart';

class GuardScreen extends StatefulWidget {
  final PlanRepository planRepository;
  final GuardRepository guardRepository;

  const GuardScreen({
    super.key,
    required this.planRepository,
    required this.guardRepository,
  });

  @override
  State<GuardScreen> createState() => _GuardScreenState();
}

class _GuardScreenState extends State<GuardScreen> {
  int _notifyHour = 9;
  int _notifyMinute = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifyTime();
  }

  Future<void> _loadNotifyTime() async {
    final h = await GuardNotificationService.getSavedHour();
    final m = await GuardNotificationService.getSavedMinute();
    if (mounted) {
      setState(() {
        _notifyHour = h;
        _notifyMinute = m;
      });
    }
  }

  Future<void> _pickNotifyTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifyHour, minute: _notifyMinute),
      helpText: 'Daily GUARD reminder time',
    );
    if (picked == null || !mounted) return;

    await GuardNotificationService.saveTime(picked.hour, picked.minute);
    final unpaidCount = widget.guardRepository
        .unpaidActiveItems(widget.planRepository.items, YearMonth.now())
        .length;
    await GuardNotificationService.scheduleDaily(
        picked.hour, picked.minute, unpaidCount);
    if (mounted) {
      setState(() {
        _notifyHour = picked.hour;
        _notifyMinute = picked.minute;
      });
    }
  }

  Future<void> _pickDueDay(PlanItem item) async {
    // For yearly items the anchor month is always validFrom.month.
    final anchorMonth = item.validFrom.month;
    final daysInMonth = DateTime(YearMonth.now().year, anchorMonth + 1, 0).day;
    final currentDay = (item.guardDueDay ?? 1).clamp(1, daysInMonth);

    int selected = currentDay;
    final title = item.frequency == PlanFrequency.monthly
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
    if (picked == null || !mounted) return;

    await widget.planRepository.updateGuardConfigForSeries(
      item.seriesId,
      guardDueDay: picked,
    );
  }

  /// Returns the period that should be displayed for [item] in the GUARD screen.
  ///
  /// Monthly items always use [now].
  /// Yearly items use the most recent anchor month (validFrom.month):
  ///   - current year if the anchor month has already arrived this year,
  ///   - previous year otherwise (anchor month is still upcoming this year).
  YearMonth _effectivePeriod(PlanItem item, YearMonth now) {
    if (item.frequency != PlanFrequency.yearly) return now;
    final anchor = item.validFrom.month;
    return anchor <= now.month
        ? YearMonth(now.year, anchor)
        : YearMonth(now.year - 1, anchor);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable:
          Listenable.merge([widget.guardRepository, widget.planRepository]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final now = YearMonth.now();
    final all = widget.planRepository.items;

    final guardedItems = <String, PlanItem>{};
    for (final item in BudgetCalculator.activeItemsForMonth(
        all, now.year, now.month)) {
      if (item.isGuarded && item.type == PlanItemType.fixedCost) {
        guardedItems[item.seriesId] = item;
      }
    }

    final timeLabel =
        '${_notifyHour.toString().padLeft(2, '0')}:${_notifyMinute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets, color: AppColors.gold, size: 20),
            SizedBox(width: 8),
            Text('GUARD'),
          ],
        ),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Notification time ──────────────────────────────────────────
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_outlined,
                  color: AppColors.gold),
              title: const Text('Daily reminder'),
              subtitle: const Text('Tap to change the notification time'),
              trailing: Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
              onTap: _pickNotifyTime,
            ),
          ),
          const SizedBox(height: 16),

          // ── Guarded items ──────────────────────────────────────────────
          if (guardedItems.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.pets, size: 48, color: AppColors.border),
                    SizedBox(height: 12),
                    Text(
                      'No guarded items',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textMuted),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Enable GUARD on a fixed cost to track payments.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _buildSectionHeader('Guarded items', guardedItems.length),
            const SizedBox(height: 6),
            ...guardedItems.values.map((item) {
              final period = _effectivePeriod(item, now);
              final nextPeriod = widget.guardRepository
                  .nextReminderPeriod(item, now, all);
              final lastPeriod = widget.guardRepository
                  .lastReminderPeriod(item, all);
              return GuardItemStatusCard(
                item: item,
                period: period,
                state: widget.guardRepository.itemStateForPeriod(item, period),
                guardRepository: widget.guardRepository,
                onChangeDueDay: () => _pickDueDay(item),
                onDeleteGuard: () => widget.planRepository
                    .disableGuardForSeries(item.seriesId),
                showIfScheduled: true,
                nextReminderLabel: nextPeriod != null
                    ? _formatReminderPeriod(item, nextPeriod)
                    : null,
                lastReminderLabel: lastPeriod != null
                    ? _formatReminderPeriod(item, lastPeriod)
                    : null,
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatReminderPeriod(PlanItem item, YearMonth period) {
    final rawDueDay = item.guardDueDay ?? 1;
    final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
    final dueDay = rawDueDay.clamp(1, daysInMonth);
    return '${YearMonth.monthNames[period.month]} $dueDay, ${period.year}';
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


