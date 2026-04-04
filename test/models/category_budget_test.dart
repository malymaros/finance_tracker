import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_budget.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/year_month.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

CategoryBudget _budget({
  String id = 'b1',
  String? seriesId,
  ExpenseCategory category = ExpenseCategory.groceries,
  double amount = 300,
  YearMonth? validFrom,
  YearMonth? validTo,
}) =>
    CategoryBudget(
      id: id,
      seriesId: seriesId ?? id,
      category: category,
      amount: amount,
      validFrom: validFrom ?? YearMonth(2025, 1),
      validTo: validTo,
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── Serialization round-trip ───────────────────────────────────────────────

  group('CategoryBudget — serialization round-trip', () {
    test('all fields preserved without validTo', () {
      final b = _budget();
      final r = CategoryBudget.fromJson(b.toJson());

      expect(r.id, b.id);
      expect(r.seriesId, b.seriesId);
      expect(r.category, b.category);
      expect(r.amount, b.amount);
      expect(r.validFrom, b.validFrom);
      expect(r.validTo, isNull);
    });

    test('validTo preserved when set', () {
      final b = _budget(validTo: YearMonth(2025, 6));
      final r = CategoryBudget.fromJson(b.toJson());
      expect(r.validTo, YearMonth(2025, 6));
    });

    test('validTo absent from JSON when null', () {
      final json = _budget().toJson();
      expect(json.containsKey('validTo'), isFalse);
    });

    test('validTo present in JSON when set', () {
      final json = _budget(validTo: YearMonth(2025, 3)).toJson();
      expect(json.containsKey('validTo'), isTrue);
    });

    test('category round-trips for all ExpenseCategory values', () {
      for (final cat in ExpenseCategory.values) {
        final b = _budget(category: cat);
        expect(CategoryBudget.fromJson(b.toJson()).category, cat);
      }
    });
  });

  // ── copyWith ───────────────────────────────────────────────────────────────

  group('CategoryBudget — copyWith', () {
    test('no args returns identical field values', () {
      final b = _budget(validTo: YearMonth(2025, 6));
      final copy = b.copyWith();

      expect(copy.id, b.id);
      expect(copy.seriesId, b.seriesId);
      expect(copy.category, b.category);
      expect(copy.amount, b.amount);
      expect(copy.validFrom, b.validFrom);
      expect(copy.validTo, b.validTo);
    });

    test('amount change preserves all other fields', () {
      final b = _budget(validTo: YearMonth(2025, 12));
      final copy = b.copyWith(amount: 500);
      expect(copy.amount, 500);
      expect(copy.validTo, b.validTo);
      expect(copy.category, b.category);
    });

    test('clearValidTo: true sets validTo to null', () {
      final b = _budget(validTo: YearMonth(2025, 6));
      final copy = b.copyWith(clearValidTo: true);
      expect(copy.validTo, isNull);
    });

    test('clearValidTo: false (default) preserves existing validTo', () {
      final b = _budget(validTo: YearMonth(2025, 6));
      final copy = b.copyWith(amount: 400);
      expect(copy.validTo, YearMonth(2025, 6));
    });

    test('passing new validTo replaces the existing one', () {
      final b = _budget(validTo: YearMonth(2025, 6));
      final copy = b.copyWith(validTo: YearMonth(2026, 3));
      expect(copy.validTo, YearMonth(2026, 3));
    });

    test('clearValidTo: true overrides a passed validTo', () {
      // clearValidTo takes priority — sets to null even if validTo is also passed
      final b = _budget(validTo: YearMonth(2025, 6));
      final copy = b.copyWith(validTo: YearMonth(2026, 1), clearValidTo: true);
      expect(copy.validTo, isNull);
    });
  });
}
