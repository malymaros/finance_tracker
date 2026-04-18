import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/services/app_repositories.dart';
import 'package:finance_tracker/services/category_budget_repository.dart';
import 'package:finance_tracker/services/category_preferences_repository.dart';
import 'package:finance_tracker/services/finance_repository.dart';
import 'package:finance_tracker/services/guard_repository.dart';
import 'package:finance_tracker/services/plan_repository.dart';

void main() {
  testWidgets('app renders without errors', (tester) async {
    await tester.pumpWidget(FinanceTrackerApp(
      repositories: AppRepositories(
        finance: FinanceRepository(persist: false),
        plan: PlanRepository(persist: false),
        budget: CategoryBudgetRepository(persist: false),
        guard: GuardRepository(persist: false),
        prefs: CategoryPreferencesRepository(),
      ),
    ));
    expect(find.text('Finance Tracker'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
