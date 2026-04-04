import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/widgets/export_date_range_dialog.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ExportDateRangeDialog', () {
    testWidgets('end date is prefilled with today on open', (tester) async {
      final today = DateTime.now();
      final expected =
          '${today.day.toString().padLeft(2, '0')}.'
          '${today.month.toString().padLeft(2, '0')}.'
          '${today.year}';

      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => ExportDateRangeDialog.show(context),
          child: const Text('Open'),
        );
      })));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(expected), findsOneWidget);
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
