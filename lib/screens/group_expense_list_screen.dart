import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/finance_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/expense_list_tile.dart';
import '../widgets/swipeable_tile.dart';
import 'add_expense_screen.dart';
import 'expense_detail_screen.dart';

/// Shows the individual expense items assigned to a single [groupName]
/// for the given [period].
class GroupExpenseListScreen extends StatefulWidget {
  final String groupName;
  final FinanceRepository repository;

  const GroupExpenseListScreen({
    super.key,
    required this.groupName,
    required this.repository,
  });

  @override
  State<GroupExpenseListScreen> createState() =>
      _GroupExpenseListScreenState();
}

class _GroupExpenseListScreenState extends State<GroupExpenseListScreen> {
  List<Expense> _allGroupExpenses() =>
      widget.repository.expenses
          .where((e) => e.group == widget.groupName)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(widget.groupName),
      ),
      body: ListenableBuilder(
        listenable: widget.repository,
        builder: (context, _) {
          final expenses = _allGroupExpenses();

          if (expenses.isEmpty) return _buildEmptyState();

          final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
          final count = expenses.length;

          return Column(
            children: [
              _buildHeader(total, count),
              const Divider(height: 1),
              Expanded(child: _buildList(context, expenses)),
            ],
          );
        },
      ),
    );
  }

  // ── Header summary ──────────────────────────────────────────────────────────

  Widget _buildHeader(double total, int count) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(30),
            child: Icon(Icons.folder_outlined, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // ── Expense list ────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, List<Expense> expenses) {
    return ListView.separated(
      itemCount: expenses.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final expense = expenses[i];
        return SwipeableTile(
          itemId: expense.id,
          onDelete: () => widget.repository.removeExpense(expense.id),
          onEdit: () => _navigateToEdit(context, expense),
          child: ExpenseListTile(
            expense: expense,
            onTap: () => _openDetail(context, expense),
          ),
        );
      },
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No expenses in "${widget.groupName}".',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Navigation ──────────────────────────────────────────────────────────────

  void _openDetail(BuildContext context, Expense expense) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (routeContext) => ExpenseDetailScreen(
        expense: expense,
        onEdit: () {
          Navigator.of(routeContext).pop();
          _navigateToEdit(context, expense);
        },
        onDelete: () {
          Navigator.of(routeContext).pop();
          widget.repository.removeExpense(expense.id);
        },
      ),
    ));
  }

  void _navigateToEdit(BuildContext context, Expense expense) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(
          repository: widget.repository,
          existing: expense,
        ),
      ),
    );
  }
}
