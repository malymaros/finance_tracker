import 'package:flutter/material.dart';

import '../../models/income_entry.dart';
import '../../services/finance_repository.dart';

class AddIncomeScreen extends StatefulWidget {
  final FinanceRepository repository;

  const AddIncomeScreen({super.key, required this.repository});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  IncomeType _selectedType = IncomeType.monthly;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

    await widget.repository.addIncome(IncomeEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      type: _selectedType,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    ));

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: ' €',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
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
            const Text('Type', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<IncomeType>(
              segments: const [
                ButtonSegment(
                  value: IncomeType.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.repeat),
                ),
                ButtonSegment(
                  value: IncomeType.oneTime,
                  label: Text('One-time'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (s) =>
                  setState(() => _selectedType = s.first),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(formattedDate),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
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
