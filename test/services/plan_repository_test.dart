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
}
