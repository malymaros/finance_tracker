import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/services/finance_repository.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    final repo = FinanceRepository(persist: false);
    await tester.pumpWidget(FinanceTrackerApp(repository: repo));
    expect(find.text('Expenses'), findsWidgets);
  });
}
