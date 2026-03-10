import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    final repo = FinanceRepository(persist: false);
    final planRepo = PlanRepository(persist: false);
    await tester.pumpWidget(
        FinanceTrackerApp(repository: repo, planRepository: planRepo));
    expect(find.text('Finance Tracker'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
