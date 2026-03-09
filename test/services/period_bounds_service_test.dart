import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/period_bounds_service.dart';

void main() {
  group('PeriodBoundsService.compute', () {
    test('no data: bounds are ±1 month around now', () {
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute();
      expect(bounds.min, equals(now.addMonths(-1)));
      expect(bounds.max, equals(now.addMonths(1)));
    });

    test('single data point older than now: min expands to data-1', () {
      final old = YearMonth(2020, 6);
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute(financeEarliest: old);
      expect(bounds.min, equals(old.addMonths(-1)));
      expect(bounds.max, equals(now.addMonths(1)));
    });

    test('data point in the future: max expands to data+1', () {
      final future = YearMonth(2099, 6);
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute(planLatest: future);
      expect(bounds.min, equals(now.addMonths(-1)));
      expect(bounds.max, equals(future.addMonths(1)));
    });

    test('finance and plan data merged: min is global earliest - 1', () {
      final finEarliest = YearMonth(2022, 3);
      final finLatest = YearMonth(2023, 8);
      final planEarliest = YearMonth(2021, 11);
      final planLatest = YearMonth(2024, 2);
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute(
        financeEarliest: finEarliest,
        financeLatest: finLatest,
        planEarliest: planEarliest,
        planLatest: planLatest,
      );
      // min = global earliest (planEarliest 2021-11) - 1 month
      expect(bounds.min, equals(YearMonth(2021, 10)));
      // max = max(planLatest 2024-02, now) + 1 month
      final expectedLatest = planLatest.isAfter(now) ? planLatest : now;
      expect(bounds.max, equals(expectedLatest.addMonths(1)));
    });

    test('year boundary: earliest in January wraps min to December prior year', () {
      final earliest = YearMonth(2023, 1);
      final bounds = PeriodBoundsService.compute(
        financeEarliest: earliest,
        financeLatest: earliest,
      );
      expect(bounds.min, equals(YearMonth(2022, 12)));
    });

    test('year boundary: latest in December wraps max to January next year', () {
      final latest = YearMonth(2023, 12);
      final now = YearMonth.now();
      final effectiveLatest = latest.isAfter(now) ? latest : now;
      final bounds = PeriodBoundsService.compute(
        financeEarliest: latest,
        financeLatest: latest,
      );
      expect(bounds.max, equals(effectiveLatest.addMonths(1)));
    });

    test('allows: returns true for period within bounds', () {
      final bounds = PeriodBoundsService.compute(
        financeEarliest: YearMonth(2023, 1),
        financeLatest: YearMonth(2023, 12),
      );
      expect(bounds.allows(YearMonth(2023, 6)), isTrue);
    });

    test('allows: returns false for period before min', () {
      final bounds = PeriodBoundsService.compute(
        financeEarliest: YearMonth(2023, 3),
        financeLatest: YearMonth(2023, 12),
      );
      expect(bounds.allows(YearMonth(2022, 1)), isFalse);
    });

    test('allows: returns false for period after max', () {
      final bounds = PeriodBoundsService.compute(
        financeEarliest: YearMonth(2020, 1),
        financeLatest: YearMonth(2020, 6),
      );
      final now = YearMonth.now();
      // max will be max(now, 2020-06) + 1 = now + 1
      expect(bounds.allows(now.addMonths(5)), isFalse);
    });
  });
}
