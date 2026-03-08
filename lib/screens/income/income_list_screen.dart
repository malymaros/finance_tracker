import 'package:flutter/material.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Income tracking coming soon.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
