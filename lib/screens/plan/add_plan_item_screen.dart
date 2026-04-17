import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../l10n/l10n_extensions.dart';
import '../../models/expense_category.dart';
import '../../models/financial_type.dart';
import '../../models/plan_item.dart';
import '../../models/year_month.dart';
import '../../services/currency_formatter.dart';
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

  /// Pre-selects the frequency when opening the form for a new income or
  /// fixed-cost item. Ignored when [existing] is non-null. When set, the
  /// frequency selector is hidden and the frequency is locked for the session.
  final PlanFrequency? initialFrequency;

  /// Pre-selects the validFrom month for new items or for a new version of a
  /// recurring item. Defaults to [YearMonth.now] when null.
  final YearMonth? initialValidFrom;

  const AddPlanItemScreen({
    super.key,
    required this.planRepository,
    this.existing,
    this.initialType,
    this.initialFrequency,
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

  /// Type is locked when editing or when pre-set via [initialType].
  bool get _typeIsLocked =>
      widget.existing != null || widget.initialType != null;

  /// Frequency is locked when editing or when pre-set via [initialFrequency].
  bool get _frequencyIsLocked =>
      widget.existing != null || widget.initialFrequency != null;

  String _computeScreenTitle(AppLocalizations l10n) {
    if (widget.existing != null) {
      if (_type == PlanItemType.income) {
        return switch (_frequency) {
          PlanFrequency.yearly  => l10n.editYearlyIncomeTitle,
          PlanFrequency.oneTime => l10n.editOneTimeIncomeTitle,
          _                     => l10n.editMonthlyIncomeTitle,
        };
      }
      return _frequency == PlanFrequency.yearly
          ? l10n.editYearlyFixedCostTitle
          : l10n.editMonthlyFixedCostTitle;
    }
    if (widget.initialType != null) {
      if (_type == PlanItemType.income) {
        return switch (_frequency) {
          PlanFrequency.yearly  => l10n.addYearlyIncomeTitle,
          PlanFrequency.oneTime => l10n.addOneTimeIncomeTitle,
          _                     => l10n.addMonthlyIncomeTitle,
        };
      }
      return _frequency == PlanFrequency.yearly
          ? l10n.addYearlyFixedCostTitle
          : l10n.addMonthlyFixedCostTitle;
    }
    return l10n.addPlanItemTitle;
  }

  bool get _canShowGuard =>
      _type == PlanItemType.fixedCost && _frequency != PlanFrequency.oneTime;

  /// True when editing an existing yearly fixed cost. In this mode the
  /// From/Until dates are locked (only name, amount, category, financial type
  /// and note are editable) and the save dialog offers whole-series or
  /// split-from-next-period choices.
  bool get _isEditingYearlyFixedCost =>
      widget.existing != null &&
      _type == PlanItemType.fixedCost &&
      _frequency == PlanFrequency.yearly;

  // ── Yearly helpers ─────────────────────────────────────────────────────────

  /// The next occurrence of the anchor month (validFrom.month) that is
  /// strictly after [YearMonth.now()]. This is the earliest date from which
  /// a split can start.
  YearMonth _nextUpcomingPeriod() {
    final anchor = widget.existing!.validFrom.month;
    final now = YearMonth.now();
    final year = anchor <= now.month ? now.year + 1 : now.year;
    return YearMonth(year, anchor);
  }

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
      // Yearly fixed cost edits: From is locked, always show e.validFrom.
      // Monthly fixed cost edits: use the selected period as the new version start.
      _validFrom = (e.type == PlanItemType.income ||
              e.frequency == PlanFrequency.oneTime ||
              e.frequency == PlanFrequency.yearly)
          ? e.validFrom
          : (widget.initialValidFrom ?? YearMonth.now());
      _validTo = e.validTo;
      _selectedCategory = e.category ?? ExpenseCategory.other;
      _selectedFinancialType = e.financialType ?? FinancialType.consumption;
      // Restore GUARD settings from existing item.
      _isGuarded = e.isGuarded;
      _guardDueDay = e.guardDueDay ?? 1;
    } else {
      _type = widget.initialType ?? PlanItemType.income;
      _frequency = widget.initialFrequency ?? PlanFrequency.monthly;
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

  // ── Month/year picker ──────────────────────────────────────────────────────

  /// Shows a dialog with month and year dropdowns. Returns the selected
  /// [YearMonth] or null if the user cancelled.
  Future<YearMonth?> _showMonthYearPicker(
    BuildContext context, {
    required YearMonth initial,
    int firstYear = 2000,
    int lastYear = 2100,
  }) {
    return showDialog<YearMonth>(
      context: context,
      builder: (ctx) {
        var selectedMonth = initial.month;
        var selectedYear = initial.year.clamp(firstYear, lastYear);
        return StatefulBuilder(
          builder: (ctx, setInner) => AlertDialog(
            title: Text(ctx.l10n.selectMonthTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedMonth,
                  decoration: InputDecoration(
                    labelText: ctx.l10n.labelMonth,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: List.generate(12, (i) {
                    final m = i + 1;
                    return DropdownMenuItem(
                      value: m,
                      child: Text(ctx.l10n.monthName(m)),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) setInner(() => selectedMonth = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedYear,
                  decoration: InputDecoration(
                    labelText: ctx.l10n.labelYear,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: List.generate(
                    lastYear - firstYear + 1,
                    (i) {
                      final y = firstYear + i;
                      return DropdownMenuItem(value: y, child: Text('$y'));
                    },
                  ),
                  onChanged: (v) {
                    if (v != null) setInner(() => selectedYear = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(ctx.l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.of(ctx).pop(YearMonth(selectedYear, selectedMonth)),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickValidFrom() async {
    final now = YearMonth.now();
    final picked = await _showMonthYearPicker(
      context,
      initial: _validFrom,
      firstYear: now.year - 10,
      lastYear: now.year + 20,
    );
    if (picked != null) {
      setState(() {
        _validFrom = picked;
        // Keep validTo consistent for yearly items: maintain the same number
        // of cycles with the new anchor month.
        // validTo = YearMonth(lastCycleYear + 1, anchorMonth).addMonths(-1)
        // so lastCycleYear = validTo.addMonths(1).year - 1
        if (_frequency == PlanFrequency.yearly && _validTo != null) {
          final lastCycleYear = _validTo!.addMonths(1).year - 1;
          _validTo = YearMonth(lastCycleYear + 1, picked.month).addMonths(-1);
        }
      });
    }
  }

  Future<void> _pickValidTo() async {
    if (_frequency == PlanFrequency.yearly) {
      await _pickYearlyEndYear();
    } else {
      final picked = await _showMonthYearPicker(
        context,
        initial: _validTo ?? _validFrom.addMonths(11),
        firstYear: _validFrom.year,
        lastYear: _validFrom.year + 20,
      );
      if (picked != null) setState(() => _validTo = picked);
    }
  }

  /// For yearly items: shows a picker where the user selects the last renewal
  /// year. The stored [validTo] is the month BEFORE the next cycle would start
  /// (= last inclusive active month).
  ///
  /// Example: anchor = March, last renewal year = 2026
  ///   → validTo = February 2027  (March 2026 through February 2027 = 12 months)
  Future<void> _pickYearlyEndYear() async {
    final anchorMonth = _validFrom.month;

    // Derive the current "last renewal year" from existing validTo.
    // validTo = YearMonth(lastRenewalYear + 1, anchorMonth).addMonths(-1)
    // → lastRenewalYear = validTo.addMonths(1).year - 1
    int currentLastRenewalYear;
    if (_validTo != null) {
      final next = _validTo!.addMonths(1);
      currentLastRenewalYear = next.month == anchorMonth
          ? next.year - 1
          : _validFrom.year; // fallback for legacy data
    } else {
      currentLastRenewalYear = _validFrom.year;
    }

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        var selected = currentLastRenewalYear;
        return StatefulBuilder(
          builder: (ctx, setInner) {
            final endDate =
                YearMonth(selected + 1, anchorMonth).addMonths(-1);
            final l10n = ctx.l10n;
            return AlertDialog(
              title: Text(l10n.lastRenewalYearTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selected,
                    decoration: InputDecoration(
                      labelText: l10n.lastMonthRenewal(l10n.monthName(anchorMonth)),
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: List.generate(20, (i) {
                      final y = _validFrom.year + i;
                      return DropdownMenuItem(
                        value: y,
                        child: Text('${l10n.monthName(anchorMonth)} $y'),
                      );
                    }),
                    onChanged: (v) {
                      if (v != null) setInner(() => selected = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.lastActiveMonthInfo(l10n.yearMonthLabel(endDate)),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textMuted),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(selected),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() =>
          _validTo = YearMonth(picked + 1, anchorMonth).addMonths(-1));
    }
  }

  /// Shows the save-choice dialog for yearly fixed cost edits.
  ///
  /// Returns true  → apply to whole series (in-place update).
  /// Returns false → split from the next upcoming period (new series).
  /// Returns null  → cancelled.
  Future<bool?> _showYearlySaveDialog() async {
    final nextPeriod = _nextUpcomingPeriod();
    final nextLabel = context.l10n.yearMonthLabel(nextPeriod);
    final capLabel = context.l10n.yearMonthLabel(nextPeriod.addMonths(-1));
    final seriesStartLabel = context.l10n.yearMonthLabel(widget.existing!.validFrom);

    // Check whether the split is meaningful: nextPeriod must still be within
    // the item's active range (for bounded items).
    final e = widget.existing!;
    final canSplit =
        e.validTo == null || nextPeriod.isAtOrBefore(e.validTo!);

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.applyChangesToTitle),
          contentPadding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option 1 — whole series
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.navy),
                title: Text(l10n.applyToWholeSeries,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.applyToWholeSeriesSubtitle(seriesStartLabel)),
                onTap: () => Navigator.of(ctx).pop(true),
              ),
              const Divider(height: 1),
              // Option 2 — split from next period
              ListTile(
                enabled: canSplit,
                leading: Icon(Icons.call_split,
                    color: canSplit ? AppColors.navy : AppColors.border),
                title: Text(l10n.applyFromOnwards(nextLabel),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: canSplit ? null : AppColors.textMuted,
                    )),
                subtitle: Text(
                  canSplit
                      ? l10n.applyFromSubtitle(capLabel, nextLabel)
                      : l10n.applyFromUnavailable,
                ),
                onTap: canSplit ? () => Navigator.of(ctx).pop(false) : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l10n.actionCancel),
            ),
          ],
        );
      },
    );
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

    final savedValidTo = _frequency != PlanFrequency.oneTime ? _validTo : null;

    // GUARD fields: only persist for guarded recurring fixed costs.
    final guardEnabled = _canShowGuard && _isGuarded;
    final guardDueDay = guardEnabled ? _guardDueDay : null;

    if (e == null) {
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
      ));
    } else if (_isEditingYearlyFixedCost) {
      // Yearly fixed cost edits: show choice dialog (whole series vs split).
      final wholeSeries = await _showYearlySaveDialog();
      if (wholeSeries == null || !mounted) return; // cancelled

      if (wholeSeries) {
        // Apply to whole (currently active) series version in place.
        await widget.planRepository.applyPlanItemEdit(
          e,
          name: name,
          amount: amount,
          frequency: _frequency,
          startFrom: e.validFrom, // same validFrom → triggers in-place update
          validTo: e.validTo,     // keep original dates (locked in form)
          note: note,
          category: isFixedCost ? _selectedCategory : null,
          financialType: isFixedCost ? _selectedFinancialType : null,
          isGuarded: guardEnabled,
          guardDueDay: guardDueDay,
        );
      } else {
        // Split: cap old series, create new independent series.
        await widget.planRepository.splitYearlySeries(
          e,
          newSeriesStart: _nextUpcomingPeriod(),
          name: name,
          amount: amount,
          category: isFixedCost ? _selectedCategory : null,
          financialType: isFixedCost ? _selectedFinancialType : null,
          note: note,
          isGuarded: guardEnabled,
          guardDueDay: guardDueDay,
        );
      }
    } else {
      // Income / monthly fixed cost / one-time: standard edit flow.
      final result = await widget.planRepository.applyPlanItemEdit(
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
      );

      if (result == PlanItemEditResult.invalidYearlyCycleBoundary) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.yearlyItemsOnlyAtRenewal),
            ),
          );
        }
        return;
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  /// A read-only date field shown when the date cannot be edited (e.g. yearly
  /// fixed cost edit mode).
  Widget _buildLockedDateRow({
    required String label,
    required String value,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.lock_outline,
                size: 16, color: AppColors.textMuted),
          ),
          child: Text(value,
              style: const TextStyle(color: AppColors.textMuted)),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(hint,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textMuted)),
          ),
      ],
    );
  }

  Widget _buildEndDateSection() {
    final hasEndDate = _validTo != null;
    final isYearly = _frequency == PlanFrequency.yearly;
    final isInvalid = hasEndDate && _validTo!.isBefore(_validFrom);

    final String? validToLabel = hasEndDate ? context.l10n.yearMonthLabel(_validTo!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: hasEndDate,
              onChanged: (on) => setState(() {
                if (on) {
                  // Yearly: one full cycle = 12 months; validTo is the last
                  // inclusive month (month before next cycle starts).
                  _validTo = isYearly
                      ? YearMonth(_validFrom.year + 1, _validFrom.month)
                          .addMonths(-1)
                      : _validFrom.addMonths(11);
                } else {
                  _validTo = null;
                }
              }),
            ),
            const SizedBox(width: 8),
            Builder(
              builder: (context) => Text(
                context.l10n.setEndDate,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        if (hasEndDate) ...[
          const SizedBox(height: 8),
          Builder(
            builder: (context) => OutlinedButton.icon(
              onPressed: _pickValidTo,
              icon: const Icon(Icons.event_busy, size: 18),
              label: Text(context.l10n.untilLabel(validToLabel!)),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
          ),
          if (isYearly && hasEndDate)
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  context.l10n.lastActiveMonthNote(context.l10n.yearMonthLabel(_validTo!)),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ),
            ),
          if (isInvalid)
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  context.l10n.endMonthAfterStart,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.expense),
                ),
              ),
            ),
        ],
      ],
    );
  }

  // ── GUARD section ──────────────────────────────────────────────────────────

  Future<void> _pickGuardDueDay() async {
    // For yearly items the anchor month is always validFrom.month.
    final anchorMonth = _validFrom.month;
    final daysInMonth = DateTime(_validFrom.year, anchorMonth + 1, 0).day;
    final safeDay = _guardDueDay.clamp(1, daysInMonth);

    int selected = safeDay;
    final l10n = context.l10n;
    final title = _frequency == PlanFrequency.monthly
        ? l10n.dueDayMonthly
        : l10n.dueDayYearly(l10n.monthName(anchorMonth));

    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          title: Text(title),
          content: DropdownButtonFormField<int>(
            initialValue: selected,
            decoration: InputDecoration(
              labelText: ctx.l10n.labelDayOfMonth,
              border: const OutlineInputBorder(),
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
              child: Text(ctx.l10n.actionCancel),
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
    return Builder(builder: (context) {
      final l10n = context.l10n;
      final anchorMonth = _validFrom.month;
      final dueDayLabel = _frequency == PlanFrequency.monthly
          ? l10n.dueDayMonthlyLabel(_guardDueDay)
          : l10n.dueDayYearlyLabel(_guardDueDay, l10n.monthName(anchorMonth));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GUARD',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      l10n.guardRemindMe,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
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
            // ── Due day picker ─────────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _pickGuardDueDay,
              icon: const Icon(Icons.event, size: 18),
              label: Text(dueDayLabel),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                side: const BorderSide(color: AppColors.gold),
                foregroundColor: AppColors.gold,
              ),
            ),
            if (_guardDueDay > 28)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  l10n.guardShorterMonths,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
              ),
          ],
          const Divider(height: 24),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = widget.existing != null;
    final validFromLabel = l10n.yearMonthLabel(_validFrom);

    return Scaffold(
      appBar: AppBar(
        title: Text(_computeScreenTitle(l10n)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Type (only shown when not locked by navigation or edit) ─────
            if (!_typeIsLocked) ...[
              Text(l10n.labelType,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              SegmentedButton<PlanItemType>(
                segments: [
                  ButtonSegment(
                    value: PlanItemType.income,
                    label: Text(l10n.typeIncome),
                    icon: const Icon(Icons.savings),
                  ),
                  ButtonSegment(
                    value: PlanItemType.fixedCost,
                    label: Text(l10n.typeFixedCost),
                    icon: const Icon(Icons.lock_outline),
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
              decoration: InputDecoration(
                labelText: l10n.labelName,
                hintText: l10n.nameHintText,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.validationEnterName : null,
            ),
            const SizedBox(height: 16),

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

            // ── Frequency ───────────────────────────────────────────────────
            if (!_frequencyIsLocked) ...[
              Text(l10n.labelFrequency,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              SegmentedButton<PlanFrequency>(
                segments: [
                  ButtonSegment(
                    value: PlanFrequency.monthly,
                    label: Text(l10n.frequencyMonthly),
                    icon: const Icon(Icons.repeat),
                  ),
                  ButtonSegment(
                    value: PlanFrequency.yearly,
                    label: Text(l10n.frequencyYearly),
                    icon: const Icon(Icons.event_repeat),
                  ),
                  if (_type == PlanItemType.income)
                    ButtonSegment(
                      value: PlanFrequency.oneTime,
                      label: Text(l10n.frequencyOneTime),
                      icon: const Icon(Icons.looks_one_outlined),
                    ),
                ],
                selected: {_frequency},
                onSelectionChanged: (s) => setState(() {
                  _frequency = s.first;
                  if (_frequency == PlanFrequency.oneTime) _isGuarded = false;
                }),
              ),
              const SizedBox(height: 16),
            ],

            // ── Category (fixedCost only) ────────────────────────────────────
            if (_type == PlanItemType.fixedCost) ...[
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
              Text(l10n.labelFinancialType,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted)),
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
            ],

            // ── Valid from / Until ──────────────────────────────────────────
            if (_isEditingYearlyFixedCost) ...[
              _buildLockedDateRow(
                label: l10n.fromFieldLabel,
                value: validFromLabel,
                hint: l10n.renewedEachMonth(l10n.monthName(_validFrom.month)),
              ),
              const SizedBox(height: 12),
              _buildLockedDateRow(
                label: l10n.untilFieldLabel,
                value: _validTo != null
                    ? l10n.lastActiveMonthParens(l10n.yearMonthLabel(_validTo!))
                    : l10n.openEnded,
              ),
              const SizedBox(height: 16),
            ] else ...[
              OutlinedButton.icon(
                onPressed: _pickValidFrom,
                icon: const Icon(Icons.calendar_month, size: 18),
                label: Text(l10n.fromDateLabel(validFromLabel)),
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
                        ? l10n.samePeriodInPlace
                        : l10n.differentPeriodNewVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: _validFrom == widget.existing!.validFrom
                          ? AppColors.textMuted
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // ── End date (income or fixedCost, recurring only) ──────────
              if (_frequency != PlanFrequency.oneTime) ...[
                _buildEndDateSection(),
                const SizedBox(height: 16),
              ],
            ],

            // ── Note ────────────────────────────────────────────────────────
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.labelNoteOptional,
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
