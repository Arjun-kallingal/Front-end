import 'package:flutter/material.dart';
import 'balance_card.dart';
import 'quick_action.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '    Welcome \n    Muhammed Irfan',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              onTap: () {
                // Navigate to profile screen later
              },
              child: const CircleAvatar(
                radius: 18,
                child: Icon(
                  Icons.person,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
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
