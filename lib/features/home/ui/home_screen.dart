import 'package:flutter/material.dart';
import 'balance_card.dart';
import 'quick_action.dart';


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            BalanceCard(),
            SizedBox(height: 16),
            QuickActionsRow(),
          ],
        ),
      ),
    );
  }
}
