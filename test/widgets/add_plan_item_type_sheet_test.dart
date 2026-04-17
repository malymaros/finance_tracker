import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/widgets/add_plan_item_type_sheet.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('AddPlanItemTypeSheet', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () {},
      )));
      expect(find.text('What are you adding?'), findsOneWidget);
    });

    testWidgets('renders Income and Fixed Cost options', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () {},
      )));
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Fixed Cost'), findsOneWidget);
    });

    testWidgets('renders Income subtitle', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () {},
      )));
      expect(find.text('Salary, bonus, pension, gifts'), findsOneWidget);
    });

    testWidgets('renders Fixed Cost subtitle', (tester) async {
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () {},
      )));
      expect(find.text('Rent, insurance, subscriptions'), findsOneWidget);
    });

    testWidgets('tapping Income card fires onIncomeSelected', (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () => called = true,
        onFixedCostSelected: () {},
      )));
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('tapping Fixed Cost card fires onFixedCostSelected',
        (tester) async {
      var called = false;
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () => called = true,
      )));
      await tester.tap(find.text('Fixed Cost'));
      await tester.pumpAndSettle();
      expect(called, isTrue);
    });

    testWidgets('tapping Income does not fire onFixedCostSelected',
        (tester) async {
      var fixedCalled = false;
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () {},
        onFixedCostSelected: () => fixedCalled = true,
      )));
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      expect(fixedCalled, isFalse);
    });

    testWidgets('tapping Fixed Cost does not fire onIncomeSelected',
        (tester) async {
      var incomeCalled = false;
      await tester.pumpWidget(_wrap(AddPlanItemTypeSheet(
        onIncomeSelected: () => incomeCalled = true,
        onFixedCostSelected: () {},
      )));
      await tester.tap(find.text('Fixed Cost'));
      await tester.pumpAndSettle();
      expect(incomeCalled, isFalse);
    });
  });
}
