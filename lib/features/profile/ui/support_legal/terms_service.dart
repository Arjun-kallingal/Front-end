import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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

                  /// prevents overflow
                  const Expanded(
                    child: Text(
                      "Terms of Service",
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

            /// ================= SCROLLABLE CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: SelectableText(
                  '''
Effective Date: [Insert Date]

App Name: Wallet Care

Welcome to Wallet Care, a financial tracking and money management application designed to help users monitor expenses, income, and budgeting.

By downloading, accessing, or using Wallet Care (“App,” “Service”), you agree to be bound by these Terms of Service (“Terms”). If you do not agree, please do not use the App.

1. Eligibility
You must be at least 18 years old to use Wallet Care.

2. Description of Service
• Expense and income tracking
• Budget management tools
• Financial insights and reports
• Data visualization and analytics

Wallet Care does not provide banking, investment, tax, or financial advisory services.

3. User Accounts
You agree to:
• Provide accurate information
• Keep credentials secure
• Notify unauthorized access

4. Financial Disclaimer
Wallet Care is a tracking tool only. Use at your own risk.

5. Data & Privacy
See Privacy Policy for details.

6. User Responsibilities
Do not hack, misuse, or upload harmful code.

7. Subscription & Payments
Subscriptions may auto-renew.

8. Intellectual Property
All rights belong to Wallet Care.

9. Termination
We may suspend access if Terms are violated.

10. Limitation of Liability
We are not liable for financial losses.

11. Third-Party Services
We are not responsible for third-party services.

12. Changes to Terms
Terms may change anytime.

13. Governing Law
Applicable under your local laws.

14. Contact
support@walletcare.com
''',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 14,
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