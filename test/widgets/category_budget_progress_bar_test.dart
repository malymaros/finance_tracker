import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/theme/app_theme.dart';
import 'package:finance_tracker/widgets/category_budget_progress_bar.dart';

Widget _wrap(double spent, double budget) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CategoryBudgetProgressBar(spent: spent, budget: budget),
      ),
    );

Color _barColor(WidgetTester tester) {
  final indicator =
      tester.widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator));
  return (indicator.valueColor! as AlwaysStoppedAnimation<Color>).value;
}

void main() {
  group('CategoryBudgetProgressBar — color thresholds', () {
    testWidgets('below 80 %: bar is green', (tester) async {
      await tester.pumpWidget(_wrap(70, 100)); // 70 %
      expect(_barColor(tester), AppColors.income);
    });

    testWidgets('exactly 0 %: bar is green', (tester) async {
      await tester.pumpWidget(_wrap(0, 100));
      expect(_barColor(tester), AppColors.income);
    });

    testWidgets('at 80 %: bar is amber', (tester) async {
      await tester.pumpWidget(_wrap(80, 100));
      expect(_barColor(tester), AppColors.warning);
    });

    testWidgets('between 80 % and 100 %: bar is amber', (tester) async {
      await tester.pumpWidget(_wrap(95, 100)); // 95 %
      expect(_barColor(tester), AppColors.warning);
    });

    testWidgets('at exactly 100 %: bar is amber (not yet over)', (tester) async {
      await tester.pumpWidget(_wrap(100, 100));
      expect(_barColor(tester), AppColors.warning);
    });

    testWidgets('above 100 %: bar is red', (tester) async {
      await tester.pumpWidget(_wrap(120, 100)); // 120 %
      expect(_barColor(tester), AppColors.expense);
    });

    testWidgets('budget = 0: bar is muted grey (avoids divide-by-zero)', (tester) async {
      await tester.pumpWidget(_wrap(50, 0));
      expect(_barColor(tester), AppColors.textMuted);
    });
  });

  group('CategoryBudgetProgressBar — label text', () {
    testWidgets('shows spent and budget amounts formatted to 2 decimal places',
        (tester) async {
      await tester.pumpWidget(_wrap(45.5, 200));
      expect(find.text('45.50 € spent  /  200.00 € budget'), findsOneWidget);
    });

    testWidgets('shows zero spent correctly', (tester) async {
      await tester.pumpWidget(_wrap(0, 300));
      expect(find.text('0.00 € spent  /  300.00 € budget'), findsOneWidget);
    });
  });

  group('CategoryBudgetProgressBar — progress indicator value', () {
    testWidgets('progress value is clamped to 1.0 when over budget', (tester) async {
      await tester.pumpWidget(_wrap(150, 100)); // 150 %
      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 1.0);
    });

    testWidgets('progress value is 0.0 when budget is zero', (tester) async {
      await tester.pumpWidget(_wrap(50, 0));
      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, 0.0);
    });

    testWidgets('progress value matches ratio for normal spending', (tester) async {
      await tester.pumpWidget(_wrap(60, 200)); // 0.3
      final indicator = tester.widget<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator));
      expect(indicator.value, closeTo(0.3, 0.001));
    });
  });
}
