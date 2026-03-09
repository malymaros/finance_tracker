import '../models/period_bounds.dart';
import '../models/year_month.dart';

/// Pure static service that computes the allowed navigation range for period
/// selectors. Always includes the current month. Expands data range by one
/// month in each direction so the user can navigate just beyond actual data.
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
      if (financeEarliest != null) financeEarliest,
      if (financeLatest != null) financeLatest,
      if (planEarliest != null) planEarliest,
      if (planLatest != null) planLatest,
    ];
    final earliest = candidates.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = candidates.reduce((a, b) => a.isAfter(b) ? a : b);
    return PeriodBounds(
      min: earliest.addMonths(-1),
      max: latest.addMonths(1),
    );
  }
}
