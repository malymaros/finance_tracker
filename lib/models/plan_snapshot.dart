import 'financial_type_income_ratio.dart';
import 'guard_state.dart';
import 'plan_item.dart';
import 'year_month.dart';

/// Pre-assembled view of all plan data for a single period.
///
/// Produced by [PlanSnapshotBuilder.build]. Immutable value object —
/// no serialization, no ChangeNotifier.
class PlanSnapshot {
  final YearMonth period;
  final bool isMonthly;
  final List<PlanItem> incomeItems;
  final List<PlanItem> fixedCostItems;
  final double totalIncome;
  final double totalFixedCosts;
  final FinancialTypeIncomeRatio financialTypeRatio;

  /// GuardState for each fixed-cost series in this period, keyed by seriesId.
  final Map<String, GuardState> guardStateMap;

  /// Guarded periods that are due and unpaid (not silenced). Shown in the
  /// GuardBanner and Expense tab strip.
  final List<(PlanItem, YearMonth)> unpaidActive;

  /// Guarded periods that are silenced (excluded from unpaidActive). Also
  /// shown in the GuardBanner as a secondary indicator.
  final List<(PlanItem, YearMonth)> silenced;

  double get spendable => totalIncome - totalFixedCosts;

  const PlanSnapshot({
    required this.period,
    required this.isMonthly,
    required this.incomeItems,
    required this.fixedCostItems,
    required this.totalIncome,
    required this.totalFixedCosts,
    required this.financialTypeRatio,
    required this.guardStateMap,
    required this.unpaidActive,
    required this.silenced,
  });
}
