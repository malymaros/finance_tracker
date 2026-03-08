import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'services/finance_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = FinanceRepository();
  await repository.load();
  runApp(FinanceTrackerApp(repository: repository));
}

class FinanceTrackerApp extends StatelessWidget {
  final FinanceRepository repository;

  const FinanceTrackerApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: MainScreen(repository: repository),
    );
  }
}
