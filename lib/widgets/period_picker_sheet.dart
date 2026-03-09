import 'package:flutter/material.dart';

import '../models/year_month.dart';

const _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

Future<void> showPeriodPicker({
  required BuildContext context,
  required YearMonth selected,
  YearMonth? min,
  YearMonth? max,
  required void Function(YearMonth) onChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    builder: (_) => _PeriodPickerSheet(
      selected: selected,
      min: min,
      max: max,
      onChanged: onChanged,
    ),
  );
}

class _PeriodPickerSheet extends StatefulWidget {
  final YearMonth selected;
  final YearMonth? min;
  final YearMonth? max;
  final void Function(YearMonth) onChanged;

  const _PeriodPickerSheet({
    required this.selected,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_PeriodPickerSheet> createState() => _PeriodPickerSheetState();
}

class _PeriodPickerSheetState extends State<_PeriodPickerSheet> {
  late int _pickerYear;

  @override
  void initState() {
    super.initState();
    _pickerYear = widget.selected.year;
  }

  bool _isDisabled(int monthIndex) {
    final ym = YearMonth(_pickerYear, monthIndex);
    if (widget.min != null && ym.isBefore(widget.min!)) return true;
    if (widget.max != null && ym.isAfter(widget.max!)) return true;
    if (ym == widget.selected) return true;
    return false;
  }

  bool get _prevYearDisabled =>
      widget.min != null && _pickerYear <= widget.min!.year;

  bool get _nextYearDisabled =>
      widget.max != null && _pickerYear >= widget.max!.year;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevYearDisabled
                      ? null
                      : () => setState(() => _pickerYear--),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    '$_pickerYear',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextYearDisabled
                      ? null
                      : () => setState(() => _pickerYear++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.0,
              children: List.generate(12, (i) {
                final monthIndex = i + 1;
                final disabled = _isDisabled(monthIndex);
                return TextButton(
                  onPressed: disabled
                      ? null
                      : () {
                          widget.onChanged(YearMonth(_pickerYear, monthIndex));
                          Navigator.of(context).pop();
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: disabled ? Colors.grey : null,
                  ),
                  child: Text(_monthNames[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
