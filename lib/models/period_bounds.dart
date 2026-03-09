import 'year_month.dart';

class PeriodBounds {
  final YearMonth? min;
  final YearMonth? max;

  const PeriodBounds({this.min, this.max});

  bool allows(YearMonth ym) {
    if (min != null && ym.isBefore(min!)) return false;
    if (max != null && ym.isAfter(max!)) return false;
    return true;
  }
}
