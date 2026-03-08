import '../models/category_total.dart';
import '../models/expense.dart';

/// Pure aggregation functions for the spending report.
/// All methods are static so they can be tested without a repository instance.
class ReportAggregator {
  /// Groups [expenses] by category and returns totals sorted descending by amount.
  static List<CategoryTotal> categoryTotals(List<Expense> expenses) {
    if (expenses.isEmpty) return [];

    final totals = <String, double>{};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0.0) + e.amount;
    }

    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);

    return totals.entries
        .map((entry) => CategoryTotal(
              category: entry.key,
              amount: entry.value,
              percentage: grandTotal > 0 ? (entry.value / grandTotal) * 100 : 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
