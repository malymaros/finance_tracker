import 'package:flutter/material.dart';

import '../../models/fixed_cost.dart';
import '../../services/finance_repository.dart';

class AddFixedCostScreen extends StatefulWidget {
  final FinanceRepository repository;
  final FixedCost? existing;

  const AddFixedCostScreen({super.key, required this.repository, this.existing});

  @override
  State<AddFixedCostScreen> createState() => _AddFixedCostScreenState();
}

class _AddFixedCostScreenState extends State<AddFixedCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  late Recurrence _recurrence;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _recurrence = e?.recurrence ?? Recurrence.monthly;
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
      setState(() =>
          _startDate = DateTime(picked.year, picked.month, 1));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cost = FixedCost(
      id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      recurrence: _recurrence,
      startYear: _startDate.year,
      startMonth: _startDate.month,
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
      appBar: AppBar(title: Text(widget.existing != null ? 'Edit Fixed Cost' : 'Add Fixed Cost')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: ' €',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter an amount';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            OutlinedButton.icon(
              onPressed: _pickStartDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text('Starts: $formattedStart'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
