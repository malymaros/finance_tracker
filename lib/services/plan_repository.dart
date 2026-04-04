import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../utils/id_generator.dart';

class PlanRepository extends ChangeNotifier {
  final bool _persist;
  final List<PlanItem> _items = [];

  // Cached documents directory path — set once in load(), used by all file helpers.
  late String _baseDirPath;

  PlanRepository({bool persist = true, List<PlanItem>? seed})
      : _persist = persist {
    if (seed != null) _items.addAll(seed);
  }

  List<PlanItem> get items => List.unmodifiable(_items);

  YearMonth? get earliestDataMonth {
    if (_items.isEmpty) return null;
    return _items.map((i) => i.validFrom).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  YearMonth? get latestDataMonth {
    if (_items.isEmpty) return null;
    return _items.map((i) => i.validFrom).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> addPlanItem(PlanItem item) async {
    _items.add(item);
    notifyListeners();
    await _save();
  }

  /// Updates [guardDueDay] and optionally [guardDueMonth] on every version of
  /// [seriesId]. Used by GuardScreen to change the due-day without creating a
  /// new plan item version — guard config is a notification preference, not a
  /// financial change.
  Future<void> updateGuardConfigForSeries(
    String seriesId, {
    required int? guardDueDay,
    int? guardDueMonth,
  }) async {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].seriesId != seriesId) continue;
      final old = _items[i];
      _items[i] = old.copyWith(
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth ?? old.guardDueMonth,
      );
      changed = true;
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }

  /// Disables GUARD on every version of [seriesId], clearing all guard fields.
  /// Used by GuardScreen to remove a guard without editing the item form.
  Future<void> disableGuardForSeries(String seriesId) async {
    bool changed = false;
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].seriesId != seriesId) continue;
      if (!_items[i].isGuarded) continue;
      _items[i] = _items[i].copyWith(
        isGuarded: false,
        guardDueDay: null,
        guardDueMonth: null,
        guardOneTime: false,
      );
      changed = true;
    }
    if (changed) {
      notifyListeners();
      await _save();
    }
  }

  /// Replaces a specific version in-place (used for error correction).
  Future<void> updatePlanItem(PlanItem item) async {
    final i = _items.indexWhere((e) => e.id == item.id);
    if (i == -1) return;
    _items[i] = item;
    notifyListeners();
    await _save();
  }

  /// Removes a single version by id.
  /// If it was the only version in its series, the series disappears.
  /// If prior versions exist, the previous one becomes active again.
  Future<void> removePlanItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  /// Stops the income/cost series from [from] onwards.
  ///
  /// - If the active version starts exactly on [from]: removes it entirely,
  ///   plus any later versions in the same series.
  /// - If the active version started before [from]: sets its validTo to the
  ///   month before [from] so prior months remain planned, then removes any
  ///   later versions in the same series (validFrom >= [from]).
  Future<void> removePlanItemFrom(String id, YearMonth from) async {
    final item = _items.firstWhere((e) => e.id == id);

    // Remove the active version by ID.
    _items.removeWhere((e) => e.id == id);

    // Remove any later versions in the same series (validFrom >= from).
    _items.removeWhere((e) =>
        e.seriesId == item.seriesId && e.validFrom.isAtOrAfter(from));

    // If the active version started before [from], add it back with validTo
    // set to the month before [from] so prior months remain intact.
    if (item.validFrom.isBefore(from)) {
      _items.add(item.copyWith(validTo: from.addMonths(-1)));
    }

    notifyListeners();
    await _save();
  }

  /// Removes all versions in [seriesId] whose validFrom is strictly after [after].
  /// Used after an edit to truncate superseded future versions.
  Future<void> removeFutureVersions(String seriesId, YearMonth after) async {
    _items.removeWhere(
        (e) => e.seriesId == seriesId && e.validFrom.isAfter(after));
    notifyListeners();
    await _save();
  }

  /// Applies an edit to [existing] using the given form values.
  ///
  /// Versioning rules:
  /// - **Income items**: always updated in place; [startFrom] is ignored and
  ///   the original [PlanItem.validFrom] is preserved.
  /// - **One-time items**: always updated in place (no versioning applies).
  /// - **Fixed cost, [startFrom] == [existing.validFrom]**: updated in place
  ///   (error correction; no new version created).
  /// - **Fixed cost, [startFrom] != [existing.validFrom]**: a new version
  ///   starting at [startFrom] is added and future versions of the same series
  ///   are removed via [removeFutureVersions].
  Future<void> applyPlanItemEdit(
    PlanItem existing, {
    required String name,
    required double amount,
    required PlanFrequency frequency,
    required YearMonth startFrom,
    required YearMonth? validTo,
    String? note,
    ExpenseCategory? category,
    FinancialType? financialType,
    bool isGuarded = false,
    int? guardDueDay,
    int? guardDueMonth,
    bool guardOneTime = false,
  }) async {
    final inPlace = existing.type == PlanItemType.income ||
        existing.frequency == PlanFrequency.oneTime ||
        startFrom == existing.validFrom;

    if (inPlace) {
      await updatePlanItem(PlanItem(
        id: existing.id,
        seriesId: existing.seriesId,
        name: name,
        amount: amount,
        type: existing.type,
        frequency: frequency,
        validFrom: existing.validFrom,
        validTo: validTo,
        note: note,
        category: category,
        financialType: financialType,
        isGuarded: isGuarded,
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth,
        guardOneTime: guardOneTime,
      ));
    } else {
      final newId = IdGenerator.generate();
      await addPlanItem(PlanItem(
        id: newId,
        seriesId: existing.seriesId,
        name: name,
        amount: amount,
        type: existing.type,
        frequency: frequency,
        validFrom: startFrom,
        validTo: validTo,
        note: note,
        category: category,
        financialType: financialType,
        isGuarded: isGuarded,
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth,
        guardOneTime: guardOneTime,
      ));
      await removeFutureVersions(existing.seriesId, startFrom);
    }
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(List<PlanItem> items) async {
    _items
      ..clear()
      ..addAll(items);
    notifyListeners();
    await _save();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> load() async {
    if (!_persist) return;
    _baseDirPath = (await getApplicationDocumentsDirectory()).path;
    final file = _dataFile();
    if (!await file.exists()) return;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final items = (json['planItems'] as List? ?? [])
          .map((e) => PlanItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _items
        ..clear()
        ..addAll(items);
      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  Future<void> _save() async {
    if (!_persist) return;
    final file = _dataFile();
    final data = jsonEncode({
      'planItems': _items.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  File _dataFile() => File('$_baseDirPath/plan_data.json');
}
