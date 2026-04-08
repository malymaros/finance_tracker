import 'package:flutter/material.dart';

import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../services/plan_repository.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for enabling, configuring, or disabling GUARD on a single
/// fixed cost plan item.
///
/// Shown from the long-press menu (via [SwipeableTile]) and from
/// [PlanItemDetailScreen]. Calls [PlanRepository] directly on save.
///
/// Enabling updates only the active version ([item.id]). Disabling calls
/// [PlanRepository.disableGuardForSeries] which clears all versions —
/// consistent with the Guard settings screen behavior.
class GuardSetupSheet extends StatefulWidget {
  final PlanItem item;
  final PlanRepository planRepository;

  const GuardSetupSheet({
    super.key,
    required this.item,
    required this.planRepository,
  });

  /// Shows this sheet as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required PlanItem item,
    required PlanRepository planRepository,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => GuardSetupSheet(
        item: item,
        planRepository: planRepository,
      ),
    );
  }

  @override
  State<GuardSetupSheet> createState() => _GuardSetupSheetState();
}

class _GuardSetupSheetState extends State<GuardSetupSheet> {
  late bool _enabled;
  late int _dueDay;

  @override
  void initState() {
    super.initState();
    _enabled = widget.item.isGuarded;
    _dueDay = widget.item.guardDueDay ?? 1;
  }

  int get _daysInAnchorMonth {
    final m = widget.item.validFrom.month;
    return DateTime(DateTime.now().year, m + 1, 0).day;
  }

  String get _dueDayLabel {
    return widget.item.frequency == PlanFrequency.monthly
        ? 'Day $_dueDay of each month'
        : 'Day $_dueDay of ${YearMonth.monthNames[widget.item.validFrom.month]}'
            ' each year';
  }

  Future<void> _pickDueDay() async {
    final daysInMonth = _daysInAnchorMonth;
    final safe = _dueDay.clamp(1, daysInMonth);
    int selected = safe;

    final title = widget.item.frequency == PlanFrequency.monthly
        ? 'Due day (repeats monthly)'
        : 'Due day (repeats every '
            '${YearMonth.monthNames[widget.item.validFrom.month]})';

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
    if (picked != null && mounted) setState(() => _dueDay = picked);
  }

  Future<void> _save() async {
    if (!_enabled && widget.item.isGuarded) {
      // Disabling an active guard — confirm first.
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
      if (confirmed != true || !mounted) return;
      await widget.planRepository.disableGuardForSeries(
          widget.item.seriesId);
    } else if (_enabled) {
      await widget.planRepository.enableGuardForItem(
          widget.item.id,
          dueDay: _dueDay);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            const Row(
              children: [
                Icon(Icons.pets, color: AppColors.gold, size: 18),
                SizedBox(width: 8),
                Text(
                  'GUARD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.name,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            // Enable / disable toggle
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enable GUARD',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Track payment and receive reminders',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enabled,
                  activeThumbColor: AppColors.gold,
                  activeTrackColor: AppColors.gold.withAlpha(80),
                  onChanged: (on) => setState(() => _enabled = on),
                ),
              ],
            ),
            if (_enabled) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDueDay,
                icon: const Icon(Icons.event_outlined, size: 16),
                label: Text(_dueDayLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold),
                  alignment: Alignment.centerLeft,
                ),
              ),
              if (_dueDay > 28)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Days 29–31 are clamped to the last day in shorter months.',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
