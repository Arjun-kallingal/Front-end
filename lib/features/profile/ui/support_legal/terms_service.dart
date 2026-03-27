import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,

      /// ✅ Use AppBar instead of custom header
      appBar: AppBar(
        title: const Text("Terms of Service"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      /// ================= CONTENT =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
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
    );
  }
}