import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/plan_repository.dart';
import '../../theme/app_theme.dart';
import '../../utils/id_generator.dart';

class AddPlanItemScreen extends StatefulWidget {
  final PlanRepository planRepository;

  /// When non-null the form opens in edit mode.
  final PlanItem? existing;

  /// Pre-selects the item type when opening the form for a new item.
  /// Ignored when [existing] is non-null.
  final PlanItemType? initialType;

  /// Pre-selects the validFrom month for new items or for a new version of a
  /// recurring item. Defaults to [YearMonth.now] when null.
  final YearMonth? initialValidFrom;

  const AddPlanItemScreen({
    super.key,
    required this.planRepository,
    this.existing,
    this.initialType,
    this.initialValidFrom,
  });

  @override
  State<AddPlanItemScreen> createState() => _AddPlanItemScreenState();
}

class _AddPlanItemScreenState extends State<AddPlanItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  late PlanItemType _type;
  late PlanFrequency _frequency;
  late YearMonth _validFrom;
  YearMonth? _validTo;
  late ExpenseCategory _selectedCategory;
  late FinancialType _selectedFinancialType;

  // ── GUARD state ────────────────────────────────────────────────────────────
  bool _isGuarded = false;
  int _guardDueDay = 1;
  int _guardDueMonth = 1;
  bool _guardOneTime = false;

  bool get _typeIsLocked =>
      widget.existing != null || widget.initialType != null;

  String get _screenTitle {
    if (widget.existing != null) {
      return _type == PlanItemType.income ? 'Edit Income' : 'Edit Fixed Cost';
    }
    if (widget.initialType != null) {
      return _type == PlanItemType.income ? 'Add Income' : 'Add Fixed Cost';
    }
    return 'Add Plan Item';
  }

  bool get _canShowGuard =>
      _type == PlanItemType.fixedCost && _frequency != PlanFrequency.oneTime;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
      _type = e.type;
      _frequency = e.frequency;
      // Income edits and one-time items: always start from the item's own
      // validFrom — income is always updated in place, no new version.
      // Fixed cost recurring edits: use the selected period as the new version start.
      _validFrom = (e.type == PlanItemType.income ||
              e.frequency == PlanFrequency.oneTime)
          ? e.validFrom
          : (widget.initialValidFrom ?? YearMonth.now());
      _validTo = e.validTo;
      _selectedCategory = e.category ?? ExpenseCategory.other;
      _selectedFinancialType = e.financialType ?? FinancialType.consumption;
      // Restore GUARD settings from existing item.
      _isGuarded = e.isGuarded;
      _guardDueDay = e.guardDueDay ?? 1;
      _guardDueMonth = e.guardDueMonth ?? e.validFrom.month;
      _guardOneTime = e.guardOneTime;
    } else {
      _type = widget.initialType ?? PlanItemType.income;
      _frequency = PlanFrequency.monthly;
      _validFrom = widget.initialValidFrom ?? YearMonth.now();
      _selectedCategory = ExpenseCategory.other;
      _selectedFinancialType = FinancialType.consumption;
      _guardDueMonth = _validFrom.month;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
      setState(() => _validFrom = YearMonth(picked.year, picked.month));
    }
  }

  Future<void> _pickValidTo() async {
    final current = _validTo ?? _validFrom.addMonths(11);
    final initial = DateTime(current.year, current.month, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select end month (day is ignored)',
    );
    if (picked != null) {
      setState(() => _validTo = YearMonth(picked.year, picked.month));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validTo != null && _validTo!.isBefore(_validFrom)) return;

    final name = _nameController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final note =
        _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

    final e = widget.existing;
    final isFixedCost = _type == PlanItemType.fixedCost;

    // validTo applies to both income and fixedCost for monthly/yearly frequency.
    final savedValidTo = _frequency != PlanFrequency.oneTime ? _validTo : null;

    // GUARD fields: only persist for guarded recurring fixed costs.
    final guardEnabled = _canShowGuard && _isGuarded;
    final guardDueDay = guardEnabled ? _guardDueDay : null;
    final guardDueMonth = (guardEnabled && _frequency == PlanFrequency.yearly)
        ? _guardDueMonth
        : null;
    final guardOneTime = guardEnabled && _guardOneTime;

    if (e == null) {
      // New item — new series.
      final newId = IdGenerator.generate();
      await widget.planRepository.addPlanItem(PlanItem(
        id: newId,
        seriesId: newId,
        name: name,
        amount: amount,
        type: _type,
        frequency: _frequency,
        validFrom: _validFrom,
        validTo: savedValidTo,
        note: note,
        category: isFixedCost ? _selectedCategory : null,
        financialType: isFixedCost ? _selectedFinancialType : null,
        isGuarded: guardEnabled,
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth,
        guardOneTime: guardOneTime,
      ));
    } else {
      // Edit — versioning rules are owned by the repository.
      await widget.planRepository.applyPlanItemEdit(
        e,
        name: name,
        amount: amount,
        frequency: _frequency,
        startFrom: _validFrom,
        validTo: savedValidTo,
        note: note,
        category: isFixedCost ? _selectedCategory : null,
        financialType: isFixedCost ? _selectedFinancialType : null,
        isGuarded: guardEnabled,
        guardDueDay: guardDueDay,
        guardDueMonth: guardDueMonth,
        guardOneTime: guardOneTime,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildEndDateSection() {
    final hasEndDate = _validTo != null;
    final validToLabel = hasEndDate
        ? '${YearMonth.monthNames[_validTo!.month]} ${_validTo!.year}'
        : null;
    final isInvalid = hasEndDate && _validTo!.isBefore(_validFrom);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: hasEndDate,
              onChanged: (on) => setState(() {
                _validTo = on ? _validFrom.addMonths(11) : null;
              }),
            ),
            const SizedBox(width: 8),
            const Text('Set end date',
                style: TextStyle(fontSize: 14)),
          ],
        ),
        if (hasEndDate) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickValidTo,
            icon: const Icon(Icons.event_busy, size: 18),
            label: Text('Until: $validToLabel'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
          ),
          if (isInvalid)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'End month must be after start month.',
                style: TextStyle(fontSize: 12, color: AppColors.expense),
              ),
            ),
        ],
      ],
    );
  }

  // ── GUARD section ──────────────────────────────────────────────────────────

  Future<void> _pickGuardDueDay() async {
    final anchorMonth =
        _frequency == PlanFrequency.yearly ? _guardDueMonth : _validFrom.month;
    final daysInMonth = DateTime(_validFrom.year, anchorMonth + 1, 0).day;
    final safeDay = _guardDueDay.clamp(1, daysInMonth);

    int selected = safeDay;
    final title = _frequency == PlanFrequency.monthly
        ? 'Due day (repeats monthly)'
        : 'Due day';

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(title),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            decoration: const InputDecoration(
              labelText: 'Day of month',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: List.generate(daysInMonth, (i) {
              final d = i + 1;
              return DropdownMenuItem(value: d, child: Text('$d'));
            }),
            onChanged: (v) {
              if (v != null) setInner(() => selected = v);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(selected),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _guardDueDay = picked);
  }

  Widget _buildGuardSection() {
    final dueDayLabel = _frequency == PlanFrequency.monthly
        ? 'Day $_guardDueDay of each month'
        : 'Day $_guardDueDay of ${YearMonth.monthNames[_guardDueMonth]}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.pets, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GUARD',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    'Remind me to confirm this payment',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isGuarded,
              activeThumbColor: AppColors.gold,
              activeTrackColor: AppColors.gold.withAlpha(80),
              onChanged: (on) => setState(() => _isGuarded = on),
            ),
          ],
        ),
        if (_isGuarded) ...[
          const SizedBox(height: 12),
          // ── Recurring vs one-time ──────────────────────────────────────
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Recurring'),
                icon: Icon(Icons.repeat, size: 16),
              ),
              ButtonSegment(
                value: true,
                label: Text('One-time'),
                icon: Icon(Icons.looks_one_outlined, size: 16),
              ),
            ],
            selected: {_guardOneTime},
            onSelectionChanged: (s) =>
                setState(() => _guardOneTime = s.first),
          ),
          const SizedBox(height: 12),
          // ── Due month (yearly only) ────────────────────────────────────
          if (_frequency == PlanFrequency.yearly) ...[
            DropdownButtonFormField<int>(
              initialValue: _guardDueMonth,
              decoration: const InputDecoration(
                labelText: 'Due month',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: List.generate(12, (i) {
                final month = i + 1;
                return DropdownMenuItem(
                  value: month,
                  child: Text(YearMonth.monthNames[month]),
                );
              }),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _guardDueMonth = v;
                    // Re-clamp day to the new month.
                    final daysInNewMonth =
                        DateTime(_validFrom.year, v + 1, 0).day;
                    _guardDueDay = _guardDueDay.clamp(1, daysInNewMonth);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
          ],
          // ── Due day picker ─────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed: _pickGuardDueDay,
            icon: const Icon(Icons.event, size: 18),
            label: Text(dueDayLabel),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              side: const BorderSide(color: AppColors.gold),
              foregroundColor: AppColors.gold,
            ),
          ),
          if (_frequency == PlanFrequency.monthly && _guardDueDay > 28)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Shorter months will use their last day.',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
        ],
        const Divider(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final validFromLabel =
        '${YearMonth.monthNames[_validFrom.month]} ${_validFrom.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type (only shown when not locked by navigation or edit) ─────
            if (!_typeIsLocked) ...[
              const Text('Type',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              SegmentedButton<PlanItemType>(
                segments: const [
                  ButtonSegment(
                    value: PlanItemType.income,
                    label: Text('Income'),
                    icon: Icon(Icons.savings),
                  ),
                  ButtonSegment(
                    value: PlanItemType.fixedCost,
                    label: Text('Fixed Cost'),
                    icon: Icon(Icons.lock_outline),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) {
                  final newType = s.first;
                  setState(() {
                    _type = newType;
                    if (newType == PlanItemType.fixedCost &&
                        _frequency == PlanFrequency.oneTime) {
                      _frequency = PlanFrequency.monthly;
                    }
                    // Reset guard when switching away from fixedCost.
                    if (newType != PlanItemType.fixedCost) {
                      _isGuarded = false;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── GUARD (fixedCost recurring only, shown at top) ──────────────
            if (_canShowGuard) _buildGuardSection(),

            // ── Name ────────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Salary, Rent, Insurance',
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

            // ── Frequency ───────────────────────────────────────────────────
            const Text('Frequency',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 8),
            SegmentedButton<PlanFrequency>(
              segments: [
                const ButtonSegment(
                  value: PlanFrequency.monthly,
                  label: Text('Monthly'),
                  icon: Icon(Icons.repeat),
                ),
                const ButtonSegment(
                  value: PlanFrequency.yearly,
                  label: Text('Yearly'),
                  icon: Icon(Icons.event_repeat),
                ),
                if (_type == PlanItemType.income)
                  const ButtonSegment(
                    value: PlanFrequency.oneTime,
                    label: Text('One-time'),
                    icon: Icon(Icons.looks_one_outlined),
                  ),
              ],
              selected: {_frequency},
              onSelectionChanged: (s) => setState(() {
                _frequency = s.first;
                // Reset guard when switching to one-time.
                if (_frequency == PlanFrequency.oneTime) _isGuarded = false;
              }),
            ),
            const SizedBox(height: 16),

            // ── Category (fixedCost only) ────────────────────────────────────
            if (_type == PlanItemType.fixedCost) ...[
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
                  if (v != null) {
                    setState(() {
                      _selectedCategory = v;
                      _selectedFinancialType = v.defaultFinancialType;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
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
            ],

            // ── Valid from ──────────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickValidFrom,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: Text('From: $validFromLabel'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 16),
              ),
            ),
            if (isEditing &&
                _type == PlanItemType.fixedCost &&
                _frequency != PlanFrequency.oneTime)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _validFrom == widget.existing!.validFrom
                      ? 'Same month as original — will update in place.'
                      : 'Different month — will create a new version.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _validFrom == widget.existing!.validFrom
                        ? AppColors.textMuted
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ── End date (income or fixedCost, recurring only) ──────────────
            if (_frequency != PlanFrequency.oneTime) ...[
              _buildEndDateSection(),
              const SizedBox(height: 16),
            ],

            // ── Note ────────────────────────────────────────────────────────
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
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
