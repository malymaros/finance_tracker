import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;

  const ExpenseCategory({required this.name, required this.icon});
}

const List<ExpenseCategory> kExpenseCategories = [
  ExpenseCategory(name: 'Food', icon: Icons.restaurant),
  ExpenseCategory(name: 'Transport', icon: Icons.directions_car),
  ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag),
  ExpenseCategory(name: 'Health', icon: Icons.favorite),
  ExpenseCategory(name: 'Other', icon: Icons.category),
];

IconData categoryIcon(String categoryName) {
  return kExpenseCategories
      .firstWhere(
        (c) => c.name == categoryName,
        orElse: () => const ExpenseCategory(name: '', icon: Icons.category),
      )
      .icon;
}
