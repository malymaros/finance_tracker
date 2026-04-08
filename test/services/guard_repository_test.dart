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
    );

PlanItem _yearlyGuarded({
  String id = 'y1',
  String seriesId = 'sy1',
  int fromYear = 2024,
  int fromMonth = 1,
  int? dueDay,
  YearMonth? validTo,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId,
      name: 'Tax',
      amount: 1000,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.yearly,
      validFrom: YearMonth(fromYear, fromMonth),
      validTo: validTo,
      category: ExpenseCategory.taxes,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: dueDay ?? 1,
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

  });

  // ── yearly items — anchor month = validFrom.month ─────────────────────────

  group('yearly guard — anchor month is validFrom.month', () {
    test('fires in validFrom.month of the active version each year', () {
      final repo = _repo();
      // Yearly item starting in March 2023 — anchor month is March.
      final item = _yearlyGuarded(
        fromYear: 2023,
        fromMonth: 3, // anchor month = March
        dueDay: 1,
      );
      final now = YearMonth(2025, 6);
      final result = repo.unpaidActiveItems([item], now);
      final periods = result.map((p) => p.$2).toList();

      // March 2023, March 2024, March 2025 should all fire.
      expect(periods, contains(YearMonth(2023, 3)));
      expect(periods, contains(YearMonth(2024, 3)));
      expect(periods, contains(YearMonth(2025, 3)));
      // Non-anchor months must NOT fire.
      expect(periods, isNot(contains(YearMonth(2024, 6))));
      expect(periods, isNot(contains(YearMonth(2024, 1))));
    });

    test('versioned series: each version uses its own validFrom.month as anchor', () {
      final repo = _repo();
      // v1: validFrom = Jan 2023 (anchor = January)
      final v1 = _yearlyGuarded(
        id: 'y_v1',
        seriesId: 'sy1',
        fromYear: 2023,
        fromMonth: 1,
        dueDay: 1,
        validTo: YearMonth(2023, 12), // capped by v2
      );
      // v2: validFrom = Jan 2024, but a different anchor month would require
      // a cycle-boundary edit; for yearly versioning the anchor must stay the same.
      // Here we model it correctly: v2 also starts in January (same anchor).
      final v2 = _yearlyGuarded(
        id: 'y_v2',
        seriesId: 'sy1',
        fromYear: 2024,
        fromMonth: 1,
        dueDay: 1,
      );
      final now = YearMonth(2025, 6);
      final result = repo.unpaidActiveItems([v1, v2], now);
      final periods = result.map((p) => p.$2).toList();

      // January fires in 2023 (v1), 2024, 2025 (v2).
      expect(periods, contains(YearMonth(2023, 1)));
      expect(periods, contains(YearMonth(2024, 1)));
      expect(periods, contains(YearMonth(2025, 1)));
    });

    test('yearly item with validTo does not fire after expiry', () {
      final repo = _repo();
      // Item active Jan 2023 – March 2025, anchor month = January.
      final item = _yearlyGuarded(
        fromYear: 2023,
        fromMonth: 1,
        dueDay: 1,
        validTo: YearMonth(2025, 3), // expires March 2025
      );
      final now = YearMonth(2026, 6);
      final result = repo.unpaidActiveItems([item], now);
      final periods = result.map((p) => p.$2).toList();

      // Jan 2023 and Jan 2024 are within active range.
      expect(periods, contains(YearMonth(2023, 1)));
      expect(periods, contains(YearMonth(2024, 1)));
      // Jan 2025 is within validTo (March 2025) — should appear.
      expect(periods, contains(YearMonth(2025, 1)));
      // Jan 2026 is after expiry — must NOT appear.
      expect(periods, isNot(contains(YearMonth(2026, 1))));
    });
  });

  // ── itemStateForPeriod — yearly non-anchor month ─────────────────────────

  group('itemStateForPeriod — yearly non-anchor month', () {
    test('returns none for a non-anchor month even when period is in the past',
        () {
      final repo = _repo();
      // Yearly item, anchor month = March (validFrom.month = 3).
      final item = _yearlyGuarded(
        fromYear: 2026,
        fromMonth: 3, // anchor = March
        dueDay: 1,
      );
      // April 2026 is a past/current period but is NOT the anchor month.
      expect(
        repo.itemStateForPeriod(item, YearMonth(2026, 4)),
        GuardState.none,
      );
      // Any other non-anchor month should also be none.
      expect(
        repo.itemStateForPeriod(item, YearMonth(2026, 6)),
        GuardState.none,
      );
      expect(
        repo.itemStateForPeriod(item, YearMonth(2026, 1)),
        GuardState.none,
      );
    });

    test('returns correct state for the anchor month (March)', () {
      final repo = _repo();
      final item = _yearlyGuarded(
        fromYear: 2024,
        fromMonth: 3,
        dueDay: 1,
      );
      // March 2024 is the anchor month — should return unpaidActive (no record).
      expect(
        repo.itemStateForPeriod(item, YearMonth(2024, 3)),
        GuardState.unpaidActive,
      );
    });

    test('future anchor month returns scheduled', () {
      final repo = _repo();
      final item = _yearlyGuarded(
        fromYear: 2024,
        fromMonth: 3,
        dueDay: 1,
      );
      // March 2099 is the anchor month but far in the future.
      expect(
        repo.itemStateForPeriod(item, YearMonth(2099, 3)),
        GuardState.scheduled,
      );
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

  // ── updatePaidDate ────────────────────────────────────────────────────────

  group('updatePaidDate', () {
    test('updates paidAt on an existing paid record', () async {
      final repo = _repo();
      final item = _monthlyGuarded();
      final period = YearMonth(2024, 3);

      await repo.confirmPayment('s1', period);
      final newDate = DateTime(2024, 3, 15);
      await repo.updatePaidDate('s1', period, newDate);

      final record = repo.payments.firstWhere(
          (p) => p.planItemSeriesId == 's1' && p.period == period);
      expect(record.paidAt, newDate);
      expect(repo.itemStateForPeriod(item, period), GuardState.paid);
    });

    test('preserves the original record id after update', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);

      await repo.confirmPayment('s1', period);
      final originalId = repo.payments
          .firstWhere((p) => p.planItemSeriesId == 's1' && p.period == period)
          .id;

      await repo.updatePaidDate('s1', period, DateTime(2024, 3, 20));

      final updatedId = repo.payments
          .firstWhere((p) => p.planItemSeriesId == 's1' && p.period == period)
          .id;
      expect(updatedId, originalId);
    });

    test('is a no-op when no paid record exists', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);

      await repo.updatePaidDate('s1', period, DateTime(2024, 3, 10));
      expect(repo.payments, isEmpty);
    });

    test('is a no-op when the record is silenced (not paid)', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);

      await repo.silencePayment('s1', period);
      await repo.updatePaidDate('s1', period, DateTime(2024, 3, 10));

      final record = repo.payments.firstWhere(
          (p) => p.planItemSeriesId == 's1' && p.period == period);
      expect(record.paidAt, isNull);
      expect(record.silencedAt, isNotNull);
    });

    test('notifies listeners after update', () async {
      final repo = _repo();
      final period = YearMonth(2024, 3);
      await repo.confirmPayment('s1', period);

      var notified = false;
      repo.addListener(() => notified = true);
      notified = false; // reset after confirmPayment notification

      await repo.updatePaidDate('s1', period, DateTime(2024, 3, 5));
      expect(notified, isTrue);
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
