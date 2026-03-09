import 'package:flutter/material.dart';

import '../../models/plan_item.dart';
import '../../services/budget_calculator.dart';
import '../../services/plan_repository.dart';
import '../../widgets/plan_item_tile.dart';
import '../plan/add_plan_item_screen.dart';

class FixedCostListScreen extends StatelessWidget {
  final PlanRepository planRepository;

  const FixedCostListScreen({super.key, required this.planRepository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: planRepository,
      builder: (context, _) {
        final now = DateTime.now();
        final allItems = planRepository.items;

        final costs = BudgetCalculator.activeItemsForMonth(
                allItems, now.year, now.month)
            .where((i) => i.type == PlanItemType.fixedCost)
            .toList();

        final monthlyTotal = BudgetCalculator.normalizedMonthlyFixedCosts(
            allItems, now.year, now.month);
        final yearlyTotal =
            BudgetCalculator.yearlyFixedCosts(allItems, now.year);

        return Scaffold(
          appBar: AppBar(title: const Text('Fixed Costs')),
          body: Column(
            children: [
              _SummaryCard(
                  monthlyTotal: monthlyTotal, yearlyTotal: yearlyTotal),
              Expanded(
                child: costs.isEmpty
                    ? _buildEmptyState()
                    : _buildList(context, costs),
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
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AddPlanItemScreen(
        planRepository: planRepository,
        initialType: PlanItemType.fixedCost,
      ),
    ));
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

  Widget _buildList(BuildContext context, List<PlanItem> costs) {
    return ListView.separated(
      itemCount: costs.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => PlanItemTile(
        item: costs[i],
        displayAmount: costs[i].amount,
        onDelete: () => planRepository.removePlanItem(costs[i].id),
        onEdit: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddPlanItemScreen(
            planRepository: planRepository,
            existing: costs[i],
          ),
        )),
      ),
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
