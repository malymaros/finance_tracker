import 'package:flutter/material.dart';

import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../theme/app_theme.dart';

/// In-app GUARD reminder card shown at the top of the Plan tab.
///
/// Displays two groups:
///   - [unpaidActive]: items with active unconfirmed payments (full alert style)
///   - [silenced]: items the user has silenced but not yet paid (muted style)
///
/// Disappears when both lists are empty.
class GuardBanner extends StatelessWidget {
  final List<(PlanItem, YearMonth)> unpaidActive;
  final List<(PlanItem, YearMonth)> silenced;
  final void Function(String seriesId, YearMonth period) onMarkPaid;
  final void Function(String seriesId, YearMonth period) onSilence;
  final void Function(PlanItem item, YearMonth period)? onTapItem;

  const GuardBanner({
    super.key,
    required this.unpaidActive,
    required this.silenced,
    required this.onMarkPaid,
    required this.onSilence,
    this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (unpaidActive.isEmpty && silenced.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.gold.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unpaidActive.isNotEmpty
                ? AppColors.gold.withAlpha(120)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            ...unpaidActive.map((pair) => _buildActiveRow(context, pair)),
            ...silenced.map((pair) => _buildSilencedRow(context, pair)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final count = unpaidActive.length + silenced.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          const Icon(Icons.pets, color: AppColors.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              count == 1
                  ? 'GUARD — 1 payment not confirmed'
                  : 'GUARD — $count payments not confirmed',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRow(BuildContext context, (PlanItem, YearMonth) pair) {
    final (item, period) = pair;
    return _GuardRow(
      item: item,
      period: period,
      isSilenced: false,
      onMarkPaid: () => onMarkPaid(item.seriesId, period),
      onSilence: () => onSilence(item.seriesId, period),
      onTapName: onTapItem != null ? () => onTapItem!(item, period) : null,
    );
  }

  Widget _buildSilencedRow(BuildContext context, (PlanItem, YearMonth) pair) {
    final (item, period) = pair;
    return _GuardRow(
      item: item,
      period: period,
      isSilenced: true,
      onMarkPaid: () => onMarkPaid(item.seriesId, period),
      onSilence: null,
      onTapName: onTapItem != null ? () => onTapItem!(item, period) : null,
    );
  }
}

// ── Individual guard row ──────────────────────────────────────────────────────

class _GuardRow extends StatelessWidget {
  final PlanItem item;
  final YearMonth period;
  final bool isSilenced;
  final VoidCallback onMarkPaid;
  final VoidCallback? onSilence;
  final VoidCallback? onTapName;

  const _GuardRow({
    required this.item,
    required this.period,
    required this.isSilenced,
    required this.onMarkPaid,
    this.onSilence,
    this.onTapName,
  });

  @override
  Widget build(BuildContext context) {
    final periodLabel =
        '${YearMonth.monthAbbreviations[period.month]} ${period.year}';
    final nameColor =
        isSilenced ? AppColors.textMuted : AppColors.guardItemText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTapName,
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: nameColor,
                      fontStyle:
                          isSilenced ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      periodLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (isSilenced) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.notifications_off,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        'silenced',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onSilence != null)
            TextButton(
              onPressed: onSilence,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppColors.textMuted,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text('Silence', style: TextStyle(fontSize: 12)),
            ),
          FilledButton(
            onPressed: onMarkPaid,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.white,
              visualDensity: VisualDensity.compact,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Paid'),
          ),
        ],
      ),
    );
  }
}
