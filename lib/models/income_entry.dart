enum IncomeType { oneTime, monthly }

class IncomeEntry {
  final String id;
  final double amount;
  final DateTime date;
  final IncomeType type;
  final String? description;

  IncomeEntry({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'type': type.name,
        'description': description,
      };

  factory IncomeEntry.fromJson(Map<String, dynamic> json) => IncomeEntry(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        type: IncomeType.values.byName(json['type'] as String),
        description: json['description'] as String?,
      );
}
