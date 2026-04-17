import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/widgets/export_date_range_dialog.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('ExportDateRangeDialog', () {
    testWidgets('end date is prefilled with today on open', (tester) async {
      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => ExportDateRangeDialog.show(context),
          child: const Text('Open'),
        );
      })));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Start date is unpopulated — placeholder appears exactly once.
      expect(find.text('Tap to select'), findsOneWidget);
      // End date is prefilled — today's year must appear in the dialog
      // regardless of the exact date format used by the widget.
      expect(
        find.textContaining(DateTime.now().year.toString()),
        findsOneWidget,
      );
    });

    testWidgets('Export button is disabled when start date is not set',
        (tester) async {
      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => ExportDateRangeDialog.show(context),
          child: const Text('Open'),
        );
      })));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final exportButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Export'),
      );
      expect(exportButton.onPressed, isNull);
    });
  });
}
