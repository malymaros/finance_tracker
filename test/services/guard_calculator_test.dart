import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations_en.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/guard_calculator.dart';

final _l10n = AppLocalizationsEn();

void main() {
  // ── daysInMonth ────────────────────────────────────────────────────────────

  group('daysInMonth', () {
    test('returns 31 for January', () {
      expect(GuardCalculator.daysInMonth(YearMonth(2025, 1)), 31);
    });

    test('returns 28 for February in a non-leap year', () {
      expect(GuardCalculator.daysInMonth(YearMonth(2025, 2)), 28);
    });

    test('returns 29 for February in a leap year', () {
      expect(GuardCalculator.daysInMonth(YearMonth(2024, 2)), 29);
    });

    test('returns 30 for April', () {
      expect(GuardCalculator.daysInMonth(YearMonth(2025, 4)), 30);
    });

    test('returns 31 for December', () {
      expect(GuardCalculator.daysInMonth(YearMonth(2025, 12)), 31);
    });
  });

  // ── clampDueDay ────────────────────────────────────────────────────────────

  group('clampDueDay', () {
    test('null rawDueDay defaults to 1', () {
      expect(GuardCalculator.clampDueDay(null, YearMonth(2025, 3)), 1);
    });

    test('valid day within month is unchanged', () {
      expect(GuardCalculator.clampDueDay(15, YearMonth(2025, 3)), 15);
    });

    test('day 31 clamped to 28 for Feb non-leap year', () {
      expect(GuardCalculator.clampDueDay(31, YearMonth(2025, 2)), 28);
    });

    test('day 31 clamped to 29 for Feb in a leap year', () {
      expect(GuardCalculator.clampDueDay(31, YearMonth(2024, 2)), 29);
    });

    test('day 31 clamped to 30 for a 30-day month (April)', () {
      expect(GuardCalculator.clampDueDay(31, YearMonth(2025, 4)), 30);
    });

    test('day 31 unchanged for a 31-day month (March)', () {
      expect(GuardCalculator.clampDueDay(31, YearMonth(2025, 3)), 31);
    });

    test('day 0 clamped to 1', () {
      expect(GuardCalculator.clampDueDay(0, YearMonth(2025, 3)), 1);
    });

    test('negative day clamped to 1', () {
      expect(GuardCalculator.clampDueDay(-5, YearMonth(2025, 3)), 1);
    });

    test('day exactly equal to month length is unchanged', () {
      expect(GuardCalculator.clampDueDay(30, YearMonth(2025, 4)), 30);
    });

    test('works correctly for December (month 12)', () {
      expect(GuardCalculator.clampDueDay(31, YearMonth(2025, 12)), 31);
    });
  });

  // ── formatReminderPeriod ───────────────────────────────────────────────────

  group('formatReminderPeriod', () {
    test('formats a standard date correctly', () {
      expect(
        GuardCalculator.formatReminderPeriod(15, YearMonth(2026, 3), _l10n),
        'March 15, 2026',
      );
    });

    test('null due day formats as day 1', () {
      expect(
        GuardCalculator.formatReminderPeriod(null, YearMonth(2026, 1), _l10n),
        'January 1, 2026',
      );
    });

    test('clamped day is reflected in the output (Feb 30 → Feb 28)', () {
      expect(
        GuardCalculator.formatReminderPeriod(30, YearMonth(2025, 2), _l10n),
        'February 28, 2025',
      );
    });
  });

  // ── dueDateLabel ──────────────────────────────────────────────────────────

  group('dueDateLabel', () {
    test('appends " due" to the formatted period', () {
      expect(
        GuardCalculator.dueDateLabel(15, YearMonth(2026, 3), _l10n),
        'March 15, 2026 due',
      );
    });

    test('null due day produces "... 1, ... due"', () {
      expect(
        GuardCalculator.dueDateLabel(null, YearMonth(2026, 5), _l10n),
        'May 1, 2026 due',
      );
    });
  });
}
