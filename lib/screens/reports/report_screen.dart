import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../models/category_total.dart';
import '../../models/expense_category.dart';
import '../../services/finance_repository.dart';
import '../../services/report_aggregator.dart';

class ReportScreen extends StatefulWidget {
  final FinanceRepository repository;

  const ReportScreen({super.key, required this.repository});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isMonthly = true;
  late int _year;
  late int _month;

  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _categoryColors = {
    'Food': Color(0xFFEF5350),
    'Transport': Color(0xFF42A5F5),
    'Shopping': Color(0xFFAB47BC),
    'Health': Color(0xFF26A69A),
    'Other': Color(0xFFFFCA28),
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
  }

  Color _colorFor(String category) =>
      _categoryColors[category] ?? Colors.blueGrey;

  void _previousPeriod() {
    setState(() {
      if (_isMonthly) {
        if (_month == 1) {
          _month = 12;
          _year--;
        } else {
          _month--;
        }
      } else {
        _year--;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_isMonthly) {
        if (_month == 12) {
          _month = 1;
          _year++;
        } else {
          _month++;
        }
      } else {
        _year++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListenableBuilder(
        listenable: widget.repository,
        builder: (context, _) {
          final expenses = _isMonthly
              ? widget.repository.expensesForMonth(_year, _month)
              : widget.repository.expensesForYear(_year);
          final totals = ReportAggregator.categoryTotals(expenses);

          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              const Divider(height: 1),
              Expanded(
                child: totals.isEmpty
                    ? _buildEmptyState()
                    : _buildChartAndList(totals),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(
            value: true,
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: false,
            label: Text('Yearly'),
            icon: Icon(Icons.calendar_today),
          ),
        ],
        selected: {_isMonthly},
        onSelectionChanged: (s) => setState(() => _isMonthly = s.first),
      ),
    );
  }

  Widget _buildPeriodNavigator() {
    final label = _isMonthly ? '${_monthNames[_month]} $_year' : '$_year';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousPeriod,
          ),
          SizedBox(
            width: 180,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextPeriod,
          ),
        ],
      ),
    );
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

  Widget _buildChartAndList(List<CategoryTotal> totals) {
    final grandTotal = totals.fold(0.0, (sum, ct) => sum + ct.amount);

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: totals
                    .map((ct) => PieChartSectionData(
                          value: ct.amount,
                          color: _colorFor(ct.category),
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
          ...totals.map((ct) => _buildCategoryRow(ct)),
          const Divider(height: 1),
          _buildTotalRow(grandTotal),
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
              color: _colorFor(ct.category),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Icon(categoryIcon(ct.category), size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(ct.category, style: const TextStyle(fontSize: 15)),
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
}
