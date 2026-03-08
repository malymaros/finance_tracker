import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/monthly_summary.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';

/// Pure static aggregation functions for budget calculations.
/// All methods take plain data — no repository dependency — making them
/// fully testable without Flutter or IO.
class BudgetCalculator {
  // ── Active version resolution ─────────────────────────────────────────────

  /// For each series in [allItems], returns the version whose [validFrom]
  /// is the latest one still at or before [year]/[month].
  ///
  /// Items whose [validFrom] is after the queried period are ignored,
  /// so future planned changes do not affect current calculations.
  static List<PlanItem> activeItemsForMonth(
      List<PlanItem> allItems, int year, int month) {
    final queried = YearMonth(year, month);
    final bySeriesId = <String, PlanItem>{};

    for (final item in allItems) {
      if (item.validFrom.isAtOrBefore(queried)) {
        final current = bySeriesId[item.seriesId];
        if (current == null || item.validFrom.isAfter(current.validFrom)) {
          bySeriesId[item.seriesId] = item;
        }
      }
    }

    return bySeriesId.values.toList();
  }

  // ── Normalized monthly contributions ─────────────────────────────────────

  /// Normalized monthly contribution of a single item for planning purposes:
  /// - monthly  → amount as-is
  /// - yearly   → amount / 12
  /// - oneTime  → amount only in its exact validFrom month, else 0
  static double _normalizedContribution(
      PlanItem item, int year, int month) {
    switch (item.frequency) {
      case PlanFrequency.monthly:
        return item.amount;
      case PlanFrequency.yearly:
        return item.amount / 12;
      case PlanFrequency.oneTime:
        return (item.validFrom.year == year && item.validFrom.month == month)
            ? item.amount
            : 0.0;
    }
  }

  /// Normalized monthly income for the given period.
  static double normalizedMonthlyIncome(
      List<PlanItem> allItems, int year, int month) {
    return activeItemsForMonth(allItems, year, month)
        .where((i) => i.type == PlanItemType.income)
        .fold(0.0, (sum, i) => sum + _normalizedContribution(i, year, month));
  }

  /// Normalized monthly fixed costs for the given period.
  static double normalizedMonthlyFixedCosts(
      List<PlanItem> allItems, int year, int month) {
    return activeItemsForMonth(allItems, year, month)
        .where((i) => i.type == PlanItemType.fixedCost)
        .fold(0.0, (sum, i) => sum + _normalizedContribution(i, year, month));
  }

  /// Spendable budget for the given month (normalized income − fixed costs).
  static double spendableBudget(
      List<PlanItem> allItems, int year, int month) {
    return normalizedMonthlyIncome(allItems, year, month) -
        normalizedMonthlyFixedCosts(allItems, year, month);
  }

  // ── Cash-flow yearly totals ───────────────────────────────────────────────

  /// Cash-flow contribution of a single item for a given month.
  /// Used for yearly totals where yearly items appear once in their anniversary
  /// month rather than being spread across 12 months.
  static double _cashFlowContribution(PlanItem item, int year, int month) {
    switch (item.frequency) {
      case PlanFrequency.monthly:
        return item.amount;
      case PlanFrequency.yearly:
        // Fires once per year in validFrom.month (the anniversary month).
        return item.validFrom.month == month ? item.amount : 0.0;
      case PlanFrequency.oneTime:
        return (item.validFrom.year == year && item.validFrom.month == month)
            ? item.amount
            : 0.0;
    }
  }

  /// Yearly total income using cash-flow rules.
  /// Each month uses the active version for that month, correctly reflecting
  /// mid-year changes (e.g. salary increase in March).
  static double yearlyIncome(List<PlanItem> allItems, int year) {
    double total = 0;
    for (int m = 1; m <= 12; m++) {
      final active = activeItemsForMonth(allItems, year, m)
          .where((i) => i.type == PlanItemType.income);
      total += active.fold(
          0.0, (sum, i) => sum + _cashFlowContribution(i, year, m));
    }
    return total;
  }

  /// Yearly total fixed costs using cash-flow rules.
  static double yearlyFixedCosts(List<PlanItem> allItems, int year) {
    double total = 0;
    for (int m = 1; m <= 12; m++) {
      final active = activeItemsForMonth(allItems, year, m)
          .where((i) => i.type == PlanItemType.fixedCost);
      total += active.fold(
          0.0, (sum, i) => sum + _cashFlowContribution(i, year, m));
    }
    return total;
  }

  // ── Budget status (Expenses tab) ─────────────────────────────────────────

  /// Returns [BudgetStatus] for the budget progress bar on the Expenses tab.
  /// Returns null if no income plan items are active (bar should be hidden).
  static BudgetStatus? budgetStatus(
      List<PlanItem> allItems, double actualSpent, int year, int month) {
    final active = activeItemsForMonth(allItems, year, month);
    final hasIncome = active.any((i) => i.type == PlanItemType.income);
    if (!hasIncome) return null;

    final income = active
        .where((i) => i.type == PlanItemType.income)
        .fold(0.0, (sum, i) => sum + _normalizedContribution(i, year, month));

    final fixedCosts = active
        .where((i) => i.type == PlanItemType.fixedCost)
        .fold(0.0, (sum, i) => sum + _normalizedContribution(i, year, month));

    final budget = income - fixedCosts;

    return BudgetStatus(
      spendableBudget: budget,
      actualSpent: actualSpent,
      remaining: budget - actualSpent,
      percentUsed: budget > 0 ? (actualSpent / budget) * 100 : 0,
    );
  }

  // ── Monthly overview ─────────────────────────────────────────────────────

  /// Produces a [MonthlySummary] for each of the 12 months in [year],
  /// comparing the normalized plan against actual [expenses].
  static List<MonthlySummary> monthlySummaries(
      List<PlanItem> allItems, List<Expense> expenses, int year) {
    return List.generate(12, (i) {
      final month = i + 1;
      final income = normalizedMonthlyIncome(allItems, year, month);
      final fixedCosts = normalizedMonthlyFixedCosts(allItems, year, month);
      final spendable = income - fixedCosts;
      final actual = expenses
          .where((e) => e.date.year == year && e.date.month == month)
          .fold(0.0, (sum, e) => sum + e.amount);

      return MonthlySummary(
        year: year,
        month: month,
        plannedIncome: income,
        plannedFixedCosts: fixedCosts,
        spendableBudget: spendable,
        actualExpenses: actual,
        difference: spendable - actual,
      );
    });
  }
}
