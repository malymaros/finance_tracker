import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/widgets/how_it_works_sheet.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

Future<void> _openSheet(WidgetTester tester, {int initialPage = 0}) async {
  await tester.pumpWidget(_wrap(Builder(
    builder: (context) => TextButton(
      onPressed: () => HowItWorksSheet.show(context, initialPage: initialPage),
      child: const Text('Open'),
    ),
  )));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
// ── Page-index constants ──────────────────────────────────────────────────────

test('HowItWorksSheet exposes named page-index constants', () {
  expect(HowItWorksSheet.pageIndexPlan,     0);
  expect(HowItWorksSheet.pageIndexExpenses, 1);
  expect(HowItWorksSheet.pageIndexReports,  4);
});

// ── Smoke tests — each outer tab renders ─────────────────────────────────────

testWidgets('Plan tab renders — shows Plan header and sub-step labels',
    (tester) async {
  await _openSheet(tester, initialPage: HowItWorksSheet.pageIndexPlan);

  expect(find.text('Plan'),      findsWidgets); // header + tab strip
  expect(find.text('Cashflow'),  findsOneWidget);
  expect(find.text('Classification'), findsOneWidget);
  expect(find.text('Allocation'), findsOneWidget);
});

testWidgets('Expenses tab renders — shows Expenses header and sub-step labels',
    (tester) async {
  await _openSheet(tester, initialPage: HowItWorksSheet.pageIndexExpenses);

  expect(find.text('Expenses'), findsWidgets);
  expect(find.text('Budget'),   findsOneWidget);
  expect(find.text('Spending'), findsOneWidget);
  expect(find.text('Result'),   findsOneWidget);
});

testWidgets('Reports tab renders — shows Reports header and sub-step labels',
    (tester) async {
  await _openSheet(tester, initialPage: HowItWorksSheet.pageIndexReports);

  expect(find.text('Reports'),   findsWidgets);
  expect(find.text('Breakdown'), findsOneWidget);
  expect(find.text('Export'),    findsOneWidget);
  expect(find.text('Overview'),  findsOneWidget);
});

// ── Navigation smoke test ─────────────────────────────────────────────────────

testWidgets('Tapping Reports tab in strip from Plan navigates to Reports',
    (tester) async {
  await _openSheet(tester, initialPage: HowItWorksSheet.pageIndexPlan);

  // Initially on Plan
  expect(find.text('Cashflow'), findsOneWidget);

  // Tap Reports in the bottom tab strip (stepNumber 3 label)
  await tester.tap(find.text('Reports').last);
  await tester.pumpAndSettle();

  expect(find.text('Breakdown'), findsOneWidget);
});

// ── Reports sub-pages smoke test ──────────────────────────────────────────────

testWidgets('Reports Export sub-page shows PDF card content', (tester) async {
  await _openSheet(tester, initialPage: HowItWorksSheet.pageIndexReports);

  // Navigate to Export sub-page
  await tester.tap(find.text('Export'));
  await tester.pumpAndSettle();

  expect(find.text('Monthly'), findsOneWidget);
  expect(find.text('Yearly'),  findsOneWidget);
});
} // end main
