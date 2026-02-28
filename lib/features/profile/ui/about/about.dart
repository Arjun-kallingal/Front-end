import 'package:flutter/material.dart';

class AboutWalletCareScreen extends StatelessWidget {
  const AboutWalletCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "About WalletCare",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      /// App Icon
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),

                      const SizedBox(height: 20),

                      /// App Name
                      Text(
                        "WalletCare",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// Version
                      Text(
                        "Version 1.0.0",
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 24),

                      /// Description
                      Text(
                        "WalletCare helps you track expenses, manage savings goals, "
                        "and stay financially organized with a clean and secure experience.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 60),

                      /// Copyright
                      Text(
                        "© 2026 WalletCare. All rights reserved.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}