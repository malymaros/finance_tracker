import 'package:flutter/material.dart';

import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/imported_expense.dart';
import '../services/currency_formatter.dart';
import '../theme/app_theme.dart';

/// Full-screen edit for a single [ImportedExpense] before it is committed.
///
/// Pops with:
///   - an [ImportedExpense] → user saved (replace the row)
///   - [EditImportRowSheet.deleted] → user removed this row from the import
///   - null → user cancelled (no change)
///
/// Layout is intentionally identical to AddExpenseScreen.
class EditImportRowSheet extends StatefulWidget {
  static const String deleted = '__deleted__';

  final ImportedExpense expense;

  const EditImportRowSheet({super.key, required this.expense});

  @override
  State<EditImportRowSheet> createState() => _EditImportRowSheetState();
}

class _EditImportRowSheetState extends State<EditImportRowSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _groupController = TextEditingController();

  late ExpenseCategory _selectedCategory;
  late FinancialType _selectedFinancialType;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _selectedCategory = e.category;
    _selectedFinancialType = e.financialType;
    _selectedDate = e.date;
    _amountController.text = e.amount.toStringAsFixed(2);
    _noteController.text = e.note ?? '';
    _groupController.text = e.group ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final updated = ImportedExpense(
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory,
      financialType: _selectedFinancialType,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      group: _groupController.text.trim().isEmpty
          ? null
          : _groupController.text.trim(),
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Remove from import',
            onPressed: () =>
                Navigator.of(context).pop(EditImportRowSheet.deleted),
          ),
        ],
      ),
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
                suffixText: ' ${CurrencyFormatter.currencySymbol}',
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
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, size: 20, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.displayName),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),
            const SizedBox(height: 16),

            // ── Financial type ───────────────────────────────────────────────
            const Text('Financial type',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
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
            const SizedBox(height: 16),

            // ── Group ────────────────────────────────────────────────────────
            TextFormField(
              controller: _groupController,
              decoration: const InputDecoration(
                labelText: 'Group (optional)',
                hintText: 'e.g. Vacation, Birthday',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
