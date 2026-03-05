import 'package:flutter/material.dart';

class AboutWalletCareScreen extends StatelessWidget {
  const AboutWalletCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("About WalletCare"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 20),

            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: theme.colorScheme.primary,
            ),

            const SizedBox(height: 20),

            Text(
              "WalletCare",
              style: theme.textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              "Version 1.0.0",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            Text(
              "WalletCare helps you track expenses, manage savings goals, "
              "and stay financially organized with a clean and secure experience.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const Spacer(),

            Text(
              "© 2026 WalletCare. All rights reserved.",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
