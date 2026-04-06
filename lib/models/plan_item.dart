import 'expense_category.dart';
import 'financial_type.dart';
import 'year_month.dart';

/// Result returned by [PlanRepository.applyPlanItemEdit].
enum PlanItemEditResult {
  success,

  /// A new version was requested for a yearly item whose [startFrom] month
  /// does not match the series anchor month ([existing.validFrom.month]).
  /// No changes are made when this is returned.
  invalidYearlyCycleBoundary,
}

enum PlanItemType { income, fixedCost }

enum PlanFrequency { monthly, yearly, oneTime }

class PlanItem {
  final String id;

  /// Groups all versions of the same logical item (e.g. "Salary").
  /// For one-time items, seriesId == id.
  final String seriesId;

  final String name;
  final double amount;
  final PlanItemType type;
  final PlanFrequency frequency;

  /// The month from which this version becomes active.
  /// For one-time items, this is the exact month the item applies.
  final YearMonth validFrom;

  /// The last month this item is active (inclusive). Null means no end date.
  /// Only meaningful for fixedCost items; always null for income items.
  final YearMonth? validTo;

  final String? note;

  /// Only relevant for fixedCost items. Null for income items.
  final ExpenseCategory? category;

  /// Only relevant for fixedCost items. Null for income items.
  final FinancialType? financialType;

  // ── GUARD ─────────────────────────────────────────────────────────────────

  /// Whether GUARD is enabled for this fixed cost item.
  /// Only meaningful for recurring fixedCost items; false for income
  /// and one-time items.
  final bool isGuarded;

  /// Day of month the payment is due (1–31). Null defaults to day 1.
  /// When the month has fewer days the due day is capped to the last day of
  /// that month at runtime (e.g. day 31 in February → 28 or 29).
  /// Used for both monthly and yearly guarded items.
  final int? guardDueDay;

  /// Month the payment is due (1–12). Only relevant for yearly guarded items.
  /// Null defaults to [validFrom.month].
  final int? guardDueMonth;

  /// When true, GUARD fires only for the first eligible period (the period
  /// containing [validFrom]) and ignores all later periods.
  /// When false (default) GUARD fires every period the item is active.
  final bool guardOneTime;

  const PlanItem({
    required this.id,
    required this.seriesId,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.validFrom,
    this.validTo,
    this.note,
    this.category,
    this.financialType,
    this.isGuarded = false,
    this.guardDueDay,
    this.guardDueMonth,
    this.guardOneTime = false,
  });

  // Sentinel used by copyWith to distinguish "not provided" from explicit null.
  static const _absent = Object();

  PlanItem copyWith({
    String? id,
    String? seriesId,
    String? name,
    double? amount,
    PlanItemType? type,
    PlanFrequency? frequency,
    YearMonth? validFrom,
    Object? validTo = _absent,
    String? note,
    Object? category = _absent,
    Object? financialType = _absent,
    bool? isGuarded,
    Object? guardDueDay = _absent,
    Object? guardDueMonth = _absent,
    bool? guardOneTime,
  }) {
    return PlanItem(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      frequency: frequency ?? this.frequency,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo == _absent ? this.validTo : validTo as YearMonth?,
      note: note ?? this.note,
      category: category == _absent ? this.category : category as ExpenseCategory?,
      financialType: financialType == _absent ? this.financialType : financialType as FinancialType?,
      isGuarded: isGuarded ?? this.isGuarded,
      guardDueDay: guardDueDay == _absent ? this.guardDueDay : guardDueDay as int?,
      guardDueMonth: guardDueMonth == _absent ? this.guardDueMonth : guardDueMonth as int?,
      guardOneTime: guardOneTime ?? this.guardOneTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seriesId': seriesId,
        'name': name,
        'amount': amount,
        'type': type.name,
        'frequency': frequency.name,
        'validFrom': validFrom.toJson(),
        if (validTo != null) 'validTo': validTo!.toJson(),
        'note': note,
        if (category != null) 'category': category!.name,
        if (financialType != null) 'financialType': financialType!.name,
        if (isGuarded) 'isGuarded': isGuarded,
        if (guardDueDay != null) 'guardDueDay': guardDueDay,
        if (guardDueMonth != null) 'guardDueMonth': guardDueMonth,
        if (guardOneTime) 'guardOneTime': guardOneTime,
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'] as String?;
    final financialTypeRaw = json['financialType'] as String?;
    return PlanItem(
      id: json['id'] as String,
      seriesId: json['seriesId'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: PlanItemType.values.asNameMap()[json['type'] as String] ??
          PlanItemType.fixedCost,
      frequency: PlanFrequency.values.asNameMap()[json['frequency'] as String] ??
          PlanFrequency.monthly,
      validFrom: YearMonth.fromJson(json['validFrom'] as Map<String, dynamic>),
      validTo: json['validTo'] != null
          ? YearMonth.fromJson(json['validTo'] as Map<String, dynamic>)
          : null,
      note: json['note'] as String?,
      category:
          categoryRaw != null ? ExpenseCategoryX.fromJson(categoryRaw) : null,
      financialType: financialTypeRaw != null
          ? FinancialType.values.byName(financialTypeRaw)
          : null,
      isGuarded: json['isGuarded'] as bool? ?? false,
      guardDueDay: json['guardDueDay'] as int?,
      guardDueMonth: json['guardDueMonth'] as int?,
      guardOneTime: json['guardOneTime'] as bool? ?? false,
    );
  }
}
