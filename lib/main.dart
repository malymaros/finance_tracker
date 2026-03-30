import 'package:flutter/material.dart';

import 'models/year_month.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/category_budget_repository.dart';
import 'services/finance_repository.dart';
import 'services/guard_notification_service.dart';
import 'services/guard_repository.dart';
import 'services/save_load_service.dart';
import 'theme/app_theme.dart';
import 'services/plan_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  final planRepository = PlanRepository();
  final budgetRepository = CategoryBudgetRepository();
  final guardRepository = GuardRepository();
  await Future.wait([
    repository.load(),
    planRepository.load(),
    budgetRepository.load(),
    guardRepository.load(),
  ]);
  await SaveLoadService.checkAndRotate(repository, planRepository, budgetRepository, guardRepository);

  // Initialise notifications and schedule the daily GUARD reminder.
  // Wrapped in try-catch: exact-alarm permission may not be granted yet on
  // first launch (Android 12+ requires manual grant in Settings), which would
  // otherwise throw before runApp().
  try {
    await GuardNotificationService.initialize();
    final unpaidCount = guardRepository
        .unpaidActiveItems(planRepository.items, YearMonth.now())
        .length;
    final hour = await GuardNotificationService.getSavedHour();
    final minute = await GuardNotificationService.getSavedMinute();
    await GuardNotificationService.scheduleDaily(hour, minute, unpaidCount);
  } catch (_) {
    // Notification setup failed silently — app still launches normally.
  }

  runApp(FinanceTrackerApp(
    repository: repository,
    planRepository: planRepository,
    budgetRepository: budgetRepository,
    guardRepository: guardRepository,
  ));
}

class FinanceTrackerApp extends StatelessWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;
  final CategoryBudgetRepository budgetRepository;
  final GuardRepository guardRepository;

  const FinanceTrackerApp({
    super.key,
    required this.repository,
    required this.planRepository,
    required this.budgetRepository,
    required this.guardRepository,
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
          guardRepository: guardRepository,
        ),
      ),
    );
  }
}
