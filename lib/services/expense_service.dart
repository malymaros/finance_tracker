import '../models/expense.dart';

class ExpenseService {
  final List<Expense> _expenses = [];

  List<Expense> getAll() => List.unmodifiable(_expenses);

  void add(Expense expense) {
    _expenses.add(expense);
  }
}