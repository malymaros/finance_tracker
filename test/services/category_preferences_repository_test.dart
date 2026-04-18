import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/category_preferences.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/services/category_preferences_repository.dart';

CategoryPreferencesRepository _repo() => CategoryPreferencesRepository();

void main() {
  group('CategoryPreferencesRepository — initial state', () {
    test('visibleForExpenses returns default set', () {
      final repo = _repo();
      for (final cat in CategoryPreferences.defaultExpenses) {
        expect(repo.visibleForExpenses, contains(cat));
      }
    });

    test('visibleForPlan returns default plan set', () {
      final repo = _repo();
      for (final cat in CategoryPreferences.defaultPlan) {
        expect(repo.visibleForPlan, contains(cat));
      }
    });

    test('isVisibleForExpenses true for default category', () {
      final repo = _repo();
      expect(repo.isVisibleForExpenses(ExpenseCategory.groceries), isTrue);
    });

    test('isVisibleForExpenses false for non-default category', () {
      final repo = _repo();
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isFalse);
    });

    test('isVisibleForPlan true for default plan category', () {
      final repo = _repo();
      expect(repo.isVisibleForPlan(ExpenseCategory.housing), isTrue);
    });
  });

  group('CategoryPreferencesRepository.toggleExpenses', () {
    test('adds non-default category to visible set', () async {
      final repo = _repo();
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isFalse);
      await repo.toggleExpenses(ExpenseCategory.fuel);
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isTrue);
    });

    test('removes non-default category on second toggle', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.fuel);
      await repo.toggleExpenses(ExpenseCategory.fuel);
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isFalse);
    });

    test('removes default category from visible set', () async {
      final repo = _repo();
      expect(repo.isVisibleForExpenses(ExpenseCategory.clothing), isTrue);
      await repo.toggleExpenses(ExpenseCategory.clothing);
      expect(repo.isVisibleForExpenses(ExpenseCategory.clothing), isFalse);
    });

    test('restores default category on second toggle', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.clothing);
      await repo.toggleExpenses(ExpenseCategory.clothing);
      expect(repo.isVisibleForExpenses(ExpenseCategory.clothing), isTrue);
    });

    test('other cannot be toggled out of visible set', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.other);
      expect(repo.isVisibleForExpenses(ExpenseCategory.other), isTrue);
    });

    test('notifies listeners on toggle', () async {
      final repo = _repo();
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.toggleExpenses(ExpenseCategory.fuel);
      expect(notified, isTrue);
    });
  });

  group('CategoryPreferencesRepository.togglePlan', () {
    test('adds non-default category to plan visible set', () async {
      final repo = _repo();
      expect(repo.isVisibleForPlan(ExpenseCategory.fuel), isFalse);
      await repo.togglePlan(ExpenseCategory.fuel);
      expect(repo.isVisibleForPlan(ExpenseCategory.fuel), isTrue);
    });

    test('removes non-default category on second toggle', () async {
      final repo = _repo();
      await repo.togglePlan(ExpenseCategory.fuel);
      await repo.togglePlan(ExpenseCategory.fuel);
      expect(repo.isVisibleForPlan(ExpenseCategory.fuel), isFalse);
    });

    test('removes default plan category from visible set', () async {
      final repo = _repo();
      expect(repo.isVisibleForPlan(ExpenseCategory.housing), isTrue);
      await repo.togglePlan(ExpenseCategory.housing);
      expect(repo.isVisibleForPlan(ExpenseCategory.housing), isFalse);
    });

    test('restores default plan category on second toggle', () async {
      final repo = _repo();
      await repo.togglePlan(ExpenseCategory.housing);
      await repo.togglePlan(ExpenseCategory.housing);
      expect(repo.isVisibleForPlan(ExpenseCategory.housing), isTrue);
    });

    test('other cannot be toggled out of plan visible set', () async {
      final repo = _repo();
      await repo.togglePlan(ExpenseCategory.other);
      expect(repo.isVisibleForPlan(ExpenseCategory.other), isTrue);
    });
  });

  group('CategoryPreferencesRepository.clearAll', () {
    test('resets added non-default category', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.fuel);
      await repo.clearAll();
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isFalse);
    });

    test('restores removed default category', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.clothing);
      await repo.clearAll();
      expect(repo.isVisibleForExpenses(ExpenseCategory.clothing), isTrue);
    });

    test('notifies listeners', () async {
      final repo = _repo();
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.clearAll();
      expect(notified, isTrue);
    });
  });

  group('CategoryPreferencesRepository.restoreFromSnapshot', () {
    test('null snapshot resets to defaults', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.fuel);
      await repo.restoreFromSnapshot(null);
      expect(repo.isVisibleForExpenses(ExpenseCategory.fuel), isFalse);
      expect(repo.isVisibleForExpenses(ExpenseCategory.groceries), isTrue);
    });

    test('restores from valid snapshot', () async {
      final original = _repo();
      await original.toggleExpenses(ExpenseCategory.fuel);
      await original.toggleExpenses(ExpenseCategory.clothing);

      final snapshot = original.preferences.toJson();

      final restored = _repo();
      await restored.restoreFromSnapshot(snapshot);
      expect(restored.isVisibleForExpenses(ExpenseCategory.fuel), isTrue);
      expect(restored.isVisibleForExpenses(ExpenseCategory.clothing), isFalse);
    });

    test('notifies listeners', () async {
      final repo = _repo();
      var notified = false;
      repo.addListener(() => notified = true);
      await repo.restoreFromSnapshot(null);
      expect(notified, isTrue);
    });
  });

  group('CategoryPreferencesRepository.preferences getter', () {
    test('exposes current preferences', () async {
      final repo = _repo();
      await repo.toggleExpenses(ExpenseCategory.fuel);
      final prefs = repo.preferences;
      expect(prefs.expensesAdded, contains(ExpenseCategory.fuel));
    });
  });
}
