import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    final repo = FinanceRepository(persist: false);
    final planRepo = PlanRepository(persist: false);
    final budgetRepo = CategoryBudgetRepository(persist: false);
    final guardRepo = GuardRepository(persist: false);
    await tester.pumpWidget(FinanceTrackerApp(
      repository: repo,
      planRepository: planRepo,
      budgetRepository: budgetRepo,
      guardRepository: guardRepo,
    ));
    expect(find.text('Finance Tracker'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
