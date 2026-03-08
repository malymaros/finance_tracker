import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/finance_repository.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/swipeable_tile.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  final FinanceRepository repository;

  const ExpenseListScreen({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final expenses = repository.expenses;
        return Scaffold(
          appBar: AppBar(title: const Text('Expenses')),
          body: expenses.isEmpty ? _buildEmptyState() : _buildList(context, expenses),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToAdd(context),
            tooltip: 'Add Expense',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(repository: repository),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No expenses yet.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add one.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Expense> expenses) {
    return ListView.separated(
      itemCount: expenses.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => SwipeableTile(
        itemId: expenses[i].id,
        onDelete: () => repository.removeExpense(expenses[i].id),
        onEdit: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddExpenseScreen(
              repository: repository,
              existing: expenses[i],
            ),
          ),
        ),
        child: ExpenseListTile(expense: expenses[i]),
      ),
    );
  }
}
