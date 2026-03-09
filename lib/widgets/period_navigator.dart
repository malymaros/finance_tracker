import 'package:flutter/material.dart';

import '../models/year_month.dart';
import 'period_picker_sheet.dart';

const _monthNames = [
  '',
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class PeriodNavigator extends StatelessWidget {
  final YearMonth selected;

  /// If true, shows only the year; if false, shows "Month YYYY".
  final bool yearOnly;

  final YearMonth? min;
  final YearMonth? max;
  final void Function(YearMonth) onChanged;

  const PeriodNavigator({
    super.key,
    required this.selected,
    required this.yearOnly,
    required this.onChanged,
    this.min,
    this.max,
  });

  bool get _prevDisabled {
    if (min == null) return false;
    if (yearOnly) return selected.year <= min!.year;
    return selected.year == min!.year && selected.month == min!.month;
  }

  bool get _nextDisabled {
    if (max == null) return false;
    if (yearOnly) return selected.year >= max!.year;
    return selected.year == max!.year && selected.month == max!.month;
  }

  YearMonth get _prevPeriod {
    if (yearOnly) return YearMonth(selected.year - 1, selected.month);
    if (selected.month == 1) return YearMonth(selected.year - 1, 12);
    return YearMonth(selected.year, selected.month - 1);
  }

  YearMonth get _nextPeriod {
    if (yearOnly) return YearMonth(selected.year + 1, selected.month);
    if (selected.month == 12) return YearMonth(selected.year + 1, 1);
    return YearMonth(selected.year, selected.month + 1);
  }

  String get _label {
    if (yearOnly) return '${selected.year}';
    return '${_monthNames[selected.month]} ${selected.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevDisabled ? null : () => onChanged(_prevPeriod),
          ),
          SizedBox(
            width: 180,
            child: yearOnly
                ? Text(
                    _label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  )
                : GestureDetector(
                    onTap: () => showPeriodPicker(
                      context: context,
                      selected: selected,
                      min: min,
                      max: max,
                      onChanged: onChanged,
                    ),
                    child: Text(
                      _label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextDisabled ? null : () => onChanged(_nextPeriod),
          ),
        ],
      ),
    );
  }
}
