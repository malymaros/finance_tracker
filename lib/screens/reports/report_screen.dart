import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Spending reports coming soon.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
