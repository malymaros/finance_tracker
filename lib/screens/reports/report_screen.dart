import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/category_total.dart';
import '../../models/expense_category.dart';
import '../../models/financial_type_income_ratio.dart';
import '../../models/report_data.dart';
import '../../models/report_line.dart';
import '../../models/monthly_pdf_data.dart';
import '../../models/period_bounds.dart';
import '../../models/year_month.dart';
import '../../models/yearly_pdf_data.dart';
import '../../l10n/l10n.dart';
import '../../services/budget_calculator.dart';
import '../../services/category_budget_repository.dart';
import '../../services/currency_formatter.dart';
import '../../services/finance_repository.dart';
import '../../services/pdf_report_service.dart';
import '../../services/pdf_strings.dart';
import '../../services/plan_repository.dart';
import '../../services/report_aggregator.dart';
import '../../services/share_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/how_it_works_sheet.dart';
import '../../widgets/overview_month_row.dart';
import '../../widgets/period_navigator.dart';
import '../../widgets/report_category_row.dart';
import 'category_report_detail_screen.dart';

enum _ReportMode { monthly, yearly, overview }

class _ReportCache {
  final int year;
  final int month;
  final _ReportMode mode;
  final ReportData data;

  const _ReportCache({
    required this.year,
    required this.month,
    required this.mode,
    required this.data,
  });

  bool matches(int year, int month, _ReportMode mode) =>
      this.year == year && this.month == month && this.mode == mode;
}

class ReportScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final CategoryBudgetRepository budgetRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;

  /// Called when the user taps an overview row to navigate to the Plan tab.
  final VoidCallback onNavigateToPlan;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;

  const ReportScreen({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.budgetRepository,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onNavigateToPlan,
    required this.onClearAll,
    required this.onOpenSaves,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _pieChartThresholdPct = 5.0;

  _ReportMode _mode = _ReportMode.monthly;
  bool _isGeneratingPdf = false;
  _ReportCache? _reportCache;

  ExpenseCategory? _selectedCategory;
  bool _otherExpanded = false;
  late final ScrollController _scrollController;

  // One stable GlobalKey per category — assigned to each ReportCategoryRow so
  // Scrollable.ensureVisible can locate the highlighted row after a pie tap.
  final _categoryRowKeys = <ExpenseCategory, GlobalKey>{
    for (final cat in ExpenseCategory.values) cat: GlobalKey(),
  };

  int get _year => widget.selectedPeriod.value.year;
  int get _month => widget.selectedPeriod.value.month;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.selectedPeriod.addListener(_onPeriodChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    widget.selectedPeriod.removeListener(_onPeriodChanged);
    super.dispose();
  }

  void _onPeriodChanged() => setState(() {
        _selectedCategory = null;
        _otherExpanded = false;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reportsTitle),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.save_outlined),
          tooltip: context.l10n.savesTooltip,
          onPressed: widget.onOpenSaves,
        ),
        actions: [
          if (_mode != _ReportMode.overview)
            if (_isGeneratingPdf)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                tooltip: context.l10n.exportPdf,
                onPressed: _onExportPdf,
              ),
        ],
      ),
      body: ListenableBuilder(
        listenable:
            Listenable.merge([widget.repository, widget.planRepository]),
        builder: (context, _) {
          // Invalidate cache on any repository change (e.g. clearAll).
          _reportCache = null;
          return Column(
            children: [
              _buildPeriodNavigator(),
              _buildModeToggle(),
              Expanded(child: _buildContent()),
            ],
          );
        },
      ),
    );
  }

  // ── ReportData cache ──────────────────────────────────────────────────────

  /// Returns cached [ReportData] for the current (year, month, mode), or
  /// computes and caches it if the cache is stale.
  ///
  /// Overview mode uses yearly lines (same as yearly mode) since overview
  /// does not render a chart but the PDF export still needs the yearly data.
  ReportData _getOrBuildReportData() {
    if (_reportCache != null && _reportCache!.matches(_year, _month, _mode)) {
      return _reportCache!.data;
    }
    final List<ReportLine> lines;
    if (_mode == _ReportMode.monthly) {
      lines = ReportAggregator.mergedLines(
        widget.repository.reportLinesForMonth(_year, _month),
        BudgetCalculator.planFixedCostReportLinesForMonth(
            widget.planRepository.items, _year, _month),
      );
    } else {
      lines = ReportAggregator.mergedLines(
        widget.repository.reportLinesForYear(_year),
        BudgetCalculator.planFixedCostReportLinesForYear(
            widget.planRepository.items, _year),
      );
    }
    final data = ReportAggregator.buildReportData(lines, _pieChartThresholdPct);
    _reportCache = _ReportCache(year: _year, month: _month, mode: _mode, data: data);
    return data;
  }

  // ── PDF export ────────────────────────────────────────────────────────────

  Future<void> _onExportPdf() async {
    if (_isGeneratingPdf) return;
    setState(() => _isGeneratingPdf = true);
    try {
      switch (_mode) {
        case _ReportMode.monthly:
          await _exportMonthlyPdf();
        case _ReportMode.yearly:
          await _exportYearlyPdf();
        case _ReportMode.overview:
          await _exportYearlyPdf();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportFailed(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _exportMonthlyPdf() async {
    final data = _getOrBuildReportData();
    final monthExpenses = widget.repository.expensesForMonth(_year, _month);
    final budgetStatus = BudgetCalculator.budgetStatus(
      widget.planRepository.items,
      monthExpenses.fold(0.0, (s, e) => s + e.amount),
      _year,
      _month,
    );
    final groupSummaries =
        widget.repository.groupSummariesForMonth(_year, _month);
    final expenses = List.of(monthExpenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final activePlanItems = BudgetCalculator.activeItemsForMonth(
      widget.planRepository.items, _year, _month);
    final categoryBudgets =
        widget.budgetRepository.allActiveBudgetsForMonth(YearMonth(_year, _month));

    FinancialTypeIncomeRatio? typeRatio;
    if (activePlanItems.isNotEmpty) {
      final mergedLines = ReportAggregator.mergedLines(
        widget.repository.reportLinesForMonth(_year, _month),
        BudgetCalculator.planFixedCostReportLinesForMonth(
            widget.planRepository.items, _year, _month),
      );
      final income = BudgetCalculator.normalizedMonthlyIncome(
          widget.planRepository.items, _year, _month);
      typeRatio = BudgetCalculator.financialTypeIncomeRatios(mergedLines, income);
    }

    final pdfData = MonthlyPdfData(
      year: _year,
      month: _month,
      categoryTotals: data.listTotals,
      grandTotal: data.grandTotal,
      budgetStatus: budgetStatus,
      groupSummaries: groupSummaries,
      expenses: expenses,
      activePlanItems: activePlanItems,
      categoryBudgets: categoryBudgets,
      typeRatio: typeRatio,
    );

    final strings = PdfStrings.fromL10n(context.l10n);
    final bytes = await PdfReportService.generateMonthlyReport(pdfData, strings);
    final filename =
        'finance_${YearMonth.monthNames[_month].toLowerCase()}_$_year.pdf';
    await ShareService.sharePdf(bytes, filename);
  }

  Future<void> _exportYearlyPdf() async {
    final data = _getOrBuildReportData();
    final allExpenses = widget.repository.expensesForYear(_year);
    final summaries = BudgetCalculator.monthlySummaries(
      widget.planRepository.items,
      allExpenses,
      _year,
    );
    final now = DateTime.now();
    final isPartialYear = _year == now.year;
    final categoryMonthlyAmounts = _buildCategoryMonthlyAmounts();
    final activePlanItems =
        BudgetCalculator.activeItemsForYear(widget.planRepository.items, _year);
    final overviewSummaries = BudgetCalculator.monthlyOverviewSummaries(
      widget.planRepository.items,
      allExpenses,
      _year,
    );

    FinancialTypeIncomeRatio? typeRatio;
    if (activePlanItems.isNotEmpty) {
      final mergedLines = ReportAggregator.mergedLines(
        widget.repository.reportLinesForYear(_year),
        BudgetCalculator.planFixedCostReportLinesForYear(
            widget.planRepository.items, _year),
      );
      final income =
          BudgetCalculator.yearlyIncome(widget.planRepository.items, _year);
      typeRatio = BudgetCalculator.financialTypeIncomeRatios(mergedLines, income);
    }

    final pdfData = YearlyPdfData(
      year: _year,
      categoryTotals: data.listTotals,
      grandTotal: data.grandTotal,
      monthlySummaries: summaries,
      isPartialYear: isPartialYear,
      categoryMonthlyAmounts: categoryMonthlyAmounts,
      typeRatio: typeRatio,
      activePlanItems: activePlanItems,
      allPlanItems: widget.planRepository.items,
      overviewSummaries: overviewSummaries,
    );

    final strings = PdfStrings.fromL10n(context.l10n);
    final bytes = await PdfReportService.generateYearlyReport(pdfData, strings);
    final filename = 'finance_yearly_$_year.pdf';
    await ShareService.sharePdf(bytes, filename);
  }

  /// Builds a per-category list of 12 monthly expense amounts for the current
  /// year. Index 0 = January, 11 = December. Fixed-cost plan lines are
  /// included alongside actual expenses.
  Map<ExpenseCategory, List<double>> _buildCategoryMonthlyAmounts() {
    final result = <ExpenseCategory, List<double>>{};

    for (var month = 1; month <= 12; month++) {
      final lines = ReportAggregator.mergedLines(
        widget.repository.reportLinesForMonth(_year, month),
        BudgetCalculator.planFixedCostReportLinesForMonth(
            widget.planRepository.items, _year, month),
      );
      for (final line in lines) {
        result.putIfAbsent(line.category, () => List.filled(12, 0.0));
        result[line.category]![month - 1] += line.amount;
      }
    }

    // Sort by annual total descending.
    final sorted = result.entries.toList()
      ..sort((a, b) {
        final ta = a.value.fold(0.0, (s, v) => s + v);
        final tb = b.value.fold(0.0, (s, v) => s + v);
        return tb.compareTo(ta);
      });

    return Map.fromEntries(sorted);
  }

  // ── Mode toggle ───────────────────────────────────────────────────────────

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SegmentedButton<_ReportMode>(
        segments: [
          ButtonSegment(
            value: _ReportMode.monthly,
            label: Text(context.l10n.reportModeMonthly),
            icon: const Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: _ReportMode.yearly,
            label: Text(context.l10n.reportModeYearly),
            icon: const Icon(Icons.calendar_today),
          ),
          ButtonSegment(
            value: _ReportMode.overview,
            label: Text(context.l10n.reportModeOverview),
            icon: const Icon(Icons.table_rows_outlined),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() {
          _mode = s.first;
          _selectedCategory = null;
          _otherExpanded = false;
        }),
      ),
    );
  }

  Widget _buildPeriodNavigator() {
    final yearOnly = _mode != _ReportMode.monthly;
    final bounds = widget.periodBounds.value;
    return Stack(
      alignment: Alignment.center,
      children: [
        PeriodNavigator(
          selected: widget.selectedPeriod.value,
          yearOnly: yearOnly,
          min: bounds.min,
          max: bounds.max,
          onChanged: (ym) => setState(() {
            widget.selectedPeriod.value = ym;
          }),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: context.l10n.howItWorksTooltip,
              onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexReports),
              style: IconButton.styleFrom(foregroundColor: AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _ReportMode.monthly:
      case _ReportMode.yearly:
        final reportData = _getOrBuildReportData();
        return reportData.chartTotals.isEmpty
            ? _buildEmptyState()
            : _buildChartAndList(reportData);

      case _ReportMode.overview:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    final summaries = BudgetCalculator.monthlyOverviewSummaries(
      widget.planRepository.items,
      widget.repository.expensesForYear(_year),
      _year,
    );
    final hasAnyData = summaries.any((s) => s.hasData);

    if (!hasAnyData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.table_rows_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              context.l10n.noIncomeOrSpendingDataForYear,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 12,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => OverviewMonthRow(
        summary: summaries[i],
        onTap: () {
          widget.selectedPeriod.value = YearMonth(_year, summaries[i].period.month);
          widget.onNavigateToPlan();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.pie_chart_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            context.l10n.noExpensesForPeriod,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => HowItWorksSheet.show(context, initialPage: HowItWorksSheet.pageIndexReports),
            icon: const Icon(Icons.help_outline, size: 16),
            label: Text(context.l10n.howItWorksQuestion),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndList(ReportData reportData) {
    final chartTotals = reportData.chartTotals;
    final otherSubcategories = reportData.otherSubcategories;
    final grandTotal = reportData.grandTotal;

    // "Other categories" bucket is present when sub-categories were collapsed.
    final hasOtherGroup = otherSubcategories.isNotEmpty;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
                    if (!event.isInterestedForInteractions) return;
                    final index =
                        response?.touchedSection?.touchedSectionIndex;
                    if (index == null ||
                        index < 0 ||
                        index >= chartTotals.length) {
                      return;
                    }
                    final tapped = chartTotals[index].category;
                    setState(() => _selectedCategory = tapped);
                    _scrollToCategory(tapped);
                  },
                ),
                sections: chartTotals.map((ct) {
                  final isSelected = ct.category == _selectedCategory;
                  final isAggOther =
                      ct.category == ExpenseCategory.other && hasOtherGroup;
                  return PieChartSectionData(
                    value: ct.amount,
                    color: isAggOther ? Colors.white : ct.category.color,
                    borderSide: isAggOther
                        ? const BorderSide(color: Colors.black, width: 2)
                        : BorderSide.none,
                    title: '${ct.percentage.toStringAsFixed(0)}%',
                    radius: isSelected ? 98.0 : 90.0,
                    titleStyle: TextStyle(
                      color: isAggOther ? Colors.black87 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._buildCategoryRows(chartTotals, otherSubcategories, hasOtherGroup),
          const Divider(height: 1),
          _buildTotalRow(grandTotal),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds the flat list of category rows, expanding the "Other categories"
  /// bucket inline when [_otherExpanded] is true.
  List<Widget> _buildCategoryRows(
    List<CategoryTotal> chartTotals,
    List<CategoryTotal> otherSubcategories,
    bool hasOtherGroup,
  ) {
    final rows = <Widget>[];
    for (final ct in chartTotals) {
      final isOtherRow =
          ct.category == ExpenseCategory.other && hasOtherGroup;
      rows.add(ReportCategoryRow(
        key: _categoryRowKeys[ct.category],
        ct: ct,
        isSelected: _selectedCategory == ct.category,
        isInteractive: true,
        isOther: isOtherRow,
        isExpanded: isOtherRow && _otherExpanded,
        onTap: isOtherRow
            ? () => setState(() => _otherExpanded = !_otherExpanded)
            : () => _navigateToCategoryDetail(ct.category),
      ));
      if (isOtherRow && _otherExpanded) {
        for (final sub in otherSubcategories) {
          rows.add(ReportCategoryRow(
            ct: sub,
            isSelected: false,
            isInteractive: true,
            onTap: () => _navigateToCategoryDetail(sub.category),
          ));
        }
      }
    }
    return rows;
  }

  void _scrollToCategory(ExpenseCategory category) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _categoryRowKeys[category]?.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    });
  }

  void _navigateToCategoryDetail(ExpenseCategory category) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CategoryReportDetailScreen(
        category: category,
        year: _year,
        month: _mode == _ReportMode.monthly ? _month : null,
        repository: widget.repository,
        planRepository: widget.planRepository,
      ),
    ));
  }

  Widget _buildTotalRow(double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Text(
            CurrencyFormatter.format(total),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

}
