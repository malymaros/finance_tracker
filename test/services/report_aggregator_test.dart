import 'package:flutter_test/flutter_test.dart';
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
