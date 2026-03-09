import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/financial_type.dart';
import '../models/income_entry.dart';
import '../models/plan_item.dart';
import '../models/year_month.dart';
import 'finance_repository.dart';
import 'plan_repository.dart';

/// Provides realistic dummy data for development and testing.
/// Only intended to be called from debug builds.
class SeedData {
  SeedData._();

  /// Seeds both repositories if they are completely empty.
  static Future<void> applyIfEmpty(
    FinanceRepository repo,
    PlanRepository planRepo,
  ) async {
    if (repo.expenses.isEmpty && planRepo.items.isEmpty) {
      await _apply(repo, planRepo);
    }
  }

  /// Clears all data and re-seeds from scratch.
  static Future<void> reset(
    FinanceRepository repo,
    PlanRepository planRepo,
  ) async {
    await repo.clearAll();
    await planRepo.clearAll();
    await _apply(repo, planRepo);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<void> _apply(
    FinanceRepository repo,
    PlanRepository planRepo,
  ) async {
    final now = DateTime.now();

    // Helper: date relative to current month
    DateTime d(int monthsAgo, int day) {
      var year = now.year;
      var month = now.month - monthsAgo;
      while (month <= 0) {
        month += 12;
        year--;
      }
      return DateTime(year, month, day);
    }

    YearMonth ym(int monthsAgo) {
      var year = now.year;
      var month = now.month - monthsAgo;
      while (month <= 0) {
        month += 12;
        year--;
      }
      return YearMonth(year, month);
    }

    var counter = 1;
    String id() => (counter++).toString();

    // ── Plan items ──────────────────────────────────────────────────────────

    final planItems = [
      // Income
      PlanItem(
        id: id(), seriesId: '1',
        name: 'Salary',
        amount: 3500,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
      ),
      PlanItem(
        id: id(), seriesId: '2',
        name: 'Freelance',
        amount: 500,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
      ),
      // Fixed costs
      PlanItem(
        id: id(), seriesId: '3',
        name: 'Rent',
        amount: 900,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      ),
      PlanItem(
        id: id(), seriesId: '4',
        name: 'Health Insurance',
        amount: 120,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
        category: ExpenseCategory.insurance,
        financialType: FinancialType.insurance,
      ),
      PlanItem(
        id: id(), seriesId: '5',
        name: 'Internet',
        amount: 35,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
        category: ExpenseCategory.communication,
        financialType: FinancialType.consumption,
      ),
      PlanItem(
        id: id(), seriesId: '6',
        name: 'Netflix',
        amount: 15,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
        category: ExpenseCategory.subscriptions,
        financialType: FinancialType.consumption,
      ),
      PlanItem(
        id: id(), seriesId: '7',
        name: 'Spotify',
        amount: 10,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: ym(5),
        category: ExpenseCategory.subscriptions,
        financialType: FinancialType.consumption,
      ),
      PlanItem(
        id: id(), seriesId: '8',
        name: 'Car Insurance',
        amount: 720,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.yearly,
        validFrom: ym(2),
        category: ExpenseCategory.insurance,
        financialType: FinancialType.insurance,
      ),
    ];

    // ── Income entries (transaction-level) ───────────────────────────────────

    final incomeEntries = [
      for (int m = 5; m >= 1; m--)
        IncomeEntry(
          id: id(),
          amount: 3500,
          date: d(m, 1),
          type: IncomeType.monthly,
          description: 'Salary',
        ),
      IncomeEntry(id: id(), amount: 500, date: d(4, 15), type: IncomeType.oneTime, description: 'Freelance project'),
      IncomeEntry(id: id(), amount: 500, date: d(2, 15), type: IncomeType.oneTime, description: 'Freelance project'),
      IncomeEntry(id: id(), amount: 500, date: d(1, 15), type: IncomeType.oneTime, description: 'Freelance project'),
    ];

    // ── Expenses ─────────────────────────────────────────────────────────────

    Expense e(
      double amount,
      ExpenseCategory cat,
      DateTime date, {
      FinancialType type = FinancialType.consumption,
      String? note,
    }) =>
        Expense(
          id: id(),
          amount: amount,
          category: cat,
          financialType: type,
          date: date,
          note: note,
        );

    final expenses = [
      // ── 2 months ago ───────────────────────────────────────────────────────
      e(65,  ExpenseCategory.groceries,     d(2, 2)),
      e(42,  ExpenseCategory.restaurants,   d(2, 5)),
      e(45,  ExpenseCategory.transport,     d(2, 6)),
      e(119, ExpenseCategory.clothing,      d(2, 8)),
      e(22,  ExpenseCategory.health,        d(2, 11)),
      e(78,  ExpenseCategory.groceries,     d(2, 12)),
      e(12,  ExpenseCategory.transport,     d(2, 14)),
      e(28,  ExpenseCategory.restaurants,   d(2, 15)),
      e(35,  ExpenseCategory.health,        d(2, 16)),
      e(52,  ExpenseCategory.groceries,     d(2, 19)),
      e(25,  ExpenseCategory.entertainment, d(2, 20)),
      e(89,  ExpenseCategory.restaurants,   d(2, 22)),
      e(55,  ExpenseCategory.gifts,         d(2, 25), type: FinancialType.asset),
      e(71,  ExpenseCategory.groceries,     d(2, 27)),
      e(40,  ExpenseCategory.education,     d(2, 28), type: FinancialType.asset),

      // ── Last month ─────────────────────────────────────────────────────────
      e(38,  ExpenseCategory.transport,     d(1, 2)),
      e(62,  ExpenseCategory.groceries,     d(1, 3)),
      e(34,  ExpenseCategory.restaurants,   d(1, 7)),
      e(18,  ExpenseCategory.health,        d(1, 9)),
      e(85,  ExpenseCategory.health,        d(1, 11), note: 'Dentist'),
      e(81,  ExpenseCategory.groceries,     d(1, 14)),
      e(45,  ExpenseCategory.entertainment, d(1, 16)),
      e(68,  ExpenseCategory.restaurants,   d(1, 19)),
      e(95,  ExpenseCategory.clothing,      d(1, 21)),
      e(28,  ExpenseCategory.housing,       d(1, 25), note: 'Lightbulbs & supplies'),
      e(47,  ExpenseCategory.groceries,     d(1, 24)),

      // ── This month (first few days) ────────────────────────────────────────
      e(55,  ExpenseCategory.groceries,     d(0, 1)),
      e(15,  ExpenseCategory.transport,     d(0, 3)),
      e(22,  ExpenseCategory.restaurants,   d(0, 4)),
      e(38,  ExpenseCategory.groceries,     d(0, 6)),
      e(8,   ExpenseCategory.restaurants,   d(0, 7)),
    ];

    // ── Populate ─────────────────────────────────────────────────────────────

    for (final item in planItems) {
      await planRepo.addPlanItem(item);
    }
    for (final entry in incomeEntries) {
      await repo.addIncome(entry);
    }
    for (final expense in expenses) {
      await repo.addExpense(expense);
    }
  }
}
