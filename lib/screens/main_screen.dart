import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/period_bounds.dart';
import '../models/year_month.dart';
import '../services/finance_repository.dart';
import '../services/period_bounds_service.dart';
import '../services/plan_repository.dart';
import '../services/seed_data.dart';
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
  final _selectedPeriod = ValueNotifier<YearMonth>(YearMonth.now());
  final _periodBounds = ValueNotifier<PeriodBounds>(const PeriodBounds());
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    widget.planRepository.addListener(_updateBounds);
    _updateBounds();
    _screens = [
      ExpenseListScreen(
          repository: widget.repository,
          planRepository: widget.planRepository,
          selectedPeriod: _selectedPeriod,
          periodBounds: _periodBounds,
          onClearAll: () => _clearAllData(context),
          onOpenSaves: () => _openSaves(context)),
      PlanScreen(
          planRepository: widget.planRepository,
          selectedPeriod: _selectedPeriod,
          periodBounds: _periodBounds,
          onClearAll: () => _clearAllData(context),
          onOpenSaves: () => _openSaves(context)),
      ReportScreen(
          repository: widget.repository,
          planRepository: widget.planRepository,
          selectedPeriod: _selectedPeriod,
          periodBounds: _periodBounds,
          onNavigateToPlan: () => setState(() => _selectedIndex = 1),
          onClearAll: () => _clearAllData(context),
          onOpenSaves: () => _openSaves(context)),
    ];
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

  @override
  void dispose() {
    widget.planRepository.removeListener(_updateBounds);
    _selectedPeriod.dispose();
    _periodBounds.dispose();
    super.dispose();
  }

  void _openSaves(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => SavesScreen(
        repository: widget.repository,
        planRepository: widget.planRepository,
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
                backgroundColor: Colors.red),
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

  Future<void> _resetWithSeedData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset with seed data?'),
        content: const Text(
            'This will delete all current data and replace it with dummy data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await SeedData.reset(widget.repository, widget.planRepository);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          if (kDebugMode)
            Positioned(
              bottom: 80,
              left: 16,
              child: Opacity(
                opacity: 0.6,
                child: FloatingActionButton.small(
                  heroTag: 'debug_seed',
                  backgroundColor: Colors.orange,
                  tooltip: 'Reset with seed data',
                  onPressed: () => _resetWithSeedData(context),
                  child: const Icon(Icons.bug_report_outlined,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.receipt_long), label: 'Expenses'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_outlined), label: 'Plan'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart), label: 'Reports'),
        ],
      ),
    );
  }
}
