import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_total.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/report_data.dart';

void main() {
  group('ReportData', () {
    final listTotals = [
      CategoryTotal(
          category: ExpenseCategory.groceries, amount: 400, percentage: 80),
      CategoryTotal(
          category: ExpenseCategory.transport, amount: 100, percentage: 20),
    ];

    final chartTotals = [
      CategoryTotal(
          category: ExpenseCategory.groceries, amount: 500, percentage: 100),
    ];

    test('stores all fields correctly', () {
      final data = ReportData(
        listTotals: listTotals,
        chartTotals: chartTotals,
        grandTotal: 500,
      );

      expect(data.listTotals, listTotals);
      expect(data.chartTotals, chartTotals);
      expect(data.grandTotal, 500);
    });

    test('grandTotal equals sum of listTotals amounts', () {
      final data = ReportData(
        listTotals: listTotals,
        chartTotals: chartTotals,
        grandTotal: listTotals.fold(0.0, (s, ct) => s + ct.amount),
      );

      final summedTotal = data.listTotals.fold(0.0, (s, ct) => s + ct.amount);
      expect(data.grandTotal, closeTo(summedTotal, 0.001));
    });

    test('empty listTotals and chartTotals are valid', () {
      const data = ReportData(
        listTotals: [],
        chartTotals: [],
        grandTotal: 0,
      );

      expect(data.listTotals, isEmpty);
      expect(data.chartTotals, isEmpty);
      expect(data.grandTotal, 0);
    });

    test('listTotals and chartTotals can differ (threshold applied)', () {
      // listTotals has all categories; chartTotals collapses small ones
      final data = ReportData(
        listTotals: listTotals,   // 2 categories
        chartTotals: chartTotals, // 1 category (collapsed)
        grandTotal: 500,
      );

      expect(data.listTotals.length, 2);
      expect(data.chartTotals.length, 1);
    });

    test('otherSubcategories defaults to empty list', () {
      const data = ReportData(
        listTotals: [],
        chartTotals: [],
        grandTotal: 0,
      );

      expect(data.otherSubcategories, isEmpty);
    });

    test('otherSubcategories stores provided list correctly', () {
      final subs = [
        CategoryTotal(
            category: ExpenseCategory.transport, amount: 30, percentage: 3),
        CategoryTotal(
            category: ExpenseCategory.clothing, amount: 20, percentage: 2),
      ];
      final data = ReportData(
        listTotals: listTotals,
        chartTotals: chartTotals,
        grandTotal: 500,
        otherSubcategories: subs,
      );

      expect(data.otherSubcategories.length, 2);
      expect(data.otherSubcategories[0].category, ExpenseCategory.transport);
      expect(data.otherSubcategories[1].category, ExpenseCategory.clothing);
    });
  });
}
