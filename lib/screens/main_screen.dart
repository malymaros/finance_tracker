import 'package:flutter/material.dart';

import '../services/finance_repository.dart';
import '../services/plan_repository.dart';
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
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ExpenseListScreen(repository: widget.repository),
      PlanScreen(planRepository: widget.planRepository),
      ReportScreen(repository: widget.repository),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
