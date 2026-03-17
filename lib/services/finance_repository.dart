import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/income_entry.dart';
import '../models/report_line.dart';
import '../models/year_month.dart';

class FinanceRepository extends ChangeNotifier {
  final bool _persist;
  final List<Expense> _expenses = [];
  final List<IncomeEntry> _income = [];

  FinanceRepository({
    bool persist = true,
    List<Expense>? seed,
    List<IncomeEntry>? seedIncome,
  }) : _persist = persist {
    if (seed != null) _expenses.addAll(seed);
    if (seedIncome != null) _income.addAll(seedIncome);
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<IncomeEntry> get income => List.unmodifiable(_income);

  YearMonth? get earliestDataMonth {
    final candidates = <YearMonth>[
      ..._expenses.map((e) => YearMonth(e.date.year, e.date.month)),
      ..._income.map((e) => YearMonth(e.date.year, e.date.month)),
    ];
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) => a.isBefore(b) ? a : b);
  }

  YearMonth? get latestDataMonth {
    final candidates = <YearMonth>[
      ..._expenses.map((e) => YearMonth(e.date.year, e.date.month)),
      ..._income.map((e) => YearMonth(e.date.year, e.date.month)),
    ];
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) => a.isAfter(b) ? a : b);
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

  Future<void> clearAll() async {
    _expenses.clear();
    _income.clear();
    notifyListeners();
    await _save();
  }

  Future<void> restoreFromSnapshot(
      List<Expense> expenses, List<IncomeEntry> income) async {
    _expenses
      ..clear()
      ..addAll(expenses);
    _income
      ..clear()
      ..addAll(income);
    notifyListeners();
    await _save();
  }

  // ── Expense aggregations ─────────────────────────────────────────────────

  List<Expense> expensesForMonth(int year, int month) => _expenses
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  List<Expense> expensesForYear(int year) =>
      _expenses.where((e) => e.date.year == year).toList();

  List<Expense> expensesForGroup(String group, int year, int month) =>
      expensesForMonth(year, month)
          .where((e) => e.group == group)
          .toList();

  // ── Income aggregations ──────────────────────────────────────────────────

  List<IncomeEntry> incomeForMonth(int year, int month) => _income
      .where((e) => e.date.year == year && e.date.month == month)
      .toList();

  double totalIncomeForMonth(int year, int month) =>
      incomeForMonth(year, month).fold(0.0, (sum, e) => sum + e.amount);

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
      final income = (json['income'] as List? ?? [])
          .map((e) => IncomeEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      _expenses
        ..clear()
        ..addAll(expenses);
      _income
        ..clear()
        ..addAll(income);

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
    });
    await file.writeAsString(data);
  }

  Future<File> _dataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/finance_data.json');
  }
}
