import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category_preferences.dart';
import '../models/expense_category.dart';

class CategoryPreferencesRepository extends ChangeNotifier {
  @visibleForTesting
  static String? testBaseDirOverride;

  CategoryPreferences _prefs = const CategoryPreferences.empty();

  CategoryPreferences get preferences => _prefs;

  Set<ExpenseCategory> get visibleForExpenses => _prefs.visibleForExpenses;
  Set<ExpenseCategory> get visibleForPlan => _prefs.visibleForPlan;

  bool isVisibleForExpenses(ExpenseCategory cat) =>
      _prefs.visibleForExpenses.contains(cat);

  bool isVisibleForPlan(ExpenseCategory cat) =>
      _prefs.visibleForPlan.contains(cat);

  Future<String> _filePath() async {
    final base = testBaseDirOverride ??
        (await getApplicationDocumentsDirectory()).path;
    return '$base/category_preferences.json';
  }

  Future<void> load() async {
    try {
      final file = File(await _filePath());
      if (!await file.exists()) return;
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      _prefs = CategoryPreferences.fromJson(json);
      notifyListeners();
    } catch (_) {
      // Silent fail — starts with empty defaults.
    }
  }

  Future<void> toggleExpenses(ExpenseCategory cat) async {
    if (cat == ExpenseCategory.other) return;
    final visible = _prefs.visibleForExpenses;
    final added = Set<ExpenseCategory>.from(_prefs.expensesAdded);
    final removed = Set<ExpenseCategory>.from(_prefs.expensesRemoved);

    if (visible.contains(cat)) {
      // Currently visible → remove from default list.
      if (CategoryPreferences.defaultExpenses.contains(cat)) {
        removed.add(cat);
        added.remove(cat);
      } else {
        added.remove(cat);
      }
    } else {
      // Currently hidden → add to default list.
      if (CategoryPreferences.defaultExpenses.contains(cat)) {
        removed.remove(cat);
      } else {
        added.add(cat);
      }
    }

    _prefs = _prefs.copyWith(expensesAdded: added, expensesRemoved: removed);
    notifyListeners();
    await _persist();
  }

  Future<void> togglePlan(ExpenseCategory cat) async {
    if (cat == ExpenseCategory.other) return;
    final visible = _prefs.visibleForPlan;
    final added = Set<ExpenseCategory>.from(_prefs.planAdded);
    final removed = Set<ExpenseCategory>.from(_prefs.planRemoved);

    if (visible.contains(cat)) {
      if (CategoryPreferences.defaultPlan.contains(cat)) {
        removed.add(cat);
        added.remove(cat);
      } else {
        added.remove(cat);
      }
    } else {
      if (CategoryPreferences.defaultPlan.contains(cat)) {
        removed.remove(cat);
      } else {
        added.add(cat);
      }
    }

    _prefs = _prefs.copyWith(planAdded: added, planRemoved: removed);
    notifyListeners();
    await _persist();
  }

  Future<void> restoreFromSnapshot(Map<String, dynamic>? json) async {
    _prefs = json != null
        ? CategoryPreferences.fromJson(json)
        : const CategoryPreferences.empty();
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _prefs = const CategoryPreferences.empty();
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final file = File(await _filePath());
      await file.writeAsString(jsonEncode(_prefs.toJson()));
    } catch (_) {}
  }
}
