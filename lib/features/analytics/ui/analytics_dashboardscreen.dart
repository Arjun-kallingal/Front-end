import 'package:flutter/material.dart';

// analytics_dashboard_screen.dart
class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.red,
        centerTitle: true,
        
      ),
      body: const Center(
        child: Text('Analytics Dashboard'),
      ),
    );
  }
}
