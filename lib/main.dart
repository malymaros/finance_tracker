import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'models/year_month.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/app_repositories.dart';
import 'services/category_budget_repository.dart';
import 'services/currency_service.dart';
import 'services/finance_repository.dart';
import 'services/guard_notification_service.dart';
import 'services/guard_repository.dart';
import 'services/language_service.dart';
import 'services/plan_repository.dart';
import 'services/save_load_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
  final repositories = AppRepositories(
    finance: repository,
    plan: planRepository,
    budget: budgetRepository,
    guard: guardRepository,
  );
  await SaveLoadService.checkAndRotate(repositories);

  CurrencyService.instance = CurrencyService();
  await CurrencyService.instance.load();

  LanguageService.instance = LanguageService();
  await LanguageService.instance.load();

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

  runApp(FinanceTrackerApp(repositories: repositories));
}

class FinanceTrackerApp extends StatelessWidget {
  final AppRepositories repositories;

  const FinanceTrackerApp({
    super.key,
    required this.repositories,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageService.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Finance Tracker',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          locale: LanguageService.instance.current,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageService.supportedLocales,
          home: WelcomeScreen(
            mainScreenBuilder: () => MainScreen(repositories: repositories),
          ),
        );
      },
    );
  }
}
