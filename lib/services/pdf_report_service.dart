import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/budget_status.dart';
import '../models/category_total.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/monthly_pdf_data.dart';
import '../models/monthly_summary.dart';
import '../models/year_month.dart';
import '../models/yearly_pdf_data.dart';

/// Pure static service that builds PDF documents from pre-assembled data.
/// Produces a [Uint8List] suitable for writing to disk and sharing via OS.
class PdfReportService {
  PdfReportService._();

  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];


  // ── Brand colors ──────────────────────────────────────────────────────────

  static PdfColor get _navy => _color(0xFF0D1B4B);
  static PdfColor get _gold => _color(0xFFD4A853);
  static PdfColor get _lightGrey => _color(0xFFF8F9FA);
  static PdfColor get _borderGrey => _color(0xFFE8EAF0);
  static PdfColor get _textMuted => _color(0xFF8E97A8);
  static PdfColor get _green => _color(0xFF1DB954);
  static PdfColor get _red => _color(0xFFE53935);
  static PdfColor get _groupHeader => _color(0xFF37474F);

  static PdfColor _color(int argb) {
    final r = ((argb >> 16) & 0xFF) / 255.0;
    final g = ((argb >> 8) & 0xFF) / 255.0;
    final b = (argb & 0xFF) / 255.0;
    return PdfColor(r, g, b);
  }

  // ── Character normalisation ───────────────────────────────────────────────
  //
  // The built-in Helvetica PDF font uses WinAnsi encoding which does not
  // render accented / Eastern European characters correctly.  Replace them
  // with their nearest ASCII equivalents before embedding in the document.

  static const _diacritics = {
    'á': 'a', 'Á': 'A', 'à': 'a', 'À': 'A', 'â': 'a', 'Â': 'A',
    'ä': 'a', 'Ä': 'A', 'ã': 'a', 'Ã': 'A', 'å': 'a', 'Å': 'A',
    'ā': 'a', 'Ā': 'A', 'ă': 'a', 'Ă': 'A', 'ą': 'a', 'Ą': 'A',
    'č': 'c', 'Č': 'C', 'ć': 'c', 'Ć': 'C', 'ç': 'c', 'Ç': 'C',
    'ď': 'd', 'Ď': 'D', 'đ': 'd', 'Đ': 'D',
    'é': 'e', 'É': 'E', 'è': 'e', 'È': 'E', 'ê': 'e', 'Ê': 'E',
    'ë': 'e', 'Ë': 'E', 'ě': 'e', 'Ě': 'E', 'ē': 'e', 'Ē': 'E',
    'ę': 'e', 'Ę': 'E',
    'í': 'i', 'Í': 'I', 'ì': 'i', 'Ì': 'I', 'î': 'i', 'Î': 'I',
    'ï': 'i', 'Ï': 'I', 'ī': 'i', 'Ī': 'I',
    'ĺ': 'l', 'Ĺ': 'L', 'ľ': 'l', 'Ľ': 'L', 'ł': 'l', 'Ł': 'L',
    'ń': 'n', 'Ń': 'N', 'ň': 'n', 'Ň': 'N', 'ñ': 'n', 'Ñ': 'N',
    'ó': 'o', 'Ó': 'O', 'ò': 'o', 'Ò': 'O', 'ô': 'o', 'Ô': 'O',
    'ö': 'o', 'Ö': 'O', 'õ': 'o', 'Õ': 'O', 'ő': 'o', 'Ő': 'O',
    'ŕ': 'r', 'Ŕ': 'R', 'ř': 'r', 'Ř': 'R',
    'ś': 's', 'Ś': 'S', 'š': 's', 'Š': 'S', 'ş': 's', 'Ş': 'S',
    'ß': 'ss',
    'ť': 't', 'Ť': 'T', 'ţ': 't', 'Ţ': 'T',
    'ú': 'u', 'Ú': 'U', 'ù': 'u', 'Ù': 'U', 'û': 'u', 'Û': 'U',
    'ü': 'u', 'Ü': 'U', 'ů': 'u', 'Ů': 'U', 'ű': 'u', 'Ű': 'U',
    'ý': 'y', 'Ý': 'Y', 'ÿ': 'y', 'Ÿ': 'Y',
    'ź': 'z', 'Ź': 'Z', 'ż': 'z', 'Ż': 'Z', 'ž': 'z', 'Ž': 'Z',
    // Common punctuation outside WinAnsi
    '\u2014': '-',   // em dash
    '\u2013': '-',   // en dash
    '\u2018': '\'',  // left single quote
    '\u2019': '\'',  // right single quote
    '\u201C': '"',   // left double quote
    '\u201D': '"',   // right double quote
    '\u2026': '...', // ellipsis
  };

  static String _n(String text) {
    var result = text;
    _diacritics.forEach((from, to) => result = result.replaceAll(from, to));
    return result;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<Uint8List> generateMonthlyReport(MonthlyPdfData data) async {
    final doc = pw.Document(
      title: 'Monthly Report ${_monthNames[data.month]} ${data.year}',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _buildHeader(
          'Monthly Report',
          '${_monthNames[data.month]} ${data.year}',
        ),
        footer: _buildFooter,
        build: (ctx) => _buildMonthlyContent(data),
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateYearlyReport(YearlyPdfData data) async {
    final doc = pw.Document(
      title: 'Yearly Report ${data.year}',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => _buildHeader(
          'Yearly Report',
          '${data.year}${data.isPartialYear ? ' (partial year)' : ''}',
        ),
        footer: _buildFooter,
        build: (ctx) => _buildYearlyContent(data),
      ),
    );

    return doc.save();
  }

  // ── Monthly content ───────────────────────────────────────────────────────

  static List<pw.Widget> _buildMonthlyContent(MonthlyPdfData data) {
    return [
      pw.SizedBox(height: 16),
      if (data.budgetStatus != null) ...[
        _sectionTitle('BUDGET SUMMARY'),
        pw.SizedBox(height: 8),
        _buildBudgetSummary(data.budgetStatus!),
        pw.SizedBox(height: 20),
      ],
      _sectionTitle('CATEGORY BREAKDOWN'),
      pw.SizedBox(height: 8),
      _buildCategoryTable(data.categoryTotals, data.grandTotal),
      if (data.groupSummaries.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('EXPENSE GROUPS'),
        pw.SizedBox(height: 8),
        _buildGroupsSection(data),
      ],
      if (data.expenses.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('EXPENSE DETAILS'),
        pw.SizedBox(height: 8),
        _buildExpenseTable(data.expenses),
      ],
    ];
  }

  // ── Yearly content ────────────────────────────────────────────────────────

  static List<pw.Widget> _buildYearlyContent(YearlyPdfData data) {
    return [
      pw.SizedBox(height: 16),
      if (data.isPartialYear) ...[
        _buildPartialYearNote(),
        pw.SizedBox(height: 12),
      ],
      _sectionTitle('CATEGORY BREAKDOWN'),
      pw.SizedBox(height: 8),
      _buildCategoryTable(data.categoryTotals, data.grandTotal),
      pw.SizedBox(height: 20),
      _sectionTitle('MONTH-BY-MONTH BUDGET'),
      pw.SizedBox(height: 8),
      _buildMonthlyBudgetTable(data.monthlySummaries),
      if (data.categoryMonthlyAmounts.isNotEmpty) ...[
        pw.SizedBox(height: 20),
        _sectionTitle('SPENDING BY CATEGORY AND MONTH'),
        pw.SizedBox(height: 8),
        _buildCategoryMonthTable(data),
      ],
    ];
  }

  // ── Header & footer ───────────────────────────────────────────────────────

  static pw.Widget _buildHeader(String title, String subtitle) {
    return pw.Container(
      decoration: pw.BoxDecoration(color: _navy),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      margin: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Finance Tracker',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  color: _gold,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                subtitle,
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context ctx) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _borderGrey, width: 0.5),
        ),
      ),
      padding: const pw.EdgeInsets.only(top: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Finance Tracker',
            style: pw.TextStyle(color: _textMuted, fontSize: 9),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: pw.TextStyle(color: _textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
        color: _textMuted,
        letterSpacing: 1.0,
      ),
    );
  }

  // ── Budget summary ────────────────────────────────────────────────────────

  static pw.Widget _buildBudgetSummary(BudgetStatus status) {
    final remaining = status.remaining;
    final pct = (status.percentUsed / 100).clamp(0.0, 1.0);
    final barColor = status.isOverBudget ? _red : _green;

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: _lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: _borderGrey, width: 0.5),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _labelValue(
                'Budget',
                '${status.spendableBudget.toStringAsFixed(2)} EUR',
              ),
              _labelValue(
                'Spent',
                '${status.actualSpent.toStringAsFixed(2)} EUR',
              ),
              _labelValue(
                remaining >= 0 ? 'Remaining' : 'Over by',
                '${remaining.abs().toStringAsFixed(2)} EUR',
                valueColor: remaining >= 0 ? _green : _red,
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          _buildBar(pct, barColor, height: 8),
        ],
      ),
    );
  }

  static pw.Widget _labelValue(
    String label,
    String value, {
    PdfColor? valueColor,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(fontSize: 9, color: _textMuted),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ── Category table ────────────────────────────────────────────────────────

  static pw.Widget _buildCategoryTable(
    List<CategoryTotal> totals,
    double grandTotal,
  ) {
    if (totals.isEmpty) {
      return pw.Text('No data.', style: pw.TextStyle(color: _textMuted));
    }

    final maxAmount =
        totals.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

    return pw.Column(
      children: [
        ...totals.asMap().entries.map((entry) {
          final i = entry.key;
          final ct = entry.value;
          final barFraction = maxAmount > 0 ? ct.amount / maxAmount : 0.0;
          final catColor = _color(ct.category.color.toARGB32());

          return pw.Container(
            color: i.isEven ? PdfColors.white : _lightGrey,
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 8,
                  height: 8,
                  decoration: pw.BoxDecoration(
                    color: catColor,
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 100,
                  child: pw.Text(
                    ct.category.displayName,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(
                  child: _buildBar(barFraction, catColor),
                ),
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 42,
                  child: pw.Text(
                    '${ct.percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    '${ct.amount.toStringAsFixed(2)} EUR',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          );
        }),
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _borderGrey)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                '${grandTotal.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Groups section with per-expense breakdown ─────────────────────────────

  /// Renders one block per group: a header row followed by a table of every
  /// expense that belongs to this group in the current month, then a subtotal.
  static pw.Widget _buildGroupsSection(MonthlyPdfData data) {
    final sections = <pw.Widget>[];

    for (var gi = 0; gi < data.groupSummaries.length; gi++) {
      final groupName = data.groupSummaries[gi].key;

      // Only the current month's expenses for this group, newest first.
      final monthExpenses = data.expenses
          .where((e) => e.group == groupName)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final monthTotal =
          monthExpenses.fold(0.0, (s, e) => s + e.amount);

      if (gi > 0) sections.add(pw.SizedBox(height: 8));

      // Group header bar.
      sections.add(
        pw.Container(
          decoration: pw.BoxDecoration(color: _groupHeader),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  _n(groupName),
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                '${monthExpenses.length} item${monthExpenses.length == 1 ? '' : 's'}',
                style: pw.TextStyle(color: _color(0xFFB0BEC5), fontSize: 9),
              ),
            ],
          ),
        ),
      );

      if (monthExpenses.isEmpty) {
        sections.add(
          pw.Container(
            color: _lightGrey,
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              'No expenses this month.',
              style: pw.TextStyle(fontSize: 9, color: _textMuted),
            ),
          ),
        );
        continue;
      }

      // Expense rows.
      for (var i = 0; i < monthExpenses.length; i++) {
        final e = monthExpenses[i];
        final day = e.date.day.toString().padLeft(2, '0');
        final month = e.date.month.toString().padLeft(2, '0');
        final note = e.note?.isNotEmpty == true ? _n(e.note!) : '-';

        sections.add(
          pw.Container(
            color: i.isEven ? PdfColors.white : _lightGrey,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 36,
                  child: pw.Text(
                    '$day.$month',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    note,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.SizedBox(
                  width: 90,
                  child: pw.Text(
                    e.category.displayName,
                    style: pw.TextStyle(fontSize: 9, color: _textMuted),
                  ),
                ),
                pw.SizedBox(
                  width: 76,
                  child: pw.Text(
                    '${e.amount.toStringAsFixed(2)} EUR',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Subtotal row.
      sections.add(
        pw.Container(
          decoration: pw.BoxDecoration(
            color: _lightGrey,
            border: pw.Border(top: pw.BorderSide(color: _borderGrey)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Group total (this month)',
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textMuted,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                '${monthTotal.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(children: sections);
  }

  // ── Expense detail table ──────────────────────────────────────────────────

  static pw.Widget _buildExpenseTable(List<Expense> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(44),
        1: pw.FlexColumnWidth(3),
        2: pw.FlexColumnWidth(2),
        3: pw.FixedColumnWidth(76),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _navy),
          children: [
            _tableHeader('Date'),
            _tableHeader('Note'),
            _tableHeader('Category'),
            _tableHeader('Amount', align: pw.TextAlign.right),
          ],
        ),
        ...expenses.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          final day = e.date.day.toString().padLeft(2, '0');
          final month = e.date.month.toString().padLeft(2, '0');
          final note =
              e.note?.isNotEmpty == true ? _n(e.note!) : '-';
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : _lightGrey,
            ),
            children: [
              _tableCell('$day.$month'),
              _tableCell(note),
              _tableCell(e.category.displayName),
              _tableCell(
                '${e.amount.toStringAsFixed(2)} EUR',
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Monthly budget table (yearly report) ─────────────────────────────────

  static pw.Widget _buildMonthlyBudgetTable(List<MonthlySummary> summaries) {
    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: const {
        0: pw.FixedColumnWidth(36),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _navy),
          children: [
            _tableHeader(''),
            _tableHeader('Budget', align: pw.TextAlign.right),
            _tableHeader('Spent', align: pw.TextAlign.right),
            _tableHeader('Difference', align: pw.TextAlign.right),
          ],
        ),
        ...summaries.asMap().entries.map((entry) {
          final i = entry.key;
          final s = entry.value;
          final diff = s.difference;
          final hasData = s.spendableBudget != 0 || s.actualExpenses != 0;
          final diffColor = diff >= 0 ? _green : _red;
          final diffText = hasData
              ? '${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(0)} EUR'
              : '-';

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : _lightGrey,
            ),
            children: [
              _tableCell(YearMonth.monthAbbreviations[s.period.month]),
              _tableCell(
                hasData
                    ? '${s.spendableBudget.toStringAsFixed(0)} EUR'
                    : '-',
                align: pw.TextAlign.right,
              ),
              _tableCell(
                s.actualExpenses > 0
                    ? '${s.actualExpenses.toStringAsFixed(0)} EUR'
                    : '-',
                align: pw.TextAlign.right,
              ),
              _tableCellColored(
                diffText,
                align: pw.TextAlign.right,
                color: hasData ? diffColor : _textMuted,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Category × month cross-tab (yearly report) ────────────────────────────

  static pw.Widget _buildCategoryMonthTable(YearlyPdfData data) {
    final amounts = data.categoryMonthlyAmounts;
    if (amounts.isEmpty) {
      return pw.Text('No data.', style: pw.TextStyle(color: _textMuted));
    }

    // Only show months that have any spending.
    final activeMonths = <int>[];
    for (var m = 1; m <= 12; m++) {
      if (amounts.values.any((list) => list[m - 1] > 0)) {
        activeMonths.add(m);
      }
    }
    if (activeMonths.isEmpty) {
      return pw.Text('No data.', style: pw.TextStyle(color: _textMuted));
    }

    final categories = amounts.keys.toList();

    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(88),
    };
    for (var i = 0; i < activeMonths.length; i++) {
      colWidths[i + 1] = const pw.FlexColumnWidth(1);
    }
    colWidths[activeMonths.length + 1] = const pw.FixedColumnWidth(58);

    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: colWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _navy),
          children: [
            _tableHeader('Category'),
            ...activeMonths.map(
              (m) => _tableHeader(YearMonth.monthAbbreviations[m], align: pw.TextAlign.right),
            ),
            _tableHeader('Total', align: pw.TextAlign.right),
          ],
        ),
        ...categories.asMap().entries.map((entry) {
          final i = entry.key;
          final cat = entry.value;
          final monthAmounts = amounts[cat]!;
          final total = monthAmounts.fold(0.0, (s, a) => s + a);

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : _lightGrey,
            ),
            children: [
              _tableCell(cat.displayName),
              ...activeMonths.map((m) {
                final v = monthAmounts[m - 1];
                return _tableCell(
                  v > 0 ? v.toStringAsFixed(0) : '-',
                  align: pw.TextAlign.right,
                );
              }),
              _tableCellBold(
                '${total.toStringAsFixed(0)} EUR',
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Partial year note ─────────────────────────────────────────────────────

  static pw.Widget _buildPartialYearNote() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _color(0xFFFFF8E1),
        border: pw.Border.all(color: _gold, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'Partial year - months without data show zeros. '
        'Year-to-date totals only.',
        style: pw.TextStyle(
          fontSize: 9,
          color: _color(0xFF795548),
        ),
      ),
    );
  }

  // ── Horizontal bar helper ─────────────────────────────────────────────────

  static pw.Widget _buildBar(
    double fraction,
    PdfColor filledColor, {
    double height = 6,
  }) {
    final filled = (fraction * 100).clamp(0.0, 100.0);
    final empty = 100.0 - filled;

    return pw.Row(
      children: [
        if (filled > 0)
          pw.Expanded(
            flex: filled.round().clamp(1, 100),
            child: pw.Container(
              height: height,
              decoration: pw.BoxDecoration(
                color: filledColor,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
            ),
          ),
        if (empty > 0)
          pw.Expanded(
            flex: empty.round().clamp(1, 100),
            child: pw.Container(
              height: height,
              decoration: pw.BoxDecoration(
                color: _borderGrey,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(3)),
              ),
            ),
          ),
      ],
    );
  }

  // ── Table cell helpers ────────────────────────────────────────────────────

  static pw.Widget _tableHeader(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCellColored(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _tableCellBold(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        textAlign: align,
      ),
    );
  }
}
