import 'package:flutter/material.dart';

import '../services/finance_repository.dart';
import 'expense_list_screen.dart';
import 'fixed_costs/fixed_cost_list_screen.dart';
import 'income/income_list_screen.dart';
import 'reports/report_screen.dart';

class MainScreen extends StatefulWidget {
  final FinanceRepository repository;

  const MainScreen({super.key, required this.repository});

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
      const IncomeListScreen(),
      const FixedCostListScreen(),
      const ReportScreen(),
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
              icon: Icon(Icons.trending_up), label: 'Income'),
          NavigationDestination(
              icon: Icon(Icons.repeat), label: 'Fixed Costs'),
          NavigationDestination(
              icon: Icon(Icons.pie_chart), label: 'Reports'),
        ],
      ),
    );
  }
}
