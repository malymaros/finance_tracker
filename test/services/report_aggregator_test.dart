import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/services/report_aggregator.dart';

Expense makeExpense({
  required String category,
  required double amount,
  DateTime? date,
}) =>
    Expense(
      id: '${category}_${amount.toInt()}',
      amount: amount,
      category: category,
      date: date ?? DateTime(2024, 3, 1),
    );

void main() {
  group('ReportAggregator.categoryTotals', () {
    test('returns empty list for no expenses', () {
      expect(ReportAggregator.categoryTotals([]), isEmpty);
    });

    test('groups expenses by category', () {
      final expenses = [
        makeExpense(category: 'Food', amount: 30),
        makeExpense(category: 'Food', amount: 20),
        makeExpense(category: 'Transport', amount: 50),
      ];
      final totals = ReportAggregator.categoryTotals(expenses);
      expect(totals.length, 2);
      final food = totals.firstWhere((c) => c.category == 'Food');
      expect(food.amount, 50.0);
      final transport = totals.firstWhere((c) => c.category == 'Transport');
      expect(transport.amount, 50.0);
    });

    test('calculates correct percentages', () {
      final expenses = [
        makeExpense(category: 'Food', amount: 75),
        makeExpense(category: 'Transport', amount: 25),
      ];
      final totals = ReportAggregator.categoryTotals(expenses);
      final food = totals.firstWhere((c) => c.category == 'Food');
      expect(food.percentage, 75.0);
      final transport = totals.firstWhere((c) => c.category == 'Transport');
      expect(transport.percentage, 25.0);
    });

    test('percentages sum to 100', () {
      final expenses = [
        makeExpense(category: 'Food', amount: 40),
        makeExpense(category: 'Transport', amount: 35),
        makeExpense(category: 'Shopping', amount: 25),
      ];
      final totals = ReportAggregator.categoryTotals(expenses);
      final sum = totals.fold(0.0, (s, ct) => s + ct.percentage);
      expect(sum, closeTo(100.0, 0.001));
    });

    test('results are sorted descending by amount', () {
      final expenses = [
        makeExpense(category: 'Transport', amount: 10),
        makeExpense(category: 'Food', amount: 80),
        makeExpense(category: 'Shopping', amount: 40),
      ];
      final totals = ReportAggregator.categoryTotals(expenses);
      expect(totals[0].category, 'Food');
      expect(totals[1].category, 'Shopping');
      expect(totals[2].category, 'Transport');
    });

    test('single category gets 100 percent', () {
      final expenses = [makeExpense(category: 'Health', amount: 200)];
      final totals = ReportAggregator.categoryTotals(expenses);
      expect(totals.length, 1);
      expect(totals.first.percentage, 100.0);
    });
  });
}
