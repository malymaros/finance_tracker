import 'expense_category.dart';

class CategoryTotal {
  final ExpenseCategory category;
  final double amount;
  final double percentage;

  /// True only for the synthetic "Other categories" bucket produced by
  /// [ReportAggregator.applyThreshold] when small slices are collapsed.
  ///
  /// This is distinct from [ExpenseCategory.other]: a real above-threshold
  /// "Other" expense category keeps its own row with [isAggregate] == false,
  /// while the collapsed bucket also uses [ExpenseCategory.other] for its
  /// colour/icon but sets [isAggregate] == true. Consumers must use this flag
  /// (not the category value) to identify the aggregation bucket, otherwise the
  /// two rows collide.
  final bool isAggregate;

  const CategoryTotal({
    required this.category,
    required this.amount,
    required this.percentage,
    this.isAggregate = false,
  });
}
