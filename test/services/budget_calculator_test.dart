import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/budget_calculator.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

PlanItem makeIncome({
  String id = '1',
  String? seriesId,
  double amount = 1000,
  PlanFrequency frequency = PlanFrequency.monthly,
  int validYear = 2024,
  int validMonth = 1,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Income $id',
      amount: amount,
      type: PlanItemType.income,
      frequency: frequency,
      validFrom: YearMonth(validYear, validMonth),
    );

PlanItem makeFixedCost({
  String id = '1',
  String? seriesId,
  double amount = 500,
  PlanFrequency frequency = PlanFrequency.monthly,
  int validYear = 2024,
  int validMonth = 1,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Cost $id',
      amount: amount,
      type: PlanItemType.fixedCost,
      frequency: frequency,
      validFrom: YearMonth(validYear, validMonth),
    );

Expense makeExpense({
  required double amount,
  required int year,
  required int month,
}) =>
    Expense(
      id: '$amount-$year-$month',
      amount: amount,
      category: 'Food',
      date: DateTime(year, month, 1),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── activeItemsForMonth ───────────────────────────────────────────────────

  group('activeItemsForMonth', () {
    test('empty list returns empty', () {
      expect(BudgetCalculator.activeItemsForMonth([], 2024, 3), isEmpty);
    });

    test('item with validFrom == queried month is active', () {
      final items = [makeIncome(validYear: 2024, validMonth: 3)];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 3).length, 1);
    });

    test('item with validFrom after queried month is not active', () {
      final items = [makeIncome(validYear: 2024, validMonth: 5)];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 3), isEmpty);
    });

    test('returns latest version of each series', () {
      final items = [
        makeIncome(id: 'v1', seriesId: 's1', amount: 3000, validYear: 2024, validMonth: 1),
        makeIncome(id: 'v2', seriesId: 's1', amount: 4500, validYear: 2024, validMonth: 3),
      ];
      // In February → v1 is active
      final feb = BudgetCalculator.activeItemsForMonth(items, 2024, 2);
      expect(feb.length, 1);
      expect(feb.first.amount, 3000);

      // In March → v2 is active
      final mar = BudgetCalculator.activeItemsForMonth(items, 2024, 3);
      expect(mar.length, 1);
      expect(mar.first.amount, 4500);

      // In April → v2 is still active
      final apr = BudgetCalculator.activeItemsForMonth(items, 2024, 4);
      expect(apr.length, 1);
      expect(apr.first.amount, 4500);
    });

    test('two different series are both returned when active', () {
      final items = [
        makeIncome(id: 'a', seriesId: 'a'),
        makeFixedCost(id: 'b', seriesId: 'b'),
      ];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 6).length, 2);
    });
  });

  // ── normalizedMonthlyIncome ───────────────────────────────────────────────

  group('normalizedMonthlyIncome', () {
    test('monthly item contributes full amount', () {
      final items = [makeIncome(amount: 3000, frequency: PlanFrequency.monthly)];
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 6), 3000);
    });

    test('yearly item contributes amount / 12', () {
      final items = [makeIncome(amount: 1200, frequency: PlanFrequency.yearly)];
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 6), 100);
    });

    test('oneTime item contributes in its exact month', () {
      final items = [
        makeIncome(amount: 500, frequency: PlanFrequency.oneTime, validYear: 2024, validMonth: 3)
      ];
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 3), 500);
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 4), 0);
    });

    test('sums multiple active income items', () {
      final items = [
        makeIncome(id: 'a', amount: 3000, frequency: PlanFrequency.monthly),
        makeIncome(id: 'b', amount: 1200, frequency: PlanFrequency.yearly),
      ];
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 6), 3100);
    });

    test('fixedCost items are excluded from income', () {
      final items = [makeFixedCost(amount: 800, frequency: PlanFrequency.monthly)];
      expect(BudgetCalculator.normalizedMonthlyIncome(items, 2024, 6), 0);
    });
  });

  // ── normalizedMonthlyFixedCosts ───────────────────────────────────────────

  group('normalizedMonthlyFixedCosts', () {
    test('monthly fixedCost contributes full amount', () {
      final items = [makeFixedCost(amount: 800, frequency: PlanFrequency.monthly)];
      expect(BudgetCalculator.normalizedMonthlyFixedCosts(items, 2024, 6), 800);
    });

    test('yearly fixedCost contributes amount / 12', () {
      final items = [makeFixedCost(amount: 240, frequency: PlanFrequency.yearly)];
      expect(BudgetCalculator.normalizedMonthlyFixedCosts(items, 2024, 6), 20);
    });
  });

  // ── spendableBudget ───────────────────────────────────────────────────────

  group('spendableBudget', () {
    test('income minus fixedCosts', () {
      final items = [
        makeIncome(id: 'i', amount: 3000, frequency: PlanFrequency.monthly),
        makeFixedCost(id: 'f', amount: 800, frequency: PlanFrequency.monthly),
      ];
      expect(BudgetCalculator.spendableBudget(items, 2024, 6), 2200);
    });

    test('returns 0 when no items', () {
      expect(BudgetCalculator.spendableBudget([], 2024, 6), 0);
    });
  });

  // ── yearlyIncome ──────────────────────────────────────────────────────────

  group('yearlyIncome', () {
    test('monthly income active all year = amount x 12', () {
      final items = [makeIncome(amount: 3000, frequency: PlanFrequency.monthly)];
      expect(BudgetCalculator.yearlyIncome(items, 2024), 36000);
    });

    test('mid-year salary change is reflected correctly', () {
      // Salary 3000 Jan-Feb, 4500 Mar-Dec
      final items = [
        makeIncome(id: 'v1', seriesId: 's', amount: 3000, validYear: 2024, validMonth: 1),
        makeIncome(id: 'v2', seriesId: 's', amount: 4500, validYear: 2024, validMonth: 3),
      ];
      // 2*3000 + 10*4500 = 6000 + 45000 = 51000
      expect(BudgetCalculator.yearlyIncome(items, 2024), 51000);
    });

    test('yearly income item appears once in its anniversary month', () {
      // Yearly bonus of 1000 in June
      final items = [
        makeIncome(amount: 1000, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 6)
      ];
      expect(BudgetCalculator.yearlyIncome(items, 2024), 1000);
      expect(BudgetCalculator.yearlyIncome(items, 2025), 1000);
    });

    test('yearly income item not counted before it starts', () {
      // Starts August 2024 — only fires in August
      final items = [
        makeIncome(amount: 500, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 8)
      ];
      // Fires in August 2024 only (not Jan-Jul)
      expect(BudgetCalculator.yearlyIncome(items, 2024), 500);
    });

    test('oneTime income counted once in its month', () {
      final items = [
        makeIncome(amount: 2000, frequency: PlanFrequency.oneTime, validYear: 2024, validMonth: 5)
      ];
      expect(BudgetCalculator.yearlyIncome(items, 2024), 2000);
      expect(BudgetCalculator.yearlyIncome(items, 2025), 0);
    });
  });

  // ── yearlyFixedCosts ──────────────────────────────────────────────────────

  group('yearlyFixedCosts', () {
    test('monthly fixedCost active all year = amount x 12', () {
      final items = [makeFixedCost(amount: 800, frequency: PlanFrequency.monthly)];
      expect(BudgetCalculator.yearlyFixedCosts(items, 2024), 9600);
    });

    test('yearly fixedCost appears once in anniversary month', () {
      final items = [
        makeFixedCost(amount: 240, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 6)
      ];
      expect(BudgetCalculator.yearlyFixedCosts(items, 2024), 240);
    });
  });

  // ── budgetStatus ──────────────────────────────────────────────────────────

  group('budgetStatus', () {
    test('returns null when no income plan items exist', () {
      final items = [makeFixedCost()];
      expect(BudgetCalculator.budgetStatus(items, 100, 2024, 6), isNull);
    });

    test('returns null when list is empty', () {
      expect(BudgetCalculator.budgetStatus([], 0, 2024, 6), isNull);
    });

    test('returns null when income item not yet active', () {
      final items = [makeIncome(validYear: 2025, validMonth: 1)];
      expect(BudgetCalculator.budgetStatus(items, 0, 2024, 6), isNull);
    });

    test('calculates status correctly', () {
      final items = [
        makeIncome(id: 'i', amount: 3000),
        makeFixedCost(id: 'f', amount: 800),
      ];
      final status = BudgetCalculator.budgetStatus(items, 500, 2024, 6)!;
      expect(status.spendableBudget, 2200);
      expect(status.actualSpent, 500);
      expect(status.remaining, 1700);
      expect(status.percentUsed, closeTo(22.7, 0.1));
      expect(status.isOverBudget, isFalse);
    });

    test('isOverBudget is true when spent exceeds budget', () {
      final items = [makeIncome(id: 'i', amount: 1000)];
      final status = BudgetCalculator.budgetStatus(items, 1500, 2024, 6)!;
      expect(status.isOverBudget, isTrue);
      expect(status.remaining, -500);
    });
  });

  // ── monthlySummaries ──────────────────────────────────────────────────────

  group('monthlySummaries', () {
    test('returns 12 entries', () {
      expect(BudgetCalculator.monthlySummaries([], [], 2024).length, 12);
    });

    test('months are numbered 1 through 12', () {
      final summaries = BudgetCalculator.monthlySummaries([], [], 2024);
      for (int i = 0; i < 12; i++) {
        expect(summaries[i].month, i + 1);
        expect(summaries[i].year, 2024);
      }
    });

    test('calculates correct values for months with data', () {
      final items = [
        makeIncome(id: 'i', amount: 2000),
        makeFixedCost(id: 'f', amount: 800),
      ];
      final expenses = [
        makeExpense(amount: 300, year: 2024, month: 1),
        makeExpense(amount: 150, year: 2024, month: 2),
      ];
      final summaries = BudgetCalculator.monthlySummaries(items, expenses, 2024);

      expect(summaries[0].plannedIncome, 2000);
      expect(summaries[0].plannedFixedCosts, 800);
      expect(summaries[0].spendableBudget, 1200);
      expect(summaries[0].actualExpenses, 300);
      expect(summaries[0].difference, 900);

      expect(summaries[1].actualExpenses, 150);
      expect(summaries[1].difference, 1050);

      // March — no expenses
      expect(summaries[2].actualExpenses, 0);
      expect(summaries[2].difference, 1200);
    });

    test('difference is negative when over budget', () {
      final items = [makeIncome(id: 'i', amount: 500)];
      final expenses = [makeExpense(amount: 800, year: 2024, month: 3)];
      final summaries = BudgetCalculator.monthlySummaries(items, expenses, 2024);
      expect(summaries[2].difference, -300);
    });
  });
}
