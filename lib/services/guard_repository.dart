import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/guard_payment.dart';
import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../utils/id_generator.dart';
import 'budget_calculator.dart';
import 'guard_calculator.dart';

class GuardRepository extends ChangeNotifier {
  final bool _persist;
  final List<GuardPayment> _payments = [];

  // Cached documents directory path — set once in load(), used by all file helpers.
  late String _baseDirPath;

  // Memoization cache for _collectGuardedPeriods.
  // Keyed by a string encoding (_payments.length, allItems.length, now, includeSilenced).
  // Cleared on every mutation so results never go stale.
  final Map<String, List<(PlanItem, YearMonth)>> _guardedPeriodsCache = {};

  GuardRepository({bool persist = true, List<GuardPayment>? seed})
      : _persist = persist {
    if (seed != null) _payments.addAll(seed);
  }

  List<GuardPayment> get payments => List.unmodifiable(_payments);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns the [GuardState] for a specific [item] in a specific [period].
  ///
  /// For non-guarded items or income items, returns [GuardState.none].
  /// For future periods, or the current period before its due day, returns
  /// [GuardState.none] — the reminder is not shown before it is due.
  /// For guarded items with no record that are due: [GuardState.unpaidActive].
  GuardState itemStateForPeriod(PlanItem item, YearMonth period) {
    if (!item.isGuarded || item.type != PlanItemType.fixedCost) {
      return GuardState.none;
    }

    // Yearly items only fire in their anchor month (validFrom.month).
    // Any other month is irrelevant regardless of the period's relation to now.
    if (item.frequency == PlanFrequency.yearly &&
        period.month != item.validFrom.month) {
      return GuardState.none;
    }

    final now = YearMonth.now();

    // Future period — reminder not yet due; show faint icon only.
    if (period.isAfter(now)) return GuardState.scheduled;

    // Current period — only alert from the due day onward.
    if (period == now) {
      final dueDay = GuardCalculator.clampDueDay(item.guardDueDay, period);
      if (DateTime.now().day < dueDay) return GuardState.scheduled;
    }

    return _stateForRecord(item.seriesId, period);
  }

  /// Returns all unresolved (unpaid active + silenced) guarded periods,
  /// each paired with the [PlanItem] version active for that period.
  ///
  /// Only returns periods that are already due (period <= [now] and the
  /// [guardDueDay] has arrived). Excludes paid periods.
  List<(PlanItem, YearMonth)> allUnresolvedItems(
      List<PlanItem> allItems, YearMonth now) {
    return _collectGuardedPeriods(allItems, now, includeSilenced: true);
  }

  /// Like [allUnresolvedItems] but excludes silenced periods.
  /// Used for the Expense tab strip and OS notification count.
  List<(PlanItem, YearMonth)> unpaidActiveItems(
      List<PlanItem> allItems, YearMonth now) {
    return _collectGuardedPeriods(allItems, now, includeSilenced: false);
  }

  /// Returns the next [YearMonth] in which [item]'s GUARD will fire, relative
  /// to [now]. Returns the current period when today is before the due day.
  /// Returns null if the item is not guarded, not a fixedCost, or has no
  /// future active period.
  YearMonth? nextReminderPeriod(
      PlanItem item, YearMonth now, List<PlanItem> allItems) {
    if (!item.isGuarded || item.type != PlanItemType.fixedCost) return null;
    if (item.frequency == PlanFrequency.oneTime) return null;

    final today = DateTime.now();

    if (item.frequency == PlanFrequency.monthly) {
      // Walk forward from now to find the next active period.
      for (var period = now;
          period.isBefore(now.addMonths(25));
          period = period.addMonths(1)) {
        final active = _activeGuardedVersionForPeriod(allItems, item.seriesId, period);
        if (active == null) continue;
        final dueDay = GuardCalculator.clampDueDay(active.guardDueDay, period);
        if (period != now || today.day <= dueDay) return period;
      }
    } else if (item.frequency == PlanFrequency.yearly) {
      // Walk forward year by year; anchor month is validFrom.month of the
      // active version for that period.
      for (var year = now.year; year <= now.year + 25; year++) {
        // Try the anchor month of the active version at the start of this year.
        final probe = YearMonth(year, item.validFrom.month);
        final active = _activeGuardedVersionForPeriod(allItems, item.seriesId, probe);
        if (active == null) continue;
        final anchorMonth = active.validFrom.month;
        final period = YearMonth(year, anchorMonth);
        final dueDay = GuardCalculator.clampDueDay(active.guardDueDay, period);
        final notYetPast = period.isAfter(now) ||
            (period == now && today.day <= dueDay);
        if (notYetPast) return period;
      }
    }
    return null;
  }

  /// Returns the last [YearMonth] in which [item]'s GUARD will fire, based on
  /// the effective end of the series. Returns null if the series is open-ended
  /// (the latest version has no [validTo]).
  YearMonth? lastReminderPeriod(PlanItem item, List<PlanItem> allItems) {
    if (!item.isGuarded || item.type != PlanItemType.fixedCost) return null;
    if (item.frequency == PlanFrequency.oneTime) return null;

    // Find all versions of this series. Filter by seriesId only — the early
    // isGuarded guard above already ensures the item is guarded; individual
    // versions may not all have the flag set in legacy data.
    final seriesVersions = allItems
        .where((i) => i.seriesId == item.seriesId)
        .toList();
    if (seriesVersions.isEmpty) return null;

    // If the latest version (highest validFrom) has no validTo, the series
    // is open-ended.
    final latestVersion = seriesVersions
        .reduce((a, b) => a.validFrom.isAfter(b.validFrom) ? a : b);
    if (latestVersion.validTo == null) return null;

    // The last reminder fires in the last anchor month at or before validTo.
    final effectiveEnd = latestVersion.validTo!;

    if (item.frequency == PlanFrequency.monthly) {
      return effectiveEnd;
    } else {
      // Yearly: find the last anchor month occurrence at or before validTo.
      final anchorMonth = latestVersion.validFrom.month;
      // Try current validTo year, then year-1 if anchor month is past validTo month.
      final candidate = YearMonth(effectiveEnd.year, anchorMonth);
      if (!candidate.isAfter(effectiveEnd)) return candidate;
      if (effectiveEnd.year > latestVersion.validFrom.year) {
        return YearMonth(effectiveEnd.year - 1, anchorMonth);
      }
      return null;
    }
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> confirmPayment(String seriesId, YearMonth period) async {
    final existing = _findRecord(seriesId, period);
    if (existing?.paidAt != null) return; // already paid
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _payments.add(GuardPayment(
      id: IdGenerator.generate(),
      planItemSeriesId: seriesId,
      period: period,
      paidAt: DateTime.now(),
    ));
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  Future<void> silencePayment(String seriesId, YearMonth period) async {
    final existing = _findRecord(seriesId, period);
    if (existing?.paidAt != null) return; // already paid, cannot silence
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _payments.add(GuardPayment(
      id: IdGenerator.generate(),
      planItemSeriesId: seriesId,
      period: period,
      silencedAt: DateTime.now(),
    ));
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  /// Updates the [paidAt] timestamp on an existing paid record.
  /// No-op if the record does not exist or is not in the paid state.
  Future<void> updatePaidDate(
      String seriesId, YearMonth period, DateTime newDate) async {
    final existing = _findRecord(seriesId, period);
    if (existing?.paidAt == null) return;
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _payments.add(GuardPayment(
      id: existing!.id,
      planItemSeriesId: seriesId,
      period: period,
      paidAt: newDate,
    ));
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  /// Removes the payment record entirely, returning the period to
  /// [GuardState.unpaidActive]. Used to undo an accidental confirmation.
  Future<void> revokePayment(String seriesId, YearMonth period) async {
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _payments.clear();
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(List<GuardPayment> payments) async {
    _payments
      ..clear()
      ..addAll(payments);
    _guardedPeriodsCache.clear();
    notifyListeners();
    await _save();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> load() async {
    if (!_persist) return;
    _baseDirPath = (await getApplicationDocumentsDirectory()).path;
    final file = _dataFile();
    if (!await file.exists()) return;
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final payments = (json['guardPayments'] as List? ?? [])
          .map((e) => GuardPayment.fromJson(e as Map<String, dynamic>))
          .toList();
      _payments
        ..clear()
        ..addAll(payments);
      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh.
    }
  }

  Future<void> _save() async {
    if (!_persist) return;
    final file = _dataFile();
    final data = jsonEncode({
      'guardPayments': _payments.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  File _dataFile() => File('$_baseDirPath/guard_payments.json');

  // ── Internal helpers ──────────────────────────────────────────────────────

  GuardPayment? _findRecord(String seriesId, YearMonth period) {
    for (final p in _payments) {
      if (p.planItemSeriesId == seriesId && p.period == period) return p;
    }
    return null;
  }

  GuardState _stateForRecord(String seriesId, YearMonth period) {
    final record = _findRecord(seriesId, period);
    if (record == null) return GuardState.unpaidActive;
    if (record.paidAt != null) return GuardState.paid;
    if (record.silencedAt != null) return GuardState.silenced;
    return GuardState.unpaidActive;
  }

  List<(PlanItem, YearMonth)> _collectGuardedPeriods(
    List<PlanItem> allItems,
    YearMonth now, {
    required bool includeSilenced,
  }) {
    // Key includes a fingerprint of all guard-relevant item fields so that
    // changes in PlanRepository (e.g. guardDueDay edits) correctly bust the
    // cache even without a GuardRepository mutation.
    final itemsFingerprint = StringBuffer();
    for (final item in allItems) {
      if (!item.isGuarded || item.type != PlanItemType.fixedCost) continue;
      itemsFingerprint.write(
        '${item.seriesId}:${item.validFrom.year}/${item.validFrom.month}:'
        '${item.validTo?.year ?? 0}/${item.validTo?.month ?? 0}:'
        '${item.guardDueDay};',
      );
    }
    final key =
        '${_payments.length}|${now.year}|${now.month}|${includeSilenced ? 1 : 0}|$itemsFingerprint';
    final cached = _guardedPeriodsCache[key];
    if (cached != null) return cached;

    final result = <(PlanItem, YearMonth)>[];
    final today = DateTime.now();

    final guardedSeriesIds = <String>{};
    for (final item in allItems) {
      if (item.isGuarded &&
          item.type == PlanItemType.fixedCost &&
          item.frequency != PlanFrequency.oneTime) {
        guardedSeriesIds.add(item.seriesId);
      }
    }

    for (final seriesId in guardedSeriesIds) {
      // Find the earliest validFrom across all versions of this series.
      YearMonth? earliest;
      for (final item in allItems) {
        if (item.seriesId != seriesId) continue;
        if (earliest == null || item.validFrom.isBefore(earliest)) {
          earliest = item.validFrom;
        }
      }
      if (earliest == null) continue;

      // Track which years have already been processed for yearly items
      // so we only fire once per calendar year for yearly-frequency periods.
      final processedYears = <int>{};

      var period = earliest;
      while (!period.isAfter(now)) {
        final activeVersion =
            _activeGuardedVersionForPeriod(allItems, seriesId, period);

        if (activeVersion != null) {
          final freq = activeVersion.frequency;

          if (freq == PlanFrequency.monthly) {
            // Monthly: check every period.
            final dueDay = GuardCalculator.clampDueDay(
                activeVersion.guardDueDay, period);
            final isDue = period != now || today.day >= dueDay;
            if (isDue) {
              final state = _stateForRecord(seriesId, period);
              if (state != GuardState.paid) {
                if (includeSilenced || state != GuardState.silenced) {
                  result.add((activeVersion, period));
                }
              }
            }
          } else if (freq == PlanFrequency.yearly) {
            // Yearly: only fire in the cycle anchor month (validFrom.month of
            // the active version), and only once per calendar year.
            final dueMonth = activeVersion.validFrom.month;
            if (period.month == dueMonth &&
                !processedYears.contains(period.year)) {
              processedYears.add(period.year);
              final dueDay = GuardCalculator.clampDueDay(
                  activeVersion.guardDueDay, period);
              final isDue = period != now || today.day >= dueDay;
              if (isDue) {
                final state = _stateForRecord(seriesId, period);
                if (state != GuardState.paid) {
                  if (includeSilenced || state != GuardState.silenced) {
                    result.add((activeVersion, period));
                  }
                }
              }
            }
          }
        }

        period = period.addMonths(1);
      }
    }

    _guardedPeriodsCache[key] = result;
    return result;
  }

  /// Returns the active version of a series for [period] if it is guarded,
  /// null otherwise.
  PlanItem? _activeGuardedVersionForPeriod(
    List<PlanItem> allItems,
    String seriesId,
    YearMonth period,
  ) {
    final activeItems = BudgetCalculator.activeItemsForMonth(
        allItems, period.year, period.month);
    for (final item in activeItems) {
      if (item.seriesId == seriesId && item.isGuarded) return item;
    }
    return null;
  }
}
