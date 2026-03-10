import 'package:flutter/material.dart';

import '../models/year_month.dart';
import '../theme/app_theme.dart';
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
    return !selected.isAfter(min!);
  }

  bool get _nextDisabled {
    if (max == null) return false;
    if (yearOnly) return selected.year >= max!.year;
    return !selected.isBefore(max!);
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

  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    side: BorderSide(color: AppColors.border),
  );

  @override
  Widget build(BuildContext context) {
    final buttonStyle = IconButton.styleFrom(
      backgroundColor: AppColors.surface,
      shape: _buttonShape,
    );

    Widget label = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: yearOnly
          ? Text(
              _label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
    );

    if (!yearOnly) {
      label = GestureDetector(
        onTap: () => showPeriodPicker(
          context: context,
          selected: selected,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
        child: label,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _prevDisabled ? null : () => onChanged(_prevPeriod),
            style: buttonStyle,
          ),
          const SizedBox(width: 8),
          label,
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextDisabled ? null : () => onChanged(_nextPeriod),
            style: buttonStyle,
          ),
        ],
      ),
    );
  }
}
