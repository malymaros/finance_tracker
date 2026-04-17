import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/category_budget.dart';
import '../../models/expense_category.dart';
import '../../models/year_month.dart';
import '../../services/category_budget_repository.dart';
import '../../services/currency_formatter.dart';
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

  /// When editing, the earliest allowed effective-from month (the series start).
  final YearMonth? minValidFrom;

  /// When true, the effective-from field is shown as read-only (closed series).
  final bool validFromLocked;

  const AddCategoryBudgetScreen({
    super.key,
    required this.budgetRepository,
    this.initialCategory,
    this.initialAmount,
    this.initialValidFrom,
    this.seriesId,
    this.minValidFrom,
    this.validFromLocked = false,
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

  // Suppress past-month warning when the effective-from is locked (closed
  // series edit) — the date is fixed to the version's own validFrom and the
  // warning text would reference wrong date bounds.
  bool get _isPastMonth =>
      !widget.validFromLocked && _validFrom.isBefore(YearMonth.now());

  List<ExpenseCategory> _availableCategories() {
    final existing =
        widget.budgetRepository.allActiveBudgetsForMonth(_validFrom);
    return (ExpenseCategory.values.toList()
          ..sort((a, b) {
            if (a == ExpenseCategory.other) return 1;
            if (b == ExpenseCategory.other) return -1;
            return context.l10n.categoryName(a).compareTo(context.l10n.categoryName(b));
          }))
        .where((c) => !existing.containsKey(c))
        .toList();
  }

  Future<void> _pickValidFrom() async {
    final picked = await showDialog<YearMonth>(
      context: context,
      builder: (ctx) => _MonthPickerDialog(
        initial: _validFrom,
        min: widget.minValidFrom,
        max: YearMonth(YearMonth.now().year + 10, 12),
      ),
    );
    if (picked != null) {
      setState(() {
        _validFrom = picked;
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

  String _pastMonthWarningText(AppLocalizations l10n) {
    final fromLabel =
        '${l10n.monthName(_validFrom.month)} ${_validFrom.year}';
    if (_isEditing) {
      final prevMonth = YearMonth.now().addMonths(-1);
      final prevLabel =
          '${l10n.monthName(prevMonth.month)} ${prevMonth.year}';
      final catName = _selectedCategory != null
          ? l10n.categoryName(_selectedCategory!)
          : 'this category';
      return l10n.pastMonthBudgetEditWarning(catName, fromLabel, prevLabel);
    }
    return l10n.pastMonthBudgetCreateWarning(fromLabel);
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
    final l10n = context.l10n;
    final validFromLabel =
        '${l10n.monthName(_validFrom.month)} ${_validFrom.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editBudgetTitle : l10n.addBudgetTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Category ────────────────────────────────────────────────────
            if (_categoryLocked) ...[
              Text(
                l10n.labelCategory,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
                    Text(l10n.categoryName(widget.initialCategory!)),
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
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.allCategoriesBudgeted,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<ExpenseCategory>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: l10n.labelCategory,
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(l10n.selectCategoryHint),
                  items: available.map((cat) {
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
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) =>
                      v == null ? l10n.validationSelectCategory : null,
                );
              }),
            ],
            const SizedBox(height: 16),

            // ── Amount ───────────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.monthlyBudgetLabel,
                suffixText: ' ${CurrencyFormatter.currencySymbol}',
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: _categoryLocked,
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

            // ── Effective from ───────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: widget.validFromLocked ? null : _pickValidFrom,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: Text(l10n.effectiveFromLabel(validFromLabel)),
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
                        _pastMonthWarningText(l10n),
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
              child: Text(l10n.actionSave),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthPickerDialog extends StatefulWidget {
  final YearMonth initial;
  final YearMonth? min;
  final YearMonth? max;
  const _MonthPickerDialog({required this.initial, this.min, this.max});

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _year = widget.initial.year;
    _selectedMonth = widget.initial.month;
  }

  bool _isDisabled(int month) {
    final ym = YearMonth(_year, month);
    if (widget.min != null && ym.isBefore(widget.min!)) return true;
    if (widget.max != null && ym.isAfter(widget.max!)) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final canGoBack = widget.min == null || _year > widget.min!.year;
    final canGoForward = widget.max == null || _year < widget.max!.year;
    bool isSelected(int month) =>
        month == _selectedMonth && _year == widget.initial.year;
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: canGoBack ? () => setState(() => _year--) : null,
          ),
          Text('$_year'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoForward ? () => setState(() => _year++) : null,
          ),
        ],
      ),
      content: SizedBox(
        width: 280,
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2,
          children: List.generate(12, (i) {
            final month = i + 1;
            final disabled = _isDisabled(month);
            return InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: disabled
                  ? null
                  : () => Navigator.of(context).pop(YearMonth(_year, month)),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected(month)
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: disabled
                        ? AppColors.border.withAlpha(80)
                        : isSelected(month)
                            ? colorScheme.primary
                            : AppColors.border,
                  ),
                ),
                child: Text(
                  l10n.monthAbbr(month),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: disabled
                        ? AppColors.textMuted.withAlpha(80)
                        : isSelected(month)
                            ? colorScheme.onPrimary
                            : null,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
      ],
    );
  }
}
