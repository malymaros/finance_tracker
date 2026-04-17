import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/widgets/plan_category_tile.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('PlanCategoryTile', () {
    testWidgets('displays category displayName', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.housing,
        total: 800,
        count: 1,
        onTap: () {},
      )));
      expect(find.text('Housing'), findsOneWidget);
    });

    testWidgets('displays formatted total amount', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.groceries,
        total: 150.75,
        count: 2,
        onTap: () {},
      )));
      expect(find.textContaining('150.75 €'), findsOneWidget);
    });

    testWidgets('displays singular "item" for count 1', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.groceries,
        total: 100,
        count: 1,
        onTap: () {},
      )));
      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('displays plural "items" for count > 1', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.groceries,
        total: 100,
        count: 4,
        onTap: () {},
      )));
      expect(find.text('4 items'), findsOneWidget);
    });

    testWidgets('shows chevron_right when isExpanded is null', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.transport,
        total: 50,
        count: 1,
        onTap: () {},
        // isExpanded defaults to null
      )));
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.expand_more), findsNothing);
      expect(find.byIcon(Icons.expand_less), findsNothing);
    });

    testWidgets('shows expand_more when isExpanded is false', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.transport,
        total: 50,
        count: 1,
        onTap: () {},
        isExpanded: false,
      )));
      expect(find.byIcon(Icons.expand_more), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('shows expand_less when isExpanded is true', (tester) async {
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.transport,
        total: 50,
        count: 1,
        onTap: () {},
        isExpanded: true,
      )));
      expect(find.byIcon(Icons.expand_less), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('onTap is called when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(PlanCategoryTile(
        category: ExpenseCategory.groceries,
        total: 100,
        count: 1,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(ListTile));
      expect(tapped, isTrue);
    });
  });
}
