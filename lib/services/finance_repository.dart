import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/fixed_cost.dart';
import '../models/income_entry.dart';
import '../models/report_line.dart';

class FinanceRepository extends ChangeNotifier {
  final bool _persist;
  final List<Expense> _expenses = [];
  final List<IncomeEntry> _income = [];
  final List<FixedCost> _fixedCosts = [];

  FinanceRepository({
    bool persist = true,
    List<Expense>? seed,
    List<IncomeEntry>? seedIncome,
    List<FixedCost>? seedFixedCosts,
  }) : _persist = persist {
    if (seed != null) _expenses.addAll(seed);
    if (seedIncome != null) _income.addAll(seedIncome);
    if (seedFixedCosts != null) _fixedCosts.addAll(seedFixedCosts);
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<IncomeEntry> get income => List.unmodifiable(_income);
  List<FixedCost> get fixedCosts => List.unmodifiable(_fixedCosts);

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

  Future<void> addIncome(IncomeEntry entry) async {
    _income.add(entry);
    notifyListeners();
    await _save();
  }

  Future<void> updateIncome(IncomeEntry entry) async {
    final i = _income.indexWhere((e) => e.id == entry.id);
    if (i == -1) return;
    _income[i] = entry;
    notifyListeners();
    await _save();
  }

  Future<void> removeIncome(String id) async {
    _income.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> addFixedCost(FixedCost cost) async {
    _fixedCosts.add(cost);
    notifyListeners();
    await _save();
  }

  Future<void> updateFixedCost(FixedCost cost) async {
    final i = _fixedCosts.indexWhere((fc) => fc.id == cost.id);
    if (i == -1) return;
    _fixedCosts[i] = cost;
    notifyListeners();
    await _save();
  }

  Future<void> removeFixedCost(String id) async {
    _fixedCosts.removeWhere((fc) => fc.id == id);
    notifyListeners();
    await _save();
  }

  // ── Expense aggregations ─────────────────────────────────────────────────

  List<Expense> expensesForMonth(int year, int month) => _expenses
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  List<Expense> expensesForYear(int year) =>
      _expenses.where((e) => e.date.year == year).toList();

  // ── Income aggregations ──────────────────────────────────────────────────

  List<IncomeEntry> incomeForMonth(int year, int month) => _income
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  double totalIncomeForMonth(int year, int month) =>
      incomeForMonth(year, month).fold(0.0, (sum, e) => sum + e.amount);

  // ── Fixed cost aggregations ──────────────────────────────────────────────

  /// Returns fixed costs that apply in the given month.
  /// Monthly costs: active if started on or before [year]/[month].
  /// Yearly costs: active if [startMonth] == [month] and started by [year].
  List<FixedCost> fixedCostsForMonth(int year, int month) {
    return _fixedCosts.where((fc) {
      if (fc.recurrence == Recurrence.monthly) {
        return fc.startYear < year ||
            (fc.startYear == year && fc.startMonth <= month);
      } else {
        return fc.startMonth == month && fc.startYear <= year;
      }
    }).toList();
  }

  double totalFixedCostsForMonth(int year, int month) =>
      fixedCostsForMonth(year, month).fold(0.0, (sum, fc) => sum + fc.amount);

  /// Sums all fixed costs over an entire year.
  /// Monthly costs are multiplied by the number of months they are active.
  /// Yearly costs count once if they apply in that year.
  double totalFixedCostsForYear(int year) {
    double total = 0;
    for (final fc in _fixedCosts) {
      if (fc.recurrence == Recurrence.monthly) {
        for (int m = 1; m <= 12; m++) {
          if (fc.startYear < year ||
              (fc.startYear == year && fc.startMonth <= m)) {
            total += fc.amount;
          }
        }
      } else {
        if (fc.startYear <= year) total += fc.amount;
      }
    }
    return total;
  }

  // ── Report lines (expenses + fixed costs combined) ───────────────────────

  /// Combined report lines for a single month.
  /// Expenses: each at their recorded amount.
  /// Fixed costs active in the month: monthly → full amount, yearly → amount/12.
  List<ReportLine> reportLinesForMonth(int year, int month) {
    final lines = <ReportLine>[];

    for (final e in expensesForMonth(year, month)) {
      lines.add(ReportLine(
          category: e.category,
          financialType: e.financialType,
          amount: e.amount));
    }

    for (final fc in fixedCostsForMonth(year, month)) {
      final amount = fc.recurrence == Recurrence.yearly
          ? fc.amount / 12
          : fc.amount;
      lines.add(ReportLine(
          category: fc.category,
          financialType: fc.financialType,
          amount: amount));
    }

    return lines;
  }

  /// Combined report lines for a full year.
  /// Expenses: each at their recorded amount.
  /// Fixed costs: monthly → amount × active months in year, yearly → full amount.
  List<ReportLine> reportLinesForYear(int year) {
    final lines = <ReportLine>[];

    for (final e in expensesForYear(year)) {
      lines.add(ReportLine(
          category: e.category,
          financialType: e.financialType,
          amount: e.amount));
    }

    for (final fc in _fixedCosts) {
      if (fc.recurrence == Recurrence.monthly) {
        double total = 0;
        for (int m = 1; m <= 12; m++) {
          if (fc.startYear < year ||
              (fc.startYear == year && fc.startMonth <= m)) {
            total += fc.amount;
          }
        }
        if (total > 0) {
          lines.add(ReportLine(
              category: fc.category,
              financialType: fc.financialType,
              amount: total));
        }
      } else {
        if (fc.startYear <= year) {
          lines.add(ReportLine(
              category: fc.category,
              financialType: fc.financialType,
              amount: fc.amount));
        }
      }
    }

    return lines;
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
      final income = (json['income'] as List? ?? [])
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      final fixedCosts = (json['fixedCosts'] as List? ?? [])
          .map((e) => FixedCost.fromJson(e as Map<String, dynamic>))
          .toList();

      _expenses
        ..clear()
        ..addAll(expenses);
      _income
        ..clear()
        ..addAll(income);
      _fixedCosts
        ..clear()
        ..addAll(fixedCosts);

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
      'income': _income.map((e) => e.toJson()).toList(),
      'fixedCosts': _fixedCosts.map((e) => e.toJson()).toList(),
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/finance_data.json');
  }
}
