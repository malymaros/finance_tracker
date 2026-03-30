import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/guard_payment.dart';
import 'package:finance_tracker/models/guard_state.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/guard_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

GuardRepository _repo({List<GuardPayment>? seed}) =>
    GuardRepository(persist: false, seed: seed);

PlanItem _monthlyGuarded({
  String id = 'i1',
  String seriesId = 's1',
  int fromYear = 2024,
  int fromMonth = 1,
  int? dueDay,
  bool guardOneTime = false,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId,
      name: 'Rent',
      amount: 500,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(fromYear, fromMonth),
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: dueDay ?? 1,
      guardOneTime: guardOneTime,
    );

PlanItem _yearlyGuarded({
  String id = 'y1',
  String seriesId = 'sy1',
  int fromYear = 2024,
  int fromMonth = 1,
  int? dueDay,
  int? dueMonth,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId,
      name: 'Tax',
      amount: 1000,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.yearly,
      validFrom: YearMonth(fromYear, fromMonth),
      category: ExpenseCategory.taxes,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: dueDay ?? 1,
      guardDueMonth: dueMonth,
    );

// ── GuardPayment model ────────────────────────────────────────────────────────

void main() {
  group('GuardPayment — mutual exclusivity (M5)', () {
    test('can be created with neither paidAt nor silencedAt', () {
      expect(
        () => GuardPayment(
          id: 'g1',
          planItemSeriesId: 's1',
          period: YearMonth(2024, 3),
        ),
        returnsNormally,
      );
    });

    test('can be created with only paidAt', () {
      expect(
        () => GuardPayment(
          id: 'g1',
          planItemSeriesId: 's1',
          period: YearMonth(2024, 3),
          paidAt: DateTime(2024, 3, 15),
        ),
        returnsNormally,
      );
    });

    test('can be created with only silencedAt', () {
      expect(
        () => GuardPayment(
          id: 'g1',
          planItemSeriesId: 's1',
          period: YearMonth(2024, 3),
          silencedAt: DateTime(2024, 3, 10),
        ),
        returnsNormally,
      );
    });

    test('throws AssertionError when both paidAt and silencedAt are set', () {
      expect(
        () => GuardPayment(
          id: 'g1',
          planItemSeriesId: 's1',
          period: YearMonth(2024, 3),
          paidAt: DateTime(2024, 3, 15),
          silencedAt: DateTime(2024, 3, 10),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  // ── itemStateForPeriod ──────────────────────────────────────────────────────

  group('itemStateForPeriod', () {
    test('returns none for income items', () {
      final repo = _repo();
      final income = PlanItem(
        id: 'i1',
        seriesId: 's1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        isGuarded: true,
      );
      expect(
        repo.itemStateForPeriod(income, YearMonth(2024, 3)),
        GuardState.none,
      );
    });

    test('returns none for non-guarded fixed costs', () {
      final repo = _repo();
      final item = PlanItem(
        id: 'i1',
        seriesId: 's1',
        name: 'Rent',
        amount: 500,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        isGuarded: false,
      );
      expect(
        repo.itemStateForPeriod(item, YearMonth(2024, 3)),
        GuardState.none,
      );
    });

    test('returns unpaidActive when no record exists', () {
      final repo = _repo();
      final item = _monthlyGuarded();
      expect(
        repo.itemStateForPeriod(item, YearMonth(2024, 3)),
        GuardState.unpaidActive,
      );
    });

    test('returns paid when paidAt record exists', () {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: YearMonth(2024, 3),
        paidAt: DateTime(2024, 3, 15),
      );
      final repo = _repo(seed: [payment]);
      final item = _monthlyGuarded();
      expect(
        repo.itemStateForPeriod(item, YearMonth(2024, 3)),
        GuardState.paid,
      );
    });

    test('returns silenced when silencedAt record exists', () {
      final payment = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: YearMonth(2024, 3),
        silencedAt: DateTime(2024, 3, 5),
      );
      final repo = _repo(seed: [payment]);
      final item = _monthlyGuarded();
      expect(
        repo.itemStateForPeriod(item, YearMonth(2024, 3)),
        GuardState.silenced,
      );
    });
  });

  // ── unpaidActiveItems ─────────────────────────────────────────────────────

  group('unpaidActiveItems', () {
    test('returns empty when no guarded items', () {
      final repo = _repo();
      final items = <PlanItem>[];
      expect(repo.unpaidActiveItems(items, YearMonth(2024, 3)), isEmpty);
    });

    test('returns unpaid periods for monthly guarded item', () {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);
      final result = repo.unpaidActiveItems([item], now);
      expect(result.length, 3); // Jan, Feb, Mar
    });

    test('does not include paid periods', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      await repo.confirmPayment('s1', YearMonth(2024, 1));
      await repo.confirmPayment('s1', YearMonth(2024, 2));
      final now = YearMonth(2024, 3);
      final result = repo.unpaidActiveItems([item], now);
      expect(result.length, 1); // Only Mar
      expect(result.first.$2, YearMonth(2024, 3));
    });

    test('excludes silenced periods', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      await repo.silencePayment('s1', YearMonth(2024, 1));
      final now = YearMonth(2024, 2);
      final unpaid = repo.unpaidActiveItems([item], now);
      expect(unpaid.length, 1); // Only Feb; Jan is silenced
      expect(unpaid.first.$2, YearMonth(2024, 2));
    });

    test('allUnresolvedItems includes silenced periods', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      await repo.silencePayment('s1', YearMonth(2024, 1));
      final now = YearMonth(2024, 2);
      final all = repo.allUnresolvedItems([item], now);
      expect(all.length, 2); // Jan (silenced) + Feb (unpaid)
    });

    test('one-time guard only fires once (guardOneTime=true)', () {
      final repo = _repo();
      final item = _monthlyGuarded(
          fromYear: 2024, fromMonth: 1, dueDay: 1, guardOneTime: true);
      final now = YearMonth(2024, 6);
      final result = repo.unpaidActiveItems([item], now);
      expect(result.length, 1); // Only validFrom month
      expect(result.first.$2, YearMonth(2024, 1));
    });
  });

  // ── yearly items — M1 per-period dueMonth ────────────────────────────────

  group('yearly guard — per-period dueMonth (M1)', () {
    test('uses guardDueMonth from active version for each year', () {
      final repo = _repo();

      // Version 1: validFrom Jan 2023, dueMonth = 3 (March)
      final v1 = _yearlyGuarded(
        id: 'y_v1',
        seriesId: 'sy1',
        fromYear: 2023,
        fromMonth: 1,
        dueDay: 1,
        dueMonth: 3,
      );

      // Version 2: validFrom Jan 2024, dueMonth = 6 (June) — plan changed
      final v2 = PlanItem(
        id: 'y_v2',
        seriesId: 'sy1',
        name: 'Tax',
        amount: 1200,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.yearly,
        validFrom: YearMonth(2024, 1),
        category: ExpenseCategory.taxes,
        financialType: FinancialType.consumption,
        isGuarded: true,
        guardDueDay: 1,
        guardDueMonth: 6,
      );

      // now = Jul 2024 (both 2023-March and 2024-June are due)
      final now = YearMonth(2024, 7);
      final result = repo.unpaidActiveItems([v1, v2], now);

      final periods = result.map((p) => p.$2).toList();
      // 2023: v1 was active → dueMonth=3 → March 2023
      expect(periods, contains(YearMonth(2023, 3)));
      // 2024: v2 is active → dueMonth=6 → June 2024
      expect(periods, contains(YearMonth(2024, 6)));
      // Should NOT contain e.g. March 2024 (that would be latestVersion's wrong month)
      expect(periods, isNot(contains(YearMonth(2024, 3))));
    });
  });
}
