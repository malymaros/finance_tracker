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

  final String? note;

  const PlanItem({
    required this.id,
    required this.seriesId,
    required this.name,
    required this.amount,
    required this.type,
    required this.frequency,
    required this.validFrom,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'seriesId': seriesId,
        'name': name,
        'amount': amount,
        'type': type.name,
        'frequency': frequency.name,
        'validFrom': validFrom.toJson(),
        'note': note,
      };

  factory PlanItem.fromJson(Map<String, dynamic> json) => PlanItem(
        id: json['id'] as String,
        seriesId: json['seriesId'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: PlanItemType.values.byName(json['type'] as String),
        frequency: PlanFrequency.values.byName(json['frequency'] as String),
        validFrom:
            YearMonth.fromJson(json['validFrom'] as Map<String, dynamic>),
        note: json['note'] as String?,
      );
}
