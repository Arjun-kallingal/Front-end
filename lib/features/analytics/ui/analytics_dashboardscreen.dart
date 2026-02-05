import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/base_app_bar.dart';
// analytics_dashboard_screen.dart
class AnalyticsDashboardScreen extends StatelessWidget { 
const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Analytics'),
      body: const Center(child: Text('Analytics Dashboard')),
    );
  }
}
