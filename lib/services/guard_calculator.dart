import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/year_month.dart';

/// Pure static helpers for GUARD due-day arithmetic.
///
/// Centralises the "clamp raw due day to the actual days in a calendar month"
/// calculation that was previously duplicated across [GuardRepository],
/// [GuardBanner], and [GuardScreen].
class GuardCalculator {
  const GuardCalculator._();

  /// Returns the number of days in the month represented by [period].
  ///
  /// Uses the "day 0 of next month" trick which is robust across leap years.
  static int daysInMonth(YearMonth period) =>
      DateTime(period.year, period.month + 1, 0).day;

  /// Clamps [rawDueDay] to the valid range [1, daysInMonth(period)].
  ///
  /// Null [rawDueDay] is treated as 1 (the safest default). Use this whenever
  /// showing or comparing a due day so that a stored value of 31 is correctly
  /// presented as 28/29/30 in shorter months.
  static int clampDueDay(int? rawDueDay, YearMonth period) =>
      (rawDueDay ?? 1).clamp(1, daysInMonth(period));

  /// Formats a period as a human-readable reminder date string.
  ///
  /// Example: "March 15, 2026"
  static String formatReminderPeriod(
      int? rawDueDay, YearMonth period, AppLocalizations l10n) {
    final day = clampDueDay(rawDueDay, period);
    return '${l10n.monthName(period.month)} $day, ${period.year}';
  }

  /// Formats a due-date label for display in the GUARD banner.
  ///
  /// Delegates to [formatReminderPeriod] and appends " due".
  /// Example: "March 15, 2026 due"
  static String dueDateLabel(
          int? rawDueDay, YearMonth period, AppLocalizations l10n) =>
      '${formatReminderPeriod(rawDueDay, period, l10n)} due';
}
