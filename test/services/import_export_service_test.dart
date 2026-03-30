import 'dart:convert';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/services/import_export_service.dart';

// ── Test helpers ──────────────────────────────────────────────────────────────

const _stdHeaders = [
  'Date',
  'Amount',
  'Category',
  'Financial Type',
  'Note',
  'Group',
];

/// Builds an xlsx with the standard headers and the given data rows.
/// Pass [null] for empty cells; non-null values are written as appropriate
/// CellValue types (String→Text, int→Int, double→Double, DateTime→Date).
Uint8List _makeXlsx(List<List<Object?>> dataRows) =>
    _makeXlsxWithHeaders(_stdHeaders, dataRows);

/// Builds an xlsx with custom headers (for header-mismatch tests).
Uint8List _makeXlsxWithHeaders(
    List<String> headers, List<List<Object?>> dataRows) {
  final excel = Excel.createExcel();
  final sheet = excel['Expenses'];
  if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');

  for (var c = 0; c < headers.length; c++) {
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
        .value = TextCellValue(headers[c]);
  }

  for (var r = 0; r < dataRows.length; r++) {
    for (var c = 0; c < dataRows[r].length; c++) {
      final val = dataRows[r][c];
      if (val == null) continue;
      final CellValue cellVal;
      if (val is String) {
        cellVal = TextCellValue(val);
      } else if (val is int) {
        cellVal = IntCellValue(val);
      } else if (val is double) {
        cellVal = DoubleCellValue(val);
      } else if (val is DateTime) {
        cellVal =
            DateCellValue(year: val.year, month: val.month, day: val.day);
      } else {
        cellVal = TextCellValue(val.toString());
      }
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
          .value = cellVal;
    }
  }

  return Uint8List.fromList(excel.encode()!);
}

/// Builds an xlsx with an Expenses sheet that has no rows at all (not even headers).
Uint8List _makeEmptySheet() {
  final excel = Excel.createExcel();
  excel['Expenses']; // create sheet, write nothing
  if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
  return Uint8List.fromList(excel.encode()!);
}

Expense _makeExpense(String id, double amount, DateTime date) => Expense(
      id: id,
      amount: amount,
      category: ExpenseCategory.groceries,
      date: date,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Hard errors ───────────────────────────────────────────────────────────

  group('parseImportFile — hard errors', () {
    test('invalid bytes returns headerError', () {
      final result = ImportExportService.parseImportFile(
          Uint8List.fromList([0, 1, 2, 3]));
      expect(result.headerError, isNotNull);
      expect(result.validRows, isEmpty);
      expect(result.invalidRows, isEmpty);
    });

    test('missing Expenses sheet returns headerError', () {
      final excel = Excel.createExcel();
      // Default workbook has only Sheet1 — no Expenses sheet
      final bytes = Uint8List.fromList(excel.encode()!);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.headerError, contains('Expenses'));
    });

    test('empty Expenses sheet returns headerError', () {
      final result = ImportExportService.parseImportFile(_makeEmptySheet());
      expect(result.headerError, isNotNull);
    });

    test('wrong column 1 header returns headerError mentioning column', () {
      final bytes = _makeXlsxWithHeaders(
        ['WRONG', 'Amount', 'Category', 'Financial Type', 'Note', 'Group'],
        [],
      );
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.headerError, isNotNull);
      expect(result.headerError, contains('Column 1'));
    });

    test('wrong column 3 header returns headerError mentioning column', () {
      final bytes = _makeXlsxWithHeaders(
        ['Date', 'Amount', 'WRONG', 'Financial Type', 'Note', 'Group'],
        [],
      );
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.headerError, isNotNull);
      expect(result.headerError, contains('Column 3'));
    });
  });

  // ── Valid rows ────────────────────────────────────────────────────────────

  group('parseImportFile — valid rows', () {
    test('single row with all fields populated', () {
      final bytes = _makeXlsx([
        ['2026-03-01', 25.50, 'Groceries', 'Consumption', 'weekly shop', 'March'],
      ]);
      final result = ImportExportService.parseImportFile(bytes);

      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.amount, 25.50);
      expect(row.category, ExpenseCategory.groceries);
      expect(row.financialType, FinancialType.consumption);
      expect(row.date, DateTime(2026, 3, 1));
      expect(row.note, 'weekly shop');
      expect(row.group, 'March');
    });

    test('optional fields default when empty strings', () {
      final bytes = _makeXlsx([
        ['2026-01-15', 10.0, '', '', '', ''],
      ]);
      final result = ImportExportService.parseImportFile(bytes);

      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.category, ExpenseCategory.other);
      expect(row.financialType, FinancialType.consumption);
      expect(row.note, isNull);
      expect(row.group, isNull);
    });

    test('sparse row with only date and amount columns', () {
      final bytes = _makeXlsx([
        ['2026-01-15', 10.0], // only 2 columns written
      ]);
      final result = ImportExportService.parseImportFile(bytes);

      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.category, ExpenseCategory.other);
      expect(row.financialType, FinancialType.consumption);
      expect(row.note, isNull);
      expect(row.group, isNull);
    });

    test('sparse row: group set but columns D and E are empty', () {
      // Reproduces the previously reported bug where group was silently ignored
      final bytes = _makeXlsx([
        ['2027-03-28', 99.99, 'Communication', null, null, 'nic'],
      ]);
      final result = ImportExportService.parseImportFile(bytes);

      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.group, 'nic');
      expect(row.category, ExpenseCategory.communication);
      expect(row.note, isNull);
    });

    test('amount as IntCellValue (integer)', () {
      final bytes = _makeXlsx([['2026-01-01', 1]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows.first.amount, 1.0);
    });

    test('date as DateCellValue', () {
      final bytes = _makeXlsx([[DateTime(2026, 6, 15), 50.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows.first.date, DateTime(2026, 6, 15));
    });

    test('multiple valid rows are all returned', () {
      final bytes = _makeXlsx([
        ['2026-01-01', 10.0],
        ['2026-02-01', 20.0],
        ['2026-03-01', 30.0],
      ]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, hasLength(3));
      expect(result.totalRows, 3);
    });

    test('totalRows = validRows + invalidRows', () {
      final bytes = _makeXlsx([
        ['2026-01-01', 10.0], // valid
        ['BADDATE', 10.0], // invalid date
        ['2026-02-01', -5.0], // invalid amount
        ['2026-03-01', 20.0], // valid
      ]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, hasLength(2));
      expect(result.invalidRows, hasLength(2));
      expect(result.totalRows, 4);
    });

    test('fully blank rows are skipped and not counted in totalRows', () {
      final bytes = _makeXlsx([
        ['2026-01-01', 10.0],
        [null, null, null, null, null, null], // blank — skipped
        ['2026-02-01', 20.0],
      ]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, hasLength(2));
      expect(result.totalRows, 2);
    });
  });

  // ── Date parsing ──────────────────────────────────────────────────────────

  group('parseImportFile — date formats', () {
    test('YYYY-MM-DD string', () {
      final bytes = _makeXlsx([['2026-03-27', 1.0]]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.date,
        DateTime(2026, 3, 27),
      );
    });

    test('DD.MM.YYYY string (two-digit month)', () {
      final bytes = _makeXlsx([['27.03.2026', 1.0]]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.date,
        DateTime(2026, 3, 27),
      );
    });

    test('DD.M.YYYY string (single-digit month)', () {
      final bytes = _makeXlsx([['28.3.2027', 1.0]]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.date,
        DateTime(2027, 3, 28),
      );
    });

    test('D.M.YYYY string (single-digit day and month)', () {
      final bytes = _makeXlsx([['1.1.2026', 1.0]]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.date,
        DateTime(2026, 1, 1),
      );
    });

    test('invalid date string produces error row with field=Date', () {
      final bytes = _makeXlsx([['not-a-date', 10.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, isEmpty);
      expect(result.invalidRows, hasLength(1));
      expect(result.invalidRows.first.field, 'Date');
    });

    test('missing date produces error mentioning required', () {
      final bytes = _makeXlsx([['', 10.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows.first.field, 'Date');
      expect(result.invalidRows.first.message, contains('required'));
    });

    test('impossible date (Feb 30) produces error row', () {
      final bytes = _makeXlsx([['2026-02-30', 10.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows, hasLength(1));
      expect(result.invalidRows.first.field, 'Date');
    });

    test('month 13 produces error row', () {
      final bytes = _makeXlsx([['2026-13-01', 10.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows, hasLength(1));
    });
  });

  // ── Amount parsing ────────────────────────────────────────────────────────

  group('parseImportFile — amount formats', () {
    test('dot as decimal separator', () {
      final bytes = _makeXlsx([['2026-01-01', '12.50']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.amount,
        12.50,
      );
    });

    test('comma as decimal separator', () {
      final bytes = _makeXlsx([['2026-01-01', '12,50']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.amount,
        12.50,
      );
    });

    test('European format 1.234,56 (dot thousands, comma decimal)', () {
      final bytes = _makeXlsx([['2026-01-01', '1.234,56']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.amount,
        closeTo(1234.56, 0.001),
      );
    });

    test('US format 1,234.56 (comma thousands, dot decimal)', () {
      final bytes = _makeXlsx([['2026-01-01', '1,234.56']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.amount,
        closeTo(1234.56, 0.001),
      );
    });

    test('zero amount produces error with "greater than zero" message', () {
      final bytes = _makeXlsx([['2026-01-01', 0.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows.first.field, 'Amount');
      expect(result.invalidRows.first.message, contains('greater than zero'));
    });

    test('negative amount produces error row', () {
      final bytes = _makeXlsx([['2026-01-01', -5.0]]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows.first.field, 'Amount');
    });

    test('non-numeric amount string produces error row', () {
      final bytes = _makeXlsx([['2026-01-01', 'abc']]);
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.invalidRows.first.field, 'Amount');
    });
  });

  // ── Category parsing ──────────────────────────────────────────────────────

  group('parseImportFile — category', () {
    test('display name match is case-insensitive', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, 'communication']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.category,
        ExpenseCategory.communication,
      );
    });

    test('mixed-case display name matches', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, 'Communication']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.category,
        ExpenseCategory.communication,
      );
    });

    test('unknown category falls back to other', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, 'UnknownXYZ']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.category,
        ExpenseCategory.other,
      );
    });

    test('empty category defaults to other', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.category,
        ExpenseCategory.other,
      );
    });
  });

  // ── Financial type parsing ────────────────────────────────────────────────

  group('parseImportFile — financial type', () {
    test('asset display name matches', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', 'Asset']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.financialType,
        FinancialType.asset,
      );
    });

    test('insurance display name matches', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', 'Insurance']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.financialType,
        FinancialType.insurance,
      );
    });

    test('display name match is case-insensitive', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', 'asset']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.financialType,
        FinancialType.asset,
      );
    });

    test('empty financial type defaults to consumption', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', '']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.financialType,
        FinancialType.consumption,
      );
    });

    test('unknown financial type defaults to consumption', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', 'unknown']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.financialType,
        FinancialType.consumption,
      );
    });
  });

  // ── Note / group trimming ─────────────────────────────────────────────────

  group('parseImportFile — note and group', () {
    test('note and group are trimmed', () {
      final bytes =
          _makeXlsx([['2026-01-01', 1.0, '', '', '  hello  ', '  world  ']]);
      final row = ImportExportService.parseImportFile(bytes).validRows.first;
      expect(row.note, 'hello');
      expect(row.group, 'world');
    });

    test('whitespace-only note becomes null', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', '', '   ', '']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.note,
        isNull,
      );
    });

    test('whitespace-only group becomes null', () {
      final bytes = _makeXlsx([['2026-01-01', 1.0, '', '', '', '   ']]);
      expect(
        ImportExportService.parseImportFile(bytes).validRows.first.group,
        isNull,
      );
    });
  });

  // ── Error row numbering ───────────────────────────────────────────────────

  group('parseImportFile — error row numbers', () {
    test('first data row is row number 2 (row 1 = header)', () {
      final bytes = _makeXlsx([['bad', 1.0]]);
      expect(
        ImportExportService.parseImportFile(bytes).invalidRows.first.rowNumber,
        2,
      );
    });

    test('error in third data row has rowNumber 4 (header + 2 data rows)', () {
      final bytes = _makeXlsx([
        ['2026-01-01', 1.0], // row 2
        ['2026-02-01', 2.0], // row 3
        ['bad-date', 3.0], // row 4 — error
      ]);
      expect(
        ImportExportService.parseImportFile(bytes).invalidRows.first.rowNumber,
        4,
      );
    });
  });

  // ── exportExpenses ────────────────────────────────────────────────────────

  group('exportExpenses', () {
    test('filters to inclusive start date', () async {
      final expenses = [
        _makeExpense('a', 10, DateTime(2026, 1, 31)), // before start — excluded
        _makeExpense('b', 20, DateTime(2026, 2, 1)), // on start — included
        _makeExpense('c', 30, DateTime(2026, 2, 15)), // inside — included
      ];
      final bytes = await ImportExportService.exportExpenses(
          expenses, DateTime(2026, 2, 1), DateTime(2026, 2, 28));
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, hasLength(2));
      expect(result.validRows.map((r) => r.amount), containsAll([20.0, 30.0]));
    });

    test('filters to inclusive end date', () async {
      final expenses = [
        _makeExpense('a', 10, DateTime(2026, 2, 28)), // on end — included
        _makeExpense('b', 20, DateTime(2026, 3, 1)), // after end — excluded
      ];
      final bytes = await ImportExportService.exportExpenses(
          expenses, DateTime(2026, 2, 1), DateTime(2026, 2, 28));
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, hasLength(1));
      expect(result.validRows.first.amount, 10.0);
    });

    test('sorts exported rows by date ascending', () async {
      final expenses = [
        _makeExpense('b', 20, DateTime(2026, 3, 1)),
        _makeExpense('a', 10, DateTime(2026, 1, 1)),
      ];
      final bytes = await ImportExportService.exportExpenses(
          expenses, DateTime(2026, 1, 1), DateTime(2026, 12, 31));
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows[0].date, DateTime(2026, 1, 1));
      expect(result.validRows[1].date, DateTime(2026, 3, 1));
    });

    test('empty result produces valid importable workbook', () async {
      final bytes = await ImportExportService.exportExpenses(
          [], DateTime(2026, 1, 1), DateTime(2026, 12, 31));
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.headerError, isNull);
      expect(result.validRows, isEmpty);
    });

    test('exported data round-trips through parseImportFile', () async {
      final original = Expense(
        id: '1',
        amount: 42.99,
        category: ExpenseCategory.transport,
        financialType: FinancialType.consumption,
        date: DateTime(2026, 5, 20),
        note: 'train ticket',
        group: 'commute',
      );
      final bytes = await ImportExportService.exportExpenses(
          [original], DateTime(2026, 5, 1), DateTime(2026, 5, 31));
      final result = ImportExportService.parseImportFile(bytes);

      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.amount, closeTo(42.99, 0.001));
      expect(row.category, ExpenseCategory.transport);
      expect(row.financialType, FinancialType.consumption);
      expect(row.date, DateTime(2026, 5, 20));
      expect(row.note, 'train ticket');
      expect(row.group, 'commute');
    });
  });

  // ── Export → import regression ───────────────────────────────────────────

  group('exportExpenses — export/import regression', () {
    // Regression: on some Android content providers the .xlsx extension is
    // stripped from the display name. The importer falls back to ZIP magic-byte
    // detection (50 4B 03 04). This test confirms exported bytes carry that
    // signature so the fallback always fires.
    test('exported bytes start with ZIP magic bytes (xlsx / PK signature)',
        () async {
      final bytes = await ImportExportService.exportExpenses(
          [], DateTime(2026, 1, 1), DateTime(2026, 12, 31));
      expect(bytes.length, greaterThan(4));
      expect(bytes[0], 0x50); // P
      expect(bytes[1], 0x4B); // K
      expect(bytes[2], 0x03);
      expect(bytes[3], 0x04);
    });

    test('export then import: all fields preserved (full field round-trip)',
        () async {
      // Simulates: export from Expenses tab → file saved (possibly losing
      // .xlsx extension) → re-imported. The service layer works on bytes only,
      // so once the UI gate passes (extension or magic bytes), this must succeed.
      final expenses = [
        Expense(
          id: '1',
          amount: 12.50,
          category: ExpenseCategory.groceries,
          financialType: FinancialType.consumption,
          date: DateTime(2026, 3, 15),
          note: 'weekly shop',
          group: 'March',
        ),
        Expense(
          id: '2',
          amount: 200.00,
          category: ExpenseCategory.transport,
          financialType: FinancialType.asset,
          date: DateTime(2026, 3, 20),
          note: null,
          group: null,
        ),
      ];
      final exportedBytes = await ImportExportService.exportExpenses(
          expenses, DateTime(2026, 3, 1), DateTime(2026, 3, 31));

      // parseImportFile works on raw bytes — no extension check at this layer.
      final result = ImportExportService.parseImportFile(exportedBytes);

      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(2));
      expect(result.invalidRows, isEmpty);

      final r0 = result.validRows[0];
      expect(r0.amount, closeTo(12.50, 0.001));
      expect(r0.category, ExpenseCategory.groceries);
      expect(r0.financialType, FinancialType.consumption);
      expect(r0.date, DateTime(2026, 3, 15));
      expect(r0.note, 'weekly shop');
      expect(r0.group, 'March');

      final r1 = result.validRows[1];
      expect(r1.amount, closeTo(200.00, 0.001));
      expect(r1.category, ExpenseCategory.transport);
      expect(r1.financialType, FinancialType.asset);
      expect(r1.date, DateTime(2026, 3, 20));
      expect(r1.note, isNull);
      expect(r1.group, isNull);
    });
  });

  // ── parseCsvFile ─────────────────────────────────────────────────────────

  group('parseCsvFile — hard errors', () {
    test('empty file returns headerError', () {
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode('')));
      expect(result.headerError, isNotNull);
    });

    test('wrong column header returns headerError', () {
      const csv = 'Date,Amount,WRONG,Financial Type,Note,Group\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.headerError, isNotNull);
      expect(result.headerError, contains('Column 3'));
    });
  });

  group('parseCsvFile — valid rows', () {
    test('single row with all fields', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-03-01,25.50,Groceries,Consumption,weekly shop,March\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));

      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.amount, 25.50);
      expect(row.category, ExpenseCategory.groceries);
      expect(row.financialType, FinancialType.consumption);
      expect(row.date, DateTime(2026, 3, 1));
      expect(row.note, 'weekly shop');
      expect(row.group, 'March');
    });

    test('empty optional fields default correctly', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-15,10.0,,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));

      expect(result.validRows, hasLength(1));
      final row = result.validRows.first;
      expect(row.category, ExpenseCategory.other);
      expect(row.financialType, FinancialType.consumption);
      expect(row.note, isNull);
      expect(row.group, isNull);
    });

    test('sparse row with only date and amount', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-15,10.0\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows, hasLength(1));
      expect(result.validRows.first.group, isNull);
    });

    test('quoted field containing comma is parsed correctly', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-01,5.00,,,,"a, b"\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows.first.group, 'a, b');
    });

    test('quoted field with escaped double-quote', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-01,5.00,,,"say ""hi""",\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows.first.note, 'say "hi"');
    });

    test('CRLF line endings are handled', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\r\n'
          '2026-01-01,10.0,,,,\r\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows, hasLength(1));
    });

    test('DD.MM.YYYY date format', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '28.3.2027,1.0,,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows.first.date, DateTime(2027, 3, 28));
    });

    test('comma as decimal separator in amount', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-01,"12,50",,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows.first.amount, 12.50);
    });

    test('blank rows are skipped', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          '2026-01-01,10.0,,,,\n'
          ',,,,, \n'
          '2026-02-01,20.0,,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.validRows, hasLength(2));
      expect(result.totalRows, 2);
    });

    test('invalid date produces error row', () {
      const csv =
          'Date,Amount,Category,Financial Type,Note,Group\n'
          'not-a-date,10.0,,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.invalidRows, hasLength(1));
      expect(result.invalidRows.first.field, 'Date');
    });

    test('case-insensitive headers are accepted', () {
      const csv =
          'date,amount,category,financial type,note,group\n'
          '2026-01-01,5.0,,,,\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(csv)));
      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
    });
  });

  // ── parseCsvFile — date formats ──────────────────────────────────────────

  group('parseCsvFile — date formats', () {
    Uint8List csv(String dateField) => Uint8List.fromList(utf8.encode(
        'Date,Amount,Category,Financial Type,Note,Group\n'
        '$dateField,1.0,,,,\n'));

    test('YYYY-MM-DD string', () {
      expect(ImportExportService.parseCsvFile(csv('2026-03-27'))
          .validRows.first.date, DateTime(2026, 3, 27));
    });

    test('DD.MM.YYYY string (two-digit month)', () {
      expect(ImportExportService.parseCsvFile(csv('27.03.2026'))
          .validRows.first.date, DateTime(2026, 3, 27));
    });

    test('DD.M.YYYY string (single-digit month)', () {
      expect(ImportExportService.parseCsvFile(csv('28.3.2027'))
          .validRows.first.date, DateTime(2027, 3, 28));
    });

    test('D.M.YYYY string (single-digit day and month)', () {
      expect(ImportExportService.parseCsvFile(csv('1.1.2026'))
          .validRows.first.date, DateTime(2026, 1, 1));
    });

    test('missing date produces error mentioning required', () {
      final result = ImportExportService.parseCsvFile(csv(''));
      expect(result.invalidRows.first.field, 'Date');
      expect(result.invalidRows.first.message, contains('required'));
    });

    test('impossible date (Feb 30) produces error row', () {
      final result = ImportExportService.parseCsvFile(csv('2026-02-30'));
      expect(result.invalidRows, hasLength(1));
      expect(result.invalidRows.first.field, 'Date');
    });

    test('month 13 produces error row', () {
      final result = ImportExportService.parseCsvFile(csv('2026-13-01'));
      expect(result.invalidRows, hasLength(1));
      expect(result.invalidRows.first.field, 'Date');
    });
  });

  // ── parseCsvFile — amount formats ─────────────────────────────────────────

  group('parseCsvFile — amount formats', () {
    Uint8List csv(String amountField) => Uint8List.fromList(utf8.encode(
        'Date,Amount,Category,Financial Type,Note,Group\n'
        '2026-01-01,$amountField,,,,\n'));

    // When the amount contains a comma it must be quoted in CSV
    Uint8List csvQ(String amountField) => Uint8List.fromList(utf8.encode(
        'Date,Amount,Category,Financial Type,Note,Group\n'
        '2026-01-01,"$amountField",,,,\n'));

    test('dot as decimal separator', () {
      expect(ImportExportService.parseCsvFile(csv('12.50'))
          .validRows.first.amount, 12.50);
    });

    test('integer amount', () {
      expect(ImportExportService.parseCsvFile(csv('5'))
          .validRows.first.amount, 5.0);
    });

    test('European format 1.234,56 (dot thousands, comma decimal)', () {
      expect(ImportExportService.parseCsvFile(csvQ('1.234,56'))
          .validRows.first.amount, closeTo(1234.56, 0.001));
    });

    test('US format 1,234.56 (comma thousands, dot decimal)', () {
      expect(ImportExportService.parseCsvFile(csvQ('1,234.56'))
          .validRows.first.amount, closeTo(1234.56, 0.001));
    });

    test('zero amount produces error with "greater than zero" message', () {
      final result = ImportExportService.parseCsvFile(csv('0'));
      expect(result.invalidRows.first.field, 'Amount');
      expect(result.invalidRows.first.message, contains('greater than zero'));
    });

    test('negative amount produces error row', () {
      final result = ImportExportService.parseCsvFile(csv('-5.0'));
      expect(result.invalidRows.first.field, 'Amount');
    });

    test('non-numeric amount produces error row', () {
      final result = ImportExportService.parseCsvFile(csv('abc'));
      expect(result.invalidRows.first.field, 'Amount');
    });
  });

  // ── parseCsvFile — category ───────────────────────────────────────────────

  group('parseCsvFile — category', () {
    Uint8List csv(String cat) => Uint8List.fromList(utf8.encode(
        'Date,Amount,Category,Financial Type,Note,Group\n'
        '2026-01-01,1.0,$cat,,,\n'));

    test('matches display name case-insensitively', () {
      expect(ImportExportService.parseCsvFile(csv('communication'))
          .validRows.first.category, ExpenseCategory.communication);
    });

    test('mixed-case display name matches', () {
      expect(ImportExportService.parseCsvFile(csv('Communication'))
          .validRows.first.category, ExpenseCategory.communication);
    });

    test('unknown category falls back to other', () {
      expect(ImportExportService.parseCsvFile(csv('UnknownXYZ'))
          .validRows.first.category, ExpenseCategory.other);
    });

    test('empty category defaults to other', () {
      expect(ImportExportService.parseCsvFile(csv(''))
          .validRows.first.category, ExpenseCategory.other);
    });
  });

  // ── parseCsvFile — financial type ─────────────────────────────────────────

  group('parseCsvFile — financial type', () {
    Uint8List csv(String type) => Uint8List.fromList(utf8.encode(
        'Date,Amount,Category,Financial Type,Note,Group\n'
        '2026-01-01,1.0,,$type,,\n'));

    test('asset display name matches', () {
      expect(ImportExportService.parseCsvFile(csv('Asset'))
          .validRows.first.financialType, FinancialType.asset);
    });

    test('insurance display name matches', () {
      expect(ImportExportService.parseCsvFile(csv('Insurance'))
          .validRows.first.financialType, FinancialType.insurance);
    });

    test('display name match is case-insensitive', () {
      expect(ImportExportService.parseCsvFile(csv('asset'))
          .validRows.first.financialType, FinancialType.asset);
    });

    test('empty financial type defaults to consumption', () {
      expect(ImportExportService.parseCsvFile(csv(''))
          .validRows.first.financialType, FinancialType.consumption);
    });

    test('unknown financial type defaults to consumption', () {
      expect(ImportExportService.parseCsvFile(csv('unknown'))
          .validRows.first.financialType, FinancialType.consumption);
    });
  });

  // ── parseCsvFile — note and group ─────────────────────────────────────────

  group('parseCsvFile — note and group', () {
    const hdr = 'Date,Amount,Category,Financial Type,Note,Group\n';

    test('note and group are trimmed (unquoted whitespace)', () {
      final bytes = Uint8List.fromList(
          utf8.encode('${hdr}2026-01-01,1.0,,,  hello  ,  world  \n'));
      final row = ImportExportService.parseCsvFile(bytes).validRows.first;
      expect(row.note, 'hello');
      expect(row.group, 'world');
    });

    test('whitespace-only note becomes null', () {
      final bytes =
          Uint8List.fromList(utf8.encode('${hdr}2026-01-01,1.0,,,   ,\n'));
      expect(ImportExportService.parseCsvFile(bytes).validRows.first.note,
          isNull);
    });

    test('whitespace-only group becomes null', () {
      final bytes =
          Uint8List.fromList(utf8.encode('${hdr}2026-01-01,1.0,,,,   \n'));
      expect(ImportExportService.parseCsvFile(bytes).validRows.first.group,
          isNull);
    });
  });

  // ── parseCsvFile — error row numbers ─────────────────────────────────────

  group('parseCsvFile — error row numbers', () {
    const hdr = 'Date,Amount,Category,Financial Type,Note,Group\n';

    test('first data row is row number 2 (row 1 = header)', () {
      final bytes =
          Uint8List.fromList(utf8.encode('${hdr}bad,10.0,,,,\n'));
      expect(ImportExportService.parseCsvFile(bytes)
          .invalidRows.first.rowNumber, 2);
    });

    test('error in third data row has rowNumber 4', () {
      final bytes = Uint8List.fromList(utf8.encode(
          '$hdr'
          '2026-01-01,1.0,,,,\n'
          '2026-02-01,2.0,,,,\n'
          'bad-date,3.0,,,,\n'));
      expect(ImportExportService.parseCsvFile(bytes)
          .invalidRows.first.rowNumber, 4);
    });

    test('totalRows = validRows + invalidRows', () {
      final bytes = Uint8List.fromList(utf8.encode(
          '$hdr'
          '2026-01-01,10.0,,,,\n' // valid
          'BADDATE,10.0,,,,\n' // invalid date
          '2026-02-01,-5.0,,,,\n' // invalid amount
          '2026-03-01,20.0,,,,\n' // valid
      ));
      final result = ImportExportService.parseCsvFile(bytes);
      expect(result.validRows, hasLength(2));
      expect(result.invalidRows, hasLength(2));
      expect(result.totalRows, 4);
    });
  });

  // ── parseCsvFile — edge cases ─────────────────────────────────────────────

  group('parseCsvFile — edge cases', () {
    const hdr = 'Date,Amount,Category,Financial Type,Note,Group\n';

    test('file without trailing newline is accepted', () {
      final bytes = Uint8List.fromList(
          utf8.encode('${hdr}2026-01-01,5.0,,,,'));
      final result = ImportExportService.parseCsvFile(bytes);
      expect(result.validRows, hasLength(1));
    });

    test('CR-only line endings (old Mac) are handled', () {
      final bytes = Uint8List.fromList(utf8.encode(
          'Date,Amount,Category,Financial Type,Note,Group\r'
          '2026-01-01,10.0,,,,\r'));
      final result = ImportExportService.parseCsvFile(bytes);
      expect(result.validRows, hasLength(1));
    });

    test('UTF-8 BOM at file start is stripped and file parses correctly', () {
      // Excel-exported CSVs often start with a UTF-8 BOM (EF BB BF)
      final content = '\uFEFF${hdr}2026-01-01,5.0,,,,\n';
      final bytes = Uint8List.fromList(utf8.encode(content));
      final result = ImportExportService.parseCsvFile(bytes);
      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
    });

    test('semicolon delimiter (European-locale Excel export) is auto-detected', () {
      const semicolonCsv =
          'Date;Amount;Category;Financial Type;Note;Group\n'
          '2026-03-01;25.50;Groceries;Consumption;note;group\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(semicolonCsv)));
      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
      expect(result.validRows.first.amount, 25.50);
      expect(result.validRows.first.category, ExpenseCategory.groceries);
      expect(result.validRows.first.note, 'note');
      expect(result.validRows.first.group, 'group');
    });

    test('semicolon delimiter with BOM (Excel on European locale)', () {
      final content =
          '\uFEFFDate;Amount;Category;Financial Type;Note;Group\n'
          '2026-01-01;10.0;Groceries;;;vacation\n';
      final result = ImportExportService.parseCsvFile(
          Uint8List.fromList(utf8.encode(content)));
      expect(result.headerError, isNull);
      expect(result.validRows, hasLength(1));
      expect(result.validRows.first.group, 'vacation');
    });

    test('headers-only file (no data rows) returns empty result', () {
      final bytes = Uint8List.fromList(utf8.encode(hdr));
      final result = ImportExportService.parseCsvFile(bytes);
      expect(result.headerError, isNull);
      expect(result.validRows, isEmpty);
      expect(result.invalidRows, isEmpty);
      expect(result.totalRows, 0);
    });

    test('empty quoted field is treated as empty string → null', () {
      final bytes = Uint8List.fromList(
          utf8.encode('${hdr}2026-01-01,1.0,,,"",\n'));
      expect(ImportExportService.parseCsvFile(bytes).validRows.first.note,
          isNull);
    });
  });

  // ── generateTemplate ──────────────────────────────────────────────────────

  group('generateTemplate', () {
    test('template has valid headers and produces no error', () async {
      final bytes = await ImportExportService.generateTemplate();
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.headerError, isNull);
    });

    test('template has no data rows', () async {
      final bytes = await ImportExportService.generateTemplate();
      final result = ImportExportService.parseImportFile(bytes);
      expect(result.validRows, isEmpty);
      expect(result.invalidRows, isEmpty);
    });
  });
}
