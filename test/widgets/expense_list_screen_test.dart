import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/screens/expense_list_screen.dart';

Widget wrapInMaterial() =>
    const MaterialApp(home: ExpenseListScreen());

void main() {
  group('ExpenseListScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('shows empty state on first load', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.text('No expenses yet.'), findsOneWidget);
      expect(find.text('Tap + to add one.'), findsOneWidget);
    });

    testWidgets('shows receipt icon in empty state', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('tapping FAB adds an expense and hides empty state',
        (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      expect(find.text('No expenses yet.'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('No expenses yet.'), findsNothing);
    });

    testWidgets('tapping FAB twice shows two list items', (tester) async {
      await tester.pumpWidget(wrapInMaterial());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      expect(find.text('Demo expense #1'), findsOneWidget);
      expect(find.text('Demo expense #2'), findsOneWidget);
    });

    testWidgets('first demo expense is in Food category', (tester) async {
      await tester.pumpWidget(wrapInMaterial());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text('Food'), findsOneWidget);
    });
  });
}
