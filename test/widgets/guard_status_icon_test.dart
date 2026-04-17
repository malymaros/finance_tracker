import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/l10n/app_localizations.dart';
import 'package:finance_tracker/models/guard_state.dart';
import 'package:finance_tracker/widgets/guard_status_icon.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  group('GuardStatusIcon', () {
    testWidgets('renders nothing for GuardState.none', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.none),
      ));
      expect(find.byIcon(Icons.pets), findsNothing);
    });

    testWidgets('renders paw icon for GuardState.unpaidActive', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.unpaidActive),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('renders paw icon for GuardState.scheduled', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.scheduled),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('renders paw icon for GuardState.paid', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.paid),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('silenced state shows paw and notifications_off badge',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.silenced),
      ));
      expect(find.byIcon(Icons.pets), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off), findsOneWidget);
    });

    testWidgets('non-silenced states do not show notifications_off',
        (tester) async {
      for (final state in [
        GuardState.unpaidActive,
        GuardState.scheduled,
        GuardState.paid,
      ]) {
        await tester.pumpWidget(_wrap(GuardStatusIcon(guardState: state)));
        expect(find.byIcon(Icons.notifications_off), findsNothing,
            reason: 'state=$state should not show notification badge');
      }
    });

    testWidgets('unpaidActive renders at full opacity (Opacity widget absent or 1.0)',
        (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.unpaidActive),
      ));
      final opacityWidgets = tester.widgetList<Opacity>(find.byType(Opacity));
      for (final o in opacityWidgets) {
        expect(o.opacity, 1.0);
      }
    });

    testWidgets('paid renders at reduced opacity', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.paid),
      ));
      final opacity = tester.widget<Opacity>(find.byType(Opacity));
      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('respects custom size parameter', (tester) async {
      await tester.pumpWidget(_wrap(
        const GuardStatusIcon(guardState: GuardState.unpaidActive, size: 24),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.pets));
      expect(icon.size, 24);
    });
  });
}
