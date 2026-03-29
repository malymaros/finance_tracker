import 'expense_category.dart';
import 'year_month.dart';

/// A versioned monthly budget target for a single expense category.
///
/// Multiple records may share the same [seriesId] to represent edits over
/// time. Only one version is active for a given month: the one whose
/// [validFrom] is the latest value ≤ the queried month and whose [validTo]
/// is null or ≥ the queried month.
class CategoryBudget {
  final String id;

  /// Groups all versions of the same category budget together.
  final String seriesId;

  final ExpenseCategory category;

  /// Monthly budget target in EUR.
  final double amount;

  /// First month this version is active (inclusive).
  final YearMonth validFrom;

  /// Last month this version is active (inclusive). Null means open-ended.
  final YearMonth? validTo;

  const CategoryBudget({
    required this.id,
    required this.seriesId,
    required this.category,
    required this.amount,
    required this.validFrom,
    this.validTo,
  });

  CategoryBudget copyWith({
    String? id,
    String? seriesId,
    ExpenseCategory? category,
    double? amount,
    YearMonth? validFrom,
    YearMonth? validTo,
    bool clearValidTo = false,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      validFrom: validFrom ?? this.validFrom,
      validTo: clearValidTo ? null : (validTo ?? this.validTo),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'seriesId': seriesId,
        'category': category.name,
        'amount': amount,
        'validFrom': validFrom.toJson(),
        if (validTo != null) 'validTo': validTo!.toJson(),
      };

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      id: json['id'] as String,
      seriesId: json['seriesId'] as String,
      category: ExpenseCategoryX.fromJson(json['category'] as String),
      amount: (json['amount'] as num).toDouble(),
      validFrom: YearMonth.fromJson(json['validFrom'] as Map<String, dynamic>),
      validTo: json['validTo'] != null
          ? YearMonth.fromJson(json['validTo'] as Map<String, dynamic>)
          : null,
    );
  }
}
