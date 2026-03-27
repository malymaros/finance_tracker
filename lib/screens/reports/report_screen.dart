import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/category_total.dart';
import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/financial_type_breakdown.dart';
import '../../models/monthly_pdf_data.dart';
import '../../models/period_bounds.dart';
import '../../models/year_month.dart';
import '../../models/yearly_pdf_data.dart';
import '../../services/budget_calculator.dart';
import '../../services/finance_repository.dart';
import '../../services/pdf_report_service.dart';
import '../../services/plan_repository.dart';
import '../../services/report_aggregator.dart';
import '../../services/share_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/overview_month_row.dart';
import '../../widgets/period_navigator.dart';
import '../../widgets/report_category_row.dart';
import 'category_report_detail_screen.dart';

enum _ReportMode { monthly, yearly, overview }

class ReportScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;

  /// Called when the user taps an overview row to navigate to the Plan tab.
  final VoidCallback onNavigateToPlan;
  final VoidCallback onClearAll;
  final VoidCallback onOpenSaves;
  final VoidCallback? onResetWithSeedData;

  const ReportScreen({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onNavigateToPlan,
    required this.onClearAll,
    required this.onOpenSaves,
    this.onResetWithSeedData,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _pieChartThresholdPct = 5.0;

  _ReportMode _mode = _ReportMode.monthly;
  bool _isGeneratingPdf = false;

  ExpenseCategory? _selectedCategory;
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
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
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
                tooltip: 'Export PDF',
                onPressed: _onExportPdf,
              ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'saves') widget.onOpenSaves();
              if (value == 'reset_seed') widget.onResetWithSeedData?.call();
              if (value == 'clear_all') widget.onClearAll();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'saves', child: Text('Saves')),
              if (widget.onResetWithSeedData != null)
                const PopupMenuItem(
                    value: 'reset_seed', child: Text('Reset with dummy data')),
              const PopupMenuItem(
                  value: 'clear_all', child: Text('Delete all data')),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable:
            Listenable.merge([widget.repository, widget.planRepository]),
        builder: (context, _) {
          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              Expanded(child: _buildContent()),
            ],
          );
        },
      ),
    );
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
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _exportMonthlyPdf() async {
    final lines = ReportAggregator.mergedLines(
      widget.repository.reportLinesForMonth(_year, _month),
      BudgetCalculator.planFixedCostReportLinesForMonth(
          widget.planRepository.items, _year, _month),
    );
    final data = ReportAggregator.buildReportData(lines, _pieChartThresholdPct);
    final budgetStatus = BudgetCalculator.budgetStatus(
      widget.planRepository.items,
      widget.repository
          .expensesForMonth(_year, _month)
          .fold(0.0, (s, e) => s + e.amount),
      _year,
      _month,
    );
    final groupSummaries =
        widget.repository.groupSummariesForMonth(_year, _month);
    final expenses = widget.repository.expensesForMonth(_year, _month)
      ..sort((a, b) => b.date.compareTo(a.date));

    final pdfData = MonthlyPdfData(
      year: _year,
      month: _month,
      categoryTotals: data.listTotals,
      breakdown: data.breakdown,
      grandTotal: data.grandTotal,
      budgetStatus: budgetStatus,
      groupSummaries: groupSummaries,
      expenses: expenses,
    );

    final bytes = await PdfReportService.generateMonthlyReport(pdfData);
    final filename =
        'finance_${YearMonth.monthNames[_month].toLowerCase()}_$_year.pdf';
    await ShareService.sharePdf(bytes, filename);
  }

  Future<void> _exportYearlyPdf() async {
    final lines = ReportAggregator.mergedLines(
      widget.repository.reportLinesForYear(_year),
      BudgetCalculator.planFixedCostReportLinesForYear(
          widget.planRepository.items, _year),
    );
    final data = ReportAggregator.buildReportData(lines, _pieChartThresholdPct);
    final summaries = BudgetCalculator.monthlySummaries(
      widget.planRepository.items,
      widget.repository.expenses,
      _year,
    );
    final now = DateTime.now();
    final isPartialYear = _year == now.year;
    final categoryMonthlyAmounts = _buildCategoryMonthlyAmounts();

    final pdfData = YearlyPdfData(
      year: _year,
      categoryTotals: data.listTotals,
      breakdown: data.breakdown,
      grandTotal: data.grandTotal,
      monthlySummaries: summaries,
      isPartialYear: isPartialYear,
      categoryMonthlyAmounts: categoryMonthlyAmounts,
    );

    final bytes = await PdfReportService.generateYearlyReport(pdfData);
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
        segments: const [
          ButtonSegment(
            value: _ReportMode.monthly,
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: _ReportMode.yearly,
            label: Text('Yearly'),
            icon: Icon(Icons.calendar_today),
          ),
          ButtonSegment(
            value: _ReportMode.overview,
            label: Text('Overview'),
            icon: Icon(Icons.table_rows_outlined),
          ),
        ],
        selected: {_mode},
        onSelectionChanged: (s) => setState(() {
          _mode = s.first;
          _selectedCategory = null;
        }),
      ),
    );
  }

  Widget _buildPeriodNavigator() {
    final yearOnly = _mode != _ReportMode.monthly;
    final bounds = widget.periodBounds.value;
    return PeriodNavigator(
      selected: widget.selectedPeriod.value,
      yearOnly: yearOnly,
      min: bounds.min,
      max: bounds.max,
      onChanged: (ym) => setState(() {
        widget.selectedPeriod.value = ym;
      }),
    );
  }

  Widget _buildContent() {
    switch (_mode) {
      case _ReportMode.monthly:
        final lines = ReportAggregator.mergedLines(
          widget.repository.reportLinesForMonth(_year, _month),
          BudgetCalculator.planFixedCostReportLinesForMonth(
              widget.planRepository.items, _year, _month),
        );
        final reportData =
            ReportAggregator.buildReportData(lines, _pieChartThresholdPct);
        return reportData.listTotals.isEmpty
            ? _buildEmptyState()
            : _buildChartAndList(
                reportData.chartTotals,
                reportData.listTotals,
                reportData.breakdown,
              );

      case _ReportMode.yearly:
        final lines = ReportAggregator.mergedLines(
          widget.repository.reportLinesForYear(_year),
          BudgetCalculator.planFixedCostReportLinesForYear(
              widget.planRepository.items, _year),
        );
        final reportData =
            ReportAggregator.buildReportData(lines, _pieChartThresholdPct);
        return reportData.listTotals.isEmpty
            ? _buildEmptyState()
            : _buildChartAndList(
                reportData.chartTotals,
                reportData.listTotals,
                reportData.breakdown,
              );

      case _ReportMode.overview:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    final summaries = BudgetCalculator.monthlyOverviewSummaries(
      widget.planRepository.items,
      widget.repository.expenses,
      _year,
    );
    final hasAnyData = summaries.any((s) => s.hasData);

    if (!hasAnyData) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_outlined, size: 64, color: AppColors.textMuted),
            SizedBox(height: 16),
            Text(
              'No income or spending data for this year.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart_outline, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No expenses for this period.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAndList(
      List<CategoryTotal> chartTotals,
      List<CategoryTotal> listTotals,
      FinancialTypeBreakdown breakdown) {
    final grandTotal = listTotals.fold(0.0, (sum, ct) => sum + ct.amount);

    // True when applyThreshold has collapsed small categories into one bucket.
    // In that case the "Other" pie slice is an aggregate and is not interactive.
    final hasAggregatedOther = chartTotals.length < listTotals.length;

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
                    if (tapped == ExpenseCategory.other && hasAggregatedOther) {
                      return;
                    }
                    setState(() => _selectedCategory = tapped);
                    _scrollToCategory(tapped);
                  },
                ),
                sections: chartTotals.map((ct) {
                  final isAggOther = ct.category == ExpenseCategory.other &&
                      hasAggregatedOther;
                  final isSelected = ct.category == _selectedCategory;
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
          ...listTotals.map((ct) => ReportCategoryRow(
            key: _categoryRowKeys[ct.category],
            ct: ct,
            isSelected: _selectedCategory == ct.category,
            isInteractive: true,
            onTap: () => _navigateToCategoryDetail(ct.category),
          )),
          const Divider(height: 1),
          _buildTotalRow(grandTotal),
          _buildTypeBreakdown(breakdown),
          const SizedBox(height: 16),
        ],
      ),
    );
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
            '${total.toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBreakdown(FinancialTypeBreakdown breakdown) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BY FINANCIAL TYPE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _buildTypeRow(FinancialType.asset, breakdown.assetPct),
          _buildTypeRow(FinancialType.consumption, breakdown.consumptionPct),
          _buildTypeRow(FinancialType.insurance, breakdown.insurancePct),
        ],
      ),
    );
  }

  Widget _buildTypeRow(FinancialType type, double pct) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(type.icon, size: 16, color: type.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(type.displayName,
                    style: const TextStyle(fontSize: 14)),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: type.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  type.color.withAlpha(160)),
            ),
          ),
        ],
      ),
    );
  }
}
