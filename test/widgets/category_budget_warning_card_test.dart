import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/expense_category.dart';
import 'package:finance_tracker/widgets/category_budget_warning_card.dart';

Widget _wrap(Map<ExpenseCategory, double> overages) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CategoryBudgetWarningCard(overages: overages),
      ),
    );

void main() {
  group('CategoryBudgetWarningCard — empty state', () {
    testWidgets('renders nothing when overages map is empty', (tester) async {
      await tester.pumpWidget(_wrap({}));
      expect(find.byType(Container), findsNothing);
      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.textContaining('budget'), findsNothing);
    });
  });

  group('CategoryBudgetWarningCard — single overage', () {
    testWidgets('shows one warning row with correct category and amount',
        (tester) async {
      await tester.pumpWidget(_wrap({
        ExpenseCategory.groceries: 35.50,
      }));
      expect(find.textContaining('Groceries'), findsOneWidget);
      expect(find.textContaining('35.50'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('warning text includes "over by" phrasing', (tester) async {
      await tester.pumpWidget(_wrap({
        ExpenseCategory.transport: 10.0,
      }));
      expect(find.textContaining('over by'), findsOneWidget);
    });
  });

  group('CategoryBudgetWarningCard — multiple overages', () {
    testWidgets('shows one row per category', (tester) async {
      await tester.pumpWidget(_wrap({
        ExpenseCategory.groceries: 20.0,
        ExpenseCategory.housing: 50.0,
        ExpenseCategory.transport: 5.0,
      }));
      expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(3));
    });

    testWidgets('rows are sorted by overage amount descending', (tester) async {
      await tester.pumpWidget(_wrap({
        ExpenseCategory.transport: 10.0,   // 2nd
        ExpenseCategory.housing: 80.0,     // 1st
        ExpenseCategory.groceries: 5.0,    // 3rd
      }));

      final rows = tester.widgetList<Text>(
        find.byWidgetPredicate(
          (w) => w is Text && w.data != null && w.data!.contains('over by'),
        ),
      ).toList();

      expect(rows.length, 3);
      // First row must be the largest overage (Housing 80 €).
      expect(rows[0].data, contains('Housing'));
      // Second row must be Transport 10 €.
      expect(rows[1].data, contains('Transport'));
      // Third row must be Groceries 5 €.
      expect(rows[2].data, contains('Groceries'));
    });

    testWidgets('amounts are formatted to 2 decimal places', (tester) async {
      await tester.pumpWidget(_wrap({
        ExpenseCategory.groceries: 12.3,
      }));
      expect(find.textContaining('12.30'), findsOneWidget);
    });
  });
}
