import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/financial_type.dart';
import 'package:finance_tracker/widgets/plan_financial_type_tile.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('PlanFinancialTypeTile', () {
    testWidgets('displays displayName for consumption', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.consumption,
        total: 400,
        count: 2,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.text('Consumption'), findsOneWidget);
    });

    testWidgets('displays displayName for asset', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.asset,
        total: 200,
        count: 1,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.text('Asset'), findsOneWidget);
    });

    testWidgets('displays displayName for insurance', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.insurance,
        total: 100,
        count: 3,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.text('Insurance'), findsOneWidget);
    });

    testWidgets('displays formatted total amount', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.consumption,
        total: 1234.56,
        count: 1,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.textContaining('1234.56 €'), findsOneWidget);
    });

    testWidgets('displays singular "item" for count 1', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.asset,
        total: 100,
        count: 1,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('displays plural "items" for count > 1', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.asset,
        total: 100,
        count: 3,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.text('3 items'), findsOneWidget);
    });

    testWidgets('shows expand_more icon when not expanded', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.consumption,
        total: 100,
        count: 1,
        isExpanded: false,
        onTap: () {},
      )));
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byIcon(Icons.expand_less), findsNothing);
    });

    testWidgets('shows expand_less icon when expanded', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.consumption,
        total: 100,
        count: 1,
        isExpanded: true,
        onTap: () {},
      )));
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
    });

    testWidgets('onTap is called when tile is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.consumption,
        total: 100,
        count: 1,
        isExpanded: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });

    testWidgets('has left border decoration', (tester) async {
      await tester.pumpWidget(_wrap(PlanFinancialTypeTile(
        type: FinancialType.asset,
        total: 100,
        count: 1,
        isExpanded: false,
        onTap: () {},
      )));
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(ListTile),
          matching: find.byType(Container),
        ).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });
}
