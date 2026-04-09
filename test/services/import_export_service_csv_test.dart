import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/services/import_export_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Encodes a CSV string to bytes the way parseCsvFile() expects them.
Uint8List _csv(String content) => Uint8List.fromList(utf8.encode(content));

/// Builds a valid CSV with the standard header and the given data rows.
/// Each element in [rows] is one data line (no trailing newline needed per row).
String _makeCsv(List<String> rows) {
  const header = 'Date,Amount,Category,Financial Type,Note,Group';
  return [header, ...rows].join('\n');
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Hard errors ─────────────────────────────────────────────────────────────

  group('CSV hard errors', () {
    test('empty file returns headerError', () {
      final result = ImportExportService.parseCsvFile(_csv(''));
      expect(result.headerError, isNotNull);
      expect(result.validRows, isEmpty);
    });

    test('only whitespace / blank lines returns headerError', () {
      final result = ImportExportService.parseCsvFile(_csv('\n\n   \n'));
      expect(result.headerError, isNotNull);
    });

    test('wrong first column header returns headerError', () {
      final csv = 'Datum,Amount,Category,Financial Type,Note,Group\n'
          '2025-01-01,10.00,Groceries,Consumption,,';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.headerError, isNotNull);
      expect(result.headerError, contains('Column 1'));
    });

    test('wrong fourth column header returns headerError', () {
      final csv = 'Date,Amount,Category,Type,Note,Group\n'
          '2025-01-01,10.00,Groceries,Consumption,,';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.headerError, isNotNull);
      expect(result.headerError, contains('Column 4'));
    });

    test('header is case-insensitive', () {
      // Headers in upper-case should still be accepted.
      final csv = 'DATE,AMOUNT,CATEGORY,FINANCIAL TYPE,NOTE,GROUP\n'
          '2025-01-01,10.00,,,, ';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.headerError, isNull);
    });
  });

  // ── Valid rows ───────────────────────────────────────────────────────────────

  group('CSV valid rows', () {
    test('parses a single complete row correctly', () {
      final csv = _makeCsv([
        '2025-03-15,120.50,Groceries,Consumption,Weekly shop,Household',
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.headerError, isNull);
      expect(result.validRows.length, 1);
      expect(result.invalidRows, isEmpty);

      final row = result.validRows.first;
      expect(row.amount, 120.50);
      expect(row.category, ExpenseCategory.groceries);
      expect(row.financialType, FinancialType.consumption);
      expect(row.date, DateTime(2025, 3, 15));
      expect(row.note, 'Weekly shop');
      expect(row.group, 'Household');
    });

    test('empty category defaults to other', () {
      final csv = _makeCsv(['2025-01-01,50.00,,,,' ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.category, ExpenseCategory.other);
    });

    test('unknown category defaults to other', () {
      final csv = _makeCsv(['2025-01-01,50.00,NotACategory,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.category, ExpenseCategory.other);
    });

    test('empty financial type defaults to consumption', () {
      final csv = _makeCsv(['2025-01-01,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.financialType, FinancialType.consumption);
    });

    test('unknown financial type defaults to consumption', () {
      final csv = _makeCsv(['2025-01-01,50.00,,Unknown,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.financialType, FinancialType.consumption);
    });

    test('empty note produces null', () {
      final csv = _makeCsv(['2025-01-01,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.note, isNull);
    });

    test('empty group produces null', () {
      final csv = _makeCsv(['2025-01-01,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.group, isNull);
    });

    test('multiple rows all parsed', () {
      final csv = _makeCsv([
        '2025-01-01,100.00,Housing,Consumption,Rent,',
        '2025-01-15,30.00,Groceries,Consumption,Bread,',
        '2025-01-20,200.00,,,, ',
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 3);
      expect(result.totalRows, 3);
      expect(result.invalidRows, isEmpty);
    });

    test('blank lines between data rows are skipped', () {
      final csv = 'Date,Amount,Category,Financial Type,Note,Group\n'
          '2025-01-01,50.00,,,, \n'
          '\n'
          '\n'
          '2025-01-02,75.00,,,, \n';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 2);
    });

    test('trailing blank line is ignored', () {
      final csv = '${_makeCsv(['2025-01-01,50.00,,,,'])}\n';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 1);
    });
  });

  // ── Date formats ─────────────────────────────────────────────────────────────

  group('CSV date formats', () {
    test('parses YYYY-MM-DD format', () {
      final csv = _makeCsv(['2025-11-30,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.date, DateTime(2025, 11, 30));
    });

    test('parses DD.MM.YYYY format', () {
      final csv = _makeCsv(['30.11.2025,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.date, DateTime(2025, 11, 30));
    });

    test('invalid date produces row error', () {
      final csv = _makeCsv(['not-a-date,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows, isEmpty);
      expect(result.invalidRows.length, 1);
      expect(result.invalidRows.first.field, 'Date');
    });

    test('empty date produces row error with "required" message', () {
      final csv = _makeCsv([',50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.message, contains('required'));
    });

    test('rejects normalised out-of-range date (e.g. Feb 30)', () {
      final csv = _makeCsv(['2025-02-30,50.00,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows, isEmpty);
      expect(result.invalidRows.length, 1);
    });
  });

  // ── Amount formats ────────────────────────────────────────────────────────────

  group('CSV amount formats', () {
    test('parses integer amount', () {
      final csv = _makeCsv(['2025-01-01,100,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.amount, 100.0);
    });

    test('parses decimal with dot separator (12.50)', () {
      final csv = _makeCsv(['2025-01-01,12.50,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.amount, 12.50);
    });

    test('parses decimal with comma separator (12,50) when field is quoted', () {
      // Note: 12,50 in a comma-delimited CSV means amount="12" and
      // category="50". The CSV parser splits on comma first.
      // The correct way to pass a comma-decimal in a comma-delimited CSV is to
      // quote the field.
      final csv = _makeCsv(['"2025-01-01","12,50",,,, ']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.amount, 12.50);
    });

    test('parses thousands separator format (1.234,56) in semicolon CSV', () {
      // Semicolon delimiter (European Excel) allows unquoted comma-decimal.
      final csv = 'Date;Amount;Category;Financial Type;Note;Group\n'
          '2025-01-01;1.234,56;;;;';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.amount, closeTo(1234.56, 0.001));
    });

    test('parses thousands separator format (1,234.56) in comma CSV', () {
      final csv = _makeCsv(['"2025-01-01","1,234.56",,,, ']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.amount, closeTo(1234.56, 0.001));
    });

    test('zero amount produces row error', () {
      final csv = _makeCsv(['2025-01-01,0,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.field, 'Amount');
      expect(result.invalidRows.first.message, contains('greater than zero'));
    });

    test('negative amount produces row error', () {
      final csv = _makeCsv(['2025-01-01,-10,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.field, 'Amount');
    });

    test('empty amount produces row error', () {
      final csv = _makeCsv(['2025-01-01,,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.field, 'Amount');
    });

    test('non-numeric amount produces row error', () {
      final csv = _makeCsv(['2025-01-01,abc,,,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.field, 'Amount');
    });
  });

  // ── Delimiters ────────────────────────────────────────────────────────────────

  group('CSV delimiter detection', () {
    test('auto-detects comma delimiter', () {
      final csv = _makeCsv(['2025-01-01,50.00,Groceries,Consumption,,']);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 1);
      expect(result.validRows.first.category, ExpenseCategory.groceries);
    });

    test('auto-detects semicolon delimiter (European Excel)', () {
      final csv = 'Date;Amount;Category;Financial Type;Note;Group\n'
          '2025-01-01;50.00;Housing;Consumption;;';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 1);
      expect(result.validRows.first.category, ExpenseCategory.housing);
    });
  });

  // ── Quoted fields ─────────────────────────────────────────────────────────────

  group('CSV quoted fields', () {
    test('quoted field with comma inside is parsed as one value', () {
      final csv = _makeCsv([
        '2025-01-01,50.00,Groceries,Consumption,"bread, milk",',
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.note, 'bread, milk');
    });

    test('escaped double-quote inside quoted field', () {
      final csv = _makeCsv([
        '2025-01-01,50.00,Groceries,Consumption,"She said ""hello""",',
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.first.note, 'She said "hello"');
    });
  });

  // ── BOM stripping ─────────────────────────────────────────────────────────────

  group('CSV BOM handling', () {
    test('UTF-8 BOM is stripped before parsing', () {
      // Prepend the UTF-8 BOM character (\uFEFF) that Excel adds.
      const bom = '\uFEFF';
      final csv = '$bom${_makeCsv(['2025-01-01,50.00,,,,'])}';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.headerError, isNull);
      expect(result.validRows.length, 1);
    });
  });

  // ── Mixed valid and invalid rows ──────────────────────────────────────────────

  group('CSV mixed valid and invalid rows', () {
    test('valid rows are collected even when some rows have errors', () {
      final csv = _makeCsv([
        '2025-01-01,100.00,Groceries,Consumption,,', // valid
        'bad-date,50.00,,,,',                          // invalid date
        '2025-01-03,200.00,Housing,Consumption,,',    // valid
        '2025-01-04,-5.00,,,,',                        // invalid amount
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 2);
      expect(result.invalidRows.length, 2);
      expect(result.totalRows, 4);
    });

    test('row numbers in errors are 1-indexed from top of file (row 1 = header)', () {
      final csv = _makeCsv([
        '2025-01-01,100.00,,,, ', // row 2 → valid
        'bad-date,50.00,,,, ',    // row 3 → invalid
      ]);
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.invalidRows.first.rowNumber, 3);
    });
  });

  // ── CRLF line endings ─────────────────────────────────────────────────────────

  group('CSV CRLF line endings', () {
    test('Windows-style CRLF line endings are normalised', () {
      final csv = 'Date,Amount,Category,Financial Type,Note,Group\r\n'
          '2025-01-01,50.00,,,, \r\n'
          '2025-01-02,75.00,,,, \r\n';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 2);
    });
  });

  // ── Column count edge cases ────────────────────────────────────────────────

  group('CSV column count edge cases', () {
    test('sparse row with fewer than 6 columns still parses date and amount', () {
      // Only 2 columns — date and amount; rest default.
      final csv = 'Date,Amount,Category,Financial Type,Note,Group\n'
          '2025-06-01,42.00';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 1);
      expect(result.validRows.first.amount, 42.00);
      expect(result.validRows.first.date, DateTime(2025, 6, 1));
      expect(result.validRows.first.category, ExpenseCategory.other);
      expect(result.validRows.first.financialType, FinancialType.consumption);
      expect(result.validRows.first.note, isNull);
      expect(result.validRows.first.group, isNull);
    });

    test('row with extra columns beyond 6 is still parsed correctly', () {
      // 8 columns — extra trailing fields should be ignored.
      final csv = 'Date,Amount,Category,Financial Type,Note,Group\n'
          '2025-06-01,55.00,Groceries,Consumption,Lunch,Work,ExtraA,ExtraB';
      final result = ImportExportService.parseCsvFile(_csv(csv));
      expect(result.validRows.length, 1);
      expect(result.validRows.first.amount, 55.00);
      expect(result.validRows.first.category, ExpenseCategory.groceries);
      expect(result.validRows.first.note, 'Lunch');
      expect(result.validRows.first.group, 'Work');
    });
  });
}
