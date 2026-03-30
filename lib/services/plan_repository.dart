import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/plan_item.dart';
import '../models/year_month.dart';

class PlanRepository extends ChangeNotifier {
  final bool _persist;
  final List<PlanItem> _items = [];

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
      _items[i] = PlanItem(
        id: old.id,
        seriesId: old.seriesId,
        name: old.name,
        amount: old.amount,
        type: old.type,
        frequency: old.frequency,
        validFrom: old.validFrom,
        validTo: old.validTo,
        note: old.note,
        category: old.category,
        financialType: old.financialType,
        isGuarded: old.isGuarded,
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth ?? old.guardDueMonth,
        guardOneTime: old.guardOneTime,
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
      final old = _items[i];
      _items[i] = PlanItem(
        id: old.id,
        seriesId: old.seriesId,
        name: old.name,
        amount: old.amount,
        type: old.type,
        frequency: old.frequency,
        validFrom: old.validFrom,
        validTo: old.validTo,
        note: old.note,
        category: old.category,
        financialType: old.financialType,
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
      _items.add(PlanItem(
        id: item.id,
        seriesId: item.seriesId,
        name: item.name,
        amount: item.amount,
        type: item.type,
        frequency: item.frequency,
        validFrom: item.validFrom,
        validTo: from.addMonths(-1),
        note: item.note,
        category: item.category,
        financialType: item.financialType,
        isGuarded: item.isGuarded,
        guardDueDay: item.guardDueDay,
        guardDueMonth: item.guardDueMonth,
        guardOneTime: item.guardOneTime,
      ));
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
    final file = await _dataFile();
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
    final file = await _dataFile();
    final data = jsonEncode({
      'planItems': _items.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/plan_data.json');
  }
}
