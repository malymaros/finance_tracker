import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../services/finance_repository.dart';

class AddExpenseScreen extends StatefulWidget {
  final FinanceRepository repository;
  final Expense? existing;

  /// Pre-fills the date picker. Ignored when [existing] is provided.
  final DateTime? initialDate;

  const AddExpenseScreen({
    super.key,
    required this.repository,
    this.existing,
    this.initialDate,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late ExpenseCategory _selectedCategory;
  late FinancialType _selectedFinancialType;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _selectedCategory = e?.category ?? ExpenseCategory.groceries;
    _selectedFinancialType = e?.financialType ?? FinancialType.consumption;
    _selectedDate = e?.date ?? widget.initialDate ?? DateTime.now();
    if (e != null) {
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      financialType: _selectedFinancialType,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (widget.existing != null) {
      await widget.repository.updateExpense(expense);
    } else {
      await widget.repository.addExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
          title:
              Text(widget.existing != null ? 'Edit Expense' : 'Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Amount ──────────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: ' €',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter an amount';
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Category ────────────────────────────────────────────────────
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: (ExpenseCategory.values.toList()
                    ..sort((a, b) {
                      if (a == ExpenseCategory.other) return 1;
                      if (b == ExpenseCategory.other) return -1;
                      return a.displayName.compareTo(b.displayName);
                    }))
                  .map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 20, color: cat.color),
                      const SizedBox(width: 8),
                      Text(cat.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 16),

            // ── Financial type ───────────────────────────────────────────────
            const Text('Financial type',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<FinancialType>(
              segments: FinancialType.values
                  .map((t) => ButtonSegment(
                        value: t,
                        label: Text(t.displayName),
                        icon: Icon(t.icon),
                      ))
                  .toList(),
              selected: {_selectedFinancialType},
              onSelectionChanged: (s) =>
                  setState(() => _selectedFinancialType = s.first),
            ),
            const SizedBox(height: 16),

            // ── Date ────────────────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(formattedDate),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // ── Note ────────────────────────────────────────────────────────
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
