import '../models/budget_status.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/financial_type_income_ratio.dart';
import '../models/monthly_overview_summary.dart';
import '../models/monthly_summary.dart';
import '../models/plan_item.dart';
import '../models/report_line.dart';
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
      if (item.frequency == PlanFrequency.oneTime) {
        // One-time items are only active in their exact validFrom month.
        if (item.validFrom == queried) {
          bySeriesId[item.seriesId] = item;
        }
        continue;
      }
      if (item.validFrom.isAtOrBefore(queried)) {
        final current = bySeriesId[item.seriesId];
        if (current == null || item.validFrom.isAfter(current.validFrom)) {
          bySeriesId[item.seriesId] = item;
        }
      }
    }

    return bySeriesId.values
        .where((i) => i.validTo == null || i.validTo!.isAtOrAfter(queried))
        .toList();
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

  // ── Normalized yearly totals ──────────────────────────────────────────────

  /// Yearly total income using normalized monthly amounts.
  /// Each month uses the active version for that month, correctly reflecting
  /// mid-year starts, end dates, and salary changes.
  static double yearlyIncome(List<PlanItem> allItems, int year) {
    double total = 0;
    for (int m = 1; m <= 12; m++) {
      final active = activeItemsForMonth(allItems, year, m)
          .where((i) => i.type == PlanItemType.income);
      total += active.fold(
          0.0, (sum, i) => sum + _normalizedContribution(i, year, m));
    }
    return total;
  }

  /// Yearly total fixed costs using normalized monthly amounts.
  static double yearlyFixedCosts(List<PlanItem> allItems, int year) {
    double total = 0;
    for (int m = 1; m <= 12; m++) {
      final active = activeItemsForMonth(allItems, year, m)
          .where((i) => i.type == PlanItemType.fixedCost);
      total += active.fold(
          0.0, (sum, i) => sum + _normalizedContribution(i, year, m));
    }
    return total;
  }

  // ── Per-item display helpers ──────────────────────────────────────────────

  /// Normalized monthly contribution for a single item.
  /// Use this to display an item's contribution in monthly plan view.
  static double itemMonthlyContribution(PlanItem item, int year, int month) =>
      _normalizedContribution(item, year, month);

  /// Returns the latest active version of each series that is active at any
  /// point during [year]. Iterates all 12 months; last active version wins
  /// per series (so December's version is the representative for the year).
  static List<PlanItem> activeItemsForYear(
      List<PlanItem> allItems, int year) {
    final result = <String, PlanItem>{};
    for (int m = 1; m <= 12; m++) {
      for (final item in activeItemsForMonth(allItems, year, m)) {
        result[item.seriesId] = item;
      }
    }
    return result.values.toList();
  }

  /// Total normalized contribution of a single item over a full year.
  /// Checks each month whether the item is the active version in its series.
  static double itemYearlyContribution(
      PlanItem item, List<PlanItem> allItems, int year) {
    double total = 0;
    for (int m = 1; m <= 12; m++) {
      if (activeItemsForMonth(allItems, year, m).any((a) => a.id == item.id)) {
        total += _normalizedContribution(item, year, m);
      }
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

    final income = normalizedMonthlyIncome(allItems, year, month);
    final fixedCosts = normalizedMonthlyFixedCosts(allItems, year, month);
    final budget = income - fixedCosts;

    return BudgetStatus(
      spendableBudget: budget,
      actualSpent: actualSpent,
      remaining: budget - actualSpent,
      percentUsed: budget > 0 ? (actualSpent / budget) * 100 : 0,
    );
  }

  // ── Plan fixed-cost report lines ─────────────────────────────────────────

  /// Converts active fixedCost PlanItems for a month into ReportLines,
  /// using normalized monthly amounts (monthly as-is, yearly /12,
  /// oneTime only in its exact month).
  ///
  /// Falls back to [ExpenseCategory.other] / [FinancialType.consumption]
  /// when the optional fields are not set on the PlanItem.
  static List<ReportLine> planFixedCostReportLinesForMonth(
      List<PlanItem> allItems, int year, int month) {
    return activeItemsForMonth(allItems, year, month)
        .where((i) => i.type == PlanItemType.fixedCost)
        .map((i) => ReportLine(
              category: i.category ?? ExpenseCategory.other,
              financialType: i.financialType ?? FinancialType.consumption,
              amount: _normalizedContribution(i, year, month),
            ))
        .toList();
  }

  /// Converts fixedCost PlanItems for a full year into ReportLines,
  /// using normalized monthly amounts summed across all active months.
  ///
  /// Lines with amount == 0 are omitted.
  static List<ReportLine> planFixedCostReportLinesForYear(
      List<PlanItem> allItems, int year) {
    final result = <ReportLine>[];
    for (int m = 1; m <= 12; m++) {
      for (final item in activeItemsForMonth(allItems, year, m)
          .where((i) => i.type == PlanItemType.fixedCost)) {
        final amount = _normalizedContribution(item, year, m);
        if (amount > 0) {
          result.add(ReportLine(
            category: item.category ?? ExpenseCategory.other,
            financialType: item.financialType ?? FinancialType.consumption,
            amount: amount,
          ));
        }
      }
    }
    return result;
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
        period: YearMonth(year, month),
        plannedIncome: income,
        plannedFixedCosts: fixedCosts,
        spendableBudget: spendable,
        actualExpenses: actual,
        difference: spendable - actual,
      );
    });
  }

  // ── Plan category breakdown ──────────────────────────────────────────────

  /// Groups [activeFixedCostItems] by category, summing each item's display
  /// amount for the given period. Returns a map sorted by total descending.
  ///
  /// In monthly mode uses [itemMonthlyContribution]; in yearly mode uses
  /// [itemYearlyContribution] (which correctly handles validity windows).
  static Map<ExpenseCategory, ({double total, int count})> planCategoryTotals(
    List<PlanItem> activeFixedCostItems,
    List<PlanItem> allItems,
    int year,
    int month,
    bool isMonthly,
  ) {
    final map = <ExpenseCategory, ({double total, int count})>{};
    for (final item in activeFixedCostItems) {
      final cat = item.category ?? ExpenseCategory.other;
      final amount = isMonthly
          ? itemMonthlyContribution(item, year, month)
          : itemYearlyContribution(item, allItems, year);
      final existing = map[cat];
      if (existing == null) {
        map[cat] = (total: amount, count: 1);
      } else {
        map[cat] = (total: existing.total + amount, count: existing.count + 1);
      }
    }
    final sorted = Map.fromEntries(
      map.entries.toList()
        ..sort((a, b) => b.value.total.compareTo(a.value.total)),
    );
    return sorted;
  }

  // ── Financial type income ratios ─────────────────────────────────────────

  /// Computes the percentage of [income] consumed by each financial type.
  /// Returns null percentages when [income] is zero or negative.
  static FinancialTypeIncomeRatio financialTypeIncomeRatios(
    List<ReportLine> lines,
    double income,
  ) {
    double consumption = 0;
    double asset = 0;
    double insurance = 0;
    for (final line in lines) {
      switch (line.financialType) {
        case FinancialType.consumption:
          consumption += line.amount;
          break;
        case FinancialType.asset:
          asset += line.amount;
          break;
        case FinancialType.insurance:
          insurance += line.amount;
          break;
      }
    }
    if (income <= 0) {
      return FinancialTypeIncomeRatio(
        consumptionPct: null,
        assetPct: null,
        insurancePct: null,
        consumptionAmount: consumption,
        assetAmount: asset,
        insuranceAmount: insurance,
      );
    }
    return FinancialTypeIncomeRatio(
      consumptionPct: (consumption / income) * 100,
      assetPct: (asset / income) * 100,
      insurancePct: (insurance / income) * 100,
      consumptionAmount: consumption,
      assetAmount: asset,
      insuranceAmount: insurance,
    );
  }

  // ── Money-flow overview ───────────────────────────────────────────────────

  /// Produces a [MonthlyOverviewSummary] for each of the 12 months in [year].
  ///
  /// Each summary captures:
  /// - [earned]      — normalized planned income
  /// - [consumption] — all lines with financialType consumption or insurance
  /// - [assets]      — all lines with financialType asset
  /// - [result]      — earned minus all allocated money
  ///
  /// Lines are merged from actual [expenses] and active fixed-cost plan items.
  static List<MonthlyOverviewSummary> monthlyOverviewSummaries(
      List<PlanItem> allItems, List<Expense> expenses, int year) {
    return List.generate(12, (i) {
      final month = i + 1;
      final earned = normalizedMonthlyIncome(allItems, year, month);

      // Build merged lines: actual expenses + plan fixed costs.
      final expenseLines = expenses
          .where((e) => e.date.year == year && e.date.month == month)
          .map((e) => ReportLine(
                category: e.category,
                financialType: e.financialType,
                amount: e.amount,
              ));
      final planLines =
          planFixedCostReportLinesForMonth(allItems, year, month);
      final allLines = [...expenseLines, ...planLines];

      double consumption = 0;
      double assets = 0;
      for (final line in allLines) {
        switch (line.financialType) {
          case FinancialType.asset:
            assets += line.amount;
          case FinancialType.consumption:
          case FinancialType.insurance:
            consumption += line.amount;
        }
      }

      return MonthlyOverviewSummary(
        period: YearMonth(year, month),
        earned: earned,
        consumption: consumption,
        assets: assets,
        result: earned - consumption - assets,
      );
    });
  }
}
