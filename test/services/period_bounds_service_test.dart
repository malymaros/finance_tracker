import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/period_bounds_service.dart';

void main() {
  group('PeriodBoundsService.compute', () {
    // ── Fresh app (no data) ───────────────────────────────────────────────

    test('no data: min is January of previous year', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
    });

    test('no data: max is December of next year', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    // ── Plan data in current year ─────────────────────────────────────────

    test('plan data in current year: window stays nowYear±1', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear, 3),
        planLatest: YearMonth(nowYear, 9),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    // ── Expansion on past boundary ────────────────────────────────────────

    test('plan data one year before now: expands min by one year', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear - 1, 6),
        planLatest: YearMonth(nowYear, 1),
      );
      // data reaches nowYear-1, so min = Jan of (nowYear-1) - 1 = nowYear-2
      expect(bounds.min, equals(YearMonth(nowYear - 2, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('plan data two years before now: expands min further', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear - 2, 1),
        planLatest: YearMonth(nowYear, 1),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 3, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    // ── Expansion on future boundary ──────────────────────────────────────

    test('plan data one year after now: expands max by one year', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear, 1),
        planLatest: YearMonth(nowYear + 1, 6),
      );
      // data reaches nowYear+1, so max = Dec of (nowYear+1) + 1 = nowYear+2
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 2, 12)));
    });

    test('plan data two years after now: expands max further', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear, 1),
        planLatest: YearMonth(nowYear + 2, 1),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 3, 12)));
    });

    // ── Only planEarliest or planLatest provided ──────────────────────────

    test('only planEarliest provided: uses it for min calculation', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(nowYear - 1, 5),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 2, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 1, 12)));
    });

    test('only planLatest provided: uses it for max calculation', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute(
        planLatest: YearMonth(nowYear + 1, 8),
      );
      expect(bounds.min, equals(YearMonth(nowYear - 1, 1)));
      expect(bounds.max, equals(YearMonth(nowYear + 2, 12)));
    });

    // ── Min is always January, max is always December ─────────────────────

    test('min is always the first month of its year', () {
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(2020, 6),
        planLatest: YearMonth(2020, 6),
      );
      expect(bounds.min!.month, equals(1));
    });

    test('max is always the last month of its year', () {
      final bounds = PeriodBoundsService.compute(
        planEarliest: YearMonth(2020, 6),
        planLatest: YearMonth(2020, 6),
      );
      expect(bounds.max!.month, equals(12));
    });

    // ── allows() integration ──────────────────────────────────────────────

    test('allows: current year is always within bounds', () {
      final now = YearMonth.now();
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(now), isTrue);
    });

    test('allows: January of min year is within bounds', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(YearMonth(nowYear - 1, 1)), isTrue);
    });

    test('allows: December of max year is within bounds', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(YearMonth(nowYear + 1, 12)), isTrue);
    });

    test('allows: month before min year is out of bounds', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(YearMonth(nowYear - 2, 12)), isFalse);
    });

    test('allows: month after max year is out of bounds', () {
      final nowYear = YearMonth.now().year;
      final bounds = PeriodBoundsService.compute();
      expect(bounds.allows(YearMonth(nowYear + 2, 1)), isFalse);
    });
  });
}
