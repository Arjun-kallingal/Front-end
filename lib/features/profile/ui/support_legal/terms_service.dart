import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: color.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 20,
              bottom:30,
              left: 0,
              right: 0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const Text(
                      "Terms of Service",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),


          /// ================= SCROLLABLE TERMS CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left: 30,right: 30,top: 30),
                    child: SelectableText(
                      '''
Effective Date: [Insert Date]

App Name: Wallet Care

Welcome to Wallet Care, a financial tracking and money management application designed to help users monitor expenses, income, and budgeting.

By downloading, accessing, or using Wallet Care (“App,” “Service”), you agree to be bound by these Terms of Service (“Terms”). If you do not agree, please do not use the App.

1. Eligibility

You must be at least 18 years old to use Wallet Care. By using the App, you confirm that you meet this requirement.

2. Description of Service

Wallet Care provides:

• Expense and income tracking
• Budget management tools
• Financial insights and reports
• Data visualization and analytics

Wallet Care does not provide banking, investment, tax, or financial advisory services.

3. User Accounts

To access certain features, you may need to create an account.

You agree to:

• Provide accurate and complete information
• Keep your login credentials secure
• Notify us immediately of unauthorized access

You are responsible for all activity under your account.

4. Financial Disclaimer

Wallet Care is a financial tracking tool only.

• We do not guarantee financial accuracy.
• We do not provide investment, tax, or legal advice.
• Decisions made using the App are your responsibility.

Always consult a qualified financial professional before making financial decisions.

5. Data & Privacy

Your use of Wallet Care is also governed by our Privacy Policy, which explains how we collect, use, and protect your information.

We implement reasonable security measures to protect your data, but no system is completely secure.

6. User Responsibilities

You agree NOT to:

• Use the App for illegal activities
• Attempt to hack, disrupt, or reverse-engineer the App
• Upload harmful code or malware
• Misuse financial data or impersonate others

7. Subscription & Payments (If Applicable)

If Wallet Care offers premium features:

• Subscriptions may renew automatically unless canceled.
• Payments are processed via third-party platforms (e.g., Apple App Store / Google Play).
• Refund policies follow the respective app store’s policies.

8. Intellectual Property

All content, branding, design, software, and features of Wallet Care are the exclusive property of [Your Company Name].

You may not copy, modify, distribute, or create derivative works without written permission.

9. Termination

We may suspend or terminate your access if you:

• Violate these Terms
• Engage in fraudulent or harmful activity
• Misuse the Service

You may stop using the App at any time.

10. Limitation of Liability

To the maximum extent permitted by law:

Wallet Care and its owners shall not be liable for:

• Financial losses
• Data loss
• Indirect or consequential damages
• Errors or inaccuracies in financial calculations

Your use of the App is at your own risk.

11. Third-Party Services

The App may integrate with third-party services (e.g., payment providers, analytics tools). We are not responsible for their policies or services.

12. Changes to Terms

We may update these Terms from time to time. Continued use of the App after changes means you accept the revised Terms.

13. Governing Law

These Terms shall be governed by the laws of [Your Country/State], without regard to conflict of law principles.

14. Contact Information

If you have questions about these Terms, contact us at:

Email: support@walletcare.com
Company Name: [Your Company Name]
Address: [Your Business Address]
''',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}