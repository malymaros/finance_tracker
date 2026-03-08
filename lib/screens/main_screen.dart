import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/year_month.dart';
import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
import '../services/seed_data.dart';
import 'expense_list_screen.dart';
import 'plan/plan_screen.dart';
import 'reports/report_screen.dart';

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
  final _requestedPlanPeriod = ValueNotifier<YearMonth?>(null);
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ExpenseListScreen(
          repository: widget.repository,
          planRepository: widget.planRepository),
      PlanScreen(
          planRepository: widget.planRepository,
          requestedPeriod: _requestedPlanPeriod),
      ReportScreen(
          repository: widget.repository,
          planRepository: widget.planRepository,
          onNavigateToPlanMonth: _navigateToPlanMonth),
    ];
  }

  @override
  void dispose() {
    _requestedPlanPeriod.dispose();
    super.dispose();
  }

  void _navigateToPlanMonth(int year, int month) {
    _requestedPlanPeriod.value = YearMonth(year, month);
    setState(() => _selectedIndex = 1);
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
