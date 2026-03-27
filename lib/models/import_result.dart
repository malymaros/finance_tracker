import 'import_row_error.dart';
import 'imported_expense.dart';

/// Result returned by [ImportExportService.parseImportFile].
class ImportResult {
  /// Rows that parsed successfully and are ready to import.
  final List<ImportedExpense> validRows;

  /// Rows that could not be parsed, with the reason.
  final List<ImportRowError> invalidRows;

  /// Total non-blank rows encountered (valid + invalid).
  final int totalRows;

  /// Non-null when the file structure itself is wrong (missing sheet, bad
  /// headers). When set, [validRows] and [invalidRows] are always empty and
  /// the import is blocked entirely.
  final String? headerError;

  const ImportResult({
    required this.validRows,
    required this.invalidRows,
    required this.totalRows,
    this.headerError,
  });
}
