import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';
import '../models/report_line.dart';
import '../models/year_month.dart';

/// Expense repository with year-based lazy loading.
///
/// Storage layout (in getApplicationDocumentsDirectory()):
///   finance_index.json      — list of years that have data
///   finance_YYYY.json       — expenses for each year
///
/// Only the current year is loaded on startup. Other years are loaded on
/// demand via [loadYear]. Call [loadAllYears] before operations that require
/// complete data (export, save-slot creation).
///
/// Legacy [finance_data.json] is silently migrated on first launch.
class FinanceRepository extends ChangeNotifier {
  final bool _persist;

  // Year-keyed expense storage. A key is present only when that year is loaded.
  final Map<int, List<Expense>> _expensesByYear = {};

  // Years that have a data file on disk (or in-memory when persist==false).
  final Set<int> _availableYears = {};

  // Cached documents directory path — set once in load(), used by all file helpers.
  late String _baseDirPath;

  FinanceRepository({
    bool persist = true,
    List<Expense>? seed,
  }) : _persist = persist {
    if (seed != null) {
      for (final e in seed) {
        _expensesByYear.putIfAbsent(e.date.year, () => []).add(e);
        _availableYears.add(e.date.year);
      }
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  /// All expenses from currently loaded years, in ascending year order,
  /// preserving insertion order within each year.
  List<Expense> get expenses {
    final result = <Expense>[];
    final sortedYears = _expensesByYear.keys.toList()..sort();
    for (final year in sortedYears) {
      result.addAll(_expensesByYear[year]!);
    }
    return List.unmodifiable(result);
  }

  bool isYearLoaded(int year) => _expensesByYear.containsKey(year);
  bool hasDataForYear(int year) => _availableYears.contains(year);

  /// Earliest month with data, based on available years (Jan of the min year).
  YearMonth? get earliestDataMonth {
    if (_availableYears.isEmpty) return null;
    return YearMonth(_availableYears.reduce((a, b) => a < b ? a : b), 1);
  }

  /// Latest month with data, based on available years (Dec of the max year).
  YearMonth? get latestDataMonth {
    if (_availableYears.isEmpty) return null;
    return YearMonth(_availableYears.reduce((a, b) => a > b ? a : b), 12);
  }

  // ── Year loading ─────────────────────────────────────────────────────────

  /// Loads expenses for [year] from disk if not already in memory.
  /// No-op when [year] is already loaded.
  /// Calls [notifyListeners] after loading new data.
  Future<void> loadYear(int year) async {
    if (_expensesByYear.containsKey(year)) return;

    if (!_persist) {
      _expensesByYear[year] = [];
      return;
    }

    final file = _yearFile(year);
    if (!await file.exists()) {
      _expensesByYear[year] = [];
      return;
    }

    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final list = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      _expensesByYear[year] = list;
      _availableYears.add(year);
    } catch (_) {
      _expensesByYear[year] = [];
    }

    notifyListeners();
  }

  /// Loads every year that has a data file.
  /// Use before export or save-slot creation to ensure no data is missing.
  Future<void> loadAllYears() async {
    for (final year in List.of(_availableYears)) {
      await loadYear(year);
    }
  }

  // ── Mutations ────────────────────────────────────────────────────────────

  Future<void> addExpense(Expense expense) async {
    final year = expense.date.year;
    _expensesByYear.putIfAbsent(year, () => []).add(expense);
    _availableYears.add(year);
    notifyListeners();
    await _saveYear(year);
    await _saveIndex();
  }

  Future<void> updateExpense(Expense expense) async {
    // Search by ID across all loaded year buckets — the year may have changed
    // if the user edited the expense date.
    int? originalYear;
    for (final year in List.of(_expensesByYear.keys)) {
      final list = _expensesByYear[year]!;
      final i = list.indexWhere((e) => e.id == expense.id);
      if (i != -1) {
        originalYear = year;
        list.removeAt(i);
        break;
      }
    }
    if (originalYear == null) return;

    final newYear = expense.date.year;
    _expensesByYear.putIfAbsent(newYear, () => []).add(expense);
    _availableYears.add(newYear);
    notifyListeners();

    if (originalYear != newYear) {
      // Date moved to a different year — clean up the old bucket if now empty.
      if ((_expensesByYear[originalYear] ?? []).isEmpty) {
        _expensesByYear.remove(originalYear);
        _availableYears.remove(originalYear);
        await _deleteYearFile(originalYear);
      } else {
        await _saveYear(originalYear);
      }
      await _saveYear(newYear);
      await _saveIndex();
    } else {
      await _saveYear(newYear);
    }
  }

  Future<void> removeExpense(String id) async {
    for (final year in List.of(_expensesByYear.keys)) {
      final list = _expensesByYear[year]!;
      final i = list.indexWhere((e) => e.id == id);
      if (i == -1) continue;
      list.removeAt(i);
      notifyListeners();
      if (list.isEmpty) {
        _expensesByYear.remove(year);
        _availableYears.remove(year);
        await _deleteYearFile(year);
        await _saveIndex();
      } else {
        await _saveYear(year);
      }
      return;
    }
  }

  Future<void> clearAll() async {
    _expensesByYear.clear();
    _availableYears.clear();
    notifyListeners();
    await _clearAllYearFiles();
    await _saveIndex();
  }

  /// Bulk-appends [expenses] in a single write per affected year.
  /// Used by the import flow.
  Future<void> addExpenses(List<Expense> expenses) async {
    if (expenses.isEmpty) return;
    final affectedYears = <int>{};
    for (final e in expenses) {
      final year = e.date.year;
      _expensesByYear.putIfAbsent(year, () => []).add(e);
      _availableYears.add(year);
      affectedYears.add(year);
    }
    notifyListeners();
    for (final year in affectedYears) {
      await _saveYear(year);
    }
    await _saveIndex();
  }

  Future<void> restoreFromSnapshot(List<Expense> expenses) async {
    _expensesByYear.clear();
    _availableYears.clear();
    for (final e in expenses) {
      final year = e.date.year;
      _expensesByYear.putIfAbsent(year, () => []).add(e);
      _availableYears.add(year);
    }
    notifyListeners();
    if (_persist) {
      await _clearAllYearFiles();
      for (final year in _availableYears) {
        await _saveYear(year);
      }
      await _saveIndex();
    }
  }

  // ── Expense aggregations ─────────────────────────────────────────────────

  List<Expense> expensesForMonth(int year, int month) =>
      (_expensesByYear[year] ?? [])
          .where((e) => e.date.month == month)
          .toList();

  List<Expense> expensesForYear(int year) =>
      List.of(_expensesByYear[year] ?? []);

  List<Expense> expensesForGroup(String group, int year, int month) =>
      expensesForMonth(year, month).where((e) => e.group == group).toList();

  /// Returns groups visible in [year]/[month], each paired with their
  /// expenses across all currently loaded years, sorted by loaded total
  /// descending.
  ///
  /// Note: totals reflect loaded years only. Years not yet loaded are
  /// excluded from the all-time total until [loadAllYears] is called.
  List<MapEntry<String, List<Expense>>> groupSummariesForMonth(
      int year, int month) {
    final groupNamesInMonth = expensesForMonth(year, month)
        .where((e) => e.group != null)
        .map((e) => e.group!)
        .toSet();

    return groupNamesInMonth.map((name) {
      final all = <Expense>[];
      for (final list in _expensesByYear.values) {
        all.addAll(list.where((e) => e.group == name));
      }
      return MapEntry(name, all);
    }).toList()
      ..sort((a, b) {
        final ta = a.value.fold(0.0, (s, e) => s + e.amount);
        final tb = b.value.fold(0.0, (s, e) => s + e.amount);
        return tb.compareTo(ta);
      });
  }

  // ── Report lines ─────────────────────────────────────────────────────────

  List<ReportLine> reportLinesForMonth(int year, int month) =>
      expensesForMonth(year, month)
          .map((e) => ReportLine(
                category: e.category,
                financialType: e.financialType,
                amount: e.amount,
              ))
          .toList();

  List<ReportLine> reportLinesForYear(int year) =>
      expensesForYear(year)
          .map((e) => ReportLine(
                category: e.category,
                financialType: e.financialType,
                amount: e.amount,
              ))
          .toList();

  // ── Persistence ──────────────────────────────────────────────────────────

  /// Loads the index and the current year's data.
  /// Transparently migrates [finance_data.json] to per-year files if needed.
  Future<void> load() async {
    if (!_persist) return;
    _baseDirPath = (await getApplicationDocumentsDirectory()).path;
    await _migrateIfNeeded();
    await _loadIndex();
    await loadYear(DateTime.now().year);
  }

  Future<void> _loadIndex() async {
    final file = _indexFile();
    if (!await file.exists()) {
      // Index missing — reconstruct from any year files already on disk.
      // This recovers from a crash that wrote year files but not the index.
      await _rebuildIndexFromDisk();
      return;
    }
    try {
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final years = (json['years'] as List? ?? []).cast<int>();
      _availableYears.addAll(years);
    } catch (_) {
      // Corrupt index — recover the same way.
      await _rebuildIndexFromDisk();
    }
  }

  /// Scans the documents directory for [finance_YYYY.json] files and
  /// reconstructs [_availableYears] from them, then persists the index.
  Future<void> _rebuildIndexFromDisk() async {
    for (final entity in Directory(_baseDirPath).listSync().whereType<File>()) {
      final name = entity.uri.pathSegments.last;
      final match = RegExp(r'^finance_(\d{4})\.json$').firstMatch(name);
      if (match != null) {
        _availableYears.add(int.parse(match.group(1)!));
      }
    }
    if (_availableYears.isNotEmpty) {
      await _saveIndex();
    }
  }

  Future<void> _saveYear(int year) async {
    if (!_persist) return;
    final file = _yearFile(year);
    await file.writeAsString(jsonEncode({
      'expenses':
          (_expensesByYear[year] ?? []).map((e) => e.toJson()).toList(),
    }));
  }

  Future<void> _saveIndex() async {
    if (!_persist) return;
    final file = _indexFile();
    await file.writeAsString(jsonEncode({
      'years': _availableYears.toList()..sort(),
    }));
  }

  Future<void> _deleteYearFile(int year) async {
    if (!_persist) return;
    final file = _yearFile(year);
    if (await file.exists()) await file.delete();
  }

  Future<void> _clearAllYearFiles() async {
    if (!_persist) return;
    for (final entity in Directory(_baseDirPath).listSync().whereType<File>()) {
      final name = entity.uri.pathSegments.last;
      if (RegExp(r'^finance_\d{4}\.json$').hasMatch(name)) {
        await entity.delete();
      }
    }
    final indexFile = _indexFile();
    if (await indexFile.exists()) await indexFile.delete();
  }

  /// One-time migration from the legacy single-file format.
  ///
  /// Reads [finance_data.json], splits expenses by year into
  /// [finance_YYYY.json] files, writes the index, then deletes the old file.
  /// The old file is only deleted after all per-year files are confirmed
  /// written, so a crash mid-migration leaves the old file intact for the
  /// next launch to retry.
  Future<void> _migrateIfNeeded() async {
    final oldFile = File('$_baseDirPath/finance_data.json');
    if (!await oldFile.exists()) return;

    // If any per-year file already exists, migration already completed;
    // clean up the old file and return.
    final alreadyMigrated = Directory(_baseDirPath).listSync().whereType<File>().any((f) {
      final name = f.uri.pathSegments.last;
      return RegExp(r'^finance_\d{4}\.json$').hasMatch(name);
    });
    if (alreadyMigrated) {
      await oldFile.delete();
      return;
    }

    try {
      final json =
          jsonDecode(await oldFile.readAsString()) as Map<String, dynamic>;
      final expenses = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();

      final byYear = <int, List<Expense>>{};
      for (final e in expenses) {
        byYear.putIfAbsent(e.date.year, () => []).add(e);
      }

      // Write all year files before touching the old file.
      for (final entry in byYear.entries) {
        final file = _yearFile(entry.key);
        await file.writeAsString(jsonEncode({
          'expenses': entry.value.map((e) => e.toJson()).toList(),
        }));
      }

      final indexFile = _indexFile();
      await indexFile.writeAsString(jsonEncode({
        'years': byYear.keys.toList()..sort(),
      }));

      // Safe to delete old file only after everything is written.
      await oldFile.delete();
    } catch (_) {
      // Migration failed — leave old file intact; will retry on next launch.
    }
  }

  File _yearFile(int year) => File('$_baseDirPath/finance_$year.json');

  File _indexFile() => File('$_baseDirPath/finance_index.json');
}
