import 'category_budget_repository.dart';
import 'finance_repository.dart';
import 'guard_repository.dart';
import 'plan_repository.dart';

/// Bundles the four app-wide repositories into a single parameter object.
/// Eliminates repetitive 4-parameter fan-out across constructors.
class AppRepositories {
  final FinanceRepository finance;
  final PlanRepository plan;
  final CategoryBudgetRepository budget;
  final GuardRepository guard;

  const AppRepositories({
    required this.finance,
    required this.plan,
    required this.budget,
    required this.guard,
  });
}
