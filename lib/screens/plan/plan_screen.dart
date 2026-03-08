import 'package:flutter/material.dart';

import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/budget_calculator.dart';
import '../../services/plan_repository.dart';
import '../../widgets/plan_item_tile.dart';
import 'add_plan_item_screen.dart';

class PlanScreen extends StatefulWidget {
  final PlanRepository planRepository;

  /// When non-null, the screen listens for requested navigation to a specific
  /// month (set by MainScreen when the user taps an Overview row).
  final ValueNotifier<YearMonth?>? requestedPeriod;

  const PlanScreen({
    super.key,
    required this.planRepository,
    this.requestedPeriod,
  });

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  bool _isMonthly = true;
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _year = now.year;
    _month = now.month;
    widget.requestedPeriod?.addListener(_onRequestedPeriod);
  }

  @override
  void dispose() {
    widget.requestedPeriod?.removeListener(_onRequestedPeriod);
    super.dispose();
  }

  void _onRequestedPeriod() {
    final ym = widget.requestedPeriod!.value;
    if (ym == null) return;
    setState(() {
      _isMonthly = true;
      _year = ym.year;
      _month = ym.month;
    });
    widget.requestedPeriod!.value = null; // consume
  }

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

  double _displayAmount(PlanItem item) {
    final all = widget.planRepository.items;
    return _isMonthly
        ? BudgetCalculator.itemMonthlyContribution(item, _year, _month)
        : BudgetCalculator.itemYearlyContribution(item, all, _year);
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          AddPlanItemScreen(planRepository: widget.planRepository),
    ));
  }

  void _navigateToEdit(BuildContext context, PlanItem item) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: widget.planRepository,
        existing: item,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: ListenableBuilder(
        listenable: widget.planRepository,
        builder: (context, _) {
          final all = widget.planRepository.items;

          final List<PlanItem> displayItems;
          final double totalIncome;
          final double totalFixedCosts;

          if (_isMonthly) {
            displayItems =
                BudgetCalculator.activeItemsForMonth(all, _year, _month);
            totalIncome =
                BudgetCalculator.normalizedMonthlyIncome(all, _year, _month);
            totalFixedCosts =
                BudgetCalculator.normalizedMonthlyFixedCosts(all, _year, _month);
          } else {
            displayItems = BudgetCalculator.activeItemsForYear(all, _year);
            totalIncome = BudgetCalculator.yearlyIncome(all, _year);
            totalFixedCosts = BudgetCalculator.yearlyFixedCosts(all, _year);
          }

          final incomeItems = displayItems
              .where((i) => i.type == PlanItemType.income)
              .toList();
          final fixedCostItems = displayItems
              .where((i) => i.type == PlanItemType.fixedCost)
              .toList();

          return Column(
            children: [
              _buildModeToggle(),
              _buildPeriodNavigator(),
              _buildSummaryCard(totalIncome, totalFixedCosts),
              const Divider(height: 1),
              Expanded(
                child: displayItems.isEmpty
                    ? _buildEmptyState()
                    : _buildItemList(
                        context, incomeItems, fixedCostItems),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAdd(context),
        tooltip: 'Add Plan Item',
        child: const Icon(Icons.add),
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
    final label =
        _isMonthly ? '${_monthNames[_month]} $_year' : '$_year';
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
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildSummaryCard(double totalIncome, double totalFixedCosts) {
    final spendable = totalIncome - totalFixedCosts;
    final isPositive = spendable >= 0;
    final periodLabel = _isMonthly ? 'this month' : 'this year';

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spendable $periodLabel',
                    style:
                        const TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  '${isPositive ? '+' : ''}${spendable.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _SummaryLine(
                    label: 'Income',
                    amount: totalIncome,
                    color: Colors.green,
                    align: CrossAxisAlignment.start,
                  ),
                ),
                Expanded(
                  child: _SummaryLine(
                    label: 'Fixed costs',
                    amount: totalFixedCosts,
                    color: Colors.red,
                    align: CrossAxisAlignment.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No plan items yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap + to add income or fixed costs.',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    List<PlanItem> incomeItems,
    List<PlanItem> fixedCostItems,
  ) {
    return ListView(
      children: [
        if (incomeItems.isNotEmpty) ...[
          const _SectionHeader(title: 'Income'),
          ...incomeItems.map((item) => PlanItemTile(
                item: item,
                displayAmount: _displayAmount(item),
                onDelete: () =>
                    widget.planRepository.removePlanItem(item.id),
                onEdit: () => _navigateToEdit(context, item),
              )),
        ],
        if (fixedCostItems.isNotEmpty) ...[
          const _SectionHeader(title: 'Fixed Costs'),
          ...fixedCostItems.map((item) => PlanItemTile(
                item: item,
                displayAmount: _displayAmount(item),
                onDelete: () =>
                    widget.planRepository.removePlanItem(item.id),
                onEdit: () => _navigateToEdit(context, item),
              )),
        ],
        const SizedBox(height: 80), // FAB clearance
      ],
    );
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final CrossAxisAlignment align;

  const _SummaryLine({
    required this.label,
    required this.amount,
    required this.color,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          '${amount.toStringAsFixed(2)} €',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }
}
