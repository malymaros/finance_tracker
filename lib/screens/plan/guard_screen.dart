import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/guard_calculator.dart';
import '../../services/guard_notification_service.dart';
import '../../services/guard_repository.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/guard_item_status_card.dart';
import '../../widgets/how_guard_work_sheet.dart';

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
      helpText: context.l10n.guardTimePicker,
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
    final anchorPeriod = YearMonth(YearMonth.now().year, anchorMonth);
    final daysInMonth = GuardCalculator.daysInMonth(anchorPeriod);
    final currentDay = GuardCalculator.clampDueDay(item.guardDueDay, anchorPeriod);

    int selected = currentDay;
    final l10n = context.l10n;
    final title = item.frequency == PlanFrequency.monthly
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, color: AppColors.gold, size: 20),
            const SizedBox(width: 8),
            Text(context.l10n.guardScreenTitle),
          ],
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => HowGuardWorkSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Notification time (fixed chrome) ──────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_outlined,
                    color: AppColors.gold),
                title: Text(context.l10n.guardDailyReminder),
                subtitle: Text(context.l10n.guardChangeNotifTime),
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
          ),
          const Divider(height: 1),
          // ── Guarded items ──────────────────────────────────────────────
          Expanded(
            child: guardedItems.isEmpty
                ? _buildEmptyState()
                : _buildItemsList(guardedItems, now, all),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(
              context.l10n.noGuardedItems,
              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.guardNoGuardedItemsHint,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => HowGuardWorkSheet.show(context),
              icon: const Icon(Icons.pets, size: 16),
              label: Text(context.l10n.howGuardWorkQuestion),
              style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList(
    Map<String, PlanItem> guardedItems,
    YearMonth now,
    List<PlanItem> all,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      children: [
        _buildSectionHeader(guardedItems.length),
        const SizedBox(height: 6),
        ...guardedItems.values.map((item) {
          final period = _effectivePeriod(item, now);
          final nextPeriod =
              widget.guardRepository.nextReminderPeriod(item, now, all);
          final lastPeriod =
              widget.guardRepository.lastReminderPeriod(item, all);
          return GuardItemStatusCard(
            item: item,
            period: period,
            state: widget.guardRepository.itemStateForPeriod(item, period),
            guardRepository: widget.guardRepository,
            onChangeDueDay: () => _pickDueDay(item),
            onDeleteGuard: () =>
                widget.planRepository.disableGuardForSeries(item.seriesId),
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
    );
  }

  String _formatReminderPeriod(PlanItem item, YearMonth period) =>
      GuardCalculator.formatReminderPeriod(item.guardDueDay, period, context.l10n);

  Widget _buildSectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        context.l10n.guardedItemsCount(count),
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
