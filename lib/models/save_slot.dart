class SaveSlot {
  final String id;
  final String name;
  final DateTime createdAt;
  final int expenseCount;
  final int planItemCount;
  final bool isDamaged;

  const SaveSlot({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.expenseCount,
    required this.planItemCount,
    this.isDamaged = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'expenseCount': expenseCount,
        'planItemCount': planItemCount,
      };

  factory SaveSlot.fromJson(Map<String, dynamic> json) => SaveSlot(
        id: json['id'] as String,
        name: json['name'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        expenseCount: json['expenseCount'] as int,
        planItemCount: json['planItemCount'] as int,
      );
}
