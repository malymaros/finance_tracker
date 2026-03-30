import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/plan_repository.dart';

PlanItem makeItem({
  String id = '1',
  String? seriesId,
  double amount = 1000,
  PlanItemType type = PlanItemType.income,
  PlanFrequency frequency = PlanFrequency.monthly,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Item $id',
      amount: amount,
      type: type,
      frequency: frequency,
      validFrom: YearMonth(2024, 1),
    );

PlanItem makeGuardedItem({
  String id = '1',
  String? seriesId,
  int fromYear = 2024,
  int fromMonth = 1,
  int? toYear,
  int? toMonth,
  int guardDueDay = 1,
  int? guardDueMonth,
  bool guardOneTime = false,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Guarded $id',
      amount: 500,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(fromYear, fromMonth),
      validTo: (toYear != null && toMonth != null)
          ? YearMonth(toYear, toMonth)
          : null,
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: guardDueDay,
      guardDueMonth: guardDueMonth,
      guardOneTime: guardOneTime,
    );

void main() {
  group('PlanRepository', () {
    test('starts empty', () {
      expect(PlanRepository(persist: false).items, isEmpty);
    });

    test('seed initializes repository', () {
      final repo = PlanRepository(persist: false, seed: [makeItem()]);
      expect(repo.items.length, 1);
    });

    test('items list is unmodifiable', () {
      final repo = PlanRepository(persist: false, seed: [makeItem()]);
      expect(() => (repo.items as dynamic).add(makeItem(id: '99')),
          throwsUnsupportedError);
    });

    test('addPlanItem increases count', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem());
      expect(repo.items.length, 1);
    });

    test('removePlanItem removes by id', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: 'a'));
      await repo.addPlanItem(makeItem(id: 'b'));
      await repo.removePlanItem('a');
      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'b');
    });

    test('removePlanItem on only version leaves list empty', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: 'x'));
      await repo.removePlanItem('x');
      expect(repo.items, isEmpty);
    });

    test('removePlanItem leaves prior version of same series active', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: 'v1', seriesId: 's', amount: 3000));
      await repo.addPlanItem(makeItem(id: 'v2', seriesId: 's', amount: 4500));
      await repo.removePlanItem('v2');
      expect(repo.items.length, 1);
      expect(repo.items.first.amount, 3000);
    });

    test('updatePlanItem replaces matching item', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: '1', amount: 1000));
      await repo.updatePlanItem(makeItem(id: '1', amount: 2000));
      expect(repo.items.first.amount, 2000);
    });

    test('updatePlanItem with unknown id does nothing', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: '1'));
      await repo.updatePlanItem(makeItem(id: 'unknown'));
      expect(repo.items.length, 1);
    });

    test('notifies listeners on add', () async {
      final repo = PlanRepository(persist: false);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.addPlanItem(makeItem());
      expect(notified, isTrue);
    });

    test('notifies listeners on remove', () async {
      final repo = PlanRepository(persist: false, seed: [makeItem()]);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.removePlanItem('1');
      expect(notified, isTrue);
    });

    test('notifies listeners on update', () async {
      final repo = PlanRepository(persist: false, seed: [makeItem(id: '1')]);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.updatePlanItem(makeItem(id: '1', amount: 9999));
      expect(notified, isTrue);
    });

    test('restoreFromSnapshot replaces all items', () async {
      final repo = PlanRepository(
        persist: false,
        seed: [makeItem(id: 'old1'), makeItem(id: 'old2')],
      );

      final newItems = [makeItem(id: 'new1', amount: 7777)];
      await repo.restoreFromSnapshot(newItems);

      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'new1');
      expect(repo.items.first.amount, 7777);
    });

    test('restoreFromSnapshot with empty list clears all items', () async {
      final repo =
          PlanRepository(persist: false, seed: [makeItem(), makeItem(id: '2')]);
      await repo.restoreFromSnapshot([]);
      expect(repo.items, isEmpty);
    });

    test('restoreFromSnapshot notifies listeners', () async {
      final repo = PlanRepository(persist: false, seed: [makeItem()]);
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.restoreFromSnapshot([]);
      expect(notified, isTrue);
    });
  });

  group('PlanItem serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = PlanItem(
        id: 'abc',
        seriesId: 'series1',
        name: 'Salary',
        amount: 3500.0,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 3),
        note: 'Main job',
      );
      final restored = PlanItem.fromJson(original.toJson());
      expect(restored.id, original.id);
      expect(restored.seriesId, original.seriesId);
      expect(restored.name, original.name);
      expect(restored.amount, original.amount);
      expect(restored.type, original.type);
      expect(restored.frequency, original.frequency);
      expect(restored.validFrom, original.validFrom);
      expect(restored.note, original.note);
    });

    test('fromJson handles null note', () {
      final item = PlanItem.fromJson({
        'id': '1',
        'seriesId': '1',
        'name': 'Rent',
        'amount': 800.0,
        'type': 'fixedCost',
        'frequency': 'monthly',
        'validFrom': {'year': 2024, 'month': 1},
        'note': null,
      });
      expect(item.note, isNull);
    });

    test('fixedCost with category and financialType round-trips correctly', () {
      final original = PlanItem(
        id: 'fc1',
        seriesId: 'fc1',
        name: 'ETF savings',
        amount: 500.0,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        category: ExpenseCategory.investment,
        financialType: FinancialType.asset,
      );
      final restored = PlanItem.fromJson(original.toJson());
      expect(restored.category, ExpenseCategory.investment);
      expect(restored.financialType, FinancialType.asset);
    });

    test('fromJson handles missing category and financialType (null)', () {
      final item = PlanItem.fromJson({
        'id': '1',
        'seriesId': '1',
        'name': 'Rent',
        'amount': 800.0,
        'type': 'fixedCost',
        'frequency': 'monthly',
        'validFrom': {'year': 2024, 'month': 1},
      });
      expect(item.category, isNull);
      expect(item.financialType, isNull);
    });

    test('income item toJson does not write category or financialType keys', () {
      final item = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
      );
      final json = item.toJson();
      expect(json.containsKey('category'), isFalse);
      expect(json.containsKey('financialType'), isFalse);
    });

    test('validTo round-trips correctly when set', () {
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Rent',
        amount: 900,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        validTo: YearMonth(2024, 6),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      );
      final restored = PlanItem.fromJson(original.toJson());
      expect(restored.validTo, equals(YearMonth(2024, 6)));
    });

    test('validTo is null when omitted from JSON', () {
      final item = PlanItem.fromJson({
        'id': '1',
        'seriesId': '1',
        'name': 'Internet',
        'amount': 30.0,
        'type': 'fixedCost',
        'frequency': 'monthly',
        'validFrom': {'year': 2024, 'month': 1},
      });
      expect(item.validTo, isNull);
    });

    test('validTo null round-trips to null', () {
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Internet',
        amount: 30,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 1),
        category: ExpenseCategory.subscriptions,
        financialType: FinancialType.consumption,
      );
      final restored = PlanItem.fromJson(original.toJson());
      expect(restored.validTo, isNull);
    });
  });

  group('removePlanItemFrom', () {
    PlanItem itemAt(String id, String seriesId, int year, int month) => PlanItem(
          id: id,
          seriesId: seriesId,
          name: 'Item $id',
          amount: 1000,
          type: PlanItemType.income,
          frequency: PlanFrequency.monthly,
          validFrom: YearMonth(year, month),
        );

    test('deleting from validFrom month removes item entirely', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('a', 'a', 2024, 1));
      await repo.removePlanItemFrom('a', YearMonth(2024, 1));
      expect(repo.items, isEmpty);
    });

    test('deleting from a later month truncates: item remains with validTo set',
        () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('a', 'a', 2024, 1));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));
      expect(repo.items.length, 1);
      expect(repo.items.first.validTo, YearMonth(2024, 2));
    });

    test('truncated item keeps its original validFrom', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('a', 'a', 2024, 1));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));
      expect(repo.items.first.validFrom, YearMonth(2024, 1));
    });

    test('deleting from a later month removes later versions in the same series',
        () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 6));
      // v1 is the active version in March; deleting from March removes v1
      // (truncated to Feb) and also removes v2 since its validFrom >= March.
      await repo.removePlanItemFrom('v1', YearMonth(2024, 3));
      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'v1');
      expect(repo.items.first.validTo, YearMonth(2024, 2));
    });

    test(
        'deleting mid-chain: earlier predecessor is preserved, '
        'target and later versions are removed', () async {
      // v1 Jan, v2 Apr, v3 Aug — all same series.
      // Deleting v2 from Apr: v1 should be untouched, v2+v3 gone.
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 4));
      await repo.addPlanItem(itemAt('v3', 's', 2024, 8));
      await repo.removePlanItemFrom('v2', YearMonth(2024, 4));
      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'v1');
      expect(repo.items.first.validTo, isNull); // v1 was not modified
    });

    test(
        'deleting from a month after start truncates active version '
        'and drops all later versions in the series', () async {
      // v1 Jan, v2 Apr, v3 Aug — deleting v2 from June (active version is v2).
      // Expected: v1 untouched, v2 truncated to May, v3 removed.
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 4));
      await repo.addPlanItem(itemAt('v3', 's', 2024, 8));
      await repo.removePlanItemFrom('v2', YearMonth(2024, 6));
      // v1 remains unchanged
      final v1 = repo.items.firstWhere((e) => e.id == 'v1');
      expect(v1.validTo, isNull);
      // v2 remains but is truncated to May
      final v2 = repo.items.firstWhere((e) => e.id == 'v2');
      expect(v2.validTo, YearMonth(2024, 5));
      // v3 is gone
      expect(repo.items.any((e) => e.id == 'v3'), isFalse);
    });
  });

  group('removeFutureVersions', () {
    PlanItem itemAt(String id, String seriesId, int year, int month) => PlanItem(
          id: id,
          seriesId: seriesId,
          name: 'Item $id',
          amount: 1000,
          type: PlanItemType.income,
          frequency: PlanFrequency.monthly,
          validFrom: YearMonth(year, month),
        );

    test('does not remove the item at exactly the given month', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 6));
      await repo.removeFutureVersions('s', YearMonth(2024, 6));
      expect(repo.items.any((e) => e.id == 'v2'), isTrue);
    });

    test('removes items with validFrom strictly after the given month',
        () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 6));
      await repo.removeFutureVersions('s', YearMonth(2024, 1));
      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'v1');
    });

    test('does not touch items in a different series', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('a1', 'a', 2024, 1));
      await repo.addPlanItem(itemAt('a2', 'a', 2024, 6));
      await repo.addPlanItem(itemAt('b1', 'b', 2024, 3));
      await repo.removeFutureVersions('a', YearMonth(2024, 1));
      expect(repo.items.any((e) => e.id == 'b1'), isTrue);
    });

    test('no-op when no items qualify', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.removeFutureVersions('s', YearMonth(2024, 12));
      expect(repo.items.length, 1);
    });

    test('removes multiple future versions in one call', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(itemAt('v1', 's', 2024, 1));
      await repo.addPlanItem(itemAt('v2', 's', 2024, 4));
      await repo.addPlanItem(itemAt('v3', 's', 2024, 8));
      await repo.addPlanItem(itemAt('v4', 's', 2024, 11));
      await repo.removeFutureVersions('s', YearMonth(2024, 1));
      expect(repo.items.length, 1);
      expect(repo.items.first.id, 'v1');
    });
  });

  // ── removePlanItemFrom — guard fields regression ──────────────────────────

  group('removePlanItemFrom — guard fields preserved on truncated item', () {
    // Regression: the re-added historical item was missing isGuarded, guardDueDay,
    // guardDueMonth, and guardOneTime. Those fields defaulted to false/null,
    // silently disabling GUARD on past periods.

    test('truncated item keeps isGuarded=true', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'a', seriesId: 'a'));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));

      expect(repo.items.length, 1);
      expect(repo.items.first.isGuarded, isTrue);
    });

    test('truncated item keeps guardDueDay', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(
          makeGuardedItem(id: 'a', seriesId: 'a', guardDueDay: 15));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));

      expect(repo.items.first.guardDueDay, 15);
    });

    test('truncated item keeps guardDueMonth', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(
          makeGuardedItem(id: 'a', seriesId: 'a', guardDueMonth: 6));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));

      expect(repo.items.first.guardDueMonth, 6);
    });

    test('truncated item keeps guardOneTime=true', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(
          makeGuardedItem(id: 'a', seriesId: 'a', guardOneTime: true));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));

      expect(repo.items.first.guardOneTime, isTrue);
    });

    test('non-guarded item truncated normally with isGuarded=false', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: 'a', seriesId: 'a'));
      await repo.removePlanItemFrom('a', YearMonth(2024, 3));

      expect(repo.items.first.isGuarded, isFalse);
    });
  });

  // ── updateGuardConfigForSeries ────────────────────────────────────────────

  group('updateGuardConfigForSeries', () {
    test('updates guardDueDay on all versions of a series', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's', guardDueDay: 1));
      await repo.addPlanItem(makeGuardedItem(id: 'v2', seriesId: 's', guardDueDay: 1));

      await repo.updateGuardConfigForSeries('s', guardDueDay: 20);

      for (final item in repo.items) {
        expect(item.guardDueDay, 20);
      }
    });

    test('updates guardDueMonth when provided', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's', guardDueMonth: 3));

      await repo.updateGuardConfigForSeries('s', guardDueDay: 5, guardDueMonth: 9);

      expect(repo.items.first.guardDueMonth, 9);
    });

    test('preserves existing guardDueMonth when not provided', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's', guardDueMonth: 6));

      await repo.updateGuardConfigForSeries('s', guardDueDay: 10);

      expect(repo.items.first.guardDueMonth, 6); // unchanged
    });

    test('does not touch items in a different series', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'a', seriesId: 'a', guardDueDay: 1));
      await repo.addPlanItem(makeGuardedItem(id: 'b', seriesId: 'b', guardDueDay: 1));

      await repo.updateGuardConfigForSeries('a', guardDueDay: 25);

      final b = repo.items.firstWhere((e) => e.id == 'b');
      expect(b.guardDueDay, 1); // unchanged
    });

    test('notifies listeners', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's'));
      var notified = false;
      repo.addListener(() => notified = true);

      await repo.updateGuardConfigForSeries('s', guardDueDay: 5);
      expect(notified, isTrue);
    });

    test('no-op for unknown seriesId', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's', guardDueDay: 1));
      var notified = false;
      repo.addListener(() => notified = true);

      await repo.updateGuardConfigForSeries('unknown', guardDueDay: 5);

      expect(notified, isFalse);
      expect(repo.items.first.guardDueDay, 1); // unchanged
    });
  });

  // ── disableGuardForSeries ─────────────────────────────────────────────────

  group('disableGuardForSeries', () {
    test('sets isGuarded=false on all versions of a series', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's'));
      await repo.addPlanItem(makeGuardedItem(id: 'v2', seriesId: 's'));

      await repo.disableGuardForSeries('s');

      for (final item in repo.items) {
        expect(item.isGuarded, isFalse);
      }
    });

    test('clears guardDueDay and guardDueMonth', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(
          makeGuardedItem(id: 'v1', seriesId: 's', guardDueDay: 15, guardDueMonth: 6));

      await repo.disableGuardForSeries('s');

      expect(repo.items.first.guardDueDay, isNull);
      expect(repo.items.first.guardDueMonth, isNull);
    });

    test('clears guardOneTime', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(
          makeGuardedItem(id: 'v1', seriesId: 's', guardOneTime: true));

      await repo.disableGuardForSeries('s');

      expect(repo.items.first.guardOneTime, isFalse);
    });

    test('does not touch items in a different series', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'a', seriesId: 'a'));
      await repo.addPlanItem(makeGuardedItem(id: 'b', seriesId: 'b'));

      await repo.disableGuardForSeries('a');

      final b = repo.items.firstWhere((e) => e.id == 'b');
      expect(b.isGuarded, isTrue); // unchanged
    });

    test('notifies listeners', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeGuardedItem(id: 'v1', seriesId: 's'));
      var notified = false;
      repo.addListener(() => notified = true);

      await repo.disableGuardForSeries('s');
      expect(notified, isTrue);
    });

    test('no-op when series is already unguarded', () async {
      final repo = PlanRepository(persist: false);
      await repo.addPlanItem(makeItem(id: 'v1', seriesId: 's'));
      var notified = false;
      repo.addListener(() => notified = true);

      await repo.disableGuardForSeries('s');
      expect(notified, isFalse);
    });
  });

  // ── PlanItem guard field serialization ───────────────────────────────────

  group('PlanItem — guard field serialization', () {
    test('guard fields round-trip through toJson/fromJson', () {
      final original = makeGuardedItem(
        id: 'g1',
        guardDueDay: 15,
        guardDueMonth: 6,
        guardOneTime: true,
      );
      final restored = PlanItem.fromJson(original.toJson());
      expect(restored.isGuarded, isTrue);
      expect(restored.guardDueDay, 15);
      expect(restored.guardDueMonth, 6);
      expect(restored.guardOneTime, isTrue);
    });

    test('fromJson with missing guard keys defaults to false/null', () {
      final item = PlanItem.fromJson({
        'id': '1',
        'seriesId': '1',
        'name': 'Rent',
        'amount': 800.0,
        'type': 'fixedCost',
        'frequency': 'monthly',
        'validFrom': {'year': 2024, 'month': 1},
      });
      expect(item.isGuarded, isFalse);
      expect(item.guardDueDay, isNull);
      expect(item.guardDueMonth, isNull);
      expect(item.guardOneTime, isFalse);
    });

    test('unguarded item toJson omits guard keys', () {
      final item = makeItem(id: '1', type: PlanItemType.fixedCost);
      final json = item.toJson();
      expect(json.containsKey('isGuarded'), isFalse);
      expect(json.containsKey('guardDueDay'), isFalse);
      expect(json.containsKey('guardDueMonth'), isFalse);
      expect(json.containsKey('guardOneTime'), isFalse);
    });

    test('guarded item toJson writes isGuarded=true and due fields', () {
      final item = makeGuardedItem(id: 'g1', guardDueDay: 10, guardDueMonth: 3);
      final json = item.toJson();
      expect(json['isGuarded'], isTrue);
      expect(json['guardDueDay'], 10);
      expect(json['guardDueMonth'], 3);
    });
  });
}
