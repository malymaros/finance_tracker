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

    // Regression: _activeGuardedVersionForYear used year-only validTo comparison.
    // An item expiring mid-year (e.g. validTo=March 2025) should not contribute
    // a reminder for a dueMonth that falls after that expiry.
    test('yearly item with mid-year validTo does not fire for dueMonth after expiry',
        () {
      final repo = _repo();
      // Single version: active Jan 2023 – March 2025, due in December each year.
      final item = PlanItem(
        id: 'y1',
        seriesId: 'sy1',
        name: 'Tax',
        amount: 1000,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.yearly,
        validFrom: YearMonth(2023, 1),
        validTo: YearMonth(2025, 3), // expires March 2025
        category: ExpenseCategory.taxes,
        financialType: FinancialType.consumption,
        isGuarded: true,
        guardDueDay: 1,
        guardDueMonth: 12, // due in December
      );

      // now = Jan 2026 — December 2025 is in the past but item expired in March 2025
      final now = YearMonth(2026, 1);
      final result = repo.unpaidActiveItems([item], now);
      final periods = result.map((p) => p.$2).toList();

      // Dec 2023 and Dec 2024 are within the item's active range — should appear
      expect(periods, contains(YearMonth(2023, 12)));
      expect(periods, contains(YearMonth(2024, 12)));
      // Dec 2025 is after the item expired (validTo = March 2025) — must NOT appear
      expect(periods, isNot(contains(YearMonth(2025, 12))));
    });

    test('yearly item fires for the dueMonth year that matches validTo year when due month is within range',
        () {
      final repo = _repo();
      // validTo = June 2025, dueMonth = 3 (March) — March 2025 is before validTo
      final item = PlanItem(
        id: 'y1',
        seriesId: 'sy1',
        name: 'Tax',
        amount: 800,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.yearly,
        validFrom: YearMonth(2024, 1),
        validTo: YearMonth(2025, 6),
        category: ExpenseCategory.taxes,
        financialType: FinancialType.consumption,
        isGuarded: true,
        guardDueDay: 1,
        guardDueMonth: 3,
      );

      final now = YearMonth(2026, 1);
      final result = repo.unpaidActiveItems([item], now);
      final periods = result.map((p) => p.$2).toList();

      // March 2024 and March 2025 are both within the active range
      expect(periods, contains(YearMonth(2024, 3)));
      expect(periods, contains(YearMonth(2025, 3)));
      // March 2026 is after expiry — must NOT appear
      expect(periods, isNot(contains(YearMonth(2026, 3))));
    });
  });

  // ── itemStateForPeriod — scheduled ───────────────────────────────────────

  group('itemStateForPeriod — scheduled state', () {
    test('future period returns scheduled', () {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      // Use a period far in the future so it is always after YearMonth.now()
      expect(
        repo.itemStateForPeriod(item, YearMonth(2099, 12)),
        GuardState.scheduled,
      );
    });
  });

  // ── revokePayment ─────────────────────────────────────────────────────────

  group('revokePayment', () {
    test('after confirm, revoking returns period to unpaidActive', () async {
      final repo = _repo();
      final item = _monthlyGuarded();
      final period = YearMonth(2024, 3);

      await repo.confirmPayment('s1', period);
      expect(repo.itemStateForPeriod(item, period), GuardState.paid);

      await repo.revokePayment('s1', period);
      expect(repo.itemStateForPeriod(item, period), GuardState.unpaidActive);
    });

    test('revoking a non-existent record is a no-op', () async {
      final repo = _repo();
      await repo.revokePayment('s1', YearMonth(2024, 3));
      expect(repo.payments, isEmpty);
    });

    test('revoking a silenced period also returns it to unpaidActive', () async {
      final repo = _repo();
      final item = _monthlyGuarded();
      final period = YearMonth(2024, 3);

      await repo.silencePayment('s1', period);
      expect(repo.itemStateForPeriod(item, period), GuardState.silenced);

      await repo.revokePayment('s1', period);
      expect(repo.itemStateForPeriod(item, period), GuardState.unpaidActive);
    });
  });

  // ── confirmPayment idempotency ────────────────────────────────────────────

  group('confirmPayment idempotency', () {
    test('confirming an already-paid period is a no-op', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);

      await repo.confirmPayment('s1', period);
      final firstPaidAt =
          repo.payments.first.paidAt;

      await repo.confirmPayment('s1', period);
      expect(repo.payments.length, 1);
      expect(repo.payments.first.paidAt, firstPaidAt); // unchanged
    });

    test('silencing an already-paid period is a no-op', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);

      await repo.confirmPayment('s1', period);
      await repo.silencePayment('s1', period);

      // Record should still be paid, not silenced
      expect(repo.payments.length, 1);
      expect(repo.payments.first.paidAt, isNotNull);
      expect(repo.payments.first.silencedAt, isNull);
    });
  });

  // ── clearAll ──────────────────────────────────────────────────────────────

  group('clearAll', () {
    test('removes all payment records', () async {
      final repo = _repo();
      await repo.confirmPayment('s1', YearMonth(2024, 1));
      await repo.silencePayment('s1', YearMonth(2024, 2));
      expect(repo.payments.length, 2);

      await repo.clearAll();
      expect(repo.payments, isEmpty);
    });

    test('notifies listeners', () async {
      final repo = _repo();
      await repo.confirmPayment('s1', YearMonth(2024, 1));
      var notified = false;
      repo.addListener(() => notified = true);

      await repo.clearAll();
      expect(notified, isTrue);
    });
  });

  // ── restoreFromSnapshot ───────────────────────────────────────────────────

  group('restoreFromSnapshot', () {
    test('replaces existing payments', () async {
      final repo = _repo();
      await repo.confirmPayment('s1', YearMonth(2024, 1));

      final newPayments = [
        GuardPayment(
          id: 'new1',
          planItemSeriesId: 's2',
          period: YearMonth(2024, 6),
          paidAt: DateTime(2024, 6, 5),
        ),
      ];
      await repo.restoreFromSnapshot(newPayments);

      expect(repo.payments.length, 1);
      expect(repo.payments.first.id, 'new1');
      expect(repo.payments.first.planItemSeriesId, 's2');
    });

    test('restoring empty list clears all records', () async {
      final repo = _repo();
      await repo.confirmPayment('s1', YearMonth(2024, 1));
      await repo.restoreFromSnapshot([]);
      expect(repo.payments, isEmpty);
    });
  });

  // ── GuardPayment serialization ────────────────────────────────────────────

  group('GuardPayment serialization', () {
    test('paid record round-trips through toJson/fromJson', () {
      final original = GuardPayment(
        id: 'g1',
        planItemSeriesId: 's1',
        period: YearMonth(2024, 3),
        paidAt: DateTime(2024, 3, 15, 10, 30),
      );
      final restored = GuardPayment.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.planItemSeriesId, original.planItemSeriesId);
      expect(restored.period, original.period);
      expect(restored.paidAt, original.paidAt);
      expect(restored.silencedAt, isNull);
    });

    test('silenced record round-trips through toJson/fromJson', () {
      final original = GuardPayment(
        id: 'g2',
        planItemSeriesId: 's1',
        period: YearMonth(2024, 4),
        silencedAt: DateTime(2024, 4, 2),
      );
      final restored = GuardPayment.fromJson(original.toJson());
      expect(restored.silencedAt, original.silencedAt);
      expect(restored.paidAt, isNull);
    });

    test('bare record (no paidAt, no silencedAt) round-trips', () {
      final original = GuardPayment(
        id: 'g3',
        planItemSeriesId: 's1',
        period: YearMonth(2024, 5),
      );
      final restored = GuardPayment.fromJson(original.toJson());
      expect(restored.paidAt, isNull);
      expect(restored.silencedAt, isNull);
    });
  });

  // ── _collectGuardedPeriods cache invalidation ─────────────────────────────
  //
  // These tests verify that the result of unpaidActiveItems / allUnresolvedItems
  // updates correctly after each mutation, proving the cache is invalidated and
  // not returning stale data.

  group('_collectGuardedPeriods cache invalidation', () {
    test('repeated calls with same inputs return identical result', () {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      final first = repo.unpaidActiveItems([item], now);
      final second = repo.unpaidActiveItems([item], now);
      expect(second.length, first.length);
      for (var i = 0; i < first.length; i++) {
        expect(second[i].$2, first[i].$2);
      }
    });

    test('cache is invalidated after confirmPayment', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      // Populate cache.
      final before = repo.unpaidActiveItems([item], now);
      expect(before.length, 3); // Jan, Feb, Mar

      await repo.confirmPayment('s1', YearMonth(2024, 1));

      // Must reflect the new state, not the cached result.
      final after = repo.unpaidActiveItems([item], now);
      expect(after.length, 2); // Feb, Mar (Jan is paid)
    });

    test('cache is invalidated after silencePayment', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      // Populate cache for unpaidActive.
      final before = repo.unpaidActiveItems([item], now);
      expect(before.length, 3);

      await repo.silencePayment('s1', YearMonth(2024, 1));

      // unpaidActiveItems excludes silenced — result must shrink.
      final after = repo.unpaidActiveItems([item], now);
      expect(after.length, 2); // Feb, Mar (Jan is silenced)
    });

    test('cache is invalidated after revokePayment', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      await repo.confirmPayment('s1', YearMonth(2024, 1));

      // Populate cache with Jan already paid.
      final withPaid = repo.unpaidActiveItems([item], now);
      expect(withPaid.length, 2); // Feb, Mar

      await repo.revokePayment('s1', YearMonth(2024, 1));

      // Jan returns to unpaidActive — result must grow.
      final afterRevoke = repo.unpaidActiveItems([item], now);
      expect(afterRevoke.length, 3); // Jan, Feb, Mar
    });

    test('allUnresolvedItems cache is invalidated after silencePayment', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 2);

      // Populate cache — both months unresolved.
      final before = repo.allUnresolvedItems([item], now);
      expect(before.length, 2); // Jan, Feb

      await repo.silencePayment('s1', YearMonth(2024, 1));

      // allUnresolvedItems includes silenced — count unchanged but Jan is silenced.
      final after = repo.allUnresolvedItems([item], now);
      expect(after.length, 2); // Jan (silenced) + Feb (unpaid)
      // The item in the result must still be there; state changes happen via
      // itemStateForPeriod, not through the list itself.
    });

    test('cache is invalidated after restoreFromSnapshot', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      // Populate cache with no payments.
      final before = repo.unpaidActiveItems([item], now);
      expect(before.length, 3);

      // Restore a snapshot that marks Jan as paid.
      final snapshot = [
        GuardPayment(
          id: 'g1',
          planItemSeriesId: 's1',
          period: YearMonth(2024, 1),
          paidAt: DateTime(2024, 1, 15),
        ),
      ];
      await repo.restoreFromSnapshot(snapshot);

      final after = repo.unpaidActiveItems([item], now);
      expect(after.length, 2); // Feb, Mar (Jan paid via snapshot)
    });

    test('cache is invalidated after clearAll', () async {
      final repo = _repo();
      final item = _monthlyGuarded(fromYear: 2024, fromMonth: 1, dueDay: 1);
      final now = YearMonth(2024, 3);

      await repo.confirmPayment('s1', YearMonth(2024, 1));
      await repo.confirmPayment('s1', YearMonth(2024, 2));

      // Populate cache with 2 payments recorded.
      final withPaid = repo.unpaidActiveItems([item], now);
      expect(withPaid.length, 1); // Only Mar

      await repo.clearAll();

      // All payments gone — all 3 months are unpaid again.
      final afterClear = repo.unpaidActiveItems([item], now);
      expect(afterClear.length, 3);
    });
  });
}
