import 'package:flutter/material.dart';

import '../models/import_row_error.dart';
import '../theme/app_theme.dart';

/// Compact tile showing one row that failed to parse, with the reason.
class ImportErrorTile extends StatelessWidget {
  final ImportRowError error;

  const ImportErrorTile({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warning,
        size: 20,
      ),
      title: Text(
        'Row ${error.rowNumber} — ${error.field}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.warning,
        ),
      ),
      subtitle: Text(
        error.message,
        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
      ),
    );
  }
}
