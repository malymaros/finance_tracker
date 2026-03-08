import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_total.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/report_line.dart';
import 'package:finance_tracker/services/report_aggregator.dart';

ReportLine makeLine({
  ExpenseCategory category = ExpenseCategory.groceries,
  FinancialType financialType = FinancialType.consumption,
  required double amount,
}) =>
    ReportLine(category: category, financialType: financialType, amount: amount);

void main() {
  group('ReportAggregator.categoryTotals', () {
    test('returns empty list for no lines', () {
      expect(ReportAggregator.categoryTotals([]), isEmpty);
    });

    test('groups lines by category', () {
      final lines = [
        makeLine(category: ExpenseCategory.groceries, amount: 30),
        makeLine(category: ExpenseCategory.groceries, amount: 20),
        makeLine(category: ExpenseCategory.transport, amount: 50),
      ];
      final totals = ReportAggregator.categoryTotals(lines);
      expect(totals.length, 2);
      final groceries =
          totals.firstWhere((c) => c.category == ExpenseCategory.groceries);
      expect(groceries.amount, 50.0);
      final transport =
          totals.firstWhere((c) => c.category == ExpenseCategory.transport);
      expect(transport.amount, 50.0);
    });

    test('calculates correct percentages', () {
      final lines = [
        makeLine(category: ExpenseCategory.groceries, amount: 75),
        makeLine(category: ExpenseCategory.transport, amount: 25),
      ];
      final totals = ReportAggregator.categoryTotals(lines);
      final groceries =
          totals.firstWhere((c) => c.category == ExpenseCategory.groceries);
      expect(groceries.percentage, 75.0);
      final transport =
          totals.firstWhere((c) => c.category == ExpenseCategory.transport);
      expect(transport.percentage, 25.0);
    });

    test('percentages sum to 100', () {
      final lines = [
        makeLine(category: ExpenseCategory.groceries, amount: 40),
        makeLine(category: ExpenseCategory.transport, amount: 35),
        makeLine(category: ExpenseCategory.clothing, amount: 25),
      ];
      final totals = ReportAggregator.categoryTotals(lines);
      final sum = totals.fold(0.0, (s, ct) => s + ct.percentage);
      expect(sum, closeTo(100.0, 0.001));
    });

    test('results are sorted descending by amount', () {
      final lines = [
        makeLine(category: ExpenseCategory.transport, amount: 10),
        makeLine(category: ExpenseCategory.groceries, amount: 80),
        makeLine(category: ExpenseCategory.clothing, amount: 40),
      ];
      final totals = ReportAggregator.categoryTotals(lines);
      expect(totals[0].category, ExpenseCategory.groceries);
      expect(totals[1].category, ExpenseCategory.clothing);
      expect(totals[2].category, ExpenseCategory.transport);
    });

    test('single category gets 100 percent', () {
      final lines = [makeLine(category: ExpenseCategory.health, amount: 200)];
      final totals = ReportAggregator.categoryTotals(lines);
      expect(totals.length, 1);
      expect(totals.first.percentage, 100.0);
    });
  });

  group('ReportAggregator.applyThreshold', () {
    // Helper: build a CategoryTotal directly (avoids going through lines)
    CategoryTotal makeTotal(ExpenseCategory cat, double amount, double pct) =>
        CategoryTotal(category: cat, amount: amount, percentage: pct);

    test('returns empty list unchanged', () {
      expect(ReportAggregator.applyThreshold([], 5.0), isEmpty);
    });

    test('returns list unchanged when all categories are above threshold', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 600, 60),
        makeTotal(ExpenseCategory.housing, 400, 40),
      ];
      final result = ReportAggregator.applyThreshold(totals, 5.0);
      expect(result.length, 2);
      expect(result.any((ct) => ct.category == ExpenseCategory.other), isFalse);
    });

    test('collapses below-threshold category into Other', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 950, 95),
        makeTotal(ExpenseCategory.transport, 30, 3),  // below 5%
        makeTotal(ExpenseCategory.clothing, 20, 2),   // below 5%
      ];
      final result = ReportAggregator.applyThreshold(totals, 5.0);
      expect(result.length, 2);
      expect(result[0].category, ExpenseCategory.groceries);
      final other = result[1];
      expect(other.category, ExpenseCategory.other);
      expect(other.amount, closeTo(50, 0.001));
      expect(other.percentage, closeTo(5, 0.001));
    });

    test('always absorbs real ExpenseCategory.other regardless of size', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 600, 60),
        makeTotal(ExpenseCategory.housing, 300, 30),
        // real "other" is 10% — above a 5% threshold, but still absorbed
        makeTotal(ExpenseCategory.other, 100, 10),
      ];
      final result = ReportAggregator.applyThreshold(totals, 5.0);
      // groceries and housing stay; real "other" is folded into the bucket
      expect(result.length, 3);
      final otherRow =
          result.firstWhere((ct) => ct.category == ExpenseCategory.other);
      expect(otherRow.amount, 100);
      expect(otherRow.percentage, 10);
    });

    test('Other bucket is always the last element', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 700, 70),
        makeTotal(ExpenseCategory.transport, 20, 2),  // below 5%
        makeTotal(ExpenseCategory.housing, 280, 28),
      ];
      final result = ReportAggregator.applyThreshold(totals, 5.0);
      expect(result.last.category, ExpenseCategory.other);
    });

    test('big categories remain sorted descending by amount', () {
      final totals = [
        makeTotal(ExpenseCategory.housing, 500, 50),
        makeTotal(ExpenseCategory.groceries, 400, 40),
        makeTotal(ExpenseCategory.clothing, 50, 5),   // exactly at threshold: kept
        makeTotal(ExpenseCategory.transport, 40, 4),  // below 5%: collapsed
        makeTotal(ExpenseCategory.gifts, 10, 1),      // below 5%: collapsed
      ];
      final result = ReportAggregator.applyThreshold(totals, 5.0);
      // housing, groceries, clothing stay (≥5%); transport+gifts → Other
      expect(result[0].category, ExpenseCategory.housing);
      expect(result[1].category, ExpenseCategory.groceries);
      expect(result[2].category, ExpenseCategory.clothing);
      expect(result[3].category, ExpenseCategory.other);
      expect(result[3].amount, closeTo(50, 0.001));
    });

    test('all categories below threshold → single Other bucket', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 60, 0.6),
        makeTotal(ExpenseCategory.transport, 40, 0.4),
      ];
      final result = ReportAggregator.applyThreshold(totals, 1.0);
      expect(result.length, 1);
      expect(result.first.category, ExpenseCategory.other);
      expect(result.first.amount, closeTo(100, 0.001));
    });

    test('percentage of Other equals sum of collapsed percentages', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 900, 90),
        makeTotal(ExpenseCategory.transport, 6, 0.6),
        makeTotal(ExpenseCategory.clothing, 4, 0.4),
      ];
      final result = ReportAggregator.applyThreshold(totals, 1.0);
      final other = result.firstWhere((ct) => ct.category == ExpenseCategory.other);
      expect(other.percentage, closeTo(1.0, 0.001));
    });

    test('1% threshold: category at exactly 1.0% is kept', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 99, 99),
        makeTotal(ExpenseCategory.transport, 1, 1.0), // exactly at threshold
      ];
      final result = ReportAggregator.applyThreshold(totals, 1.0);
      expect(result.length, 2);
      expect(result.any((ct) => ct.category == ExpenseCategory.transport), isTrue);
      expect(result.any((ct) => ct.category == ExpenseCategory.other), isFalse);
    });

    test('1% threshold: category below 1.0% is collapsed', () {
      final totals = [
        makeTotal(ExpenseCategory.groceries, 99.5, 99.5),
        makeTotal(ExpenseCategory.transport, 0.5, 0.5), // below 1%
      ];
      final result = ReportAggregator.applyThreshold(totals, 1.0);
      expect(result.length, 2);
      expect(result.last.category, ExpenseCategory.other);
    });
  });

  group('ReportAggregator.financialTypeBreakdown', () {
    test('returns all zeros for empty list', () {
      final b = ReportAggregator.financialTypeBreakdown([]);
      expect(b.assetPct, 0);
      expect(b.consumptionPct, 0);
      expect(b.insurancePct, 0);
    });

    test('100% consumption when all lines are consumption', () {
      final lines = [
        makeLine(financialType: FinancialType.consumption, amount: 100),
        makeLine(financialType: FinancialType.consumption, amount: 50),
      ];
      final b = ReportAggregator.financialTypeBreakdown(lines);
      expect(b.consumptionPct, 100.0);
      expect(b.assetPct, 0);
      expect(b.insurancePct, 0);
    });

    test('splits correctly across three types', () {
      final lines = [
        makeLine(financialType: FinancialType.asset, amount: 200),
        makeLine(financialType: FinancialType.consumption, amount: 600),
        makeLine(financialType: FinancialType.insurance, amount: 200),
      ];
      final b = ReportAggregator.financialTypeBreakdown(lines);
      expect(b.assetPct, closeTo(20.0, 0.001));
      expect(b.consumptionPct, closeTo(60.0, 0.001));
      expect(b.insurancePct, closeTo(20.0, 0.001));
    });

    test('percentages sum to 100', () {
      final lines = [
        makeLine(financialType: FinancialType.asset, amount: 333),
        makeLine(financialType: FinancialType.consumption, amount: 333),
        makeLine(financialType: FinancialType.insurance, amount: 334),
      ];
      final b = ReportAggregator.financialTypeBreakdown(lines);
      final sum = b.assetPct + b.consumptionPct + b.insurancePct;
      expect(sum, closeTo(100.0, 0.001));
    });
  });
}
