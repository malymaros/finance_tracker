import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/import_result.dart';
import '../models/import_row_error.dart';
import '../models/imported_expense.dart';

/// Pure static service for generating and parsing Finance Tracker xlsx files.
///
/// The workbook format is shared by the template, exports, and the parser so
/// that any exported file can be re-imported on another device without change.
///
/// Sheet layout:
///   Expenses     — the data sheet (headers + rows)
///   Instructions — human-readable field guide
///   _Lists       — dropdown source values (categories / financial types)
class ImportExportService {
  ImportExportService._();

  // ── Column indices (0-based) ──────────────────────────────────────────────

  static const _colDate = 0;
  static const _colAmount = 1;
  static const _colCategory = 2;
  static const _colFinancialType = 3;
  static const _colNote = 4;
  static const _colGroup = 5;

  static const _headers = [
    'Date',
    'Amount',
    'Category',
    'Financial Type',
    'Note',
    'Group',
  ];

  // ── Public constants ──────────────────────────────────────────────────────

  static const String xlsxMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Builds an empty import template workbook and returns its bytes.
  static Future<Uint8List> generateTemplate() async {
    return _buildWorkbook(const []);
  }

  /// Filters [expenses] to the inclusive date range [start]…[end] (full days),
  /// sorts them by date ascending, then returns a populated workbook.
  static Future<Uint8List> exportExpenses(
    List<Expense> expenses,
    DateTime start,
    DateTime end,
  ) async {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    final filtered = expenses
        .where((e) => !e.date.isBefore(startDay) && !e.date.isAfter(endDay))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return _buildWorkbook(filtered);
  }

  /// Parses an xlsx file and returns an [ImportResult].
  ///
  /// Hard errors (wrong file / scrambled headers) are returned as
  /// [ImportResult.headerError]; soft errors (bad rows) are in
  /// [ImportResult.invalidRows]. Valid rows are in [ImportResult.validRows].
  static ImportResult parseImportFile(Uint8List bytes) {
    // Decode workbook
    late final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (_) {
      return _hardError(
          'Could not read the file. Please ensure it is a valid .xlsx file.');
    }

    // Find the Expenses sheet (case-insensitive)
    Sheet? expensesSheet;
    for (final key in excel.sheets.keys) {
      if (key.trim().toLowerCase() == 'expenses') {
        expensesSheet = excel.sheets[key];
        break;
      }
    }
    if (expensesSheet == null) {
      return _hardError(
          'Sheet "Expenses" not found. Please use the Finance Tracker import template.');
    }

    final rows = expensesSheet.rows;
    if (rows.isEmpty) {
      return _hardError('The Expenses sheet is empty.');
    }

    // Validate header row
    final headerRow = rows[0];
    final expectedHeaders = [
      'date',
      'amount',
      'category',
      'financial type',
      'note',
      'group',
    ];
    for (var col = 0; col < expectedHeaders.length; col++) {
      final raw = col < headerRow.length ? headerRow[col]?.value : null;
      final actual = _cellString(raw)?.trim().toLowerCase() ?? '';
      if (actual != expectedHeaders[col]) {
        return _hardError(
            'Column ${col + 1} header mismatch: expected '
            '"${expectedHeaders[col]}", got "${actual.isEmpty ? '(empty)' : actual}". '
            'Please use the Finance Tracker import template.');
      }
    }

    // Parse data rows
    final validRows = <ImportedExpense>[];
    final invalidRows = <ImportRowError>[];
    var totalRows = 0;

    for (var i = 1; i < rows.length; i++) {
      // Use sheet.cell() directly so sparse rows (missing trailing columns)
      // are still fully accessible — sheet.rows truncates at the last non-null cell.
      CellValue? getCell(int col) =>
          expensesSheet!.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: i),
          ).value;

      final dateRaw = getCell(_colDate);
      final amountRaw = getCell(_colAmount);

      // Skip fully blank rows
      final dateStr = _cellString(dateRaw);
      final amountStr = _cellString(amountRaw);
      if ((dateStr == null || dateStr.isEmpty) &&
          (amountStr == null || amountStr.isEmpty)) {
        continue;
      }

      totalRows++;
      final rowNumber = i + 1; // 1-indexed (row 1 = header, row 2 = first data)

      // -- Date (required)
      final date = _cellDate(dateRaw);
      if (date == null) {
        invalidRows.add(ImportRowError(
          rowNumber: rowNumber,
          field: 'Date',
          message: dateStr == null || dateStr.isEmpty
              ? 'Date is required.'
              : 'Invalid date "${_truncate(dateStr, 20)}". Use YYYY-MM-DD or DD.MM.YYYY.',
        ));
        continue;
      }

      // -- Amount (required, > 0)
      final amount = _cellAmount(amountRaw);
      if (amount == null || amount <= 0) {
        invalidRows.add(ImportRowError(
          rowNumber: rowNumber,
          field: 'Amount',
          message: (amount != null && amount <= 0)
              ? 'Amount must be greater than zero.'
              : 'Invalid amount "${_truncate(amountStr ?? '', 20)}". Enter a positive number.',
        ));
        continue;
      }

      // -- Optional fields
      final categoryStr = _cellString(getCell(_colCategory))?.trim() ?? '';
      final typeStr = _cellString(getCell(_colFinancialType))?.trim() ?? '';
      final noteStr = _cellString(getCell(_colNote))?.trim();
      final groupStr = _cellString(getCell(_colGroup))?.trim();

      validRows.add(ImportedExpense(
        amount: amount,
        category: categoryStr.isEmpty
            ? ExpenseCategory.other
            : _categoryFromDisplayName(categoryStr),
        financialType: typeStr.isEmpty
            ? FinancialType.consumption
            : FinancialTypeX.fromDisplayName(typeStr),
        date: date,
        note: (noteStr == null || noteStr.isEmpty) ? null : noteStr,
        group: (groupStr == null || groupStr.isEmpty) ? null : groupStr,
      ));
    }

    return ImportResult(
      validRows: validRows,
      invalidRows: invalidRows,
      totalRows: totalRows,
    );
  }

  // ── Workbook builder ──────────────────────────────────────────────────────

  static Uint8List _buildWorkbook(List<Expense> data) {
    final excel = Excel.createExcel();

    // Access (creates) named sheets
    final expensesSheet = excel['Expenses'];
    final instructionsSheet = excel['Instructions'];
    final listsSheet = excel['_Lists'];

    // Remove the default 'Sheet1' created by Excel.createExcel()
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // -- Expenses: headers
    for (var col = 0; col < _headers.length; col++) {
      expensesSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
          .value = TextCellValue(_headers[col]);
    }

    // -- Expenses: data rows
    for (var i = 0; i < data.length; i++) {
      final e = data[i];
      final row = i + 1;
      _setCell(expensesSheet, _colDate, row, TextCellValue(_formatDate(e.date)));
      _setCell(expensesSheet, _colAmount, row, DoubleCellValue(e.amount));
      _setCell(expensesSheet, _colCategory, row, TextCellValue(e.category.displayName));
      _setCell(expensesSheet, _colFinancialType, row, TextCellValue(e.financialType.displayName));
      _setCell(expensesSheet, _colNote, row, TextCellValue(e.note ?? ''));
      _setCell(expensesSheet, _colGroup, row, TextCellValue(e.group ?? ''));
    }

    // -- Instructions sheet
    _buildInstructionsSheet(instructionsSheet);

    // -- _Lists sheet (dropdown sources)
    final categories = ExpenseCategory.values.map((c) => c.displayName).toList();
    for (var i = 0; i < categories.length; i++) {
      listsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
          .value = TextCellValue(categories[i]);
    }
    final types = FinancialType.values.map((t) => t.displayName).toList();
    for (var i = 0; i < types.length; i++) {
      listsSheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i))
          .value = TextCellValue(types[i]);
    }

    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode workbook.');
    return Uint8List.fromList(bytes);
  }

  static void _setCell(Sheet sheet, int col, int row, CellValue value) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row))
        .value = value;
  }

  static void _buildInstructionsSheet(Sheet sheet) {
    final lines = <String>[
      'Finance Tracker — Expense Import / Export Template',
      '',
      'HOW TO USE',
      '──────────────────────────────────────────────────',
      'Enter expenses in the "Expenses" sheet starting from row 2.',
      'Row 1 contains the column headers — do not modify them.',
      'Do not rename or delete the "Expenses" sheet.',
      '',
      'COLUMNS',
      '',
      'A  Date (required)',
      '   Accepted formats:',
      '     YYYY-MM-DD  e.g.  2026-03-27',
      '     DD.MM.YYYY  e.g.  27.03.2026',
      '',
      'B  Amount (required)',
      '   Positive number. Decimal separator can be . or ,',
      '   Examples:  12.50  |  12,50  |  1.234,56',
      '',
      'C  Category (optional — default: Other)',
      '   Valid values:',
      ...ExpenseCategory.values.map((c) => '     ${c.displayName}'),
      '   Unknown values are imported as Other.',
      '',
      'D  Financial Type (optional — default: Consumption)',
      '   Valid values:',
      ...FinancialType.values.map((t) => '     ${t.displayName}'),
      '   Unknown values are imported as Consumption.',
      '',
      'E  Note (optional)',
      '   Any text.',
      '',
      'F  Group (optional)',
      '   Any text. Groups expenses across months.',
      '',
      'NOTES',
      '  • Only expenses can be imported.',
      '    Income and plan items are not supported.',
      '  • Exported files can be re-imported on another device.',
      '  • The "_Lists" sheet is used internally — do not modify it.',
    ];

    for (var i = 0; i < lines.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
          .value = TextCellValue(lines[i]);
    }
  }

  // ── Cell value helpers ────────────────────────────────────────────────────

  static String? _cellString(CellValue? value) {
    if (value == null) return null;
    if (value is TextCellValue) return value.value.toString();
    if (value is IntCellValue) return value.value.toString();
    if (value is DoubleCellValue) {
      final d = value.value;
      // Avoid trailing ".0" for whole numbers when shown as strings
      return d == d.roundToDouble() ? d.toInt().toString() : d.toString();
    }
    if (value is DateCellValue) {
      return '${value.year.toString().padLeft(4, '0')}-'
          '${value.month.toString().padLeft(2, '0')}-'
          '${value.day.toString().padLeft(2, '0')}';
    }
    return value.toString();
  }

  static DateTime? _cellDate(CellValue? value) {
    if (value == null) return null;
    if (value is DateCellValue) {
      try {
        final d = DateTime(value.year, value.month, value.day);
        // Sanity-check: DateTime constructor normalises invalid dates silently
        if (d.month == value.month && d.day == value.day) return d;
      } catch (_) {}
      return null;
    }
    final s = _cellString(value);
    if (s == null || s.isEmpty) return null;
    return _parseDateString(s);
  }

  static double? _cellAmount(CellValue? value) {
    if (value == null) return null;
    if (value is DoubleCellValue) return value.value;
    if (value is IntCellValue) return value.value.toDouble();
    final s = _cellString(value);
    if (s == null || s.isEmpty) return null;
    return _parseAmountString(s);
  }

  static DateTime? _parseDateString(String raw) {
    final s = raw.trim();

    // Try YYYY-MM-DD (ISO 8601)
    // Dart normalises out-of-range values (e.g. Feb 30 → Mar 2) instead of
    // returning null, so we verify the parsed components match the string.
    final iso = DateTime.tryParse(s);
    if (iso != null) {
      final d = DateTime(iso.year, iso.month, iso.day);
      final dashParts = s.split('-');
      if (dashParts.length == 3) {
        final m = int.tryParse(dashParts[1].trim());
        final dy = int.tryParse(dashParts[2].trim());
        if (m != null && dy != null && (m != d.month || dy != d.day)) {
          return null; // Normalised — reject (e.g. 2026-02-30, 2026-13-01)
        }
      }
      return d;
    }

    // Try DD.MM.YYYY
    final parts = s.split('.');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0].trim());
      final month = int.tryParse(parts[1].trim());
      final year = int.tryParse(parts[2].trim());
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12 &&
          year >= 1900 &&
          year <= 2100) {
        try {
          final d = DateTime(year, month, day);
          if (d.day == day && d.month == month) return d;
        } catch (_) {}
      }
    }
    return null;
  }

  static double? _parseAmountString(String raw) {
    var s = raw.trim().replaceAll('\u00a0', '').replaceAll(' ', '');
    if (s.isEmpty) return null;

    final dots = '.'.allMatches(s).length;
    final commas = ','.allMatches(s).length;

    if (dots > 0 && commas > 0) {
      // Both present — whichever comes last is the decimal separator
      final lastDot = s.lastIndexOf('.');
      final lastComma = s.lastIndexOf(',');
      if (lastComma > lastDot) {
        // 1.234,56 → remove dots (thousands), swap comma to dot
        s = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // 1,234.56 → remove commas (thousands)
        s = s.replaceAll(',', '');
      }
    } else if (commas == 1 && dots == 0) {
      // Single comma → decimal separator
      s = s.replaceAll(',', '.');
    } else if (commas > 1) {
      // Multiple commas → thousands separators only
      s = s.replaceAll(',', '');
    }
    // else: only dots or no separators — parse as-is

    return double.tryParse(s);
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  /// Parses a category from a display name (case-insensitive).
  /// Falls back to [ExpenseCategoryX.fromJson] to handle raw enum names and
  /// legacy values, ensuring backward compatibility with older exports.
  static ExpenseCategory _categoryFromDisplayName(String value) {
    final normalized = value.toLowerCase();
    for (final cat in ExpenseCategory.values) {
      if (cat.displayName.toLowerCase() == normalized) return cat;
    }
    return ExpenseCategoryX.fromJson(value); // handles enum names + legacy strings
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static ImportResult _hardError(String message) => ImportResult(
        validRows: const [],
        invalidRows: const [],
        totalRows: 0,
        headerError: message,
      );

  static String _truncate(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';

  // ── CSV parser ────────────────────────────────────────────────────────────

  /// Parses a comma-separated file.
  ///
  /// The first row must contain the standard headers (same as the xlsx format):
  /// Date, Amount, Category, Financial Type, Note, Group.
  /// Quoted fields (RFC 4180) are supported.
  static ImportResult parseCsvFile(Uint8List bytes) {
    String content;
    try {
      content = utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return _hardError(
          'Could not read the file. Please ensure it is a valid CSV file.');
    }

    // Strip UTF-8 BOM (added by Excel on many systems)
    if (content.startsWith('\uFEFF')) content = content.substring(1);

    // Normalise line endings and split into rows
    final normalized =
        content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    // Auto-detect delimiter: semicolons are used by European-locale Excel
    final delimiter = _detectCsvDelimiter(normalized);

    final rawLines = normalized.split('\n');
    final lines = rawLines.map((l) => _parseCsvRow(l, delimiter)).toList();

    // Drop trailing blank rows that result from a trailing newline
    while (lines.isNotEmpty && lines.last.every((f) => f.isEmpty)) {
      lines.removeLast();
    }

    if (lines.isEmpty) {
      return _hardError('The CSV file is empty.');
    }

    // Validate header row
    final headerRow = lines[0];
    const expectedHeaders = [
      'date', 'amount', 'category', 'financial type', 'note', 'group',
    ];
    for (var col = 0; col < expectedHeaders.length; col++) {
      final actual =
          col < headerRow.length ? headerRow[col].trim().toLowerCase() : '';
      if (actual != expectedHeaders[col]) {
        return _hardError(
          'Column ${col + 1} header mismatch: expected '
          '"${expectedHeaders[col]}", got '
          '"${actual.isEmpty ? '(empty)' : actual}". '
          'Please use the headers: '
          'Date, Amount, Category, Financial Type, Note, Group.',
        );
      }
    }

    // Parse data rows
    final validRows = <ImportedExpense>[];
    final invalidRows = <ImportRowError>[];
    var totalRows = 0;

    for (var i = 1; i < lines.length; i++) {
      final row = lines[i];
      String getField(int col) => col < row.length ? row[col].trim() : '';

      final dateStr = getField(_colDate);
      final amountStr = getField(_colAmount);

      if (dateStr.isEmpty && amountStr.isEmpty) continue; // blank row

      totalRows++;
      final rowNumber = i + 1;

      final date = _parseDateString(dateStr);
      if (date == null) {
        invalidRows.add(ImportRowError(
          rowNumber: rowNumber,
          field: 'Date',
          message: dateStr.isEmpty
              ? 'Date is required.'
              : 'Invalid date "${_truncate(dateStr, 20)}". Use YYYY-MM-DD or DD.MM.YYYY.',
        ));
        continue;
      }

      final amount =
          amountStr.isEmpty ? null : _parseAmountString(amountStr);
      if (amount == null || amount <= 0) {
        invalidRows.add(ImportRowError(
          rowNumber: rowNumber,
          field: 'Amount',
          message: (amount != null && amount <= 0)
              ? 'Amount must be greater than zero.'
              : 'Invalid amount "${_truncate(amountStr, 20)}". Enter a positive number.',
        ));
        continue;
      }

      final categoryStr = getField(_colCategory);
      final typeStr = getField(_colFinancialType);
      final noteStr = getField(_colNote);
      final groupStr = getField(_colGroup);

      validRows.add(ImportedExpense(
        amount: amount,
        category: categoryStr.isEmpty
            ? ExpenseCategory.other
            : _categoryFromDisplayName(categoryStr),
        financialType: typeStr.isEmpty
            ? FinancialType.consumption
            : FinancialTypeX.fromDisplayName(typeStr),
        date: date,
        note: noteStr.isEmpty ? null : noteStr,
        group: groupStr.isEmpty ? null : groupStr,
      ));
    }

    return ImportResult(
      validRows: validRows,
      invalidRows: invalidRows,
      totalRows: totalRows,
    );
  }

  /// Detects the field delimiter by examining the first line.
  /// Returns `;` if it looks like a semicolon-delimited file (European Excel),
  /// otherwise returns `,`.
  static String _detectCsvDelimiter(String content) {
    final firstLine = content.split('\n').first;
    final commas = ','.allMatches(firstLine).length;
    final semis = ';'.allMatches(firstLine).length;
    return semis > commas ? ';' : ',';
  }

  /// Parses one line of CSV text into a list of field strings.
  ///
  /// [delimiter] is the field separator (`,` or `;`).
  /// Handles quoted fields (double-quote escaping via `""`).
  /// Unquoted fields are trimmed; quoted field content is preserved as-is.
  static List<String> _parseCsvRow(String line, [String delimiter = ',']) {
    final sep = delimiter[0]; // always a single character
    final fields = <String>[];
    var i = 0;

    while (true) {
      // Skip leading spaces before each field
      while (i < line.length && line[i] == ' ') {
        i++;
      }

      if (i >= line.length) {
        // Trailing delimiter → empty final field
        if (fields.isNotEmpty) fields.add('');
        break;
      }

      if (line[i] == '"') {
        // Quoted field
        i++; // skip opening "
        final buf = StringBuffer();
        while (i < line.length) {
          if (line[i] == '"') {
            if (i + 1 < line.length && line[i + 1] == '"') {
              buf.write('"');
              i += 2; // escaped quote
            } else {
              i++; // closing quote
              break;
            }
          } else {
            buf.write(line[i++]);
          }
        }
        fields.add(buf.toString());
        // Skip trailing spaces then delimiter
        while (i < line.length && line[i] == ' ') {
          i++;
        }
        if (i < line.length && line[i] == sep) {
          i++;
        } else {
          break; // end of row
        }
      } else {
        // Unquoted field — read until delimiter or end of line
        final start = i;
        while (i < line.length && line[i] != sep) {
          i++;
        }
        fields.add(line.substring(start, i).trim());
        if (i < line.length && line[i] == sep) {
          i++;
        } else {
          break; // end of row
        }
      }
    }

    return fields;
  }
}
