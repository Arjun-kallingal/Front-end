import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/base_app_bar.dart';
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Transaction History'),
      body: const Center(child: Text('Transactions History')),
    );
  }
}
