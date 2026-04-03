import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/expense.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/data_portability_service.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

Expense makeExpense({String id = 'e1', double amount = 50.0}) => Expense(
      id: id,
      amount: amount,
      category: ExpenseCategory.groceries,
      financialType: FinancialType.consumption,
      date: DateTime(2024, 3, 15),
    );

PlanItem makePlanItem({String id = 'p1'}) => PlanItem(
      id: id,
      seriesId: id,
      name: 'Salary',
      amount: 3000,
      type: PlanItemType.income,
      frequency: PlanFrequency.monthly,
      validFrom: YearMonth(2024, 1),
    );

AppRepositories _repos({
  FinanceRepository? finance,
  PlanRepository? plan,
  CategoryBudgetRepository? budget,
  GuardRepository? guard,
}) =>
    AppRepositories(
      finance: finance ?? FinanceRepository(persist: false),
      plan: plan ?? PlanRepository(persist: false),
      budget: budget ?? CategoryBudgetRepository(persist: false),
      guard: guard ?? GuardRepository(persist: false),
    );

void main() {
  group('DataPortabilityService — exportData', () {
    test('returns valid JSON string', () async {
      final result = await DataPortabilityService.exportData(_repos());
      expect(() => jsonDecode(result), returnsNormally);
    });

    test('contains version: 1', () async {
      final map = jsonDecode(await DataPortabilityService.exportData(_repos()))
          as Map<String, dynamic>;
      expect(map['version'], 1);
    });

    test('contains non-empty exportedAt field', () async {
      final map = jsonDecode(await DataPortabilityService.exportData(_repos()))
          as Map<String, dynamic>;
      expect(map['exportedAt'], isA<String>());
      expect((map['exportedAt'] as String).isNotEmpty, isTrue);
    });

    test('empty repos produce empty expenses and planItems arrays', () async {
      final map = jsonDecode(await DataPortabilityService.exportData(_repos()))
          as Map<String, dynamic>;
      expect(map['expenses'], isEmpty);
      expect(map['planItems'], isEmpty);
    });

    test('expenses array matches repo contents', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense(id: 'e1', amount: 25.0));
      await repo.addExpense(makeExpense(id: 'e2', amount: 75.0));

      final map = jsonDecode(
              await DataPortabilityService.exportData(_repos(finance: repo)))
          as Map<String, dynamic>;
      final expenses = map['expenses'] as List;

      expect(expenses.length, 2);
      expect(expenses[0]['id'], 'e1');
      expect(expenses[1]['id'], 'e2');
    });

    test('planItems array matches planRepo contents', () async {
      final planRepo = PlanRepository(persist: false);
      await planRepo.addPlanItem(makePlanItem(id: 'p1'));

      final map = jsonDecode(
              await DataPortabilityService.exportData(_repos(plan: planRepo)))
          as Map<String, dynamic>;
      final planItems = map['planItems'] as List;

      expect(planItems.length, 1);
      expect(planItems[0]['id'], 'p1');
    });
  });

  group('DataPortabilityService — importData', () {
    test('restores expenses and planItems into repositories', () async {
      final exportRepo = FinanceRepository(persist: false);
      final exportPlanRepo = PlanRepository(persist: false);
      await exportRepo.addExpense(makeExpense(id: 'e1'));
      await exportPlanRepo.addPlanItem(makePlanItem(id: 'p1'));

      final jsonString = await DataPortabilityService.exportData(
          _repos(finance: exportRepo, plan: exportPlanRepo));

      final importRepo = FinanceRepository(persist: false);
      final importPlanRepo = PlanRepository(persist: false);
      await DataPortabilityService.importData(
          jsonString, _repos(finance: importRepo, plan: importPlanRepo));

      expect(importRepo.expenses.length, 1);
      expect(importRepo.expenses.first.id, 'e1');
      expect(importPlanRepo.items.length, 1);
      expect(importPlanRepo.items.first.id, 'p1');
    });

    test('replaces existing data in repositories', () async {
      final importRepo = FinanceRepository(persist: false);
      final importPlanRepo = PlanRepository(persist: false);
      await importRepo.addExpense(makeExpense(id: 'old'));

      final jsonString = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': [makeExpense(id: 'new').toJson()],
        'planItems': <dynamic>[],
      });

      await DataPortabilityService.importData(
          jsonString, _repos(finance: importRepo, plan: importPlanRepo));

      expect(importRepo.expenses.length, 1);
      expect(importRepo.expenses.first.id, 'new');
    });

    test('throws FormatException when version field is missing', () async {
      final jsonString = jsonEncode({
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': <dynamic>[],
        'planItems': <dynamic>[],
      });

      expect(
        () => DataPortabilityService.importData(jsonString, _repos()),
        throwsA(isA<FormatException>()),
      );
    });

    test('handles missing expenses key — treats as empty list', () async {
      final repo = FinanceRepository(persist: false);
      await repo.addExpense(makeExpense());

      final jsonString = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'planItems': <dynamic>[],
      });

      await DataPortabilityService.importData(
          jsonString, _repos(finance: repo));
      expect(repo.expenses, isEmpty);
    });

    test('handles missing planItems key — treats as empty list', () async {
      final planRepo = PlanRepository(persist: false);
      await planRepo.addPlanItem(makePlanItem());

      final jsonString = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': <dynamic>[],
      });

      await DataPortabilityService.importData(
          jsonString, _repos(plan: planRepo));
      expect(planRepo.items, isEmpty);
    });

    test('handles missing categoryBudgets key — backward compatible', () async {
      final budgetRepo = CategoryBudgetRepository(persist: false);

      // Simulate a file exported before the budget feature existed.
      final jsonString = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': <dynamic>[],
        'planItems': <dynamic>[],
        // no 'categoryBudgets' key
      });

      await DataPortabilityService.importData(
          jsonString, _repos(budget: budgetRepo));
      expect(budgetRepo.budgets, isEmpty);
    });

    test('handles missing guardPayments key — backward compatible', () async {
      final guardRepo = GuardRepository(persist: false);

      // Simulate a file exported before the GUARD feature existed.
      final jsonString = jsonEncode({
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'expenses': <dynamic>[],
        'planItems': <dynamic>[],
        // no 'guardPayments' key
      });

      await DataPortabilityService.importData(
          jsonString, _repos(guard: guardRepo));
      expect(guardRepo.payments, isEmpty);
    });

    test('throws on completely invalid JSON string', () async {
      expect(
        () => DataPortabilityService.importData('not valid json {{', _repos()),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trip export→import preserves all expense fields', () async {
      final exportRepo = FinanceRepository(persist: false);
      final original = Expense(
        id: 'rt1',
        amount: 123.45,
        category: ExpenseCategory.transport,
        financialType: FinancialType.asset,
        date: DateTime(2024, 6, 20),
        note: 'Round-trip test',
      );
      await exportRepo.addExpense(original);

      final jsonString = await DataPortabilityService.exportData(
          _repos(finance: exportRepo));

      final importRepo = FinanceRepository(persist: false);
      await DataPortabilityService.importData(
          jsonString, _repos(finance: importRepo));

      final restored = importRepo.expenses.first;
      expect(restored.id, original.id);
      expect(restored.amount, original.amount);
      expect(restored.category, original.category);
      expect(restored.financialType, original.financialType);
      expect(restored.date, original.date);
      expect(restored.note, original.note);
    });

    test('round-trip export→import preserves all plan item fields', () async {
      final exportPlanRepo = PlanRepository(persist: false);
      final original = PlanItem(
        id: 'rt2',
        seriesId: 'rt2',
        name: 'Rent',
        amount: 850.0,
        type: PlanItemType.fixedCost,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2024, 3),
        validTo: YearMonth(2025, 12),
        category: ExpenseCategory.housing,
        financialType: FinancialType.consumption,
      );
      await exportPlanRepo.addPlanItem(original);

      final jsonString = await DataPortabilityService.exportData(
          _repos(plan: exportPlanRepo));

      final importPlanRepo = PlanRepository(persist: false);
      await DataPortabilityService.importData(
          jsonString, _repos(plan: importPlanRepo));

      final restored = importPlanRepo.items.first;
      expect(restored.id, original.id);
      expect(restored.seriesId, original.seriesId);
      expect(restored.name, original.name);
      expect(restored.amount, original.amount);
      expect(restored.type, original.type);
      expect(restored.frequency, original.frequency);
      expect(restored.validFrom, original.validFrom);
      expect(restored.validTo, original.validTo);
      expect(restored.category, original.category);
      expect(restored.financialType, original.financialType);
    });
  });
}
