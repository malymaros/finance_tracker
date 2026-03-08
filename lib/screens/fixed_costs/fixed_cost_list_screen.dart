import 'package:flutter/material.dart';

class FixedCostListScreen extends StatelessWidget {
  const FixedCostListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fixed Costs')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Fixed costs coming soon.',
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
