/// Describes a single row that could not be parsed during import.
class ImportRowError {
  /// Spreadsheet row number (1-indexed; row 1 is the header, data starts at 2).
  final int rowNumber;

  /// Name of the field that caused the error (e.g. 'Date', 'Amount').
  final String field;

  /// Human-readable description of the problem.
  final String message;

  const ImportRowError({
    required this.rowNumber,
    required this.field,
    required this.message,
  });
}
