import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    await tester.pumpWidget(const FinanceTrackerApp());
    expect(find.text('Expenses'), findsOneWidget);
  });
}
