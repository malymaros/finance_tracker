import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/plan_item.dart';

class PlanRepository extends ChangeNotifier {
  final bool _persist;
  final List<PlanItem> _items = [];

  PlanRepository({bool persist = true, List<PlanItem>? seed})
      : _persist = persist {
    if (seed != null) _items.addAll(seed);
  }

  List<PlanItem> get items => List.unmodifiable(_items);

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> addPlanItem(PlanItem item) async {
    _items.add(item);
    notifyListeners();
    await _save();
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

  Future<void> clearAll() async {
    _items.clear();
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
