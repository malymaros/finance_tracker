import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/category_budget_repository.dart';
import 'services/finance_repository.dart';
import 'theme/app_theme.dart';
import 'services/plan_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  final planRepository = PlanRepository();
  final budgetRepository = CategoryBudgetRepository();
  await Future.wait([
    repository.load(),
    planRepository.load(),
    budgetRepository.load(),
  ]);
  runApp(FinanceTrackerApp(
    repository: repository,
    planRepository: planRepository,
    budgetRepository: budgetRepository,
  ));
}

class FinanceTrackerApp extends StatelessWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final CategoryBudgetRepository budgetRepository;

  const FinanceTrackerApp({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.budgetRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: WelcomeScreen(
        mainScreenBuilder: () => MainScreen(
          repository: repository,
          planRepository: planRepository,
          budgetRepository: budgetRepository,
        ),
      ),
    );
  }
}
