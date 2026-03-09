import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'services/finance_repository.dart';
import 'services/fixed_cost_migration.dart';
import 'services/plan_repository.dart';
import 'services/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  final planRepository = PlanRepository();
  await Future.wait([repository.load(), planRepository.load()]);
  await FixedCostMigration.migrateIfNeeded(planRepository);
  if (kDebugMode) {
    await SeedData.applyIfEmpty(repository, planRepository);
  }
  runApp(FinanceTrackerApp(
      repository: repository, planRepository: planRepository));
}

class FinanceTrackerApp extends StatelessWidget {
  final FinanceRepository repository;
  final PlanRepository planRepository;

  const FinanceTrackerApp({
    super.key,
    required this.repository,
    required this.planRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MainScreen(repository: repository, planRepository: planRepository),
    );
  }
}
