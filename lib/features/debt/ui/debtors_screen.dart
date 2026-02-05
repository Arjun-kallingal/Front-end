import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/base_app_bar.dart';
class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Debt Management'),
      body: const Center(child: Text('Debt Screen')),
    );
  }
}

