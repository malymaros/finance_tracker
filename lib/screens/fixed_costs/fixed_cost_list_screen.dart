import 'package:flutter/material.dart';

import '../../models/fixed_cost.dart';
import '../../services/finance_repository.dart';
import '../../widgets/fixed_cost_tile.dart';
import 'add_fixed_cost_screen.dart';

class FixedCostListScreen extends StatelessWidget {
  final FinanceRepository repository;

  const FixedCostListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final costs = repository.fixedCosts;
        final now = DateTime.now();
        final monthlyTotal =
            repository.totalFixedCostsForMonth(now.year, now.month);
        final yearlyTotal = repository.totalFixedCostsForYear(now.year);

        return Scaffold(
          appBar: AppBar(title: const Text('Fixed Costs')),
          body: Column(
            children: [
              _SummaryCard(
                  monthlyTotal: monthlyTotal, yearlyTotal: yearlyTotal),
              Expanded(
                child: costs.isEmpty
                    ? _buildEmptyState()
                    : _buildList(costs),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAdd(context),
            tooltip: 'Add Fixed Cost',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddFixedCostScreen(repository: repository),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No fixed costs yet.',
              style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text('Tap + to add one.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList(List<FixedCost> costs) {
    return ListView.separated(
      itemCount: costs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) => FixedCostTile(cost: costs[i]),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double monthlyTotal;
  final double yearlyTotal;

  const _SummaryCard(
      {required this.monthlyTotal, required this.yearlyTotal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('This month',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '${monthlyTotal.toStringAsFixed(2)} €',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('This year',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    '${yearlyTotal.toStringAsFixed(2)} €',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
