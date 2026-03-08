import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../widgets/expense_list_tile.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final ExpenseService _service = ExpenseService();
  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = _service.getAll();
  }

  void _addDemoExpense() {
    final categories = ['Food', 'Transport', 'Shopping', 'Health', 'Other'];
    final index = _expenses.length % categories.length;

    _service.add(Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: ((_expenses.length + 1) * 7.5),
      category: categories[index],
      date: DateTime.now(),
      note: 'Demo expense #${_expenses.length + 1}',
    ));

    setState(() {
      _expenses = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: _expenses.isEmpty ? _buildEmptyState() : _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDemoExpense,
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
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

  Widget _buildList() {
    return ListView.separated(
      itemCount: _expenses.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          ExpenseListTile(expense: _expenses[index]),
    );
  }
}