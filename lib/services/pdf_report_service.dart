import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/category_total.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/financial_type_income_ratio.dart';
import '../models/monthly_overview_summary.dart';
import '../models/monthly_pdf_data.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import '../models/yearly_pdf_data.dart';
import '../services/budget_calculator.dart';

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

  static final _navy         = _color(0xFF0D1B4B);
  static final _gold         = _color(0xFFD4A853);
  static final _lightGrey    = _color(0xFFF8F9FA);
  static final _borderGrey   = _color(0xFFE8EAF0);
  static final _textMuted    = _color(0xFF8E97A8);
  static final _green        = _color(0xFF1DB954); // income green
  static final _red          = _color(0xFFE53935); // consumption / error red
  static final _assetGreen   = _color(0xFF43A047); // asset green
  static final _insuranceBlue = _color(0xFF1565C0); // insurance blue
  static final _amber        = _color(0xFFF59E0B); // warning amber
  static final _amberLight   = _color(0xFFFFF8E1); // amber card background
  static final _groupHeader  = _color(0xFF37474F); // dark slate for group bars
  static final _slateLight   = _color(0xFFB0BEC5); // light slate for secondary text

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

    final monthLabel = _monthNames[data.month];
    final yearLabel = data.year;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => ctx.pageNumber == 1
            ? _buildFirstPageHeader(
                'MONTHLY REPORT FOR ${monthLabel.toUpperCase()} $yearLabel')
            : _buildHeader('Monthly Report', '$monthLabel $yearLabel'),
        footer: _buildFooter,
        build: (ctx) => _buildMonthlyContent(data),
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateYearlyReport(YearlyPdfData data) async {
    final yearStr = data.year.toString();
    final subtitleStr =
        data.isPartialYear ? '$yearStr (partial year)' : yearStr;

    final doc = pw.Document(title: 'Yearly Report $yearStr');

    // Main portrait pages (Spending vs Income, Category Summary,
    // Cash Flow Summary, Yearly Overview).
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => ctx.pageNumber == 1
            ? _buildFirstPageHeader('YEARLY REPORT FOR $yearStr')
            : _buildHeader('Yearly Report', subtitleStr),
        footer: _buildFooter,
        build: (ctx) => _buildYearlyContent(data),
      ),
    );

    // Landscape page for Spending by Category and Month.
    if (data.categoryMonthlyAmounts.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => _buildHeader('Yearly Report', subtitleStr),
          footer: _buildFooter,
          build: (ctx) => [
            pw.SizedBox(height: 12),
            _sectionTitle('SPENDING BY CATEGORY AND MONTH'),
            pw.SizedBox(height: 8),
            _buildCategoryMonthTable(data),
          ],
        ),
      );
    }

    return doc.save();
  }

  // ── Monthly content ───────────────────────────────────────────────────────

  static List<pw.Widget> _buildMonthlyContent(MonthlyPdfData data) {
    final hasPlanData = data.activePlanItems.isNotEmpty;

    return [
      pw.SizedBox(height: 16),
      // Page 1: Spending vs Income (if any) + Category Summary — flow naturally.
      if (hasPlanData) ...[
        _sectionTitle('SPENDING VS INCOME'),
        pw.SizedBox(height: 8),
        _buildSpendingVsIncomeWidget(data.typeRatio!, 'month'),
        pw.SizedBox(height: 20),
      ],
      _sectionTitle('CATEGORY SUMMARY'),
      pw.SizedBox(height: 8),
      _buildCategorySummarySection(data),
      // Page 2: Cash Flow Summary — always forced new page.
      if (hasPlanData) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle('CASH FLOW SUMMARY'),
        pw.SizedBox(height: 8),
        _buildCashFlowSummarySection(data),
        pw.SizedBox(height: 20),
      ],
      if (data.groupSummaries.isNotEmpty) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle('EXPENSE GROUPS'),
        pw.SizedBox(height: 8),
        _buildGroupsSection(data),
      ],
      if (data.expenses.isNotEmpty) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle('EXPENSE DETAILS'),
        pw.SizedBox(height: 8),
        _buildExpenseTable(data.expenses, data.grandTotal),
      ],
    ];
  }

  // ── Yearly content ────────────────────────────────────────────────────────

  static List<pw.Widget> _buildYearlyContent(YearlyPdfData data) {
    final hasPlanData = data.activePlanItems.isNotEmpty;
    final hasOverview = data.overviewSummaries.any((s) => s.hasData);

    return [
      pw.SizedBox(height: 16),
      if (data.isPartialYear) ...[
        _buildPartialYearNote(),
        pw.SizedBox(height: 12),
      ],
      // Page 1: Spending vs Income (if any) + Category Summary — flow naturally.
      if (hasPlanData) ...[
        _sectionTitle('SPENDING VS INCOME'),
        pw.SizedBox(height: 8),
        _buildSpendingVsIncomeWidget(data.typeRatio!, 'year'),
        pw.SizedBox(height: 20),
      ],
      _sectionTitle('CATEGORY SUMMARY'),
      pw.SizedBox(height: 8),
      _buildCategoryTable(data.categoryTotals, data.grandTotal),
      // Page 2: Cash Flow Summary — always forced new page.
      if (hasPlanData) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle('CASH FLOW SUMMARY'),
        pw.SizedBox(height: 8),
        _buildYearlyCashFlowSection(data),
        pw.SizedBox(height: 20),
      ],
      // Page 3: Yearly Overview.
      if (hasOverview) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle('YEARLY OVERVIEW'),
        pw.SizedBox(height: 8),
        _buildYearlyOverviewSection(data.overviewSummaries),
      ],
      // Spending by Category and Month is rendered on a separate landscape
      // page added by generateYearlyReport.
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

  static pw.Widget _buildFirstPageHeader(String title) {
    return pw.Container(
      decoration: pw.BoxDecoration(color: _navy),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            'Finance Tracker',
            style: pw.TextStyle(
              color: _gold,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.5,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
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

  // ── Spending vs Income widget (FinancialTypeDistributionCard style) ─────────

  /// [periodLabel] is either 'month' or 'year' — used in the earned label and
  /// overspend warning text.
  static pw.Widget _buildSpendingVsIncomeWidget(
      FinancialTypeIncomeRatio ratio, String periodLabel) {
    final overspend = ratio.overspendAmount;

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
          // Earned this month row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Earned this $periodLabel',
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
              pw.Text(
                '${ratio.income.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _green,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 0.5, color: _borderGrey),
          pw.SizedBox(height: 4),
          if (ratio.consumptionAmount > 0)
            _buildTypeRatioRow(FinancialType.consumption,
                ratio.consumptionAmount, ratio.consumptionPct, _red),
          if (ratio.assetAmount > 0)
            _buildTypeRatioRow(
                FinancialType.asset, ratio.assetAmount, ratio.assetPct, _assetGreen),
          if (ratio.insuranceAmount > 0)
            _buildTypeRatioRow(FinancialType.insurance,
                ratio.insuranceAmount, ratio.insurancePct, _insuranceBlue),
          if (overspend != null) ...[
            pw.SizedBox(height: 10),
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: _amberLight,
                borderRadius:
                    const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: _amber, width: 0.8),
              ),
              child: pw.Row(
                children: [
                  pw.Text(
                    '! ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: _amber,
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      'This $periodLabel you spent ${overspend.toStringAsFixed(2)} EUR more than you earned!',
                      style: pw.TextStyle(fontSize: 9, color: _amber),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Horizontal fill bar row: [dot] [name 70px] [bar expanded] [pct 34px] [EUR 85px]
  static pw.Widget _buildTypeRatioRow(
    FinancialType type,
    double amount,
    double? pct,
    PdfColor typeColor,
  ) {
    final barFraction = pct != null ? (pct / 100).clamp(0.0, 1.0) : 0.0;
    final pctLabel = pct == null ? '-' : '${pct.toStringAsFixed(0)}%';

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              color: typeColor,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              type.displayName,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: _buildBar(barFraction, typeColor, height: 8),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 34,
            child: pw.Text(
              pctLabel,
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: typeColor,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 85,
            child: pw.Text(
              '${amount.toStringAsFixed(2)} EUR',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: typeColor,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // ── Cash Flow Summary section ─────────────────────────────────────────────

  static pw.Widget _buildCashFlowSummarySection(MonthlyPdfData data) {
    double amountFn(PlanItem item) =>
        BudgetCalculator.itemMonthlyContribution(item, data.year, data.month);
    String suffixFn(PlanItem item) =>
        item.frequency == PlanFrequency.yearly ? ' (normalized)' : '';

    final incomeItems = data.activePlanItems
        .where((i) => i.type == PlanItemType.income)
        .toList();
    final fixedCostItems = data.activePlanItems
        .where((i) => i.type == PlanItemType.fixedCost)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (incomeItems.isNotEmpty) ...[
          _buildIncomeCard(incomeItems, amountFn, suffixFn),
          pw.SizedBox(height: 12),
        ],
        if (fixedCostItems.isNotEmpty)
          _buildFixedCostsCard(fixedCostItems, amountFn, suffixFn),
      ],
    );
  }

  static pw.Widget _buildYearlyCashFlowSection(YearlyPdfData data) {
    double amountFn(PlanItem item) =>
        BudgetCalculator.itemYearlyContribution(item, data.allPlanItems, data.year);
    String suffixFn(PlanItem item) =>
        item.frequency == PlanFrequency.monthly ? ' (annualized)' : '';

    final incomeItems = data.activePlanItems
        .where((i) => i.type == PlanItemType.income)
        .toList();
    final fixedCostItems = data.activePlanItems
        .where((i) => i.type == PlanItemType.fixedCost)
        .toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (incomeItems.isNotEmpty) ...[
          _buildIncomeCard(incomeItems, amountFn, suffixFn),
          pw.SizedBox(height: 12),
        ],
        if (fixedCostItems.isNotEmpty)
          _buildFixedCostsCard(fixedCostItems, amountFn, suffixFn),
      ],
    );
  }

  static pw.Widget _buildIncomeCard(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn) {
    final total = items.fold(0.0, (s, i) => s + amountFn(i));

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
          // Header row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'INCOME',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              pw.Text(
                '${total.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          // Item rows
          ...items.map((item) {
            final amount = amountFn(item);
            final suffix = suffixFn(item);
            return pw.Padding(
              padding: const pw.EdgeInsets.only(top: 4),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      _n('${item.name}$suffix'),
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    ),
                  ),
                  pw.Text(
                    '${amount.toStringAsFixed(2)} EUR',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildFixedCostsCard(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn) {
    final grandTotal = items.fold(0.0, (s, i) => s + amountFn(i));

    // Group by financial type in display order
    const typeOrder = [
      FinancialType.consumption,
      FinancialType.asset,
      FinancialType.insurance,
    ];

    final byType = <FinancialType, List<PlanItem>>{};
    for (final item in items) {
      final type = item.financialType ?? FinancialType.consumption;
      byType.putIfAbsent(type, () => []).add(item);
    }

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
          // Top header row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'FIXED COSTS',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _textMuted,
                  letterSpacing: 0.8,
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
          pw.SizedBox(height: 10),
          // Financial type groups
          ...typeOrder
              .where((t) => byType.containsKey(t))
              .map((type) => _buildFinancialTypeGroup(
                    type, byType[type]!, amountFn, suffixFn)),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialTypeGroup(
      FinancialType type,
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn) {
    final typeTotal = items.fold(0.0, (s, i) => s + amountFn(i));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Financial type header row
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                type.displayName,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                '${typeTotal.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (type == FinancialType.consumption)
          _buildConsumptionItems(items, amountFn, suffixFn)
        else
          _buildFlatItems(items, amountFn, suffixFn),
      ],
    );
  }

  /// Consumption items grouped by category, then individual items under each.
  static pw.Widget _buildConsumptionItems(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn) {
    // Group items by category
    final byCategory = <ExpenseCategory, List<PlanItem>>{};
    for (final item in items) {
      final cat = item.category ?? ExpenseCategory.other;
      byCategory.putIfAbsent(cat, () => []).add(item);
    }
    // Pre-compute contributions once to avoid redundant calls in sort + catTotal.
    final contributions = {for (final item in items) item: amountFn(item)};

    // Sort categories by total descending
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) {
        final ta = a.value.fold(0.0, (s, i) => s + contributions[i]!);
        final tb = b.value.fold(0.0, (s, i) => s + contributions[i]!);
        return tb.compareTo(ta);
      });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: sortedCategories.map((entry) {
        final cat = entry.key;
        final catItems = entry.value;
        final catTotal = catItems.fold(0.0, (s, i) => s + contributions[i]!);
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Category sub-header (8px indent)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, top: 3, bottom: 1),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    cat.displayName,
                    style: pw.TextStyle(
                        fontSize: 9,
                        color: _textMuted,
                        fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    '${catTotal.toStringAsFixed(2)} EUR',
                    style: pw.TextStyle(fontSize: 9, color: _textMuted),
                  ),
                ],
              ),
            ),
            // Items (16px indent)
            ...catItems.map((item) {
              final amount = contributions[item]!;
              final suffix = suffixFn(item);
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, top: 2),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        _n('${item.name}$suffix'),
                        style: pw.TextStyle(fontSize: 9, color: _textMuted),
                      ),
                    ),
                    pw.Text(
                      '${amount.toStringAsFixed(2)} EUR',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  /// Asset and Insurance: flat item list with 8px indent.
  static pw.Widget _buildFlatItems(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: items.map((item) {
        final amount = amountFn(item);
        final suffix = suffixFn(item);
        return pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, top: 3),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  _n('${item.name}$suffix'),
                  style: pw.TextStyle(fontSize: 9, color: _textMuted),
                ),
              ),
              pw.Text(
                '${amount.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Category summary section ──────────────────────────────────────────────

  static pw.Widget _buildCategorySummarySection(MonthlyPdfData data) {
    // Collect over-budget categories sorted by overage descending.
    final overages = <({ExpenseCategory category, double overage})>[];
    for (final ct in data.categoryTotals) {
      final budget = data.categoryBudgets[ct.category];
      if (budget != null && ct.amount > budget) {
        overages.add((category: ct.category, overage: ct.amount - budget));
      }
    }
    overages.sort((a, b) => b.overage.compareTo(a.overage));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildCategoryTable(data.categoryTotals, data.grandTotal,
            budgets: data.categoryBudgets),
        if (overages.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: pw.BoxDecoration(
              color: _amberLight,
              borderRadius:
                  const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: _amber, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: overages.map((o) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Row(
                      children: [
                        pw.Text(
                          '! ',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _amber,
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text(
                            '${o.category.displayName} budget: over by ${o.overage.toStringAsFixed(2)} EUR',
                            style: pw.TextStyle(fontSize: 9, color: _amber),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ── Category table ────────────────────────────────────────────────────────
  //
  // Unified for both the no-budget and with-budget cases.
  // When [budgets] is non-empty, extra columns are shown:
  //   % (42) | gap (8) | budget (70) | gap (8) | spent (80) | gap (4) | status (16)
  // The TOTAL row grand total aligns under the "spent" column.
  // When [budgets] is empty, only % (42) + amount (80) are shown on the right.

  static pw.Widget _buildCategoryTable(
    List<CategoryTotal> totals,
    double grandTotal, {
    Map<ExpenseCategory, double> budgets = const {},
  }) {
    if (totals.isEmpty) {
      return pw.Text('No data.', style: pw.TextStyle(color: _textMuted));
    }

    final hasBudgets = budgets.isNotEmpty;
    final maxAmount =
        totals.map((t) => t.amount).reduce((a, b) => a > b ? a : b);

    return pw.Column(
      children: [
        ...totals.asMap().entries.map((entry) {
          final i = entry.key;
          final ct = entry.value;
          final barFraction = maxAmount > 0 ? ct.amount / maxAmount : 0.0;
          final catColor = _color(ct.category.color.toARGB32());
          final budget = budgets[ct.category];
          final isOverBudget = budget != null && ct.amount > budget;

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
                pw.Expanded(child: _buildBar(barFraction, catColor)),
                pw.SizedBox(width: 8),
                // % column
                pw.SizedBox(
                  width: 42,
                  child: pw.Text(
                    '${ct.percentage.toStringAsFixed(1)}%',
                    style: pw.TextStyle(fontSize: 9, color: _textMuted),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                pw.SizedBox(width: 8),
                if (hasBudgets) ...[
                  // Budget column (left of spent)
                  pw.SizedBox(
                    width: 70,
                    child: pw.Text(
                      budget != null ? '${budget.toStringAsFixed(2)} EUR' : '',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                ],
                // Amount / spent column
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    '${ct.amount.toStringAsFixed(2)} EUR',
                    style: pw.TextStyle(
                      fontSize: hasBudgets ? 9 : 10,
                      fontWeight: pw.FontWeight.bold,
                      color: isOverBudget ? _red : null,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
                if (hasBudgets) ...[
                  pw.SizedBox(width: 4),
                  // Status marker — only shown when over budget
                  pw.SizedBox(
                    width: 16,
                    child: pw.Text(
                      isOverBudget ? '!' : '',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _red,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
        // TOTAL row
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
              if (hasBudgets)
                // Skip gap(8) + %(42) + gap(8) + budget(70) + gap(8) to align
                // grand total under the "spent" column
                pw.SizedBox(width: 8 + 42 + 8 + 70 + 8),
              pw.SizedBox(
                width: 80,
                child: pw.Text(
                  '${grandTotal.toStringAsFixed(2)} EUR',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              if (hasBudgets)
                pw.SizedBox(width: 4 + 16), // skip status column
            ],
          ),
        ),
      ],
    );
  }

  // ── Groups section with per-expense breakdown ─────────────────────────────

  /// Renders one block per group: a header row followed by a table of every
  /// expense that belongs to this group in the current month, then a subtotal
  /// and an all-time total.
  static pw.Widget _buildGroupsSection(MonthlyPdfData data) {
    final sections = <pw.Widget>[];

    for (var gi = 0; gi < data.groupSummaries.length; gi++) {
      final groupName = data.groupSummaries[gi].key;
      final allGroupExpenses = data.groupSummaries[gi].value;

      // Split into this-month and other-period expenses.
      final monthExpenses = allGroupExpenses
          .where((e) =>
              e.date.year == data.year && e.date.month == data.month)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final otherExpenses = allGroupExpenses
          .where((e) =>
              !(e.date.year == data.year && e.date.month == data.month))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final monthTotal = monthExpenses.fold(0.0, (s, e) => s + e.amount);
      final allTimeTotal = allGroupExpenses.fold(0.0, (s, e) => s + e.amount);

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
                '${monthExpenses.length} item${monthExpenses.length == 1 ? '' : 's'} this month',
                style: pw.TextStyle(color: _slateLight, fontSize: 9),
              ),
            ],
          ),
        ),
      );

      // This-month expense rows (normal).
      for (var i = 0; i < monthExpenses.length; i++) {
        final e = monthExpenses[i];
        final dayStr = e.date.day.toString().padLeft(2, '0');
        final monthStr = e.date.month.toString().padLeft(2, '0');
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
                    '$dayStr.$monthStr',
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
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Other-period expense rows (muted, full date dd.mm.yyyy, no label).
      if (otherExpenses.isNotEmpty) {
        for (var i = 0; i < otherExpenses.length; i++) {
          final e = otherExpenses[i];
          final dayStr = e.date.day.toString().padLeft(2, '0');
          final monthStr = e.date.month.toString().padLeft(2, '0');
          final yearStr = e.date.year.toString();
          final note = e.note?.isNotEmpty == true ? _n(e.note!) : '-';

          sections.add(
            pw.Container(
              color: i.isEven ? PdfColors.white : _lightGrey,
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              child: pw.Row(
                children: [
                  pw.SizedBox(
                    width: 52,
                    child: pw.Text(
                      '$dayStr.$monthStr.$yearStr',
                      style: pw.TextStyle(fontSize: 8, color: _textMuted),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      note,
                      style: pw.TextStyle(fontSize: 8, color: _textMuted),
                    ),
                  ),
                  pw.SizedBox(
                    width: 90,
                    child: pw.Text(
                      e.category.displayName,
                      style: pw.TextStyle(fontSize: 8, color: _textMuted),
                    ),
                  ),
                  pw.SizedBox(
                    width: 76,
                    child: pw.Text(
                      '${e.amount.toStringAsFixed(2)} EUR',
                      style: pw.TextStyle(fontSize: 8, color: _textMuted),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }

      // Period subtotal row.
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
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      // All-time total row (muted, smaller).
      sections.add(
        pw.Container(
          color: _lightGrey,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'All periods total',
                  style: pw.TextStyle(fontSize: 8, color: _textMuted),
                ),
              ),
              pw.Text(
                '${allTimeTotal.toStringAsFixed(2)} EUR',
                style: pw.TextStyle(fontSize: 8, color: _textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(children: sections);
  }

  // ── Expense detail table ──────────────────────────────────────────────────

  static pw.Widget _buildExpenseTable(
      List<Expense> expenses, double grandTotal) {
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
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _navy),
          children: [
            _tableHeader(''),
            _tableHeader(''),
            _tableHeader('TOTAL', align: pw.TextAlign.right),
            _tableHeader(
              '${grandTotal.toStringAsFixed(2)} EUR',
              align: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  // ── Yearly Overview section ───────────────────────────────────────────────

  /// Mirrors the app's OverviewMonthRow for all 12 months.
  /// Each row: month name | bar + numbers | result
  static pw.Widget _buildYearlyOverviewSection(
      List<MonthlyOverviewSummary> summaries) {
    final rows = <pw.Widget>[];

    for (var i = 0; i < summaries.length; i++) {
      final s = summaries[i];
      final monthName =
          YearMonth.monthAbbreviations[s.period.month]; // e.g. "Jan"
      final diff = s.result;
      final diffText = diff >= 0
          ? '+${diff.toStringAsFixed(0)} EUR'
          : '${diff.toStringAsFixed(0)} EUR';
      final diffColor = diff >= 0 ? _green : _red;

      rows.add(
        pw.Container(
          color: i.isEven ? PdfColors.white : _lightGrey,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Month label
              pw.SizedBox(
                width: 32,
                child: pw.Text(
                  monthName,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _textMuted,
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              // Bar + numbers stacked
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (s.earned > 0) _buildOverviewBar(s),
                    pw.SizedBox(height: 4),
                    _buildOverviewNumbers(s),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              // Result
              pw.SizedBox(
                width: 72,
                child: s.hasData
                    ? pw.Text(
                        diffText,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: diffColor,
                        ),
                        textAlign: pw.TextAlign.right,
                      )
                    : pw.Text(
                        '—',
                        style: pw.TextStyle(fontSize: 10, color: _textMuted),
                        textAlign: pw.TextAlign.right,
                      ),
              ),
            ],
          ),
        ),
      );
    }

    return pw.Column(children: rows);
  }

  /// Background track = full width (grey). Foreground = allocated fraction,
  /// split into asset (green, left) and consumption (red, right) segments.
  static pw.Widget _buildOverviewBar(MonthlyOverviewSummary s) {
    final fraction = (s.allocated / s.earned).clamp(0.0, 1.0);
    final assetFlex = (s.assetPct * fraction).clamp(0.0, 100.0);
    final consumptionFlex = (s.consumptionPct * fraction).clamp(0.0, 100.0);
    final emptyFlex = (100.0 - assetFlex - consumptionFlex).clamp(0.0, 100.0);

    return pw.Container(
      height: 7,
      child: pw.Row(
        children: [
          if (assetFlex > 0)
            pw.Expanded(
              flex: assetFlex.round().clamp(1, 100),
              child: pw.Container(
                height: 7,
                decoration: pw.BoxDecoration(
                  color: _green,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(3),
                    bottomLeft: pw.Radius.circular(3),
                  ),
                ),
              ),
            ),
          if (consumptionFlex > 0)
            pw.Expanded(
              flex: consumptionFlex.round().clamp(1, 100),
              child: pw.Container(
                height: 7,
                color: _red,
              ),
            ),
          if (emptyFlex > 0)
            pw.Expanded(
              flex: emptyFlex.round().clamp(1, 100),
              child: pw.Container(
                height: 7,
                decoration: pw.BoxDecoration(
                  color: _borderGrey,
                  borderRadius: const pw.BorderRadius.only(
                    topRight: pw.Radius.circular(3),
                    bottomRight: pw.Radius.circular(3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildOverviewNumbers(MonthlyOverviewSummary s) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // Assets (green dot + amount)
        pw.Row(
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration:
                  pw.BoxDecoration(color: _green, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 3),
            pw.Text(
              '${s.assets.toStringAsFixed(0)} EUR',
              style: pw.TextStyle(fontSize: 9, color: _green),
            ),
          ],
        ),
        // Consumption (red dot + amount)
        pw.Row(
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration:
                  pw.BoxDecoration(color: _red, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 3),
            pw.Text(
              '${s.consumption.toStringAsFixed(0)} EUR',
              style: pw.TextStyle(fontSize: 9, color: _red),
            ),
          ],
        ),
        // Earned
        pw.Text(
          'Earned: ${s.earned.toStringAsFixed(0)} EUR',
          style: pw.TextStyle(fontSize: 9, color: _textMuted),
        ),
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

    // Landscape A4 content width ≈ 762pt. Use FlexColumnWidth(1) for months —
    // with landscape there is ample room for full month names and 4-digit amounts.
    final colWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(100),
    };
    for (var i = 0; i < activeMonths.length; i++) {
      colWidths[i + 1] = const pw.FlexColumnWidth(1);
    }
    colWidths[activeMonths.length + 1] = const pw.FixedColumnWidth(70);

    return pw.Table(
      border: pw.TableBorder.all(color: _borderGrey, width: 0.5),
      columnWidths: colWidths,
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _navy),
          children: [
            _tableHeader('Category'),
            ...activeMonths.map(
              (m) => _tableHeader(_monthNames[m], align: pw.TextAlign.right),
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
