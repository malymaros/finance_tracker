import 'package:flutter/material.dart';

import '../../models/income_entry.dart';
import '../../services/finance_repository.dart';
import '../../widgets/income_entry_tile.dart';
import 'add_income_screen.dart';

class IncomeListScreen extends StatelessWidget {
  final FinanceRepository repository;

  const IncomeListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final income = repository.income.reversed.toList();
        final now = DateTime.now();
        final monthTotal =
            repository.totalIncomeForMonth(now.year, now.month);

        return Scaffold(
          appBar: AppBar(title: const Text('Income')),
          body: Column(
            children: [
              _SummaryCard(monthTotal: monthTotal),
              Expanded(
                child: income.isEmpty
                    ? _buildEmptyState()
                    : _buildList(income),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAdd(context),
            tooltip: 'Add Income',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddIncomeScreen(repository: repository),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No income entries yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap + to add one.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList(List<IncomeEntry> income) {
    return ListView.separated(
      itemCount: income.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => IncomeEntryTile(entry: income[i]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double monthTotal;

  const _SummaryCard({required this.monthTotal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('This month',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(
              '${monthTotal.toStringAsFixed(2)} €',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
