import 'package:flutter/material.dart';
import 'balance_card.dart';
 import 'quick_action_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '          Welcome',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 2),
            Text(
              '       Syamjith',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: const CircleAvatar(
                radius: 18,
                child: Icon(Icons.person, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 10),
            BalanceCard(),
            SizedBox(height: 10),
            QuickActionsSection(),
          ],
        ),
      ),
    );
  }
}
