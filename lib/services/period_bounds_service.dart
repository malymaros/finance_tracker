import '../models/period_bounds.dart';
import '../models/year_month.dart';

/// Pure static service that computes the allowed navigation range for period
/// selectors.
///
/// The window is year-based and always provides one empty buffer year on each
/// side of the plan data range. On a fresh install the window covers:
///   previous year — current year — next year
///
/// When the user adds plan data in a boundary year that year becomes part of
/// the active range and one additional empty year unlocks on that side.
///
/// Only plan data drives boundary expansion. Finance data (expenses/income)
/// does not affect the window.
class PeriodBoundsService {
  const PeriodBoundsService._();

  static PeriodBounds compute({
    YearMonth? planEarliest,
    YearMonth? planLatest,
  }) {
    final nowYear = YearMonth.now().year;

    final int minYear;
    final int maxYear;

    if (planEarliest == null && planLatest == null) {
      minYear = nowYear - 1;
      maxYear = nowYear + 1;
    } else {
      final lowestPlan  = planEarliest?.year ?? planLatest!.year;
      final highestPlan = planLatest?.year  ?? planEarliest!.year;
      minYear = (lowestPlan  - 1 < nowYear - 1) ? lowestPlan  - 1 : nowYear - 1;
      maxYear = (highestPlan + 1 > nowYear + 1) ? highestPlan + 1 : nowYear + 1;
    }

    return PeriodBounds(
      min: YearMonth(minYear, 1),
      max: YearMonth(maxYear, 12),
    );
  }
}
