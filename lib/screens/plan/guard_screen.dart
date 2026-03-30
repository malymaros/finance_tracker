import 'package:flutter/material.dart';

import '../../models/guard_state.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/guard_notification_service.dart';
import '../../services/guard_repository.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';

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
    final now = YearMonth.now();
    final anchorMonth = item.frequency == PlanFrequency.yearly
        ? (item.guardDueMonth ?? item.validFrom.month)
        : now.month;
    final anchorYear = now.year;
    final daysInMonth = DateTime(anchorYear, anchorMonth + 1, 0).day;
    final currentDay = (item.guardDueDay ?? 1).clamp(1, daysInMonth);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(anchorYear, anchorMonth, currentDay),
      firstDate: DateTime(anchorYear, anchorMonth, 1),
      lastDate: DateTime(anchorYear, anchorMonth, daysInMonth),
      helpText: item.frequency == PlanFrequency.monthly
          ? 'Pick due day (repeats monthly)'
          : 'Pick due day',
    );
    if (picked == null || !mounted) return;

    await widget.planRepository.updateGuardConfigForSeries(
      item.seriesId,
      guardDueDay: picked.day,
      guardDueMonth: item.guardDueMonth,
    );
  }

  Future<void> _onSilenceRequested(
      PlanItem item, YearMonth period) async {
    final periodLabel =
        '${YearMonth.monthNames[period.month]} ${period.year}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Silence this reminder?'),
        content: Text(
          'The $periodLabel payment will still be shown as unconfirmed. '
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
      await widget.guardRepository.silencePayment(item.seriesId, period);
    }
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
    final unresolved = widget.guardRepository.allUnresolvedItems(all, now);
    final unpaidActive = unresolved
        .where((p) =>
            widget.guardRepository.itemStateForPeriod(p.$1, p.$2) ==
            GuardState.unpaidActive)
        .toList();
    final silenced = unresolved
        .where((p) =>
            widget.guardRepository.itemStateForPeriod(p.$1, p.$2) ==
            GuardState.silenced)
        .toList();

    // All distinct guarded items (for due-day management).
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

          // ── Unpaid active ──────────────────────────────────────────────
          if (unpaidActive.isNotEmpty) ...[
            _buildSectionHeader('Pending', unpaidActive.length),
            const SizedBox(height: 6),
            ...unpaidActive.map((pair) => _GuardItemCard(
                  item: pair.$1,
                  period: pair.$2,
                  isSilenced: false,
                  onMarkPaid: () => widget.guardRepository
                      .confirmPayment(pair.$1.seriesId, pair.$2),
                  onSilence: () => _onSilenceRequested(pair.$1, pair.$2),
                  onChangeDueDay: () => _pickDueDay(pair.$1),
                )),
            const SizedBox(height: 16),
          ],

          // ── Silenced ───────────────────────────────────────────────────
          if (silenced.isNotEmpty) ...[
            _buildSectionHeader('Silenced', silenced.length),
            const SizedBox(height: 6),
            ...silenced.map((pair) => _GuardItemCard(
                  item: pair.$1,
                  period: pair.$2,
                  isSilenced: true,
                  onMarkPaid: () => widget.guardRepository
                      .confirmPayment(pair.$1.seriesId, pair.$2),
                  onSilence: null,
                  onChangeDueDay: () => _pickDueDay(pair.$1),
                )),
            const SizedBox(height: 16),
          ],

          if (unresolved.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: AppColors.income),
                    SizedBox(height: 12),
                    Text(
                      'All payments confirmed',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

          // ── Due day management ─────────────────────────────────────────
          if (guardedItems.isNotEmpty) ...[
            _buildSectionHeader('Guarded items', guardedItems.length),
            const SizedBox(height: 6),
            ...guardedItems.values.map((item) => _DueDayTile(
                  item: item,
                  onChangeDueDay: () => _pickDueDay(item),
                )),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
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

// ── Guard item card ───────────────────────────────────────────────────────────

class _GuardItemCard extends StatelessWidget {
  final PlanItem item;
  final YearMonth period;
  final bool isSilenced;
  final VoidCallback onMarkPaid;
  final VoidCallback? onSilence;
  final VoidCallback onChangeDueDay;

  const _GuardItemCard({
    required this.item,
    required this.period,
    required this.isSilenced,
    required this.onMarkPaid,
    this.onSilence,
    required this.onChangeDueDay,
  });

  @override
  Widget build(BuildContext context) {
    final periodLabel =
        '${YearMonth.monthAbbreviations[period.month]} ${period.year}';
    final rawDueDay = item.guardDueDay ?? 1;
    final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
    final effectiveDueDay = rawDueDay.clamp(1, daysInMonth);
    final dueDayLabel = 'Due day $effectiveDueDay';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSilenced
                              ? AppColors.textMuted
                              : AppColors.guardItemText,
                          fontStyle: isSilenced
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            periodLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onChangeDueDay,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.gold),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dueDayLabel,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                FilledButton(
                  onPressed: onMarkPaid,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Paid'),
                ),
                if (onSilence != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onSilence,
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppColors.textMuted,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    child: const Text('Silence',
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
                if (isSilenced) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.notifications_off,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  const Text('silenced',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted,
                          fontStyle: FontStyle.italic)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Due day tile (guarded items list at bottom) ───────────────────────────────

class _DueDayTile extends StatelessWidget {
  final PlanItem item;
  final VoidCallback onChangeDueDay;

  const _DueDayTile({required this.item, required this.onChangeDueDay});

  @override
  Widget build(BuildContext context) {
    final rawDueDay = item.guardDueDay ?? 1;
    final freqLabel = item.frequency == PlanFrequency.monthly
        ? 'Monthly · Day $rawDueDay'
        : 'Yearly · Day $rawDueDay of ${YearMonth.monthNames[item.guardDueMonth ?? item.validFrom.month]}';
    final typeLabel = item.guardOneTime ? 'One-time' : 'Recurring';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading:
            const Icon(Icons.pets, color: AppColors.gold, size: 20),
        title: Text(item.name),
        subtitle: Text(
          '$freqLabel · $typeLabel',
          style:
              const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: TextButton(
          onPressed: onChangeDueDay,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.gold,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('Change day'),
        ),
      ),
    );
  }
}
