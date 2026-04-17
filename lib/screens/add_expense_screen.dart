import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../l10n/l10n_extensions.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../services/currency_formatter.dart';
import '../services/finance_repository.dart';
import '../theme/app_theme.dart';
import '../utils/id_generator.dart';

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
  final _groupController = TextEditingController();

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
      _groupController.text = e.group ?? '';
    }
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
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = Expense(
      id: widget.existing?.id ??
          IdGenerator.generate(),
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

    if (widget.existing != null) {
      await widget.repository.updateExpense(expense);
    } else {
      await widget.repository.addExpense(expense);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formattedDate =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing != null
              ? l10n.editExpenseTitle
              : l10n.addExpenseTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Amount ──────────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.labelAmount,
                suffixText: ' ${CurrencyFormatter.currencySymbol}',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return l10n.validationAmountEmpty;
                }
                final parsed = double.tryParse(v.trim());
                if (parsed == null || parsed <= 0) {
                  return l10n.validationAmountInvalid;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Category ────────────────────────────────────────────────────
            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.labelCategory,
                border: const OutlineInputBorder(),
              ),
              items: (ExpenseCategory.values.toList()
                    ..sort((a, b) {
                      if (a == ExpenseCategory.other) return 1;
                      if (b == ExpenseCategory.other) return -1;
                      return l10n.categoryName(a).compareTo(l10n.categoryName(b));
                    }))
                  .map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 20, color: cat.color),
                      const SizedBox(width: 8),
                      Text(l10n.categoryName(cat)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedCategory = v;
                    _selectedFinancialType = v.defaultFinancialType;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // ── Financial type ───────────────────────────────────────────────
            Text(l10n.labelFinancialType,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            SegmentedButton<FinancialType>(
              segments: FinancialType.values
                  .map((t) => ButtonSegment(
                        value: t,
                        label: Text(l10n.financialTypeName(t)),
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
              decoration: InputDecoration(
                labelText: l10n.labelNoteOptional,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // ── Group ────────────────────────────────────────────────────────
            TextFormField(
              controller: _groupController,
              decoration: InputDecoration(
                labelText: l10n.labelGroupOptional,
                hintText: l10n.groupHintText,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _submit,
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}
