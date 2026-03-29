import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/report_line.dart';
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

    test('oneTime item is active only in its exact validFrom month', () {
      final items = [
        makeIncome(
            frequency: PlanFrequency.oneTime, validYear: 2024, validMonth: 3),
      ];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 3).length, 1);
    });

    test('oneTime item is NOT active in the month after its validFrom', () {
      final items = [
        makeIncome(
            frequency: PlanFrequency.oneTime, validYear: 2024, validMonth: 3),
      ];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 4), isEmpty);
    });

    test('oneTime item is NOT active in the month before its validFrom', () {
      final items = [
        makeIncome(
            frequency: PlanFrequency.oneTime, validYear: 2024, validMonth: 3),
      ];
      expect(BudgetCalculator.activeItemsForMonth(items, 2024, 2), isEmpty);
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

    test('returns null in a month after a oneTime income item — regression',
        () {
      // Before the activeItemsForMonth fix, a oneTime income item leaked into
      // all months after its validFrom, causing budgetStatus to return non-null
      // (hasIncome = true) even in months where it had no contribution.
      final items = [
        makeIncome(
            amount: 500,
            frequency: PlanFrequency.oneTime,
            validYear: 2024,
            validMonth: 3),
      ];
      // March: one-time income is active → budgetStatus is non-null
      expect(BudgetCalculator.budgetStatus(items, 0, 2024, 3), isNotNull);
      // April: one-time income is NOT active → budgetStatus must be null
      expect(BudgetCalculator.budgetStatus(items, 0, 2024, 4), isNull);
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

    test('no plan items: all months have zero income and fixed costs', () {
      final summaries = BudgetCalculator.monthlySummaries([], [], 2024);
      for (final s in summaries) {
        expect(s.plannedIncome, 0);
        expect(s.plannedFixedCosts, 0);
        expect(s.spendableBudget, 0);
        expect(s.actualExpenses, 0);
      }
    });

    test('income starting mid-year: months before validFrom have zero income', () {
      // Income starts April 2024 (month 4)
      final items = [makeIncome(id: 'i', amount: 3000, validMonth: 4)];
      final summaries = BudgetCalculator.monthlySummaries(items, [], 2024);

      // January–March: no income
      for (int m = 0; m < 3; m++) {
        expect(summaries[m].plannedIncome, 0,
            reason: 'month ${m + 1} should have zero income');
      }
      // April–December: income active
      for (int m = 3; m < 12; m++) {
        expect(summaries[m].plannedIncome, 3000,
            reason: 'month ${m + 1} should have income');
      }
    });

    test('fixedCost expiring mid-year: months after validTo have zero cost', () {
      // Rent active Jan–Jun 2024 only
      final rent = PlanItem(
        id: 'r',
        seriesId: 'r',
        name: 'Rent',
        amount: 1000,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        validTo: YearMonth(2024, 6),
      );
      final summaries = BudgetCalculator.monthlySummaries([rent], [], 2024);

      // January–June: cost active
      for (int m = 0; m < 6; m++) {
        expect(summaries[m].plannedFixedCosts, 1000,
            reason: 'month ${m + 1} should have fixed cost');
      }
      // July–December: cost expired
      for (int m = 6; m < 12; m++) {
        expect(summaries[m].plannedFixedCosts, 0,
            reason: 'month ${m + 1} cost should be zero after validTo');
      }
    });

    test('spendableBudget is income minus fixedCosts each month', () {
      final items = [
        makeIncome(id: 'i', amount: 3000),
        makeFixedCost(id: 'f', amount: 800),
      ];
      final summaries = BudgetCalculator.monthlySummaries(items, [], 2024);
      for (final s in summaries) {
        expect(s.spendableBudget,
            closeTo(s.plannedIncome - s.plannedFixedCosts, 0.001));
      }
    });

    test('difference is spendableBudget minus actualExpenses each month', () {
      final items = [makeIncome(id: 'i', amount: 2000)];
      final expenses = [makeExpense(amount: 500, year: 2024, month: 5)];
      final summaries = BudgetCalculator.monthlySummaries(items, expenses, 2024);
      for (final s in summaries) {
        expect(s.difference,
            closeTo(s.spendableBudget - s.actualExpenses, 0.001));
      }
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
      // The oneTime item is no longer active in April — activeItemsForMonth
      // excludes it for any month other than its exact validFrom. The list is
      // empty, so every() vacuously returns true.
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

  // ── planFinancialTypeTotals ───────────────────────────────────────────────

  group('planFinancialTypeTotals', () {
    test('empty list returns empty map', () {
      final result = BudgetCalculator.planFinancialTypeTotals(
          [], [], 2024, 1, true);
      expect(result, isEmpty);
    });

    test('single consumption item appears under consumption', () {
      final item = makeFixedCost(
        id: 'c1', amount: 300,
        financialType: FinancialType.consumption,
      );
      final result = BudgetCalculator.planFinancialTypeTotals(
          [item], [item], 2024, 1, true);
      expect(result.containsKey(FinancialType.consumption), isTrue);
      expect(result[FinancialType.consumption]!.total, 300);
      expect(result[FinancialType.consumption]!.count, 1);
    });

    test('null financialType falls back to consumption', () {
      final item = makeFixedCost(id: 'n1', amount: 200); // no financialType
      final result = BudgetCalculator.planFinancialTypeTotals(
          [item], [item], 2024, 1, true);
      expect(result.containsKey(FinancialType.consumption), isTrue);
      expect(result[FinancialType.consumption]!.total, 200);
    });

    test('items of different types are grouped correctly', () {
      final consumption = makeFixedCost(
        id: 'c1', amount: 400, financialType: FinancialType.consumption);
      final asset = makeFixedCost(
        id: 'a1', amount: 200, financialType: FinancialType.asset);
      final insurance = makeFixedCost(
        id: 'i1', amount: 100, financialType: FinancialType.insurance);
      final all = [consumption, asset, insurance];

      final result = BudgetCalculator.planFinancialTypeTotals(
          all, all, 2024, 1, true);

      expect(result[FinancialType.consumption]!.total, 400);
      expect(result[FinancialType.asset]!.total, 200);
      expect(result[FinancialType.insurance]!.total, 100);
    });

    test('count tracks number of items per type', () {
      final items = [
        makeFixedCost(id: 'c1', amount: 100, financialType: FinancialType.consumption),
        makeFixedCost(id: 'c2', amount: 200, financialType: FinancialType.consumption),
        makeFixedCost(id: 'a1', amount: 50, financialType: FinancialType.asset),
      ];
      final result = BudgetCalculator.planFinancialTypeTotals(
          items, items, 2024, 1, true);

      expect(result[FinancialType.consumption]!.count, 2);
      expect(result[FinancialType.consumption]!.total, 300);
      expect(result[FinancialType.asset]!.count, 1);
    });

    test('type with no items is absent from map', () {
      final item = makeFixedCost(
        id: 'a1', amount: 100, financialType: FinancialType.asset);
      final result = BudgetCalculator.planFinancialTypeTotals(
          [item], [item], 2024, 1, true);
      expect(result.containsKey(FinancialType.consumption), isFalse);
      expect(result.containsKey(FinancialType.insurance), isFalse);
    });

    test('monthly mode uses itemMonthlyContribution', () {
      final item = makeFixedCost(
        id: 'y1', amount: 1200,
        frequency: PlanFrequency.yearly,
        financialType: FinancialType.consumption,
      );
      final result = BudgetCalculator.planFinancialTypeTotals(
          [item], [item], 2024, 1, true);
      // yearly 1200 / 12 = 100 monthly
      expect(result[FinancialType.consumption]!.total, closeTo(100, 0.001));
    });

    test('yearly mode uses itemYearlyContribution', () {
      final item = makeFixedCost(
        id: 'm1', amount: 100,
        frequency: PlanFrequency.monthly,
        financialType: FinancialType.asset,
      );
      final result = BudgetCalculator.planFinancialTypeTotals(
          [item], [item], 2024, 1, false);
      // monthly 100 × 12 = 1200 yearly
      expect(result[FinancialType.asset]!.total, closeTo(1200, 0.001));
    });
  });

  // ── planCategoryTotals ────────────────────────────────────────────────────

  group('planCategoryTotals', () {
    test('empty list returns empty map', () {
      final result = BudgetCalculator.planCategoryTotals(
          [], [], 2024, 1, true);
      expect(result, isEmpty);
    });

    test('single item appears under its category', () {
      final item = makeFixedCost(
        id: 'h1', amount: 800, category: ExpenseCategory.housing);
      final result = BudgetCalculator.planCategoryTotals(
          [item], [item], 2024, 1, true);
      expect(result.containsKey(ExpenseCategory.housing), isTrue);
      expect(result[ExpenseCategory.housing]!.total, 800);
      expect(result[ExpenseCategory.housing]!.count, 1);
    });

    test('null category defaults to other', () {
      final item = makeFixedCost(id: 'n1', amount: 100); // no category
      final result = BudgetCalculator.planCategoryTotals(
          [item], [item], 2024, 1, true);
      expect(result.containsKey(ExpenseCategory.other), isTrue);
    });

    test('items in same category are summed', () {
      final items = [
        makeFixedCost(id: 'g1', amount: 50, category: ExpenseCategory.groceries),
        makeFixedCost(id: 'g2', amount: 75, category: ExpenseCategory.groceries),
      ];
      final result = BudgetCalculator.planCategoryTotals(
          items, items, 2024, 1, true);
      expect(result[ExpenseCategory.groceries]!.total, 125);
      expect(result[ExpenseCategory.groceries]!.count, 2);
    });

    test('result is sorted by total descending', () {
      final items = [
        makeFixedCost(id: 'a', amount: 50, category: ExpenseCategory.groceries),
        makeFixedCost(id: 'b', amount: 200, category: ExpenseCategory.housing),
        makeFixedCost(id: 'c', amount: 100, category: ExpenseCategory.transport),
      ];
      final result = BudgetCalculator.planCategoryTotals(
          items, items, 2024, 1, true);
      final totals = result.values.map((v) => v.total).toList();
      expect(totals, [200, 100, 50]);
    });

    test('financialTypeFilter excludes items of other types', () {
      final consumption = makeFixedCost(
        id: 'c1', amount: 300,
        category: ExpenseCategory.groceries,
        financialType: FinancialType.consumption,
      );
      final asset = makeFixedCost(
        id: 'a1', amount: 500,
        category: ExpenseCategory.investment,
        financialType: FinancialType.asset,
      );
      final all = [consumption, asset];

      final result = BudgetCalculator.planCategoryTotals(
        all, all, 2024, 1, true,
        financialTypeFilter: FinancialType.consumption,
      );

      expect(result.containsKey(ExpenseCategory.groceries), isTrue);
      expect(result.containsKey(ExpenseCategory.investment), isFalse);
    });

    test('financialTypeFilter null includes all items', () {
      final items = [
        makeFixedCost(
          id: 'c1', amount: 100,
          category: ExpenseCategory.groceries,
          financialType: FinancialType.consumption,
        ),
        makeFixedCost(
          id: 'a1', amount: 200,
          category: ExpenseCategory.investment,
          financialType: FinancialType.asset,
        ),
      ];
      final result = BudgetCalculator.planCategoryTotals(
          items, items, 2024, 1, true);
      expect(result.length, 2);
    });

    test('financialTypeFilter: null financialType falls back to consumption', () {
      // Item with no financialType should be included when filtering for consumption
      final item = makeFixedCost(
        id: 'n1', amount: 150, category: ExpenseCategory.groceries);
      final result = BudgetCalculator.planCategoryTotals(
        [item], [item], 2024, 1, true,
        financialTypeFilter: FinancialType.consumption,
      );
      expect(result.containsKey(ExpenseCategory.groceries), isTrue);
    });

    test('financialTypeFilter: null item excluded when filter is asset', () {
      final item = makeFixedCost(
        id: 'n1', amount: 150, category: ExpenseCategory.groceries);
      final result = BudgetCalculator.planCategoryTotals(
        [item], [item], 2024, 1, true,
        financialTypeFilter: FinancialType.asset,
      );
      expect(result, isEmpty);
    });

    test('monthly mode normalizes yearly item amounts', () {
      final item = makeFixedCost(
        id: 'y1', amount: 1200,
        frequency: PlanFrequency.yearly,
        category: ExpenseCategory.housing,
      );
      final result = BudgetCalculator.planCategoryTotals(
          [item], [item], 2024, 6, true);
      expect(result[ExpenseCategory.housing]!.total, closeTo(100, 0.001));
    });
  });

  // ── financialTypeIncomeRatios ─────────────────────────────────────────────

  group('financialTypeIncomeRatios', () {
    ReportLine makeLine(FinancialType type, double amount) => ReportLine(
          category: ExpenseCategory.other,
          financialType: type,
          amount: amount,
        );

    test('returns null percentages when income is zero', () {
      final lines = [makeLine(FinancialType.consumption, 100)];
      final ratio = BudgetCalculator.financialTypeIncomeRatios(lines, 0);
      expect(ratio.hasIncome, isFalse);
      expect(ratio.consumptionPct, isNull);
      expect(ratio.assetPct, isNull);
      expect(ratio.insurancePct, isNull);
    });

    test('returns null percentages when income is negative', () {
      final ratio = BudgetCalculator.financialTypeIncomeRatios([], -100);
      expect(ratio.hasIncome, isFalse);
    });

    test('computes correct percentages', () {
      final lines = [
        makeLine(FinancialType.consumption, 500),
        makeLine(FinancialType.asset, 200),
        makeLine(FinancialType.insurance, 100),
      ];
      final ratio = BudgetCalculator.financialTypeIncomeRatios(lines, 1000);
      expect(ratio.hasIncome, isTrue);
      expect(ratio.consumptionPct, closeTo(50.0, 0.001));
      expect(ratio.assetPct, closeTo(20.0, 0.001));
      expect(ratio.insurancePct, closeTo(10.0, 0.001));
    });

    test('handles empty lines with positive income', () {
      final ratio = BudgetCalculator.financialTypeIncomeRatios([], 1000);
      expect(ratio.hasIncome, isTrue);
      expect(ratio.consumptionPct, closeTo(0.0, 0.001));
      expect(ratio.assetPct, closeTo(0.0, 0.001));
      expect(ratio.insurancePct, closeTo(0.0, 0.001));
    });

    test('sums multiple lines of same type', () {
      final lines = [
        makeLine(FinancialType.consumption, 300),
        makeLine(FinancialType.consumption, 200),
      ];
      final ratio = BudgetCalculator.financialTypeIncomeRatios(lines, 1000);
      expect(ratio.consumptionPct, closeTo(50.0, 0.001));
    });
  });

  // ── categoryOverages ─────────────────────────────────────────────────────

  group('BudgetCalculator.categoryOverages', () {
    Expense makeOverageExpense(ExpenseCategory category, double amount) =>
        Expense(
          id: '${category.name}_$amount',
          amount: amount,
          category: category,
          financialType: FinancialType.consumption,
          date: DateTime(2025, 3, 1),
        );

    test('returns empty map when budgets map is empty', () {
      final expenses = [makeOverageExpense(ExpenseCategory.groceries, 400)];
      expect(BudgetCalculator.categoryOverages(expenses, {}), isEmpty);
    });

    test('returns empty map when no spending exceeds any budget', () {
      final expenses = [makeOverageExpense(ExpenseCategory.groceries, 200)];
      final budgets = {ExpenseCategory.groceries: 300.0};
      expect(BudgetCalculator.categoryOverages(expenses, budgets), isEmpty);
    });

    test('returns overage when spending exceeds budget', () {
      final expenses = [makeOverageExpense(ExpenseCategory.groceries, 400)];
      final budgets = {ExpenseCategory.groceries: 300.0};
      final result = BudgetCalculator.categoryOverages(expenses, budgets);
      expect(result[ExpenseCategory.groceries], closeTo(100.0, 0.001));
    });

    test('does not include categories at exactly budget limit', () {
      final expenses = [makeOverageExpense(ExpenseCategory.groceries, 300)];
      final budgets = {ExpenseCategory.groceries: 300.0};
      expect(BudgetCalculator.categoryOverages(expenses, budgets), isEmpty);
    });

    test('only checks categories present in budgets map', () {
      // Housing is over-spent but has no budget → should not appear in overages.
      final expenses = [
        makeOverageExpense(ExpenseCategory.groceries, 200),
        makeOverageExpense(ExpenseCategory.housing, 2000),
      ];
      final budgets = {ExpenseCategory.groceries: 300.0};
      final result = BudgetCalculator.categoryOverages(expenses, budgets);
      expect(result.containsKey(ExpenseCategory.housing), isFalse);
    });

    test('returns zero spending categories as no overage', () {
      // Transport has a budget but no expenses.
      final budgets = {ExpenseCategory.transport: 100.0};
      final result = BudgetCalculator.categoryOverages([], budgets);
      expect(result, isEmpty);
    });

    test('sums multiple expenses in the same category', () {
      final expenses = [
        makeOverageExpense(ExpenseCategory.groceries, 150),
        makeOverageExpense(ExpenseCategory.groceries, 200),
      ];
      final budgets = {ExpenseCategory.groceries: 300.0};
      final result = BudgetCalculator.categoryOverages(expenses, budgets);
      expect(result[ExpenseCategory.groceries], closeTo(50.0, 0.001));
    });

    test('handles multiple categories with mixed results', () {
      final expenses = [
        makeOverageExpense(ExpenseCategory.groceries, 400), // over by 100
        makeOverageExpense(ExpenseCategory.housing, 800),   // under (budget 1000)
        makeOverageExpense(ExpenseCategory.transport, 250), // over by 50
      ];
      final budgets = {
        ExpenseCategory.groceries: 300.0,
        ExpenseCategory.housing: 1000.0,
        ExpenseCategory.transport: 200.0,
      };
      final result = BudgetCalculator.categoryOverages(expenses, budgets);
      expect(result.length, 2);
      expect(result[ExpenseCategory.groceries], closeTo(100.0, 0.001));
      expect(result[ExpenseCategory.transport], closeTo(50.0, 0.001));
      expect(result.containsKey(ExpenseCategory.housing), isFalse);
    });
  });
}
