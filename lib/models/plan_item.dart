import 'expense_category.dart';
import 'financial_type.dart';
import 'year_month.dart';

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
  });

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
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    final categoryRaw = json['category'] as String?;
    final financialTypeRaw = json['financialType'] as String?;
    return PlanItem(
      id: json['id'] as String,
      seriesId: json['seriesId'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: PlanItemType.values.byName(json['type'] as String),
      frequency: PlanFrequency.values.byName(json['frequency'] as String),
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
    );
  }
}
