import 'package:flutter/material.dart';

import '../../models/category_budget.dart';
import '../../models/expense_category.dart';
import '../../models/year_month.dart';
import '../../services/category_budget_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/id_generator.dart';

class AddCategoryBudgetScreen extends StatefulWidget {
  final CategoryBudgetRepository budgetRepository;

  /// When non-null, the category selector is hidden and the category is locked.
  /// Used when editing an existing budget.
  final ExpenseCategory? initialCategory;

  final double? initialAmount;

  /// The month the budget should become effective. Defaults to [YearMonth.now].
  final YearMonth? initialValidFrom;

  /// Non-null when editing an existing series; null when creating a new budget.
  final String? seriesId;

  const AddCategoryBudgetScreen({
    super.key,
    required this.budgetRepository,
    this.initialCategory,
    this.initialAmount,
    this.initialValidFrom,
    this.seriesId,
  });

  @override
  State<AddCategoryBudgetScreen> createState() =>
      _AddCategoryBudgetScreenState();
}

class _AddCategoryBudgetScreenState extends State<AddCategoryBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  ExpenseCategory? _selectedCategory;
  late YearMonth _validFrom;

  bool get _isEditing => widget.seriesId != null;
  bool get _categoryLocked => widget.initialCategory != null;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _validFrom = widget.initialValidFrom ?? YearMonth.now();
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  bool get _isPastMonth => _validFrom.isBefore(YearMonth.now());

  List<ExpenseCategory> _availableCategories() {
    final existing =
        widget.budgetRepository.allActiveBudgetsForMonth(_validFrom);
    return (ExpenseCategory.values.toList()
          ..sort((a, b) {
            if (a == ExpenseCategory.other) return 1;
            if (b == ExpenseCategory.other) return -1;
            return a.displayName.compareTo(b.displayName);
          }))
        .where((c) => !existing.containsKey(c))
        .toList();
  }

  Future<void> _pickValidFrom() async {
    final initial = DateTime(_validFrom.year, _validFrom.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select start month (day is ignored)',
    );
    if (picked != null) {
      setState(() {
        _validFrom = YearMonth(picked.year, picked.month);
        // Reset selected category if it now conflicts with the new month.
        if (!_categoryLocked && _selectedCategory != null) {
          final existing =
              widget.budgetRepository.allActiveBudgetsForMonth(_validFrom);
          if (existing.containsKey(_selectedCategory)) {
            _selectedCategory = null;
          }
        }
      });
    }
  }

  String _pastMonthWarningText() {
    final fromLabel =
        '${YearMonth.monthNames[_validFrom.month]} ${_validFrom.year}';
    if (_isEditing) {
      final prevMonth = YearMonth.now().addMonths(-1);
      final prevLabel =
          '${YearMonth.monthNames[prevMonth.month]} ${prevMonth.year}';
      final catName = _selectedCategory?.displayName ?? 'this category';
      return 'This will change the $catName budget back to $fromLabel. '
          'Months $fromLabel\u2013$prevLabel will use the new amount.';
    }
    return 'You are creating a budget for a past month. '
        'It will apply retroactively from $fromLabel.';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final amount = double.parse(_amountController.text.trim());

    if (_isEditing) {
      await widget.budgetRepository.changeCategoryBudgetFrom(
        widget.seriesId!,
        _validFrom,
        amount,
      );
    } else {
      final newId = IdGenerator.generate();
      await widget.budgetRepository.addCategoryBudget(CategoryBudget(
        id: newId,
        seriesId: newId,
        category: _selectedCategory!,
        amount: amount,
        validFrom: _validFrom,
        validTo: null,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final validFromLabel =
        '${YearMonth.monthNames[_validFrom.month]} ${_validFrom.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Add Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Category ────────────────────────────────────────────────────
            if (_categoryLocked) ...[
              const Text(
                'Category',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.initialCategory!.icon,
                      size: 20,
                      color: widget.initialCategory!.color,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.initialCategory!.displayName),
                  ],
                ),
              ),
            ] else ...[
              Builder(builder: (context) {
                final available = _availableCategories();
                if (available.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.surface,
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: AppColors.textMuted),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All categories already have a budget for this month. '
                            'Select a different month to add another.',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<ExpenseCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select a category'),
                  items: available.map((cat) {
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
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Select a category' : null,
                );
              }),
            ],
            const SizedBox(height: 16),

            // ── Amount ───────────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Monthly budget',
                suffixText: ' €',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: _categoryLocked,
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

            // ── Effective from ───────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickValidFrom,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: Text('Effective from: $validFromLabel'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
              ),
            ),

            // ── Past-month warning ───────────────────────────────────────────
            if (_isPastMonth) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.warning.withAlpha(80)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pastMonthWarningText(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
