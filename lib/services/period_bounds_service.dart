import '../models/period_bounds.dart';
import '../models/year_month.dart';

/// Pure static service that computes the allowed navigation range for period
/// selectors. Always includes the current month.
/// Min is set to the earliest actual data month (no past buffer) so that
/// navigation cannot reach periods where no data has ever existed.
/// Max is extended by one month so users can plan one month ahead.
class PeriodBoundsService {
  const PeriodBoundsService._();

  static PeriodBounds compute({
    YearMonth? financeEarliest,
    YearMonth? financeLatest,
    YearMonth? planEarliest,
    YearMonth? planLatest,
  }) {
    final now = YearMonth.now();
    final candidates = <YearMonth>[
      now,
      ?financeEarliest,
      ?financeLatest,
      ?planEarliest,
      ?planLatest,
    ];
    final earliest = candidates.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = candidates.reduce((a, b) => a.isAfter(b) ? a : b);
    return PeriodBounds(
      min: earliest,
      max: latest.addMonths(1),
    );
  }
}
