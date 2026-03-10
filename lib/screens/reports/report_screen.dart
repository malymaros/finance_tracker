import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/category_total.dart';
import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/financial_type_breakdown.dart';
import '../../models/monthly_summary.dart';
import '../../models/period_bounds.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/finance_repository.dart';
import '../../services/plan_repository.dart';
import '../../services/report_aggregator.dart';
import '../../widgets/period_navigator.dart';

enum _ReportMode { monthly, yearly, overview }

class ReportScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final ValueNotifier<YearMonth> selectedPeriod;
  final ValueNotifier<PeriodBounds> periodBounds;

  /// Called when the user taps an overview row to navigate to the Plan tab.
  final VoidCallback onNavigateToPlan;
  final VoidCallback onClearAll;

  const ReportScreen({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.selectedPeriod,
    required this.periodBounds,
    required this.onNavigateToPlan,
    required this.onClearAll,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  static const _pieChartThresholdPct = 10.0;

  _ReportMode _mode = _ReportMode.monthly;

  int get _year => widget.selectedPeriod.value.year;
  int get _month => widget.selectedPeriod.value.month;

  static const _monthAbbr = [
    '',
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    widget.selectedPeriod.addListener(_onPeriodChanged);
  }

  @override
  void dispose() {
    widget.selectedPeriod.removeListener(_onPeriodChanged);
    super.dispose();
  }

  void _onPeriodChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') widget.onClearAll();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'clear_all',
                child: Text('Delete all data'),
              ),
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
              const Divider(height: 1),
              Expanded(child: _buildContent()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
        onSelectionChanged: (s) => setState(() => _mode = s.first),
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
        final listTotals = ReportAggregator.categoryTotals(lines);
        final chartTotals = ReportAggregator.applyThreshold(
            listTotals, _pieChartThresholdPct);
        final breakdown = ReportAggregator.financialTypeBreakdown(lines);
        return listTotals.isEmpty
            ? _buildEmptyState()
            : _buildChartAndList(chartTotals, listTotals, breakdown);

      case _ReportMode.yearly:
        final lines = ReportAggregator.mergedLines(
          widget.repository.reportLinesForYear(_year),
          BudgetCalculator.planFixedCostReportLinesForYear(
              widget.planRepository.items, _year),
        );
        final listTotals = ReportAggregator.categoryTotals(lines);
        final chartTotals = ReportAggregator.applyThreshold(
            listTotals, _pieChartThresholdPct);
        final breakdown = ReportAggregator.financialTypeBreakdown(lines);
        return listTotals.isEmpty
            ? _buildEmptyState()
            : _buildChartAndList(chartTotals, listTotals, breakdown);

      case _ReportMode.overview:
        return _buildOverview();
    }
  }

  Widget _buildOverview() {
    final summaries = BudgetCalculator.monthlySummaries(
      widget.planRepository.items,
      widget.repository.expenses,
      _year,
    );
    final hasAnyData =
        summaries.any((s) => s.spendableBudget != 0 || s.actualExpenses != 0);

    if (!hasAnyData) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No plan or expenses for this year.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 12,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => _buildOverviewRow(summaries[i]),
    );
  }

  Widget _buildOverviewRow(MonthlySummary s) {
    final diff = s.difference;
    final hasData = s.spendableBudget != 0 || s.actualExpenses != 0;
    final diffColor = diff >= 0 ? Colors.green : Colors.red;
    final diffText = diff >= 0
        ? '+${diff.toStringAsFixed(0)} €'
        : '${diff.toStringAsFixed(0)} €';

    return InkWell(
      onTap: () {
        widget.selectedPeriod.value = YearMonth(_year, s.period.month);
        widget.onNavigateToPlan();
      },
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              _monthAbbr[s.period.month],
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.spendableBudget > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (s.actualExpenses / s.spendableBudget)
                          .clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        s.actualExpenses > s.spendableBudget
                            ? Colors.red
                            : Colors.teal,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: ${s.spendableBudget.toStringAsFixed(0)} €',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'Spent: ${s.actualExpenses.toStringAsFixed(0)} €',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (hasData)
            Text(
              diffText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: diffColor,
              ),
            )
          else
            const Text('—',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    ));
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No expenses for this period.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
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

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: chartTotals
                    .map((ct) => PieChartSectionData(
                          value: ct.amount,
                          color: ct.category.color,
                          title: '${ct.percentage.toStringAsFixed(0)}%',
                          radius: 80,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ))
                    .toList(),
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          ...listTotals.map((ct) => _buildCategoryRow(ct)),
          const Divider(height: 1),
          _buildTotalRow(grandTotal),
          const Divider(height: 1),
          _buildTypeBreakdown(breakdown),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(CategoryTotal ct) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ct.category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(ct.category.icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(ct.category.displayName,
                style: const TextStyle(fontSize: 15)),
          ),
          Text(
            '${ct.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(width: 12),
          Text(
            '${ct.amount.toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
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
              color: Colors.grey,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
    );
  }
}
