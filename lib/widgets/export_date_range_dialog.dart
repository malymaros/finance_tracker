import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Dialog that collects a start and end date for an expense export.
///
/// Usage:
/// ```dart
/// final range = await ExportDateRangeDialog.show(context);
/// if (range != null) { /* use range.start, range.end */ }
/// ```
class ExportDateRangeDialog extends StatefulWidget {
  const ExportDateRangeDialog({super.key});

  /// Shows the dialog and returns the selected range, or null if cancelled.
  static Future<({DateTime start, DateTime end})?> show(BuildContext context) {
    return showDialog<({DateTime start, DateTime end})>(
      context: context,
      builder: (_) => const ExportDateRangeDialog(),
    );
  }

  @override
  State<ExportDateRangeDialog> createState() => _ExportDateRangeDialogState();
}

class _ExportDateRangeDialogState extends State<ExportDateRangeDialog> {
  DateTime? _start;
  DateTime? _end;

  bool get _canConfirm =>
      _start != null && _end != null && !_end!.isBefore(_start!);

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final endBeforeStart =
        _start != null && _end != null && _end!.isBefore(_start!);

    return AlertDialog(
      title: const Text('Export Expenses'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Select the date range to export:',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Start Date',
            value: _start,
            formatted: _start != null ? _formatDate(_start!) : null,
            onTap: _pickStart,
          ),
          const SizedBox(height: 10),
          _DateField(
            label: 'End Date',
            value: _end,
            formatted: _end != null ? _formatDate(_end!) : null,
            onTap: _pickEnd,
          ),
          if (endBeforeStart) ...[
            const SizedBox(height: 8),
            const Text(
              'End date must be on or after start date.',
              style: TextStyle(color: AppColors.expense, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop((start: _start!, end: _end!))
              : null,
          child: const Text('Export'),
        ),
      ],
    );
  }
}

// ── Private helper widget ─────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? formatted;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.formatted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatted ?? 'Tap to select',
                    style: TextStyle(
                      fontSize: 14,
                      color: formatted != null ? null : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
