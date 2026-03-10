import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
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
  ExpenseCategory? category,
  FinancialType? financialType,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Cost $id',
      amount: amount,
      type: PlanItemType.fixedCost,
      frequency: frequency,
      validFrom: YearMonth(validYear, validMonth),
      category: category,
      financialType: financialType,
    );

Expense makeExpense({
  required double amount,
  required int year,
  required int month,
}) =>
    Expense(
      id: '$amount-$year-$month',
      amount: amount,
      category: ExpenseCategory.groceries,
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

    test('yearly income item distributed over active months', () {
      // Yearly bonus of 1000, starts June 2024 (active Jun–Dec = 7 months)
      final items = [
        makeIncome(amount: 1000, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 6)
      ];
      // 2024: 7 months × (1000/12) ≈ 583.33
      expect(BudgetCalculator.yearlyIncome(items, 2024), closeTo(7 * (1000 / 12), 0.01));
      // 2025: full year = 12 × (1000/12) = 1000
      expect(BudgetCalculator.yearlyIncome(items, 2025), closeTo(1000.0, 0.01));
    });

    test('yearly income item not counted before it starts', () {
      // Starts August 2024 — active Aug–Dec = 5 months
      final items = [
        makeIncome(amount: 500, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 8)
      ];
      // 5 months × (500/12) ≈ 208.33
      expect(BudgetCalculator.yearlyIncome(items, 2024), closeTo(5 * (500 / 12), 0.01));
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

    test('yearly fixedCost is distributed over active months', () {
      // Starts June 2024 — active Jun–Dec = 7 months × (240/12) = 140
      final items = [
        makeFixedCost(amount: 240, frequency: PlanFrequency.yearly, validYear: 2024, validMonth: 6)
      ];
      expect(BudgetCalculator.yearlyFixedCosts(items, 2024), closeTo(140.0, 0.01));
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

  // ── itemMonthlyContribution ───────────────────────────────────────────────

  group('itemMonthlyContribution', () {
    test('monthly item returns full amount', () {
      final item = makeIncome(amount: 3000, frequency: PlanFrequency.monthly);
      expect(BudgetCalculator.itemMonthlyContribution(item, 2024, 6), 3000);
    });

    test('yearly item returns amount / 12', () {
      final item = makeIncome(amount: 1200, frequency: PlanFrequency.yearly);
      expect(BudgetCalculator.itemMonthlyContribution(item, 2024, 6), 100);
    });

    test('oneTime item returns amount only in its exact month', () {
      final item = makeIncome(
          amount: 500,
          frequency: PlanFrequency.oneTime,
          validYear: 2024,
          validMonth: 3);
      expect(BudgetCalculator.itemMonthlyContribution(item, 2024, 3), 500);
      expect(BudgetCalculator.itemMonthlyContribution(item, 2024, 4), 0);
    });
  });

  // ── activeItemsForYear ────────────────────────────────────────────────────

  group('activeItemsForYear', () {
    test('returns empty for empty list', () {
      expect(BudgetCalculator.activeItemsForYear([], 2024), isEmpty);
    });

    test('returns item active during the year', () {
      final items = [makeIncome(validYear: 2024, validMonth: 1)];
      expect(BudgetCalculator.activeItemsForYear(items, 2024).length, 1);
    });

    test('excludes item starting after the year', () {
      final items = [makeIncome(validYear: 2025, validMonth: 1)];
      expect(BudgetCalculator.activeItemsForYear(items, 2024), isEmpty);
    });

    test('returns latest version active in the year (last-month-wins)', () {
      final items = [
        makeIncome(
            id: 'v1', seriesId: 's', amount: 3000,
            validYear: 2024, validMonth: 1),
        makeIncome(
            id: 'v2', seriesId: 's', amount: 4500,
            validYear: 2024, validMonth: 6),
      ];
      final result = BudgetCalculator.activeItemsForYear(items, 2024);
      expect(result.length, 1);
      expect(result.first.amount, 4500); // v2 is last active version
    });

    test('returns one entry per series even with multiple versions', () {
      final items = [
        makeIncome(id: 'v1', seriesId: 's', validYear: 2024, validMonth: 1),
        makeIncome(id: 'v2', seriesId: 's', validYear: 2024, validMonth: 6),
        makeFixedCost(id: 'f1', validYear: 2024, validMonth: 1),
      ];
      expect(BudgetCalculator.activeItemsForYear(items, 2024).length, 2);
    });
  });

  // ── itemYearlyContribution ────────────────────────────────────────────────

  group('itemYearlyContribution', () {
    test('monthly item active all year = amount x 12', () {
      final items = [makeIncome(amount: 3000)];
      expect(
          BudgetCalculator.itemYearlyContribution(items.first, items, 2024),
          36000);
    });

    test('monthly item active from March = amount x 10', () {
      final items = [
        makeIncome(amount: 1000, validYear: 2024, validMonth: 3)
      ];
      expect(
          BudgetCalculator.itemYearlyContribution(items.first, items, 2024),
          10000);
    });

    test('yearly item is distributed over active months', () {
      // Starts June 2024 — active Jun–Dec = 7 months × (1200/12) = 700
      final items = [
        makeIncome(
            amount: 1200,
            frequency: PlanFrequency.yearly,
            validYear: 2024,
            validMonth: 6)
      ];
      expect(
          BudgetCalculator.itemYearlyContribution(items.first, items, 2024),
          closeTo(700.0, 0.01));
    });

    test('item superseded mid-year contributes only while active', () {
      // v1 active Jan-May (3000), v2 active Jun-Dec (4500)
      final items = [
        makeIncome(
            id: 'v1', seriesId: 's', amount: 3000,
            validYear: 2024, validMonth: 1),
        makeIncome(
            id: 'v2', seriesId: 's', amount: 4500,
            validYear: 2024, validMonth: 6),
      ];
      // v1 active Jan-May = 5 months × 3000 = 15000
      expect(
          BudgetCalculator.itemYearlyContribution(items[0], items, 2024),
          15000);
      // v2 active Jun-Dec = 7 months × 4500 = 31500
      expect(
          BudgetCalculator.itemYearlyContribution(items[1], items, 2024),
          31500);
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
        expect(summaries[i].period.month, i + 1);
        expect(summaries[i].period.year, 2024);
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

  // ── planFixedCostReportLinesForMonth ──────────────────────────────────────

  group('planFixedCostReportLinesForMonth', () {
    test('empty plan returns empty list', () {
      expect(
        BudgetCalculator.planFixedCostReportLinesForMonth([], 2024, 3),
        isEmpty,
      );
    });

    test('income items are excluded', () {
      final items = [makeIncome(amount: 3000)];
      expect(
        BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 3),
        isEmpty,
      );
    });

    test('monthly fixedCost → line with full amount', () {
      final items = [
        makeFixedCost(
          amount: 800,
          frequency: PlanFrequency.monthly,
          category: ExpenseCategory.housing,
          financialType: FinancialType.consumption,
        )
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 6);
      expect(lines.length, 1);
      expect(lines.first.amount, 800);
      expect(lines.first.category, ExpenseCategory.housing);
      expect(lines.first.financialType, FinancialType.consumption);
    });

    test('yearly fixedCost → normalized to amount / 12', () {
      final items = [
        makeFixedCost(amount: 1200, frequency: PlanFrequency.yearly)
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 6);
      expect(lines.length, 1);
      expect(lines.first.amount, 100); // 1200 / 12
    });

    test('oneTime fixedCost → amount only in its exact month, 0 otherwise', () {
      final items = [
        makeFixedCost(
          amount: 500,
          frequency: PlanFrequency.oneTime,
          validYear: 2024,
          validMonth: 3,
        )
      ];
      final march =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 3);
      expect(march.length, 1);
      expect(march.first.amount, 500);

      final april =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 4);
      // oneTime is no longer active in April (validFrom > queried would filter
      // it, but it is still the active version; _normalizedContribution returns 0)
      expect(april.every((l) => l.amount == 0), isTrue);
    });

    test('investment/asset fixedCost — category and financialType propagated',
        () {
      // This is the exact bug scenario: user adds a fixed cost with
      // category=investment, type=asset via the Plan tab.
      final items = [
        makeFixedCost(
          amount: 500,
          frequency: PlanFrequency.monthly,
          category: ExpenseCategory.investment,
          financialType: FinancialType.asset,
        )
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 3);
      expect(lines.length, 1);
      expect(lines.first.category, ExpenseCategory.investment);
      expect(lines.first.financialType, FinancialType.asset);
      expect(lines.first.amount, 500);
    });

    test('null category defaults to ExpenseCategory.other', () {
      final items = [makeFixedCost(amount: 100)]; // no category set
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 3);
      expect(lines.first.category, ExpenseCategory.other);
    });

    test('null financialType defaults to FinancialType.consumption', () {
      final items = [makeFixedCost(amount: 100)]; // no financialType set
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 3);
      expect(lines.first.financialType, FinancialType.consumption);
    });

    test('returns one line per active fixedCost item', () {
      final items = [
        makeFixedCost(id: 'a', amount: 800),
        makeFixedCost(id: 'b', amount: 200),
        makeIncome(id: 'c', amount: 3000),
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 6);
      expect(lines.length, 2);
    });

    test('item not yet active is excluded', () {
      final items = [
        makeFixedCost(amount: 500, validYear: 2025, validMonth: 1)
      ];
      expect(
        BudgetCalculator.planFixedCostReportLinesForMonth(items, 2024, 12),
        isEmpty,
      );
    });
  });

  // ── planFixedCostReportLinesForYear ───────────────────────────────────────

  group('planFixedCostReportLinesForYear', () {
    test('empty plan returns empty list', () {
      expect(
        BudgetCalculator.planFixedCostReportLinesForYear([], 2024),
        isEmpty,
      );
    });

    test('income items are excluded', () {
      final items = [makeIncome(amount: 3000)];
      expect(
        BudgetCalculator.planFixedCostReportLinesForYear(items, 2024),
        isEmpty,
      );
    });

    test('monthly fixedCost → 12 lines for a full year', () {
      final items = [makeFixedCost(amount: 800, frequency: PlanFrequency.monthly)];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForYear(items, 2024);
      expect(lines.length, 12);
      expect(lines.fold(0.0, (s, l) => s + l.amount), 9600); // 800 × 12
    });

    test('yearly fixedCost → 1 line per active month, normalized amount', () {
      // Starts June 2024 — active Jun–Dec = 7 months × (1200/12) = 100/month
      final items = [
        makeFixedCost(
          amount: 1200,
          frequency: PlanFrequency.yearly,
          validYear: 2024,
          validMonth: 6,
        )
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForYear(items, 2024);
      expect(lines.length, 7);
      expect(lines.fold(0.0, (s, l) => s + l.amount), closeTo(700.0, 0.01));
    });

    test('investment/asset fixedCost appears in yearly report', () {
      // Full regression test for the reported bug
      final items = [
        makeFixedCost(
          amount: 500,
          frequency: PlanFrequency.monthly,
          category: ExpenseCategory.investment,
          financialType: FinancialType.asset,
        )
      ];
      final lines =
          BudgetCalculator.planFixedCostReportLinesForYear(items, 2024);
      expect(lines.isNotEmpty, isTrue);
      expect(lines.every((l) => l.category == ExpenseCategory.investment),
          isTrue);
      expect(lines.every((l) => l.financialType == FinancialType.asset), isTrue);
    });

    test('lines with amount == 0 are omitted (oneTime in wrong year)', () {
      final items = [
        makeFixedCost(
          amount: 500,
          frequency: PlanFrequency.oneTime,
          validYear: 2023,
          validMonth: 6,
        )
      ];
      // oneTime from 2023 — no cash-flow contribution in 2024
      final lines =
          BudgetCalculator.planFixedCostReportLinesForYear(items, 2024);
      expect(lines, isEmpty);
    });

    test('total amount equals yearlyFixedCosts for consistent items', () {
      final items = [
        makeFixedCost(id: 'a', amount: 500, frequency: PlanFrequency.monthly),
        makeFixedCost(
          id: 'b',
          amount: 1200,
          frequency: PlanFrequency.yearly,
          validYear: 2024,
          validMonth: 3,
        ),
      ];
      final expectedTotal = BudgetCalculator.yearlyFixedCosts(items, 2024);
      final lines =
          BudgetCalculator.planFixedCostReportLinesForYear(items, 2024);
      final linesTotal = lines.fold(0.0, (s, l) => s + l.amount);
      expect(linesTotal, closeTo(expectedTotal, 0.001));
    });
  });
}
