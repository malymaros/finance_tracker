import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/fixed_cost.dart';
import '../../services/finance_repository.dart';

class AddFixedCostScreen extends StatefulWidget {
  final FinanceRepository repository;
  final FixedCost? existing;

  const AddFixedCostScreen(
      {super.key, required this.repository, this.existing});

  @override
  State<AddFixedCostScreen> createState() => _AddFixedCostScreenState();
}

class _AddFixedCostScreenState extends State<AddFixedCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  late Recurrence _recurrence;
  late ExpenseCategory _selectedCategory;
  late FinancialType _selectedFinancialType;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _recurrence = e?.recurrence ?? Recurrence.monthly;
    _selectedCategory = e?.category ?? ExpenseCategory.other;
    _selectedFinancialType = e?.financialType ?? FinancialType.consumption;
    _startDate = e != null
        ? DateTime(e.startYear, e.startMonth, 1)
        : DateTime(DateTime.now().year, DateTime.now().month, 1);
    if (e != null) {
      _nameController.text = e.name;
      _amountController.text = e.amount.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10),
      helpText: 'Select start month',
    );
    if (picked != null) {
      setState(() => _startDate = DateTime(picked.year, picked.month, 1));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cost = FixedCost(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      recurrence: _recurrence,
      startYear: _startDate.year,
      startMonth: _startDate.month,
      category: _selectedCategory,
      financialType: _selectedFinancialType,
    );

    if (widget.existing != null) {
      await widget.repository.updateFixedCost(cost);
    } else {
      await widget.repository.addFixedCost(cost);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedStart =
        '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing != null
              ? 'Edit Fixed Cost'
              : 'Add Fixed Cost')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Name ────────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),

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
              items: ExpenseCategory.values.map((cat) {
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

            // ── Recurrence ──────────────────────────────────────────────────
            const Text('Recurrence',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<Recurrence>(
              segments: const [
                ButtonSegment(
                  value: Recurrence.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.repeat),
                ),
                ButtonSegment(
                  value: Recurrence.yearly,
                  label: Text('Yearly'),
                  icon: Icon(Icons.event_repeat),
                ),
              ],
              selected: {_recurrence},
              onSelectionChanged: (s) =>
                  setState(() => _recurrence = s.first),
            ),
            const SizedBox(height: 16),

            // ── Start date ──────────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text('Starts: $formattedStart'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
              ),
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
