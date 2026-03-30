import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/guard_payment.dart';
import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import 'budget_calculator.dart';

class GuardRepository extends ChangeNotifier {
  final bool _persist;
  final List<GuardPayment> _payments = [];

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

    final now = YearMonth.now();

    // Future period — reminder not yet due; show faint icon only.
    if (period.isAfter(now)) return GuardState.scheduled;

    // Current period — only alert from the due day onward.
    if (period == now) {
      final rawDueDay = item.guardDueDay ?? 1;
      final daysInMonth = DateTime(period.year, period.month + 1, 0).day;
      final dueDay = rawDueDay.clamp(1, daysInMonth);
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

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> confirmPayment(String seriesId, YearMonth period) async {
    final existing = _findRecord(seriesId, period);
    if (existing?.paidAt != null) return; // already paid
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _payments.add(GuardPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      planItemSeriesId: seriesId,
      period: period,
      paidAt: DateTime.now(),
    ));
    notifyListeners();
    await _save();
  }

  Future<void> silencePayment(String seriesId, YearMonth period) async {
    final existing = _findRecord(seriesId, period);
    if (existing?.paidAt != null) return; // already paid, cannot silence
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    _payments.add(GuardPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      planItemSeriesId: seriesId,
      period: period,
      silencedAt: DateTime.now(),
    ));
    notifyListeners();
    await _save();
  }

  /// Removes the payment record entirely, returning the period to
  /// [GuardState.unpaidActive]. Used to undo an accidental confirmation.
  Future<void> revokePayment(String seriesId, YearMonth period) async {
    _payments.removeWhere(
        (p) => p.planItemSeriesId == seriesId && p.period == period);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _payments.clear();
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(List<GuardPayment> payments) async {
    _payments
      ..clear()
      ..addAll(payments);
    notifyListeners();
    await _save();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> load() async {
    if (!_persist) return;
    final file = await _dataFile();
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
    final file = await _dataFile();
    final data = jsonEncode({
      'guardPayments': _payments.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/guard_payments.json');
  }

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
    final result = <(PlanItem, YearMonth)>[];
    final today = DateTime.now();

    // Collect all unique seriesIds that have at least one guarded version.
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

      // Determine frequency from the latest version (most up-to-date config).
      PlanItem? latestVersion;
      for (final item in allItems) {
        if (item.seriesId != seriesId) continue;
        if (latestVersion == null ||
            item.validFrom.isAfter(latestVersion.validFrom)) {
          latestVersion = item;
        }
      }
      if (latestVersion == null) continue;

      final freq = latestVersion.frequency;

      if (freq == PlanFrequency.monthly) {
        var period = earliest;
        while (!period.isAfter(now)) {
          // Get the active version for this specific period.
          final activeVersion = _activeGuardedVersionForPeriod(
              allItems, seriesId, period);
          if (activeVersion != null) {
            // Cap the due day to the actual number of days in this month.
            final rawDueDay = activeVersion.guardDueDay ?? 1;
            final daysInMonth =
                DateTime(period.year, period.month + 1, 0).day;
            final dueDay = rawDueDay.clamp(1, daysInMonth);
            // Skip if due day hasn't arrived yet in the current month.
            final isDue = period != now || today.day >= dueDay;
            if (isDue) {
              final state = _stateForRecord(seriesId, period);
              if (state != GuardState.paid) {
                if (includeSilenced || state != GuardState.silenced) {
                  result.add((activeVersion, period));
                }
              }
            }
            // One-time guard: only fire for the validFrom period.
            if (activeVersion.guardOneTime) break;
          }
          period = period.addMonths(1);
        }
      } else if (freq == PlanFrequency.yearly) {
        // For yearly items, check one period per year. We determine the due
        // month from the active version for each specific year, not from
        // latestVersion — different versions may have different guardDueMonth.
        for (int year = earliest.year; year <= now.year; year++) {
          // Find the version active during this year to get its guardDueMonth.
          final versionForYear =
              _activeGuardedVersionForYear(allItems, seriesId, year);
          if (versionForYear == null) continue;

          final dueMonth =
              versionForYear.guardDueMonth ?? versionForYear.validFrom.month;
          final duePeriod = YearMonth(year, dueMonth);
          if (duePeriod.isAfter(now)) continue;

          // Get the precise active version for the exact due period.
          final activeVersion = _activeGuardedVersionForPeriod(
              allItems, seriesId, duePeriod);
          if (activeVersion != null) {
            // Cap the due day to the actual number of days in the due month.
            final rawDueDay = activeVersion.guardDueDay ?? 1;
            final daysInMonth =
                DateTime(duePeriod.year, duePeriod.month + 1, 0).day;
            final dueDay = rawDueDay.clamp(1, daysInMonth);
            // Skip if due day hasn't arrived yet in the current month/year.
            final isDue = duePeriod != now || today.day >= dueDay;
            if (isDue) {
              final state = _stateForRecord(seriesId, duePeriod);
              if (state != GuardState.paid) {
                if (includeSilenced || state != GuardState.silenced) {
                  result.add((activeVersion, duePeriod));
                }
              }
            }
            // One-time guard: only fire for the first eligible year.
            if (activeVersion.guardOneTime) break;
          }
        }
      }
    }

    return result;
  }

  /// Returns the active guarded version of [seriesId] active at some point
  /// during [year] (i.e. validFrom.year <= year and not expired before [year]).
  /// Used to determine [guardDueMonth] for yearly items on a per-year basis.
  PlanItem? _activeGuardedVersionForYear(
    List<PlanItem> allItems,
    String seriesId,
    int year,
  ) {
    PlanItem? result;
    for (final item in allItems) {
      if (item.seriesId != seriesId) continue;
      if (!item.isGuarded) continue;
      if (item.validFrom.year > year) continue;
      if (item.validTo != null && item.validTo!.isBefore(YearMonth(year, 1))) continue;
      if (result == null || item.validFrom.isAfter(result.validFrom)) {
        result = item;
      }
    }
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
