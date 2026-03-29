import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_budget.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

CategoryBudget _budget({
  String id = 'b1',
  String? seriesId,
  ExpenseCategory category = ExpenseCategory.groceries,
  double amount = 300,
  required YearMonth validFrom,
  YearMonth? validTo,
}) =>
    CategoryBudget(
      id: id,
      seriesId: seriesId ?? id,
      category: category,
      amount: amount,
      validFrom: validFrom,
      validTo: validTo,
    );

CategoryBudgetRepository _repo([List<CategoryBudget>? seed]) =>
    CategoryBudgetRepository(persist: false, seed: seed);

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── activeBudgetForMonth ─────────────────────────────────────────────────

  group('activeBudgetForMonth', () {
    test('returns null when no budgets exist', () {
      final repo = _repo();
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        isNull,
      );
    });

    test('returns amount when month is within open-ended range', () {
      final repo = _repo([
        _budget(validFrom: YearMonth(2025, 1)),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 6)),
        300,
      );
    });

    test('returns null when queried month is before validFrom', () {
      final repo = _repo([
        _budget(validFrom: YearMonth(2025, 3)),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 2)),
        isNull,
      );
    });

    test('returns null when queried month is after validTo', () {
      final repo = _repo([
        _budget(
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 6),
        ),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 7)),
        isNull,
      );
    });

    test('returns amount on validFrom boundary month', () {
      final repo = _repo([
        _budget(validFrom: YearMonth(2025, 4)),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 4)),
        300,
      );
    });

    test('returns amount on validTo boundary month', () {
      final repo = _repo([
        _budget(
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 4),
        ),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 4)),
        300,
      );
    });

    test('returns null for a different category', () {
      final repo = _repo([
        _budget(
          category: ExpenseCategory.housing,
          validFrom: YearMonth(2025, 1),
        ),
      ]);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        isNull,
      );
    });
  });

  // ── activeBudgetRecordForMonth ───────────────────────────────────────────

  group('activeBudgetRecordForMonth', () {
    test('returns full record for active month', () {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      final record = repo.activeBudgetRecordForMonth(
          ExpenseCategory.groceries, YearMonth(2025, 5));
      expect(record, isNotNull);
      expect(record!.id, 'b1');
      expect(record.seriesId, 's1');
    });

    test('returns null when no active record', () {
      final repo = _repo([
        _budget(
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 3),
        ),
      ]);
      expect(
        repo.activeBudgetRecordForMonth(
            ExpenseCategory.groceries, YearMonth(2025, 6)),
        isNull,
      );
    });
  });

  // ── allActiveBudgetsForMonth ─────────────────────────────────────────────

  group('allActiveBudgetsForMonth', () {
    test('returns empty map when no budgets', () {
      expect(_repo().allActiveBudgetsForMonth(YearMonth(2025, 1)), isEmpty);
    });

    test('returns all active categories for the month', () {
      final repo = _repo([
        _budget(
          id: 'b1',
          category: ExpenseCategory.groceries,
          amount: 300,
          validFrom: YearMonth(2025, 1),
        ),
        _budget(
          id: 'b2',
          category: ExpenseCategory.housing,
          amount: 1000,
          validFrom: YearMonth(2025, 1),
        ),
      ]);
      final budgets = repo.allActiveBudgetsForMonth(YearMonth(2025, 3));
      expect(budgets.length, 2);
      expect(budgets[ExpenseCategory.groceries], 300);
      expect(budgets[ExpenseCategory.housing], 1000);
    });

    test('excludes categories whose validTo is before queried month', () {
      final repo = _repo([
        _budget(
          id: 'b1',
          category: ExpenseCategory.groceries,
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 2),
        ),
        _budget(
          id: 'b2',
          category: ExpenseCategory.housing,
          validFrom: YearMonth(2025, 1),
        ),
      ]);
      final budgets = repo.allActiveBudgetsForMonth(YearMonth(2025, 3));
      expect(budgets.length, 1);
      expect(budgets.containsKey(ExpenseCategory.housing), isTrue);
    });
  });

  // ── addCategoryBudget ────────────────────────────────────────────────────

  group('addCategoryBudget', () {
    test('budget is queryable after add', () async {
      final repo = _repo();
      await repo.addCategoryBudget(
          _budget(validFrom: YearMonth(2025, 1)));
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        300,
      );
    });

    test('notifies listeners on add', () async {
      final repo = _repo();
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addCategoryBudget(_budget(validFrom: YearMonth(2025, 1)));
      expect(notified, isTrue);
    });
  });

  // ── changeCategoryBudgetFrom — in-place correction ───────────────────────

  group('changeCategoryBudgetFrom — in-place correction', () {
    test('replaces amount when from == active.validFrom', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', amount: 300, validFrom: YearMonth(2025, 3)),
      ]);
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 3), 500);

      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        500,
      );
      // Only one record — no new version created.
      expect(repo.budgets.length, 1);
    });

    test('preserves validTo when correcting in place', () async {
      final repo = _repo([
        _budget(
          id: 'b1',
          seriesId: 's1',
          amount: 300,
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 6),
        ),
      ]);
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 1), 400);

      final record = repo.activeBudgetRecordForMonth(
          ExpenseCategory.groceries, YearMonth(2025, 1));
      expect(record!.amount, 400);
      expect(record.validTo, YearMonth(2025, 6));
    });
  });

  // ── changeCategoryBudgetFrom — forward versioning ────────────────────────

  group('changeCategoryBudgetFrom — forward versioning', () {
    test('old month returns old amount, new month returns new amount', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', amount: 300, validFrom: YearMonth(2025, 1)),
      ]);
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 4), 500);

      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        300,
      );
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 4)),
        500,
      );
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 6)),
        500,
      );
    });

    test('caps previous version at from − 1', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', amount: 300, validFrom: YearMonth(2025, 1)),
      ]);
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 4), 500);

      final old = repo.activeBudgetRecordForMonth(
          ExpenseCategory.groceries, YearMonth(2025, 3));
      expect(old!.validTo, YearMonth(2025, 3));
    });

    test('creates two records after forward change', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', amount: 300, validFrom: YearMonth(2025, 1)),
      ]);
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 4), 500);
      expect(repo.budgets.length, 2);
    });

    test('prunes future versions beyond from', () async {
      // Two existing versions: b1 (Jan–Mar), b2 (Apr–)
      final repo = _repo([
        _budget(
          id: 'b1',
          seriesId: 's1',
          amount: 300,
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 3),
        ),
        _budget(
          id: 'b2',
          seriesId: 's1',
          amount: 400,
          validFrom: YearMonth(2025, 4),
        ),
      ]);
      // Change from Feb — b2 is in the future relative to Feb, should be pruned.
      await repo.changeCategoryBudgetFrom('s1', YearMonth(2025, 2), 999);

      // Only the corrected/new record survives; b2 is gone.
      expect(repo.budgets.where((b) => b.id == 'b2').isEmpty, isTrue);
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 6)),
        999,
      );
    });

    test('no-op when seriesId is not found', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      await repo.changeCategoryBudgetFrom('unknown', YearMonth(2025, 3), 999);
      expect(repo.budgets.length, 1);
      expect(repo.budgets.first.amount, 300);
    });
  });

  // ── endCategoryBudget ────────────────────────────────────────────────────

  group('endCategoryBudget', () {
    test('removes record entirely when from == active.validFrom', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 3)),
      ]);
      await repo.endCategoryBudget('s1', YearMonth(2025, 3));
      expect(repo.budgets, isEmpty);
    });

    test('caps validTo at from − 1 when from > validFrom', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      await repo.endCategoryBudget('s1', YearMonth(2025, 5));

      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 4)),
        300,
      );
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 5)),
        isNull,
      );
    });

    test('preserves earlier history after ending mid-series', () async {
      final repo = _repo([
        _budget(
          id: 'b1',
          seriesId: 's1',
          amount: 200,
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 5),
        ),
        _budget(
          id: 'b2',
          seriesId: 's1',
          amount: 400,
          validFrom: YearMonth(2025, 6),
        ),
      ]);
      await repo.endCategoryBudget('s1', YearMonth(2025, 6));

      // b1 (Jan–May) is preserved untouched.
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 3)),
        200,
      );
      // b2 started at Jun and was ended at Jun — removed entirely.
      expect(
        repo.activeBudgetForMonth(ExpenseCategory.groceries, YearMonth(2025, 6)),
        isNull,
      );
    });

    test('no-op when seriesId is not found', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      await repo.endCategoryBudget('unknown', YearMonth(2025, 3));
      expect(repo.budgets.length, 1);
    });

    test('notifies listeners on end', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.endCategoryBudget('s1', YearMonth(2025, 3));
      expect(notified, isTrue);
    });
  });

  // ── yearlyTotalForCategory ────────────────────────────────────────────────

  group('yearlyTotalForCategory', () {
    test('returns 0 when no budget exists', () {
      final repo = _repo();
      expect(
        repo.yearlyTotalForCategory(ExpenseCategory.groceries, 2025),
        0,
      );
    });

    test('full year with open-ended budget returns 12 × amount', () {
      final repo = _repo([
        _budget(amount: 100, validFrom: YearMonth(2025, 1)),
      ]);
      expect(repo.yearlyTotalForCategory(ExpenseCategory.groceries, 2025), 1200);
    });

    test('partial year budget sums only active months', () {
      final repo = _repo([
        _budget(
          amount: 100,
          validFrom: YearMonth(2025, 7),
          validTo: YearMonth(2025, 9),
        ),
      ]);
      // Active: Jul, Aug, Sep = 3 months
      expect(repo.yearlyTotalForCategory(ExpenseCategory.groceries, 2025), 300);
    });

    test('version change mid-year reflects both amounts', () async {
      final repo = _repo([
        _budget(
          id: 'b1',
          seriesId: 's1',
          amount: 200,
          validFrom: YearMonth(2025, 1),
          validTo: YearMonth(2025, 5),
        ),
        _budget(
          id: 'b2',
          seriesId: 's1',
          amount: 400,
          validFrom: YearMonth(2025, 6),
        ),
      ]);
      // Jan–May = 5 × 200 = 1000; Jun–Dec = 7 × 400 = 2800
      expect(repo.yearlyTotalForCategory(ExpenseCategory.groceries, 2025), 3800);
    });
  });

  // ── restoreFromSnapshot ──────────────────────────────────────────────────

  group('restoreFromSnapshot', () {
    test('replaces all existing records', () async {
      final repo = _repo([
        _budget(id: 'old', seriesId: 'old', validFrom: YearMonth(2025, 1)),
      ]);
      await repo.restoreFromSnapshot([
        _budget(id: 'new', seriesId: 'new', validFrom: YearMonth(2026, 1)),
      ]);
      expect(repo.budgets.length, 1);
      expect(repo.budgets.first.id, 'new');
    });

    test('restoring empty list clears all budgets', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
      ]);
      await repo.restoreFromSnapshot([]);
      expect(repo.budgets, isEmpty);
    });

    test('notifies listeners after restore', () async {
      final repo = _repo();
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.restoreFromSnapshot([]);
      expect(notified, isTrue);
    });
  });

  // ── clearAll ─────────────────────────────────────────────────────────────

  group('clearAll', () {
    test('removes all records', () async {
      final repo = _repo([
        _budget(id: 'b1', seriesId: 's1', validFrom: YearMonth(2025, 1)),
        _budget(
            id: 'b2',
            seriesId: 's2',
            category: ExpenseCategory.housing,
            validFrom: YearMonth(2025, 1)),
      ]);
      await repo.clearAll();
      expect(repo.budgets, isEmpty);
    });
  });
}
