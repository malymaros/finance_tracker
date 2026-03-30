import 'year_month.dart';

/// Represents a payment confirmation or silence action for one recurring
/// period of a guarded fixed cost.
///
/// A [GuardPayment] record is only created when the user acts (marks paid
/// or silences). The absence of a record for a given (seriesId, period)
/// pair implies the payment is unpaid and active.
class GuardPayment {
  final String id;

  /// The [PlanItem.seriesId] this record belongs to.
  /// Using seriesId (not id) means the record survives plan item versioning.
  final String planItemSeriesId;

  /// The month/year this payment record covers.
  final YearMonth period;

  /// Non-null when the user confirmed the payment was made.
  final DateTime? paidAt;

  /// Non-null when the user silenced notifications for this period without
  /// confirming payment. Always null when [paidAt] is set.
  final DateTime? silencedAt;

  const GuardPayment({
    required this.id,
    required this.planItemSeriesId,
    required this.period,
    this.paidAt,
    this.silencedAt,
  }) : assert(paidAt == null || silencedAt == null,
            'A GuardPayment cannot be both paid and silenced');

  Map<String, dynamic> toJson() => {
        'id': id,
        'planItemSeriesId': planItemSeriesId,
        'period': period.toJson(),
        if (paidAt != null) 'paidAt': paidAt!.toIso8601String(),
        if (silencedAt != null) 'silencedAt': silencedAt!.toIso8601String(),
      };

  factory GuardPayment.fromJson(Map<String, dynamic> json) {
    return GuardPayment(
      id: json['id'] as String,
      planItemSeriesId: json['planItemSeriesId'] as String,
      period: YearMonth.fromJson(json['period'] as Map<String, dynamic>),
      paidAt: json['paidAt'] != null
          ? DateTime.parse(json['paidAt'] as String)
          : null,
      silencedAt: json['silencedAt'] != null
          ? DateTime.parse(json['silencedAt'] as String)
          : null,
    );
  }
}
