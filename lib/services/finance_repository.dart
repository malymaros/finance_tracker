import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/expense.dart';

class FinanceRepository extends ChangeNotifier {
  final bool _persist;
  final List<Expense> _expenses = [];

  FinanceRepository({bool persist = true, List<Expense>? seed})
      : _persist = persist {
    if (seed != null) _expenses.addAll(seed);
  }

  List<Expense> get expenses => List.unmodifiable(_expenses);

  Future<void> load() async {
    if (!_persist) return;
    final file = await _dataFile();
    if (!await file.exists()) return;
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final list = (json['expenses'] as List? ?? [])
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
      _expenses
        ..clear()
        ..addAll(list);
      notifyListeners();
    } catch (_) {
      // Corrupt data — start fresh
    }
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _save();
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
