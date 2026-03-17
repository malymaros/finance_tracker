import 'package:flutter/material.dart';

import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/plan_repository.dart';

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
  static const _monthNames = [
    '',
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

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
      // One-time items: keep original validFrom (edit in place).
      // Recurring items: use the selected app period as the new version start.
      _validFrom = e.frequency == PlanFrequency.oneTime
          ? e.validFrom
          : (widget.initialValidFrom ?? YearMonth.now());
      _validTo = e.validTo;
      _selectedCategory = e.category ?? ExpenseCategory.other;
      _selectedFinancialType = e.financialType ?? FinancialType.consumption;
    } else {
      _type = widget.initialType ?? PlanItemType.income;
      _frequency = PlanFrequency.monthly;
      _validFrom = widget.initialValidFrom ?? YearMonth.now();
      _selectedCategory = ExpenseCategory.other;
      _selectedFinancialType = FinancialType.consumption;
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

    if (e == null) {
      // New item — new series
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      await widget.planRepository.addPlanItem(PlanItem(
        id: newId,
        seriesId: newId,
        name: name,
        amount: amount,
        type: _type,
        frequency: _frequency,
        validFrom: _validFrom,
        validTo: isFixedCost ? _validTo : null,
        note: note,
        category: isFixedCost ? _selectedCategory : null,
        financialType: isFixedCost ? _selectedFinancialType : null,
      ));
    } else if (_validFrom == e.validFrom) {
      // Same validFrom → fix in place (error correction)
      await widget.planRepository.updatePlanItem(PlanItem(
        id: e.id,
        seriesId: e.seriesId,
        name: name,
        amount: amount,
        type: _type,
        frequency: _frequency,
        validFrom: _validFrom,
        validTo: isFixedCost ? _validTo : null,
        note: note,
        category: isFixedCost ? _selectedCategory : null,
        financialType: isFixedCost ? _selectedFinancialType : null,
      ));
    } else {
      // Different validFrom → new version of same series (validTo defaults to null)
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      await widget.planRepository.addPlanItem(PlanItem(
        id: newId,
        seriesId: e.seriesId,
        name: name,
        amount: amount,
        type: _type,
        frequency: _frequency,
        validFrom: _validFrom,
        validTo: isFixedCost ? _validTo : null,
        note: note,
        category: isFixedCost ? _selectedCategory : null,
        financialType: isFixedCost ? _selectedFinancialType : null,
      ));
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _buildEndDateSection() {
    final hasEndDate = _validTo != null;
    final validToLabel = hasEndDate
        ? '${_monthNames[_validTo!.month]} ${_validTo!.year}'
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
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final validFromLabel =
        '${_monthNames[_validFrom.month]} ${_validFrom.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Plan Item' : 'Add Plan Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type ────────────────────────────────────────────────────────
            const Text('Type',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            SegmentedButton<PlanItemType>(
              segments: const [
                ButtonSegment(
                  value: PlanItemType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.trending_up),
                ),
                ButtonSegment(
                  value: PlanItemType.fixedCost,
                  label: Text('Fixed Cost'),
                  icon: Icon(Icons.payments_outlined),
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
                });
              },
            ),
            const SizedBox(height: 16),

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
                style: TextStyle(fontSize: 12, color: Colors.grey)),
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
              onSelectionChanged: (s) => setState(() => _frequency = s.first),
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
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),
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
            if (isEditing && _frequency != PlanFrequency.oneTime)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _validFrom == widget.existing!.validFrom
                      ? 'Same month as original — will update in place.'
                      : 'Different month — will create a new version.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _validFrom == widget.existing!.validFrom
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ── End date (fixedCost recurring only) ─────────────────────────
            if (_type == PlanItemType.fixedCost &&
                _frequency != PlanFrequency.oneTime)
              _buildEndDateSection(),
            const SizedBox(height: 16),

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
