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
import '../models/yearly_pdf_data.dart';
import '../services/budget_calculator.dart';
import '../services/currency_formatter.dart';
import '../services/pdf_strings.dart';

/// Pure static service that builds PDF documents from pre-assembled data.
/// Produces a [Uint8List] suitable for writing to disk and sharing via OS.
class PdfReportService {
  PdfReportService._();

  // ── Brand colors ──────────────────────────────────────────────────────────

  static final _navy         = _color(0xFF0D1B4B);
  static final _gold         = _color(0xFFD4A853);
  static final _lightGrey    = _color(0xFFF8F9FA);
  static final _borderGrey   = _color(0xFFE8EAF0);
  static final _textMuted    = _color(0xFF8E97A8);
  static final _green        = _color(0xFF1DB954);
  static final _red          = _color(0xFFE53935);
  static final _assetGreen   = _color(0xFF43A047);
  static final _insuranceBlue = _color(0xFF1565C0);
  static final _amber        = _color(0xFFF59E0B);
  static final _amberLight   = _color(0xFFFFF8E1);
  static final _groupHeader  = _color(0xFF37474F);
  static final _slateLight   = _color(0xFFB0BEC5);

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
    '\u2014': '-',
    '\u2013': '-',
    '\u2018': '\'',
    '\u2019': '\'',
    '\u201C': '"',
    '\u201D': '"',
    '\u2026': '...',
  };

  static String _n(String text) {
    var result = text;
    _diacritics.forEach((from, to) => result = result.replaceAll(from, to));
    return result;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<Uint8List> generateMonthlyReport(
      MonthlyPdfData data, PdfStrings strings) async {
    final monthLabel = strings.monthNames[data.month];
    final yearLabel  = data.year;

    final doc = pw.Document(
      title: '${strings.monthlyReport} $monthLabel $yearLabel',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => ctx.pageNumber == 1
            ? _buildFirstPageHeader(
                strings.monthlyReportHeader(monthLabel, yearLabel))
            : _buildHeader(strings.monthlyReport, '$monthLabel $yearLabel'),
        footer: (ctx) => _buildFooter(ctx, strings),
        build: (ctx) => _buildMonthlyContent(data, strings),
      ),
    );

    return doc.save();
  }

  static Future<Uint8List> generateYearlyReport(
      YearlyPdfData data, PdfStrings strings) async {
    final yearStr    = data.year.toString();
    final subtitleStr = data.isPartialYear
        ? '$yearStr ${strings.partialYear}'
        : yearStr;

    final doc = pw.Document(title: '${strings.yearlyReport} $yearStr');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (ctx) => ctx.pageNumber == 1
            ? _buildFirstPageHeader(strings.yearlyReportHeader(data.year))
            : _buildHeader(strings.yearlyReport, subtitleStr),
        footer: (ctx) => _buildFooter(ctx, strings),
        build: (ctx) => _buildYearlyContent(data, strings),
      ),
    );

    if (data.categoryMonthlyAmounts.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(40),
          header: (ctx) => _buildHeader(strings.yearlyReport, subtitleStr),
          footer: (ctx) => _buildFooter(ctx, strings),
          build: (ctx) => [
            pw.SizedBox(height: 12),
            _sectionTitle(strings.sectionSpendingByCategory),
            pw.SizedBox(height: 8),
            _buildCategoryMonthTable(data, strings),
          ],
        ),
      );
    }

    return doc.save();
  }

  // ── Monthly content ───────────────────────────────────────────────────────

  static List<pw.Widget> _buildMonthlyContent(
      MonthlyPdfData data, PdfStrings strings) {
    final hasPlanData = data.activePlanItems.isNotEmpty;

    return [
      pw.SizedBox(height: 16),
      if (hasPlanData) ...[
        _sectionTitle(strings.sectionSpendingVsIncome),
        pw.SizedBox(height: 8),
        _buildSpendingVsIncomeWidget(data.typeRatio!, false, strings),
        pw.SizedBox(height: 20),
      ],
      _sectionTitle(strings.sectionCategorySummary),
      pw.SizedBox(height: 8),
      _buildCategorySummarySection(data, strings),
      if (hasPlanData) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle(strings.sectionCashFlowSummary),
        pw.SizedBox(height: 8),
        _buildCashFlowSummarySection(data, strings),
        pw.SizedBox(height: 20),
      ],
      if (data.groupSummaries.isNotEmpty) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle(strings.sectionExpenseGroups),
        pw.SizedBox(height: 8),
        _buildGroupsSection(data, strings),
      ],
      if (data.expenses.isNotEmpty) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle(strings.sectionExpenseDetails),
        pw.SizedBox(height: 8),
        _buildExpenseTable(data.expenses, data.grandTotal, strings),
      ],
    ];
  }

  // ── Yearly content ────────────────────────────────────────────────────────

  static List<pw.Widget> _buildYearlyContent(
      YearlyPdfData data, PdfStrings strings) {
    final hasPlanData = data.activePlanItems.isNotEmpty;
    final hasOverview = data.overviewSummaries.any((s) => s.hasData);

    return [
      pw.SizedBox(height: 16),
      if (data.isPartialYear) ...[
        _buildPartialYearNote(strings),
        pw.SizedBox(height: 12),
      ],
      if (hasPlanData) ...[
        _sectionTitle(strings.sectionSpendingVsIncome),
        pw.SizedBox(height: 8),
        _buildSpendingVsIncomeWidget(data.typeRatio!, true, strings),
        pw.SizedBox(height: 20),
      ],
      _sectionTitle(strings.sectionCategorySummary),
      pw.SizedBox(height: 8),
      _buildCategoryTable(data.categoryTotals, data.grandTotal,
          strings: strings),
      if (hasPlanData) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle(strings.sectionCashFlowSummary),
        pw.SizedBox(height: 8),
        _buildYearlyCashFlowSection(data, strings),
        pw.SizedBox(height: 20),
      ],
      if (hasOverview) ...[
        pw.NewPage(),
        pw.SizedBox(height: 12),
        _sectionTitle(strings.sectionYearlyOverview),
        pw.SizedBox(height: 8),
        _buildYearlyOverviewSection(data.overviewSummaries, strings),
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

  static pw.Widget _buildFooter(pw.Context ctx, PdfStrings strings) {
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
            strings.pageOf(ctx.pageNumber, ctx.pagesCount),
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

  // ── Spending vs Income widget ─────────────────────────────────────────────

  static pw.Widget _buildSpendingVsIncomeWidget(
      FinancialTypeIncomeRatio ratio, bool isYearly, PdfStrings strings) {
    final overspend   = ratio.overspendAmount;
    final earnedLabel = isYearly ? strings.earnedThisYear : strings.earnedThisMonth;
    final periodWord  = isYearly ? strings.periodYear : strings.periodMonth;

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
              pw.Text(
                earnedLabel,
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(ratio.income),
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
                ratio.consumptionAmount, ratio.consumptionPct, _red, strings),
          if (ratio.assetAmount > 0)
            _buildTypeRatioRow(FinancialType.asset,
                ratio.assetAmount, ratio.assetPct, _assetGreen, strings),
          if (ratio.insuranceAmount > 0)
            _buildTypeRatioRow(FinancialType.insurance,
                ratio.insuranceAmount, ratio.insurancePct, _insuranceBlue,
                strings),
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
                      strings.overspendWarning(
                          periodWord,
                          CurrencyFormatter.formatForPdf(overspend)),
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

  static pw.Widget _buildTypeRatioRow(
    FinancialType type,
    double amount,
    double? pct,
    PdfColor typeColor,
    PdfStrings strings,
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
              strings.financialTypeName(type),
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
              CurrencyFormatter.formatForPdf(amount),
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

  static pw.Widget _buildCashFlowSummarySection(
      MonthlyPdfData data, PdfStrings strings) {
    double amountFn(PlanItem item) =>
        BudgetCalculator.itemMonthlyContribution(item, data.year, data.month);
    String suffixFn(PlanItem item) {
      if (item.frequency == PlanFrequency.yearly) return strings.normalized;
      if (item.frequency == PlanFrequency.oneTime) {
        return ' (${strings.monthNames[item.validFrom.month]})';
      }
      return '';
    }

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
          _buildIncomeCard(incomeItems, amountFn, suffixFn, strings),
          pw.SizedBox(height: 12),
        ],
        if (fixedCostItems.isNotEmpty)
          _buildFixedCostsCard(fixedCostItems, amountFn, suffixFn, strings),
      ],
    );
  }

  static pw.Widget _buildYearlyCashFlowSection(
      YearlyPdfData data, PdfStrings strings) {
    double amountFn(PlanItem item) =>
        BudgetCalculator.itemYearlyContribution(
            item, data.allPlanItems, data.year);
    String suffixFn(PlanItem item) {
      if (item.frequency == PlanFrequency.monthly) return strings.annualized;
      if (item.frequency == PlanFrequency.oneTime) {
        return ' (${strings.monthNames[item.validFrom.month]})';
      }
      return '';
    }

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
          _buildIncomeCard(incomeItems, amountFn, suffixFn, strings),
          pw.SizedBox(height: 12),
        ],
        if (fixedCostItems.isNotEmpty)
          _buildFixedCostsCard(fixedCostItems, amountFn, suffixFn, strings),
      ],
    );
  }

  static pw.Widget _buildIncomeCard(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn,
      PdfStrings strings) {
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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                strings.incomeHeader,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _green,
                  letterSpacing: 0.8,
                ),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(total),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _green,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
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
                    CurrencyFormatter.formatForPdf(amount),
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
      String Function(PlanItem) suffixFn,
      PdfStrings strings) {
    final grandTotal = items.fold(0.0, (s, i) => s + amountFn(i));

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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                strings.fixedCostsHeader,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _red,
                  letterSpacing: 0.8,
                ),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(grandTotal),
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _red,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          ...typeOrder
              .where((t) => byType.containsKey(t))
              .map((type) => _buildFinancialTypeGroup(
                    type, byType[type]!, amountFn, suffixFn, strings)),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialTypeGroup(
      FinancialType type,
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn,
      PdfStrings strings) {
    final typeTotal = items.fold(0.0, (s, i) => s + amountFn(i));
    final typeColor = type == FinancialType.consumption
        ? _red
        : type == FinancialType.asset
            ? _assetGreen
            : _insuranceBlue;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                strings.financialTypeName(type),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: typeColor,
                ),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(typeTotal),
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ],
          ),
        ),
        if (type == FinancialType.consumption)
          _buildConsumptionItems(items, amountFn, suffixFn, strings)
        else
          _buildFlatItems(items, amountFn, suffixFn),
      ],
    );
  }

  static pw.Widget _buildConsumptionItems(
      List<PlanItem> items,
      double Function(PlanItem) amountFn,
      String Function(PlanItem) suffixFn,
      PdfStrings strings) {
    final byCategory = <ExpenseCategory, List<PlanItem>>{};
    for (final item in items) {
      final cat = item.category ?? ExpenseCategory.other;
      byCategory.putIfAbsent(cat, () => []).add(item);
    }
    final contributions = {for (final item in items) item: amountFn(item)};

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
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, top: 3, bottom: 1),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    strings.categoryName(cat),
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    CurrencyFormatter.formatForPdf(catTotal),
                    style: pw.TextStyle(
                        fontSize: 9, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
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
                      CurrencyFormatter.formatForPdf(amount),
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
                CurrencyFormatter.formatForPdf(amount),
                style: pw.TextStyle(fontSize: 9, color: _textMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Category summary section ──────────────────────────────────────────────

  static pw.Widget _buildCategorySummarySection(
      MonthlyPdfData data, PdfStrings strings) {
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
            budgets: data.categoryBudgets, strings: strings),
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
                            strings.budgetOverBy(
                              strings.categoryName(o.category),
                              CurrencyFormatter.formatForPdf(o.overage),
                            ),
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

  static pw.Widget _buildCategoryTable(
    List<CategoryTotal> totals,
    double grandTotal, {
    Map<ExpenseCategory, double> budgets = const {},
    required PdfStrings strings,
  }) {
    if (totals.isEmpty) {
      return pw.Text(strings.noData, style: pw.TextStyle(color: _textMuted));
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
                    strings.categoryName(ct.category),
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Expanded(child: _buildBar(barFraction, catColor)),
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
                if (hasBudgets) ...[
                  pw.SizedBox(
                    width: 70,
                    child: pw.Text(
                      budget != null
                          ? CurrencyFormatter.formatForPdf(budget)
                          : '',
                      style: pw.TextStyle(fontSize: 9, color: _textMuted),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                ],
                pw.SizedBox(
                  width: 80,
                  child: pw.Text(
                    CurrencyFormatter.formatForPdf(ct.amount),
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
        pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: _borderGrey)),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  strings.total,
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (hasBudgets)
                pw.SizedBox(width: 8 + 42 + 8 + 70 + 8),
              pw.SizedBox(
                width: 80,
                child: pw.Text(
                  CurrencyFormatter.formatForPdf(grandTotal),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.right,
                ),
              ),
              if (hasBudgets)
                pw.SizedBox(width: 4 + 16),
            ],
          ),
        ),
      ],
    );
  }

  // ── Groups section ────────────────────────────────────────────────────────

  static pw.Widget _buildGroupsSection(
      MonthlyPdfData data, PdfStrings strings) {
    final sections = <pw.Widget>[];

    for (var gi = 0; gi < data.groupSummaries.length; gi++) {
      final groupName      = data.groupSummaries[gi].key;
      final allGroupExpenses = data.groupSummaries[gi].value;

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

      final monthTotal   = monthExpenses.fold(0.0, (s, e) => s + e.amount);
      final allTimeTotal = allGroupExpenses.fold(0.0, (s, e) => s + e.amount);

      if (gi > 0) sections.add(pw.SizedBox(height: 8));

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
                strings.itemsThisMonth(monthExpenses.length),
                style: pw.TextStyle(color: _slateLight, fontSize: 9),
              ),
            ],
          ),
        ),
      );

      for (var i = 0; i < monthExpenses.length; i++) {
        final e      = monthExpenses[i];
        final dayStr = e.date.day.toString().padLeft(2, '0');
        final monStr = e.date.month.toString().padLeft(2, '0');
        final note   = e.note?.isNotEmpty == true ? _n(e.note!) : '-';

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
                    '$dayStr.$monStr',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(note, style: const pw.TextStyle(fontSize: 9)),
                ),
                pw.SizedBox(
                  width: 90,
                  child: pw.Text(
                    strings.categoryName(e.category),
                    style: pw.TextStyle(fontSize: 9, color: _textMuted),
                  ),
                ),
                pw.SizedBox(
                  width: 76,
                  child: pw.Text(
                    CurrencyFormatter.formatForPdf(e.amount),
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

      if (otherExpenses.isNotEmpty) {
        for (var i = 0; i < otherExpenses.length; i++) {
          final e      = otherExpenses[i];
          final dayStr = e.date.day.toString().padLeft(2, '0');
          final monStr = e.date.month.toString().padLeft(2, '0');
          final yrStr  = e.date.year.toString();
          final note   = e.note?.isNotEmpty == true ? _n(e.note!) : '-';

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
                      '$dayStr.$monStr.$yrStr',
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
                      strings.categoryName(e.category),
                      style: pw.TextStyle(fontSize: 8, color: _textMuted),
                    ),
                  ),
                  pw.SizedBox(
                    width: 76,
                    child: pw.Text(
                      CurrencyFormatter.formatForPdf(e.amount),
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
                  strings.groupTotal,
                  style: pw.TextStyle(
                    fontSize: 9,
                    color: _textMuted,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(monthTotal),
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      sections.add(
        pw.Container(
          color: _lightGrey,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  strings.allPeriodsTotal,
                  style: pw.TextStyle(fontSize: 8, color: _textMuted),
                ),
              ),
              pw.Text(
                CurrencyFormatter.formatForPdf(allTimeTotal),
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
      List<Expense> expenses, double grandTotal, PdfStrings strings) {
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
            _tableHeader(strings.dateLabel),
            _tableHeader(strings.noteLabel),
            _tableHeader(strings.categoryLabel),
            _tableHeader(strings.amountLabel, align: pw.TextAlign.right),
          ],
        ),
        ...expenses.asMap().entries.map((entry) {
          final i    = entry.key;
          final e    = entry.value;
          final day  = e.date.day.toString().padLeft(2, '0');
          final mon  = e.date.month.toString().padLeft(2, '0');
          final note = e.note?.isNotEmpty == true ? _n(e.note!) : '-';
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : _lightGrey,
            ),
            children: [
              _tableCell('$day.$mon'),
              _tableCell(note),
              _tableCell(strings.categoryName(e.category)),
              _tableCell(
                CurrencyFormatter.formatForPdf(e.amount),
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
            _tableHeader(strings.total, align: pw.TextAlign.right),
            _tableHeader(
              CurrencyFormatter.formatForPdf(grandTotal),
              align: pw.TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }

  // ── Yearly Overview section ───────────────────────────────────────────────

  static pw.Widget _buildYearlyOverviewSection(
      List<MonthlyOverviewSummary> summaries, PdfStrings strings) {
    final rows = <pw.Widget>[
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 8, bottom: 6),
        child: pw.Row(
          children: [
            pw.Container(
              width: 8,
              height: 8,
              decoration:
                  pw.BoxDecoration(color: _assetGreen, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              strings.financialTypeName(FinancialType.asset),
              style: pw.TextStyle(fontSize: 8, color: _textMuted),
            ),
            pw.SizedBox(width: 14),
            pw.Container(
              width: 8,
              height: 8,
              decoration:
                  pw.BoxDecoration(color: _red, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              strings.financialTypeName(FinancialType.consumption),
              style: pw.TextStyle(fontSize: 8, color: _textMuted),
            ),
          ],
        ),
      ),
    ];

    for (var i = 0; i < summaries.length; i++) {
      final s         = summaries[i];
      final monthName = strings.monthAbbreviations[s.period.month];
      final diff      = s.result;
      final diffText  = diff >= 0
          ? '+${diff.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}'
          : '${diff.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}';
      final diffColor = diff >= 0 ? _green : _red;

      rows.add(
        pw.Container(
          color: i.isEven ? PdfColors.white : _lightGrey,
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
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
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (s.earned > 0) _buildOverviewBar(s),
                    pw.SizedBox(height: 4),
                    _buildOverviewNumbers(s, strings),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
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

  static pw.Widget _buildOverviewBar(MonthlyOverviewSummary s) {
    final fraction      = (s.allocated / s.earned).clamp(0.0, 1.0);
    final assetFlex     = (s.assetPct * fraction).clamp(0.0, 100.0);
    final consumFlex    = (s.consumptionPct * fraction).clamp(0.0, 100.0);
    final emptyFlex     = (100.0 - assetFlex - consumFlex).clamp(0.0, 100.0);

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
                  color: _assetGreen,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(3),
                    bottomLeft: pw.Radius.circular(3),
                  ),
                ),
              ),
            ),
          if (consumFlex > 0)
            pw.Expanded(
              flex: consumFlex.round().clamp(1, 100),
              child: pw.Container(height: 7, color: _red),
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

  static pw.Widget _buildOverviewNumbers(
      MonthlyOverviewSummary s, PdfStrings strings) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 6,
              height: 6,
              decoration:
                  pw.BoxDecoration(color: _assetGreen, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 3),
            pw.Text(
              '${s.assets.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}',
              style: pw.TextStyle(fontSize: 9, color: _assetGreen),
            ),
          ],
        ),
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
              '${s.consumption.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}',
              style: pw.TextStyle(fontSize: 9, color: _red),
            ),
          ],
        ),
        pw.Text(
          strings.earnedLabel(
              '${s.earned.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}'),
          style: pw.TextStyle(fontSize: 9, color: _textMuted),
        ),
      ],
    );
  }

  // ── Category × month cross-tab (yearly report) ────────────────────────────

  static pw.Widget _buildCategoryMonthTable(
      YearlyPdfData data, PdfStrings strings) {
    final amounts = data.categoryMonthlyAmounts;
    if (amounts.isEmpty) {
      return pw.Text(strings.noData, style: pw.TextStyle(color: _textMuted));
    }

    final activeMonths = <int>[];
    for (var m = 1; m <= 12; m++) {
      if (amounts.values.any((list) => list[m - 1] > 0)) {
        activeMonths.add(m);
      }
    }
    if (activeMonths.isEmpty) {
      return pw.Text(strings.noData, style: pw.TextStyle(color: _textMuted));
    }

    final categories = amounts.keys.toList();

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
            _tableHeader(strings.categoryLabel),
            ...activeMonths.map(
              (m) => _tableHeader(strings.monthAbbreviations[m],
                  align: pw.TextAlign.right),
            ),
            _tableHeader(strings.colTotal, align: pw.TextAlign.right),
          ],
        ),
        ...categories.asMap().entries.map((entry) {
          final i           = entry.key;
          final cat         = entry.value;
          final monthAmounts = amounts[cat]!;
          final total        = monthAmounts.fold(0.0, (s, a) => s + a);

          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: i.isEven ? PdfColors.white : _lightGrey,
            ),
            children: [
              _tableCell(strings.categoryName(cat)),
              ...activeMonths.map((m) {
                final v = monthAmounts[m - 1];
                return _tableCell(
                  v > 0 ? v.toStringAsFixed(0) : '-',
                  align: pw.TextAlign.right,
                );
              }),
              _tableCellBold(
                '${total.toStringAsFixed(0)} ${CurrencyFormatter.currencyCode}',
                align: pw.TextAlign.right,
              ),
            ],
          );
        }),
      ],
    );
  }

  // ── Partial year note ─────────────────────────────────────────────────────

  static pw.Widget _buildPartialYearNote(PdfStrings strings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: _color(0xFFFFF8E1),
        border: pw.Border.all(color: _gold, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        strings.partialYearNote,
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
    final empty  = 100.0 - filled;

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
