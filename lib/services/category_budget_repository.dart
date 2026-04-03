import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/category_budget.dart';
import '../models/expense_category.dart';
import '../models/year_month.dart';

class CategoryBudgetRepository extends ChangeNotifier {
  final bool _persist;
  final List<CategoryBudget> _budgets = [];

  CategoryBudgetRepository({bool persist = true, List<CategoryBudget>? seed})
      : _persist = persist {
    if (seed != null) _budgets.addAll(seed);
  }

  List<CategoryBudget> get budgets => List.unmodifiable(_budgets);

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns the budget amount active for [category] in [month], or null if
  /// no budget exists for that month.
  double? activeBudgetForMonth(ExpenseCategory category, YearMonth month) =>
      activeBudgetRecordForMonth(category, month)?.amount;

  /// Returns the full [CategoryBudget] record active for [category] in [month],
  /// or null if no budget exists for that month.
  CategoryBudget? activeBudgetRecordForMonth(
      ExpenseCategory category, YearMonth month) {
    for (final b in _budgets) {
      if (b.category != category) continue;
      if (b.validFrom.isAfter(month)) continue;
      if (b.validTo != null && b.validTo!.isBefore(month)) continue;
      return b;
    }
    return null;
  }

  /// Returns all categories that have an active budget in [month], mapped to
  /// their budget amount.
  Map<ExpenseCategory, double> allActiveBudgetsForMonth(YearMonth month) {
    final result = <ExpenseCategory, double>{};
    for (final b in _budgets) {
      if (b.validFrom.isAfter(month)) continue;
      if (b.validTo != null && b.validTo!.isBefore(month)) continue;
      result[b.category] = b.amount;
    }
    return result;
  }

  /// Computes the yearly budget total for [category] in [year] by summing the
  /// active monthly amount for each of the 12 months.
  double yearlyTotalForCategory(ExpenseCategory category, int year) {
    double total = 0.0;
    for (int m = 1; m <= 12; m++) {
      final budget = activeBudgetForMonth(category, YearMonth(year, m));
      if (budget != null) total += budget;
    }
    return total;
  }

  /// Returns yearly totals for all categories that have at least one active
  /// budget month in [year].
  Map<ExpenseCategory, double> allYearlyTotals(int year) {
    final result = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      final total = yearlyTotalForCategory(category, year);
      if (total > 0) result[category] = total;
    }
    return result;
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> addCategoryBudget(CategoryBudget budget) async {
    _budgets.add(budget);
    notifyListeners();
    await _save();
  }

  /// Applies a budget change for [seriesId] starting from [from].
  ///
  /// - If [from] equals the active version's validFrom: replaces in place
  ///   (error correction, no new version).
  /// - Otherwise: caps the current active version at [from] − 1 month and
  ///   adds a new version starting at [from]. Any future versions after [from]
  ///   in the same series are removed.
  Future<void> changeCategoryBudgetFrom(
    String seriesId,
    YearMonth from,
    double newAmount,
  ) async {
    // Find the version that covers [from].
    final activeIndex = _budgets.indexWhere(
      (b) =>
          b.seriesId == seriesId &&
          b.validFrom.isAtOrBefore(from) &&
          (b.validTo == null || b.validTo!.isAtOrAfter(from)),
    );

    if (activeIndex == -1) return;
    final active = _budgets[activeIndex];

    // Remove future versions (validFrom > from) for this series.
    _budgets.removeWhere(
      (b) => b.seriesId == seriesId && b.validFrom.isAfter(from),
    );

    if (from == active.validFrom) {
      // Correction in place — same validFrom, just update the amount.
      final idx = _budgets.indexWhere((b) => b.id == active.id);
      if (idx != -1) {
        _budgets[idx] = CategoryBudget(
          id: active.id,
          seriesId: active.seriesId,
          category: active.category,
          amount: newAmount,
          validFrom: active.validFrom,
          validTo: active.validTo,
        );
      }
    } else {
      // Forward change: cap current version, add new version.
      final idx = _budgets.indexWhere((b) => b.id == active.id);
      if (idx != -1) {
        _budgets[idx] = CategoryBudget(
          id: active.id,
          seriesId: active.seriesId,
          category: active.category,
          amount: active.amount,
          validFrom: active.validFrom,
          validTo: from.addMonths(-1),
        );
      }
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      _budgets.add(CategoryBudget(
        id: newId,
        seriesId: seriesId,
        category: active.category,
        amount: newAmount,
        validFrom: from,
        validTo: null,
      ));
    }

    notifyListeners();
    await _save();
  }

  /// Ends the budget series from [from] onwards, preserving history before it.
  ///
  /// - If [from] equals the active version's validFrom: removes the record
  ///   entirely (no history to keep).
  /// - Otherwise: sets validTo = [from] − 1 on the active version.
  Future<void> endCategoryBudget(String seriesId, YearMonth from) async {
    final activeIndex = _budgets.indexWhere(
      (b) =>
          b.seriesId == seriesId &&
          b.validFrom.isAtOrBefore(from) &&
          (b.validTo == null || b.validTo!.isAtOrAfter(from)),
    );

    if (activeIndex == -1) return;
    final active = _budgets[activeIndex];

    // Remove future versions.
    _budgets.removeWhere(
      (b) => b.seriesId == seriesId && b.validFrom.isAfter(from),
    );

    if (from == active.validFrom) {
      // Started exactly at [from] — remove entirely.
      _budgets.removeWhere((b) => b.id == active.id);
    } else {
      // Cap at from − 1 to preserve earlier history.
      final idx = _budgets.indexWhere((b) => b.id == active.id);
      if (idx != -1) {
        _budgets[idx] = CategoryBudget(
          id: active.id,
          seriesId: active.seriesId,
          category: active.category,
          amount: active.amount,
          validFrom: active.validFrom,
          validTo: from.addMonths(-1),
        );
      }
    }

    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _budgets.clear();
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(List<CategoryBudget> budgets) async {
    _budgets
      ..clear()
      ..addAll(budgets);
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
      final budgets = (json['categoryBudgets'] as List? ?? [])
          .map((e) => CategoryBudget.fromJson(e as Map<String, dynamic>))
          .toList();
      _budgets
        ..clear()
        ..addAll(budgets);
      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh.
    }
  }

  Future<void> _save() async {
    if (!_persist) return;
    final file = await _dataFile();
    final data = jsonEncode({
      'categoryBudgets': _budgets.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/category_budgets.json');
  }
}
