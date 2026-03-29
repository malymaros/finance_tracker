import 'package:flutter/material.dart';

import '../models/period_bounds.dart';
import '../theme/app_theme.dart';
import '../models/year_month.dart';
import '../services/finance_repository.dart';
import '../services/period_bounds_service.dart';
import '../services/plan_repository.dart';
import 'expense_list_screen.dart';
import 'plan/plan_screen.dart';
import 'reports/report_screen.dart';
import 'saves_screen.dart';

class MainScreen extends StatefulWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;

  const MainScreen({
    super.key,
    required this.repository,
    required this.planRepository,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  final _selectedPeriod = ValueNotifier<YearMonth>(YearMonth.now());
  final _periodBounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget.planRepository.addListener(_updateBounds);
    _selectedPeriod.addListener(_onPeriodChanged);
    _updateBounds();
    _screens = [
      _KeepAliveTab(
        child: ExpenseListScreen(
            repository: widget.repository,
            planRepository: widget.planRepository,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context)),
      ),
      _KeepAliveTab(
        child: PlanScreen(
            repository: widget.repository,
            planRepository: widget.planRepository,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context)),
      ),
      _KeepAliveTab(
        child: ReportScreen(
            repository: widget.repository,
            planRepository: widget.planRepository,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onNavigateToPlan: () => _navigateToTab(1),
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context)),
      ),
    ];
  }

  void _onPeriodChanged() {
    widget.repository.loadYear(_selectedPeriod.value.year);
  }

  void _updateBounds() {
    final bounds = PeriodBoundsService.compute(
      planEarliest: widget.planRepository.earliestDataMonth,
      planLatest: widget.planRepository.latestDataMonth,
    );
    _periodBounds.value = bounds;
    if (!bounds.allows(_selectedPeriod.value)) {
      _selectedPeriod.value = YearMonth.now();
    }
  }

  void _navigateToTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    widget.planRepository.removeListener(_updateBounds);
    _selectedPeriod.removeListener(_onPeriodChanged);
    _selectedPeriod.dispose();
    _periodBounds.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openSaves(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SavesScreen(
        repository: widget.repository,
        planRepository: widget.planRepository,
        onClearAll: () => _clearAllData(context),
      ),
    ));
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
            'This will permanently delete all expenses, income, plan items, and fixed costs. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.expense),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await Future.wait([
        widget.repository.clearAll(),
        widget.planRepository.clearAll(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _selectedIndex = i),
        children: _screens,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.navyBorder)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _navigateToTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_outlined),
              selectedIcon: Icon(Icons.account_balance),
              label: 'Plan',
            ),
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline),
              selectedIcon: Icon(Icons.pie_chart),
              label: 'Reports',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Keep-alive wrapper for PageView tabs ──────────────────────────────────────

class _KeepAliveTab extends StatefulWidget {
  final Widget child;

  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by AutomaticKeepAliveClientMixin
    return widget.child;
  }
}
