import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/year_month.dart';
import 'package:finance_tracker/widgets/period_navigator.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _navigator({
  required YearMonth selected,
  YearMonth? min,
  YearMonth? max,
  bool yearOnly = false,
  void Function(YearMonth)? onChanged,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: PeriodNavigator(
        selected: selected,
        yearOnly: yearOnly,
        min: min,
        max: max,
        onChanged: onChanged ?? (_) {},
      ),
    ),
  );
}

IconButton _prevButton(WidgetTester tester) =>
    tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_left),
    );

IconButton _nextButton(WidgetTester tester) =>
    tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.chevron_right),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PeriodNavigator — prev button boundary (month mode)', () {
    testWidgets('disabled when selected equals min', (tester) async {
      final min = YearMonth(2023, 3);
      await tester.pumpWidget(_navigator(selected: min, min: min));
      expect(_prevButton(tester).onPressed, isNull);
    });

    // Regression: old code used exact equality; if selected < min, prev was
    // enabled and the user could navigate indefinitely into the past.
    testWidgets('disabled when selected is before min', (tester) async {
      final min = YearMonth(2023, 3);
      final beforeMin = YearMonth(2023, 2); // one month before min
      await tester.pumpWidget(_navigator(selected: beforeMin, min: min));
      expect(_prevButton(tester).onPressed, isNull);
    });

    testWidgets('disabled when selected is well before min', (tester) async {
      final min = YearMonth(2023, 3);
      final wayBefore = YearMonth(2022, 6); // entire year before min
      await tester.pumpWidget(_navigator(selected: wayBefore, min: min));
      expect(_prevButton(tester).onPressed, isNull);
    });

    testWidgets('enabled when selected is one month after min', (tester) async {
      final min = YearMonth(2023, 3);
      final afterMin = YearMonth(2023, 4);
      await tester.pumpWidget(_navigator(selected: afterMin, min: min));
      expect(_prevButton(tester).onPressed, isNotNull);
    });

    testWidgets('enabled when no min is set', (tester) async {
      await tester.pumpWidget(_navigator(selected: YearMonth(2023, 6)));
      expect(_prevButton(tester).onPressed, isNotNull);
    });
  });

  group('PeriodNavigator — next button boundary (month mode)', () {
    testWidgets('disabled when selected equals max', (tester) async {
      final max = YearMonth(2024, 12);
      await tester.pumpWidget(_navigator(selected: max, max: max));
      expect(_nextButton(tester).onPressed, isNull);
    });

    // Regression: old code used exact equality; if selected > max, next was
    // enabled and the user could navigate indefinitely into the future.
    testWidgets('disabled when selected is after max', (tester) async {
      final max = YearMonth(2024, 12);
      final afterMax = YearMonth(2025, 1); // one month after max
      await tester.pumpWidget(_navigator(selected: afterMax, max: max));
      expect(_nextButton(tester).onPressed, isNull);
    });

    testWidgets('disabled when selected is well after max', (tester) async {
      final max = YearMonth(2024, 12);
      final wayAfter = YearMonth(2026, 6);
      await tester.pumpWidget(_navigator(selected: wayAfter, max: max));
      expect(_nextButton(tester).onPressed, isNull);
    });

    testWidgets('enabled when selected is one month before max', (tester) async {
      final max = YearMonth(2024, 12);
      final beforeMax = YearMonth(2024, 11);
      await tester.pumpWidget(_navigator(selected: beforeMax, max: max));
      expect(_nextButton(tester).onPressed, isNotNull);
    });

    testWidgets('enabled when no max is set', (tester) async {
      await tester.pumpWidget(_navigator(selected: YearMonth(2023, 6)));
      expect(_nextButton(tester).onPressed, isNotNull);
    });
  });

  group('PeriodNavigator — year-only mode boundaries', () {
    testWidgets('prev disabled at min year', (tester) async {
      final min = YearMonth(2022, 1);
      await tester.pumpWidget(
        _navigator(selected: YearMonth(2022, 6), min: min, yearOnly: true),
      );
      expect(_prevButton(tester).onPressed, isNull);
    });

    testWidgets('prev enabled one year above min year', (tester) async {
      final min = YearMonth(2022, 1);
      await tester.pumpWidget(
        _navigator(selected: YearMonth(2023, 6), min: min, yearOnly: true),
      );
      expect(_prevButton(tester).onPressed, isNotNull);
    });

    testWidgets('next disabled at max year', (tester) async {
      final max = YearMonth(2024, 12);
      await tester.pumpWidget(
        _navigator(selected: YearMonth(2024, 6), max: max, yearOnly: true),
      );
      expect(_nextButton(tester).onPressed, isNull);
    });

    testWidgets('next enabled one year below max year', (tester) async {
      final max = YearMonth(2024, 12);
      await tester.pumpWidget(
        _navigator(selected: YearMonth(2023, 6), max: max, yearOnly: true),
      );
      expect(_nextButton(tester).onPressed, isNotNull);
    });
  });

  group('PeriodNavigator — navigation fires correct period', () {
    testWidgets('prev navigates one month back', (tester) async {
      YearMonth? received;
      await tester.pumpWidget(_navigator(
        selected: YearMonth(2024, 3),
        min: YearMonth(2022, 1),
        onChanged: (ym) => received = ym,
      ));
      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(received, equals(YearMonth(2024, 2)));
    });

    testWidgets('prev wraps December to January of previous year', (tester) async {
      YearMonth? received;
      await tester.pumpWidget(_navigator(
        selected: YearMonth(2024, 1),
        min: YearMonth(2022, 1),
        onChanged: (ym) => received = ym,
      ));
      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_left));
      expect(received, equals(YearMonth(2023, 12)));
    });

    testWidgets('next navigates one month forward', (tester) async {
      YearMonth? received;
      await tester.pumpWidget(_navigator(
        selected: YearMonth(2024, 3),
        max: YearMonth(2026, 12),
        onChanged: (ym) => received = ym,
      ));
      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(received, equals(YearMonth(2024, 4)));
    });

    testWidgets('next wraps December to January of next year', (tester) async {
      YearMonth? received;
      await tester.pumpWidget(_navigator(
        selected: YearMonth(2024, 12),
        max: YearMonth(2026, 12),
        onChanged: (ym) => received = ym,
      ));
      await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
      expect(received, equals(YearMonth(2025, 1)));
    });
  });
}
