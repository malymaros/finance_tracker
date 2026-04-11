import 'package:flutter/material.dart';

import '../models/period_bounds.dart';
import '../theme/app_theme.dart';
import '../models/year_month.dart';
import '../services/app_repositories.dart';
import '../services/guard_notification_service.dart';
import '../services/period_bounds_service.dart';
import 'expense_list_screen.dart';
import 'plan/plan_screen.dart';
import 'reports/report_screen.dart';
import 'saves_screen.dart';
import '../widgets/save_action_dialog.dart';

class MainScreen extends StatefulWidget {
  final AppRepositories repositories;

  const MainScreen({
    super.key,
    required this.repositories,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // start on Expenses tab
  late final PageController _pageController;
  final _selectedPeriod = ValueNotifier<YearMonth>(YearMonth.now());
  final _periodBounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
    widget.repositories.plan.addListener(_updateBounds);
    widget.repositories.guard.addListener(_onGuardChanged);
    _selectedPeriod.addListener(_onPeriodChanged);
    _updateBounds();
    _screens = [
      _KeepAliveTab(
        child: PlanScreen(
            repositories: widget.repositories,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context)),
      ),
      _KeepAliveTab(
        child: ExpenseListScreen(
            repositories: widget.repositories,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context),
            onSwitchToPlanTab: () => _navigateToTab(0)),
      ),
      _KeepAliveTab(
        child: ReportScreen(
            repository: widget.repositories.finance,
            planRepository: widget.repositories.plan,
            budgetRepository: widget.repositories.budget,
            selectedPeriod: _selectedPeriod,
            periodBounds: _periodBounds,
            onNavigateToPlan: () => _navigateToTab(0),
            onClearAll: () => _clearAllData(context),
            onOpenSaves: () => _openSaves(context)),
      ),
    ];
  }

  void _onPeriodChanged() {
    widget.repositories.finance.loadYear(_selectedPeriod.value.year);
  }

  void _onGuardChanged() {
    setState(() {});
    _rescheduleNotification();
  }

  Future<void> _rescheduleNotification() async {
    try {
      final unpaidCount = _unpaidActiveCount;
      final hour = await GuardNotificationService.getSavedHour();
      final minute = await GuardNotificationService.getSavedMinute();
      await GuardNotificationService.scheduleDaily(hour, minute, unpaidCount);
    } catch (_) {}
  }

  void _updateBounds() {
    final bounds = PeriodBoundsService.compute(
      planEarliest: widget.repositories.plan.earliestDataMonth,
      planLatest: widget.repositories.plan.latestDataMonth,
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
    widget.repositories.plan.removeListener(_updateBounds);
    widget.repositories.guard.removeListener(_onGuardChanged);
    _selectedPeriod.removeListener(_onPeriodChanged);
    _selectedPeriod.dispose();
    _periodBounds.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _openSaves(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SavesScreen(
        repositories: widget.repositories,
        onClearAll: () => _clearAllData(context),
      ),
    ));
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await SaveActionDialog.show(
      context,
      icon: Icons.delete_outline,
      iconColor: AppColors.expense,
      actionLabel: 'DELETE',
      description:
          'Expenses, plan items, budgets and guard payments will be permanently deleted. This cannot be undone.',
      preservedNote: 'Saved snapshots and auto-backups are not affected.',
      confirmLabel: 'Delete all',
    );
    if (confirmed && context.mounted) {
      await Future.wait([
        widget.repositories.finance.clearAll(),
        widget.repositories.plan.clearAll(),
        widget.repositories.budget.clearAll(),
        widget.repositories.guard.clearAll(),
      ]);
    }
  }

  int get _unpaidActiveCount => widget.repositories.guard
      .unpaidActiveItems(widget.repositories.plan.items, YearMonth.now())
      .length;

  @override
  Widget build(BuildContext context) {
    final unpaidCount = _unpaidActiveCount;

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
          destinations: [
            NavigationDestination(
              icon: Badge(
                isLabelVisible: unpaidCount > 0,
                label: Text('$unpaidCount'),
                child: const Icon(Icons.account_balance_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: unpaidCount > 0,
                label: Text('$unpaidCount'),
                child: const Icon(Icons.account_balance),
              ),
              label: 'Plan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
            const NavigationDestination(
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
