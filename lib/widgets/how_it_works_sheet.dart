import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/monthly_overview_summary.dart';
import '../models/year_month.dart';
import '../theme/app_theme.dart';
import 'overview_month_row.dart';
import 'sub_step_indicator.dart';

/// Bottom sheet explaining the Plan → Budget → Expenses → Result → Reports flow.
///
/// Pass [initialPage] to open at a specific card:
///   0 = Step 1 — Plan
///   1 = Step 2 — Budget  (open from Expenses tab)
///   4 = Step 3 — Reports
///
/// Internally uses a nested PageView:
///   Outer (3 pages): Plan | Expenses | Reports  — full solid-page swipe
///   Inner (3 pages): Budget | Spending | Result — sub-screen swipe with fixed header
class HowItWorksSheet extends StatefulWidget {
  final int initialPage;

  const HowItWorksSheet({super.key, this.initialPage = 0});

  /// Named page-index constants for all [show] call sites.
  static const pageIndexPlan     = 0;
  static const pageIndexExpenses = 1;
  static const pageIndexReports  = 4;

  static Future<void> show(BuildContext context, {int initialPage = 0}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HowItWorksSheet(initialPage: initialPage),
    );
  }

  @override
  State<HowItWorksSheet> createState() => _HowItWorksSheetState();
}

class _HowItWorksSheetState extends State<HowItWorksSheet> {
  late final PageController _planController;
  late final PageController _expController;
  late final PageController _repController;
  int _outerPage = 0;
  int _planPage  = 0;
  int _expPage   = 0;
  int _repPage   = 0;

  void _goOuterTo(int outerPage) {
    if (outerPage == _outerPage) return;
    if (outerPage != 0 && _planController.hasClients) {
      _planController.jumpToPage(0);
    }
    if (outerPage != 1 && _expController.hasClients) {
      _expController.jumpToPage(0);
    }
    if (outerPage != 2 && _repController.hasClients) {
      _repController.jumpToPage(0);
    }
    setState(() {
      _outerPage = outerPage;
      if (outerPage != 2) _repPage = 0;
    });
  }

  void _goPlanTo(int page) {
    _planController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goExpTo(int page) {
    _expController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goRepTo(int page) {
    _repController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  void initState() {
    super.initState();
    final orig = widget.initialPage;
    if (orig == 0) {
      _outerPage = 0; _planPage = 0; _expPage = 0; _repPage = 0;
    } else if (orig >= 4) {
      _outerPage = 2; _planPage = 0; _expPage = 0; _repPage = 0;
    } else {
      _outerPage = 1; _planPage = 0; _expPage = (orig - 1).clamp(0, 2); _repPage = 0;
    }
    _planController = PageController(initialPage: _planPage);
    _expController  = PageController(initialPage: _expPage);
    _repController  = PageController(initialPage: _repPage);
  }

  @override
  void dispose() {
    _planController.dispose();
    _expController.dispose();
    _repController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previous,
                    ?current,
                  ],
                ),
                child: KeyedSubtree(
                  key: ValueKey(_outerPage),
                  child: _buildOuterPage(),
                ),
              ),
            ),
            _buildTabStrip(),
          ],
        ),
      ),
    );
  }

  // ── Fixed chrome ───────────────────────────────────────────────────────────

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: [
          const Text(
            'How it works?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildOuterPage() {
    switch (_outerPage) {
      case 0:
        return _PlanScreen(
          planController: _planController,
          planPage: _planPage,
          onSubStepTap: _goPlanTo,
          onPageChanged: (i) => setState(() => _planPage = i),
        );
      case 2:
        return _ReportsScreen(
          repController: _repController,
          repPage: _repPage,
          onSubStepTap: _goRepTo,
          onPageChanged: (i) => setState(() => _repPage = i),
        );
      default:
        return _ExpensesScreen(
          innerController: _expController,
          innerPage: _expPage,
          onSubStepTap: _goExpTo,
          onPageChanged: (i) => setState(() => _expPage = i),
        );
    }
  }

  // ── Tab strip (reflects outer page) ───────────────────────────────────────

  // Visual column order: [Plan(step1)] [arrow-slot] [Expenses(step2)] [arrow-slot] [Reports(step3)]
  // Arrow slots are always the same fixed width — red arrow visible only when that
  // transition is the current "next step"; otherwise an invisible placeholder keeps
  // the layout stable so nothing shifts.

  Widget _buildTabStrip() {
    _TabState stateFor(int outerIdx) {
      if (_outerPage == outerIdx) return _TabState.active;
      if (_outerPage == 0 && outerIdx == 1) return _TabState.next; // Plan→Expenses
      if (_outerPage == 1 && outerIdx == 2) return _TabState.next; // Expenses→Reports
      return _TabState.plain;
    }

    Widget arrowSlot(bool active) {
      return SizedBox(
        width: 20,
        child: Icon(
          Icons.arrow_forward,
          size: 16,
          color: active ? Colors.red : AppColors.border,
        ),
      );
    }

    final plan     = Expanded(child: _TabItem(icon: Icons.account_balance_outlined, label: 'Plan',     stepNumber: 1, state: stateFor(0), onTap: () => _goOuterTo(0)));
    final expenses = Expanded(child: _TabItem(icon: Icons.receipt_long_outlined,    label: 'Expenses', stepNumber: 2, state: stateFor(1), onTap: () => _goOuterTo(1)));
    final reports  = Expanded(child: _TabItem(icon: Icons.pie_chart_outline,        label: 'Reports',  stepNumber: 3, state: stateFor(2), onTap: () => _goOuterTo(2)));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            plan,
            arrowSlot(_outerPage == 0), // Plan → Expenses
            expenses,
            arrowSlot(_outerPage == 1), // Expenses → Reports
            reports,
          ],
        ),
      ),
    );
  }

}

// ── Expenses screen — fixed header + inner PageView ───────────────────────

class _ExpensesScreen extends StatelessWidget {
  final PageController innerController;
  final int innerPage;
  final void Function(int innerPage) onSubStepTap;
  final void Function(int innerPage) onPageChanged;

  const _ExpensesScreen({
    required this.innerController,
    required this.innerPage,
    required this.onSubStepTap,
    required this.onPageChanged,
  });

  static const _subtitles = [
    'Your available budget, calculated from Plan',
    'Day-to-day spending you record',
    'Did you stay within budget?',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _StepHeader(

            name: 'Expenses',
            subtitle: _subtitles[innerPage],
            subStep: innerPage,
            onSubStepTap: onSubStepTap,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PageView(
            controller: innerController,
            onPageChanged: onPageChanged,
            children: const [
              _BudgetContent(),
              _SpendingContent(),
              _ResultContent(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tab state enum ─────────────────────────────────────────────────────────

enum _TabState { active, next, plain }

// ── Tab item — same layout footprint whether circled or not ───────────────

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int stepNumber;
  final _TabState state;
  final VoidCallback? onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.stepNumber,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = state == _TabState.active;
    final iconColor   = isActive ? AppColors.navy : AppColors.textMuted;
    final stepColor   = isActive ? Colors.red : AppColors.textMuted;
    final borderColor = isActive ? Colors.red : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'STEP $stepNumber',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: stepColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: iconColor,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Step header ────────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final int? subStep;
  final List<String>? subStepLabels;
  final void Function(int)? onSubStepTap;

  const _StepHeader({
    required this.name,
    required this.subtitle,
    this.subStep,
    this.subStepLabels,
    this.onSubStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
        if (subStep != null) ...[
          const SizedBox(height: 10),
          SubStepIndicator(
            activeSubStep: subStep!,
            labels: subStepLabels ?? const ['Budget', 'Spending', 'Result'],
            onTap: onSubStepTap,
          ),
        ],
      ],
    );
  }
}



// ── Plan screen — fixed header + inner PageView (3 sub-pages) ────────────

class _PlanScreen extends StatelessWidget {
  final PageController planController;
  final int planPage;
  final void Function(int) onSubStepTap;
  final void Function(int) onPageChanged;

  const _PlanScreen({
    required this.planController,
    required this.planPage,
    required this.onSubStepTap,
    required this.onPageChanged,
  });

  static const _subtitles = [
    'Your salary and committed monthly bills',
    'How your fixed costs are classified',
    'How much of your income each type consumes',
  ];

  static const _subStepLabels = ['Cashflow', 'Classification', 'Allocation'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _StepHeader(
            name: 'Plan',
            subtitle: _subtitles[planPage],
            subStep: planPage,
            subStepLabels: _subStepLabels,
            onSubStepTap: onSubStepTap,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PageView(
            controller: planController,
            onPageChanged: onPageChanged,
            children: const [
              _PlanIncomeContent(),
              _PlanFinancialTypesContent(),
              _PlanSpendingVsIncomeContent(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Plan sub-page 1: Income & Fixed Costs ─────────────────────────────────

class _PlanIncomeContent extends StatelessWidget {
  const _PlanIncomeContent();

  static const _incomeColor = AppColors.income;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildIncomeCard()),
                const SizedBox(width: 8),
                Expanded(child: _buildFixedCostsCard()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Body(
            'Enter your salary and committed monthly bills — rent, insurance, '
            'subscriptions. These are real, known numbers, not estimates or goals.',
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _CompactCardHeader(
              icon: Icons.savings,
              iconColor: _incomeColor,
              title: 'Income',
              total: '+2 700 €',
              totalColor: _incomeColor,
            ),
            Divider(height: 12),
            _CompactCardItem(
              icon: Icons.savings,
              iconColor: _incomeColor,
              name: 'Salary',
              amount: '+2 500 €',
              amountColor: _incomeColor,
            ),
            SizedBox(height: 4),
            _CompactCardItem(
              icon: Icons.savings,
              iconColor: _incomeColor,
              name: 'Bonus',
              amount: '+200 €',
              amountColor: _incomeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedCostsCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CompactCardHeader(
              icon: Icons.lock_outline,
              iconColor: AppColors.textMuted,
              title: 'Fixed Costs',
              total: '-1 120 €',
              totalColor: AppColors.expense,
            ),
            const Divider(height: 12),
            _CompactCardItem(
              icon: ExpenseCategory.housing.icon,
              iconColor: ExpenseCategory.housing.color,
              name: 'Rent',
              amount: '-800 €',
              amountColor: AppColors.expense,
              leftBorderColor: AppColors.expense,
            ),
            const SizedBox(height: 4),
            _CompactCardItem(
              icon: ExpenseCategory.insurance.icon,
              iconColor: ExpenseCategory.insurance.color,
              name: 'Insurance',
              amount: '-120 €',
              amountColor: FinancialType.insurance.color,
              leftBorderColor: FinancialType.insurance.color,
            ),
            const SizedBox(height: 4),
            _CompactCardItem(
              icon: Icons.trending_up,
              iconColor: FinancialType.asset.color,
              name: 'ETF fonds',
              amount: '-200 €',
              amountColor: FinancialType.asset.color,
              leftBorderColor: FinancialType.asset.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Plan sub-page 2: Financial Types ──────────────────────────────────────

class _PlanFinancialTypesContent extends StatelessWidget {
  const _PlanFinancialTypesContent();

  static final _types = [
    (
      icon: FinancialType.consumption.icon,
      color: FinancialType.consumption.color,
      name: FinancialType.consumption.displayName,
      description: 'Day-to-day spending — groceries, rent, dining, transport',
    ),
    (
      icon: FinancialType.asset.icon,
      color: FinancialType.asset.color,
      name: FinancialType.asset.displayName,
      description: 'Investments and savings that grow your wealth over time',
    ),
    (
      icon: FinancialType.insurance.icon,
      color: FinancialType.insurance.color,
      name: FinancialType.insurance.displayName,
      description: 'Protection costs — car, health, and life insurance',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < _types.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _types[i].color.withAlpha(30),
                          child: Icon(_types[i].icon,
                              color: _types[i].color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _types[i].name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _types[i].description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < _types.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Body(
            'Each fixed cost is tagged with a financial type. '
            'This lets the app show how your income is distributed across '
            'spending, savings, and protection.',
          ),
        ],
      ),
    );
  }
}

// ── Plan sub-page 3: Spending vs Income ───────────────────────────────────

class _PlanSpendingVsIncomeContent extends StatelessWidget {
  const _PlanSpendingVsIncomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MockSpendingVsIncomeCard(),
          SizedBox(height: 16),
          _Body(
            'The Plan tab shows how much of your income goes to each financial '
            'type — so you can see at a glance whether you spend, save, or '
            'protect the right share of what you earn.',
          ),
        ],
      ),
    );
  }
}

/// Reproduces [FinancialTypeDistributionCard] with hardcoded mock data.
/// Income: 2 500 €  Consumption: 800 € (32%)  Insurance: 120 € (5%)  Asset: 200 €
class _MockSpendingVsIncomeCard extends StatelessWidget {
  const _MockSpendingVsIncomeCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending vs Income',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            _MockRatioRow(
              icon: FinancialType.consumption.icon,
              color: FinancialType.consumption.color,
              name: FinancialType.consumption.displayName,
              amount: '800.00 €',
              pct: 32,
            ),
            _MockRatioRow(
              icon: FinancialType.asset.icon,
              color: FinancialType.asset.color,
              name: FinancialType.asset.displayName,
              amount: '200.00 €',
              pct: 8,
            ),
            _MockRatioRow(
              icon: FinancialType.insurance.icon,
              color: FinancialType.insurance.color,
              name: FinancialType.insurance.displayName,
              amount: '120.00 €',
              pct: 5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Reproduces [FinancialTypeRatioRow] with hardcoded values.
class _MockRatioRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String amount;
  final int? pct;

  const _MockRatioRow({
    required this.icon,
    required this.color,
    required this.name,
    required this.amount,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final ringValue = pct == null ? 0.0 : (pct! / 100).clamp(0.0, 1.0);
    final label = pct == null ? '—' : '$pct%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(amount,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ringValue,
                  strokeWidth: 5,
                  backgroundColor: color.withAlpha(40),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: pct == null ? 16 : 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetContent extends StatelessWidget {
  const _BudgetContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MockBudgetProgressBar(),
          SizedBox(height: 16),
          _Body(
            "The app subtracts your fixed costs from your income and shows the "
            "result here. You don't set this number — it comes from your Plan.",
          ),
        ],
      ),
    );
  }
}

class _SpendingContent extends StatelessWidget {
  const _SpendingContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ExpensesBox(),
          SizedBox(height: 16),
          _Body(
            'Log groceries, meals, shopping and other variable spending. '
            'Fixed monthly bills like rent belong in Plan, not here.',
          ),
        ],
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _MockMonthBudgetSummary(isOver: false),
          SizedBox(height: 10),
          _MockMonthBudgetSummary(isOver: true),
          SizedBox(height: 16),
          _Body(
            'At the end of the month the Expenses tab shows which outcome you had.',
          ),
        ],
      ),
    );
  }
}

// ── Reports screen — fixed header + inner PageView (3 sub-pages) ─────────

class _ReportsScreen extends StatelessWidget {
  final PageController repController;
  final int repPage;
  final void Function(int) onSubStepTap;
  final void Function(int) onPageChanged;

  const _ReportsScreen({
    required this.repController,
    required this.repPage,
    required this.onSubStepTap,
    required this.onPageChanged,
  });

  static const _subtitles = [
    'Where did your money go?',
    'Your finances on paper',
    'The big picture, month by month',
  ];

  static const _subStepLabels = ['Breakdown', 'Export', 'Overview'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: _StepHeader(
            name: 'Reports',
            subtitle: _subtitles[repPage],
            subStep: repPage,
            subStepLabels: _subStepLabels,
            onSubStepTap: onSubStepTap,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: PageView(
            controller: repController,
            onPageChanged: onPageChanged,
            children: const [
              _ReportsBreakdownContent(),
              _ReportsExportContent(),
              _ReportsOverviewContent(),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Reports sub-page 1: Breakdown ─────────────────────────────────────────

class _ReportsBreakdownContent extends StatelessWidget {
  const _ReportsBreakdownContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PieChartBox(),
          SizedBox(height: 16),
          _Body(
            'Breakdown shows your spending by category for any month or year. '
            'Tap a slice or category row to drill into the individual expenses '
            'and fixed costs behind it.',
          ),
        ],
      ),
    );
  }
}

// ── Reports sub-page 2: Export ────────────────────────────────────────────

class _ReportsExportContent extends StatelessWidget {
  const _ReportsExportContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _MockPdfCard(
                    title: 'Monthly',
                    icon: Icons.calendar_view_month,
                    features: [
                      'Category totals',
                      'Budget vs actual',
                      'Financial type split',
                      'All expenses listed',
                      'Category budgets',
                      'Group summaries',
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _MockPdfCard(
                    title: 'Yearly',
                    icon: Icons.calendar_today,
                    features: [
                      '12-month overview',
                      'Annual totals',
                      'Monthly breakdown',
                      'Plan vs actual',
                      'Type ratios',
                      'Active plan items',
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          _Body(
            'Use the PDF button in Breakdown to export. '
            'Reports are shareable via any app on your device.',
          ),
        ],
      ),
    );
  }
}

// ── Reports sub-page 3: Overview ──────────────────────────────────────────

class _ReportsOverviewContent extends StatelessWidget {
  const _ReportsOverviewContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                OverviewMonthRow(
                  summary: const MonthlyOverviewSummary(period: YearMonth(2025, 1), earned: 2500, consumption: 820, assets: 800, result: 880),
                  onTap: () {},
                ),
                const Divider(height: 1),
                OverviewMonthRow(
                  summary: const MonthlyOverviewSummary(period: YearMonth(2025, 2), earned: 2500, consumption: 1720, assets: 1000, result: -220),
                  onTap: () {},
                ),
                const Divider(height: 1),
                OverviewMonthRow(
                  summary: const MonthlyOverviewSummary(period: YearMonth(2025, 3), earned: 2500, consumption: 630, assets: 1670, result: 200),
                  onTap: () {},
                ),
                const Divider(height: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    '· · · 9 more months',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _Body(
            'Overview shows all 12 months side by side — how much you earned, '
            'what went into assets, and what was consumed. '
            'Tap any month to jump to that period in the Plan.',
          ),
        ],
      ),
    );
  }
}

// ── Mock widgets (pixel-faithful reproductions with hardcoded data) ─────────

/// Reproduces [BudgetProgressBar] with fake data: 780 € spent of 1 570 €.
class _MockBudgetProgressBar extends StatelessWidget {
  const _MockBudgetProgressBar();

  static const double _spent = 780;
  static const double _budget = 1570;
  static const double _remaining = _budget - _spent;
  static const double _progress = _spent / _budget; // ~49.7%

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "This month's budget",
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  '${_remaining.toStringAsFixed(2)} € left',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: const LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.income),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${_spent.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  'Budget: ${_budget.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Reproduces [MonthBudgetSummary] with fake data.
/// [isOver] switches between the saved and over-budget states.
class _MockMonthBudgetSummary extends StatelessWidget {
  final bool isOver;

  const _MockMonthBudgetSummary({required this.isOver});

  static const double _budget = 1570;
  static const double _spentSaved = 780;
  static const double _spentOver = 1810;

  @override
  Widget build(BuildContext context) {
    final double spent = isOver ? _spentOver : _spentSaved;
    final double diff = (spent - _budget).abs();
    final Color statusColor =
        isOver ? AppColors.expense : AppColors.income;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOver
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isOver
                      ? 'Over budget by ${diff.toStringAsFixed(2)} €'
                      : 'Saved ${diff.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${spent.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  'Budget: ${_budget.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Compact card helpers (side-by-side half-width cards) ──────────────────

class _CompactCardHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String total;
  final Color totalColor;

  const _CompactCardHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.total,
    required this.totalColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          total,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: totalColor,
          ),
        ),
      ],
    );
  }
}

class _CompactCardItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String amount;
  final Color amountColor;
  final Color? leftBorderColor;

  const _CompactCardItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.amount,
    required this.amountColor,
    this.leftBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: leftBorderColor != null
          ? BoxDecoration(
              border: Border(
                left: BorderSide(width: 2, color: leftBorderColor!),
              ),
            )
          : null,
      padding: EdgeInsets.only(left: leftBorderColor != null ? 5 : 0),
      child: Row(
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spending card helper ───────────────────────────────────────────────────

class _ExpensesBox extends StatelessWidget {
  const _ExpensesBox();

  static String _date(int year, int month, int day) {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final y = now.year;
    final mo = now.month;

    final rows = [
      (
        icon: ExpenseCategory.groceries.icon,
        iconColor: ExpenseCategory.groceries.color,
        label: ExpenseCategory.groceries.displayName,
        subtitle: 'supermarket · ${_date(y, mo, 8)}',
        amount: '47.30 €',
      ),
      (
        icon: ExpenseCategory.restaurants.icon,
        iconColor: ExpenseCategory.restaurants.color,
        label: ExpenseCategory.restaurants.displayName,
        subtitle: _date(y, mo, 7),
        amount: '32.00 €',
      ),
      (
        icon: ExpenseCategory.clothing.icon,
        iconColor: ExpenseCategory.clothing.color,
        label: ExpenseCategory.clothing.displayName,
        subtitle: 'outlet · ${_date(y, mo, 5)}',
        amount: '65.90 €',
      ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: rows[i].iconColor.withAlpha(30),
                child: Icon(
                  rows[i].icon,
                  size: 20,
                  color: rows[i].iconColor.withAlpha(180),
                ),
              ),
              title: Text(
                rows[i].label,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                rows[i].subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              trailing: Text(
                rows[i].amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.expense,
                ),
              ),
            ),
            if (i < rows.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

// ── Reports card helpers ───────────────────────────────────────────────────

class _MockPdfCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> features;

  const _MockPdfCard({
    required this.title,
    required this.icon,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.picture_as_pdf_outlined,
                    color: AppColors.expense, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.income),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _PieChartBox extends StatelessWidget {
  const _PieChartBox();

  // Mock data — colors and icons sourced from ExpenseCategory extensions.
  static final _items = [
    (label: ExpenseCategory.groceries.displayName,   icon: ExpenseCategory.groceries.icon,   color: ExpenseCategory.groceries.color,   pct: 30, amount: '450'),
    (label: ExpenseCategory.housing.displayName,     icon: ExpenseCategory.housing.icon,     color: ExpenseCategory.housing.color,     pct: 22, amount: '330'),
    (label: ExpenseCategory.transport.displayName,   icon: ExpenseCategory.transport.icon,   color: ExpenseCategory.transport.color,   pct: 18, amount: '270'),
    (label: ExpenseCategory.restaurants.displayName, icon: ExpenseCategory.restaurants.icon, color: ExpenseCategory.restaurants.color, pct: 15, amount: '225'),
    (label: 'Other categories', icon: Icons.more_horiz, color: const Color(0xFFE0E0E0),      pct: 15, amount: '225'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _PieChartPainter(
                segments: _items
                    .map((i) => (sweep: i.pct / 100.0, color: i.color))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _items.map((item) => _MockBreakdownRow(
                label: item.label,
                icon: item.icon,
                color: item.color,
                pct: item.pct,
                amount: item.amount,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockBreakdownRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final int pct;
  final String amount;

  const _MockBreakdownRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.pct,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 13, color: color.withAlpha(200)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$pct%',
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(width: 6),
          Text(
            '$amount €',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<({double sweep, Color color})> segments;

  const _PieChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;

    for (final seg in segments) {
      final sweepAngle = seg.sweep * 2 * math.pi;
      canvas.drawArc(rect, startAngle, sweepAngle, true,
          Paint()..color = seg.color);
      canvas.drawArc(rect, startAngle, sweepAngle, true,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(_PieChartPainter old) => false;
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Colors.black87,
      ),
    );
  }
}
