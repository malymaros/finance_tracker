import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

PlanItem _income({
  String id = 'i1',
  String? seriesId,
  double amount = 3000,
  PlanFrequency frequency = PlanFrequency.monthly,
}) =>
    PlanItem(
      id: id,
      seriesId: seriesId ?? id,
      name: 'Salary',
      amount: amount,
      type: PlanItemType.income,
      frequency: frequency,
      validFrom: YearMonth(2024, 1),
    );

PlanItem _guardedFixedCost({
  String id = 'f1',
  int? guardDueDay = 5,
}) =>
    PlanItem(
      id: id,
      seriesId: id,
      name: 'Rent',
      amount: 800,
      type: PlanItemType.fixedCost,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(2024, 1),
      validTo: YearMonth(2025, 12),
      note: 'Due on the 5th',
      category: ExpenseCategory.housing,
      financialType: FinancialType.consumption,
      isGuarded: true,
      guardDueDay: guardDueDay,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Basic round-trip ───────────────────────────────────────────────────────

  group('PlanItem — basic serialization round-trip', () {
    test('income item: all fields preserved', () {
      final item = _income();
      final restored = PlanItem.fromJson(item.toJson());

      expect(restored.id, item.id);
      expect(restored.seriesId, item.seriesId);
      expect(restored.name, item.name);
      expect(restored.amount, item.amount);
      expect(restored.type, item.type);
      expect(restored.frequency, item.frequency);
      expect(restored.validFrom, item.validFrom);
      expect(restored.validTo, isNull);
      expect(restored.note, isNull);
      expect(restored.category, isNull);
      expect(restored.financialType, isNull);
      expect(restored.isGuarded, isFalse);
      expect(restored.guardDueDay, isNull);
    });

    test('fixed cost item with all optional fields preserved', () {
      final item = _guardedFixedCost();
      final restored = PlanItem.fromJson(item.toJson());

      expect(restored.type, PlanItemType.fixedCost);
      expect(restored.validTo, YearMonth(2025, 12));
      expect(restored.note, 'Due on the 5th');
      expect(restored.category, ExpenseCategory.housing);
      expect(restored.financialType, FinancialType.consumption);
      expect(restored.isGuarded, isTrue);
      expect(restored.guardDueDay, 5);
    });

    test('all three frequency values round-trip', () {
      for (final freq in PlanFrequency.values) {
        final item = _income(frequency: freq);
        expect(PlanItem.fromJson(item.toJson()).frequency, freq);
      }
    });

    test('both type values round-trip', () {
      for (final type in PlanItemType.values) {
        final item = PlanItem(
          id: 't',
          seriesId: 't',
          name: 'Test',
          amount: 100,
          type: type,
          frequency: PlanFrequency.monthly,
          validFrom: YearMonth(2024, 1),
        );
        expect(PlanItem.fromJson(item.toJson()).type, type);
      }
    });
  });

  // ── GUARD field serialization ──────────────────────────────────────────────

  group('PlanItem — GUARD field conditional serialization', () {
    test('isGuarded=false: key absent from JSON', () {
      final json = _income().toJson();
      expect(json.containsKey('isGuarded'), isFalse);
    });

    test('isGuarded=true: key present in JSON', () {
      final json = _guardedFixedCost().toJson();
      expect(json['isGuarded'], isTrue);
    });

    test('guardDueDay=null: key absent from JSON', () {
      final item = _guardedFixedCost(guardDueDay: null);
      expect(item.toJson().containsKey('guardDueDay'), isFalse);
    });

    test('guardDueDay set: key present in JSON with correct value', () {
      final json = _guardedFixedCost(guardDueDay: 15).toJson();
      expect(json['guardDueDay'], 15);
    });

    test('GUARD round-trip preserves isGuarded and guardDueDay', () {
      final item = _guardedFixedCost(guardDueDay: 10);
      final restored = PlanItem.fromJson(item.toJson());

      expect(restored.isGuarded, isTrue);
      expect(restored.guardDueDay, 10);
    });

    test('legacy guardDueMonth and guardOneTime keys in JSON are silently ignored', () {
      // Old data may contain these keys; fromJson must not crash.
      final json = _guardedFixedCost(guardDueDay: 5).toJson()
        ..['guardDueMonth'] = 3
        ..['guardOneTime'] = true;
      expect(() => PlanItem.fromJson(json), returnsNormally);
      final restored = PlanItem.fromJson(json);
      expect(restored.guardDueDay, 5);
      expect(restored.isGuarded, isTrue);
    });
  });

  // ── Backward compatibility (pre-GUARD data) ────────────────────────────────

  group('PlanItem — backward compat: missing GUARD keys default correctly', () {
    Map<String, dynamic> minimalJson() => {
          'id': 'old1',
          'seriesId': 'old1',
          'name': 'Old Item',
          'amount': 500.0,
          'type': 'fixedCost',
          'frequency': 'monthly',
          'validFrom': {'year': 2023, 'month': 1},
          'note': null,
        };

    test('isGuarded defaults to false when key absent', () {
      expect(PlanItem.fromJson(minimalJson()).isGuarded, isFalse);
    });

    test('guardDueDay defaults to null when key absent', () {
      expect(PlanItem.fromJson(minimalJson()).guardDueDay, isNull);
    });

    test('validTo defaults to null when key absent', () {
      expect(PlanItem.fromJson(minimalJson()).validTo, isNull);
    });

    test('category defaults to null when key absent', () {
      expect(PlanItem.fromJson(minimalJson()).category, isNull);
    });

    test('financialType defaults to null when key absent', () {
      expect(PlanItem.fromJson(minimalJson()).financialType, isNull);
    });
  });

  // ── Unknown enum values in fromJson ───────────────────────────────────────

  group('PlanItem — fromJson unknown enum values fall back gracefully', () {
    test('unknown frequency string defaults to monthly (regression)', () {
      final json = {
        'id': 'x',
        'seriesId': 'x',
        'name': 'Item',
        'amount': 100.0,
        'type': 'income',
        'frequency': 'once', // hypothetical renamed value
        'validFrom': {'year': 2024, 'month': 1},
        'note': null,
      };
      // Must not throw; falls back to monthly.
      final item = PlanItem.fromJson(json);
      expect(item.frequency, PlanFrequency.monthly);
    });

    test('unknown type string defaults to fixedCost', () {
      final json = {
        'id': 'x',
        'seriesId': 'x',
        'name': 'Item',
        'amount': 100.0,
        'type': 'expense', // hypothetical renamed value
        'frequency': 'monthly',
        'validFrom': {'year': 2024, 'month': 1},
        'note': null,
      };
      final item = PlanItem.fromJson(json);
      expect(item.type, PlanItemType.fixedCost);
    });
  });

  // ── copyWith sentinel pattern ─────────────────────────────────────────────

  group('PlanItem — copyWith sentinel for nullable fields', () {
    final base = _guardedFixedCost(guardDueDay: 5);

    test('copyWith with no args returns identical field values', () {
      final copy = base.copyWith();
      expect(copy.id, base.id);
      expect(copy.amount, base.amount);
      expect(copy.validTo, base.validTo);
      expect(copy.category, base.category);
      expect(copy.financialType, base.financialType);
      expect(copy.isGuarded, base.isGuarded);
      expect(copy.guardDueDay, base.guardDueDay);
    });

    test('copyWith amount changes only amount', () {
      final copy = base.copyWith(amount: 1200);
      expect(copy.amount, 1200);
      expect(copy.validTo, base.validTo);
      expect(copy.category, base.category);
      expect(copy.isGuarded, isTrue);
      expect(copy.guardDueDay, base.guardDueDay);
    });

    test('copyWith validTo: null explicitly clears the field', () {
      final copy = base.copyWith(validTo: null);
      expect(copy.validTo, isNull);
    });

    test('omitting validTo in copyWith preserves existing value', () {
      final copy = base.copyWith(amount: 999);
      expect(copy.validTo, base.validTo);
    });

    test('copyWith category: null explicitly clears the field', () {
      final copy = base.copyWith(category: null);
      expect(copy.category, isNull);
    });

    test('omitting category in copyWith preserves existing value', () {
      final copy = base.copyWith(amount: 999);
      expect(copy.category, base.category);
    });

    test('copyWith financialType: null explicitly clears the field', () {
      final copy = base.copyWith(financialType: null);
      expect(copy.financialType, isNull);
    });

    test('copyWith guardDueDay: null explicitly clears the field', () {
      final copy = base.copyWith(guardDueDay: null);
      expect(copy.guardDueDay, isNull);
    });

    test('omitting guardDueDay in copyWith preserves existing value', () {
      final copy = base.copyWith(amount: 999);
      expect(copy.guardDueDay, base.guardDueDay);
    });

  });
}
