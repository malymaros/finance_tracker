import '../models/guard_state.dart';
import '../models/plan_item.dart';
import '../models/plan_snapshot.dart';
import '../models/report_line.dart';
import '../models/year_month.dart';
import 'budget_calculator.dart';
import 'report_aggregator.dart';

/// Assembles a [PlanSnapshot] from raw repository data.
///
/// Pure static class — no state, no repository dependency. Guard data is
/// passed in as plain arguments so the builder remains testable without
/// a live [GuardRepository].
class PlanSnapshotBuilder {
  const PlanSnapshotBuilder._();

  static PlanSnapshot build({
    required List<PlanItem> allItems,
    required List<ReportLine> reportLines,
    required YearMonth period,
    required bool isMonthly,
    required Map<String, GuardState> guardStateMap,
    required List<(PlanItem, YearMonth)> unpaidActive,
    required List<(PlanItem, YearMonth)> silenced,
  }) {
    final year = period.year;
    final month = period.month;

    final List<PlanItem> displayItems;
    final double totalIncome;
    final double totalFixedCosts;
    final List<ReportLine> planLines;

    if (isMonthly) {
      displayItems =
          BudgetCalculator.activeItemsForMonth(allItems, year, month);
      totalIncome =
          BudgetCalculator.normalizedMonthlyIncome(allItems, year, month);
      totalFixedCosts =
          BudgetCalculator.normalizedMonthlyFixedCosts(allItems, year, month);
      planLines = BudgetCalculator.planFixedCostReportLinesForMonth(
          allItems, year, month);
    } else {
      displayItems = BudgetCalculator.activeItemsForYear(allItems, year);
      totalIncome = BudgetCalculator.yearlyIncome(allItems, year);
      totalFixedCosts = BudgetCalculator.yearlyFixedCosts(allItems, year);
      planLines =
          BudgetCalculator.planFixedCostReportLinesForYear(allItems, year);
    }

    final incomeItems =
        displayItems.where((i) => i.type == PlanItemType.income).toList();
    final fixedCostItems =
        displayItems.where((i) => i.type == PlanItemType.fixedCost).toList();

    final mergedLines = ReportAggregator.mergedLines(reportLines, planLines);
    final ratio =
        BudgetCalculator.financialTypeIncomeRatios(mergedLines, totalIncome);

    return PlanSnapshot(
      period: period,
      isMonthly: isMonthly,
      incomeItems: incomeItems,
      fixedCostItems: fixedCostItems,
      totalIncome: totalIncome,
      totalFixedCosts: totalFixedCosts,
      financialTypeRatio: ratio,
      guardStateMap: guardStateMap,
      unpaidActive: unpaidActive,
      silenced: silenced,
    );
  }
}
