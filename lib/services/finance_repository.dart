import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/report_line.dart';
import '../models/year_month.dart';

class FinanceRepository extends ChangeNotifier {
  final bool _persist;
  final List<Expense> _expenses = [];

  FinanceRepository({
    bool persist = true,
    List<Expense>? seed,
  }) : _persist = persist {
    if (seed != null) _expenses.addAll(seed);
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Expense> get expenses => List.unmodifiable(_expenses);

  YearMonth? get earliestDataMonth {
    if (_expenses.isEmpty) return null;
    return _expenses
        .map((e) => YearMonth(e.date.year, e.date.month))
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  YearMonth? get latestDataMonth {
    if (_expenses.isEmpty) return null;
    return _expenses
        .map((e) => YearMonth(e.date.year, e.date.month))
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _save();
  }

  Future<void> updateExpense(Expense expense) async {
    final i = _expenses.indexWhere((e) => e.id == expense.id);
    if (i == -1) return;
    _expenses[i] = expense;
    notifyListeners();
    await _save();
  }

  Future<void> removeExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _expenses.clear();
    notifyListeners();
    await _save();
  }

  /// Bulk-appends [expenses] in a single write — used by the import flow.
  Future<void> addExpenses(List<Expense> expenses) async {
    _expenses.addAll(expenses);
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(List<Expense> expenses) async {
    _expenses
      ..clear()
      ..addAll(expenses);
    notifyListeners();
    await _save();
  }

  // ── Expense aggregations ─────────────────────────────────────────────────

  List<Expense> expensesForMonth(int year, int month) => _expenses
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  List<Expense> expensesForYear(int year) =>
      _expenses.where((e) => e.date.year == year).toList();

  /// Period-scoped group filter. Kept as a general-purpose helper;
  /// not used by the groups view (which uses [groupSummariesForMonth] instead).
  List<Expense> expensesForGroup(String group, int year, int month) =>
      expensesForMonth(year, month)
          .where((e) => e.group == group)
          .toList();

  /// Returns groups that are visible in [year]/[month] — i.e. have at least
  /// one expense in that period — each paired with ALL their expenses across
  /// all time, sorted by all-time total descending.
  List<MapEntry<String, List<Expense>>> groupSummariesForMonth(
      int year, int month) {
    final groupNamesInMonth = expensesForMonth(year, month)
        .where((e) => e.group != null)
        .map((e) => e.group!)
        .toSet();

    return groupNamesInMonth.map((name) {
      final all = _expenses.where((e) => e.group == name).toList();
      return MapEntry(name, all);
    }).toList()
      ..sort((a, b) {
        final ta = a.value.fold(0.0, (s, e) => s + e.amount);
        final tb = b.value.fold(0.0, (s, e) => s + e.amount);
        return tb.compareTo(ta);
      });
  }

  // ── Report lines (expenses only — fixed costs come from PlanRepository) ───

  /// Report lines for a single month containing only expense transactions.
  /// Fixed costs are sourced from PlanItems via BudgetCalculator and merged
  /// in the reporting layer (ReportScreen).
  List<ReportLine> reportLinesForMonth(int year, int month) {
    return expensesForMonth(year, month)
        .map((e) => ReportLine(
              category: e.category,
              financialType: e.financialType,
              amount: e.amount,
            ))
        .toList();
  }

  /// Report lines for a full year containing only expense transactions.
  List<ReportLine> reportLinesForYear(int year) {
    return expensesForYear(year)
        .map((e) => ReportLine(
              category: e.category,
              financialType: e.financialType,
              amount: e.amount,
            ))
        .toList();
  }

  // ── Persistence ──────────────────────────────────────────────────────────

  Future<void> load() async {
    if (!_persist) return;
    final file = await _dataFile();
    if (!await file.exists()) return;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final expenses = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();

      _expenses
        ..clear()
        ..addAll(expenses);

      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  Future<void> _save() async {
    if (!_persist) return;
    final file = await _dataFile();
    final data = jsonEncode({
      'expenses': _expenses.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/finance_data.json');
  }
}
