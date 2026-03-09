import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/plan_item.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/screens/plan/add_plan_item_screen.dart';
import 'package:finance_tracker/services/plan_repository.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

PlanRepository _repo() => PlanRepository(persist: false);

void main() {
  group('AddPlanItemScreen — initialValidFrom (Bug 1)', () {
    testWidgets('new item defaults validFrom to initialValidFrom when provided',
        (tester) async {
      final selectedMonth = YearMonth(2025, 9); // September 2025
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
        initialValidFrom: selectedMonth,
      )));

      // The "From:" button label must show the selected month, not today.
      expect(find.textContaining('September 2025'), findsOneWidget);
    });

    testWidgets('new item defaults validFrom to YearMonth.now() when initialValidFrom is null',
        (tester) async {
      final now = YearMonth.now();
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: _repo(),
      )));

      final monthNames = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      expect(
        find.textContaining('${monthNames[now.month]} ${now.year}'),
        findsOneWidget,
      );
    });

    testWidgets('saving new item uses initialValidFrom, not today',
        (tester) async {
      final selectedMonth = YearMonth(2025, 9);
      final repo = _repo();
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        initialValidFrom: selectedMonth,
      )));

      // Fill in name and amount
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name'), 'Test Income');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Amount'), '1000');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(repo.items.length, 1);
      expect(repo.items.first.validFrom, equals(selectedMonth));
    });

    testWidgets('editing recurring item defaults new-version validFrom to initialValidFrom',
        (tester) async {
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Salary',
        amount: 3000,
        type: PlanItemType.income,
        frequency: PlanFrequency.monthly,
        validFrom: YearMonth(2025, 1),
      );
      await repo.addPlanItem(original);

      final selectedMonth = YearMonth(2025, 10); // currently viewed month
      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: selectedMonth,
      )));

      // The "From:" button must show the selected month, not today.
      expect(find.textContaining('October 2025'), findsOneWidget);
    });

    testWidgets('editing one-time item keeps original validFrom, ignores initialValidFrom',
        (tester) async {
      final repo = _repo();
      final original = PlanItem(
        id: '1',
        seriesId: '1',
        name: 'Bonus',
        amount: 500,
        type: PlanItemType.income,
        frequency: PlanFrequency.oneTime,
        validFrom: YearMonth(2025, 3),
      );
      await repo.addPlanItem(original);

      await tester.pumpWidget(_wrap(AddPlanItemScreen(
        planRepository: repo,
        existing: original,
        initialValidFrom: YearMonth(2025, 10), // different from original
      )));

      // One-time items always keep their original validFrom on edit.
      expect(find.textContaining('March 2025'), findsOneWidget);
    });
  });
}
