import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
              bottom: 30,
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
                      "Privacy Policy",
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


          /// ================= SCROLLABLE PRIVACY CONTENT =================
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 30,right: 30,top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    SelectableText(
                      '''
Privacy Policy for WalletCare

Last updated: February 26, 2026

Syamjith ("we", "our", or "us") operates the WalletCare mobile application. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our app.

By using WalletCare, you agree to the collection and use of information in accordance with this policy.

------------------------------------------------------------

1. Information We Collect

Personal Information

When you register and use WalletCare, we may collect:

• Name
• Email address
• Login credentials (encrypted password)
• Account profile information

Financial Information

WalletCare allows you to store financial records such as:

• Income and expense entries
• Transaction descriptions
• Categories and notes

We do NOT collect bank passwords, debit card PINs, or banking credentials.

Technical Information

We may collect:

• Device type and operating system
• App usage information
• Log data (for security and debugging)

------------------------------------------------------------

2. How We Use Your Information

We use your information to:

• Create and manage your account 👤
• Securely store your financial transactions 💰
• Provide and improve app features
• Authenticate users and prevent unauthorized access 🔐
• Provide customer support
• Fix bugs and improve performance

------------------------------------------------------------

3. Data Storage and Security

Your data is stored securely using MongoDB databases and Node.js backend services.

We implement:

• Encrypted authentication passwords
• Secure server communication (HTTPS)
• Access control to prevent unauthorized access

However, no system is 100% secure, and we cannot guarantee absolute security.

------------------------------------------------------------

4. Data Sharing

We do NOT sell, rent, or trade your personal or financial data.

We may share data only:

• To comply with legal obligations
• To protect security and prevent fraud
• With trusted infrastructure providers for hosting services

------------------------------------------------------------

5. User Account and Data Control

You can:

• Update your account information
• Delete your account (future feature or by contacting us)
• Stop using the app at any time

Upon request, we will delete your personal data from our servers where applicable.

------------------------------------------------------------

6. Authentication

WalletCare uses secure email-based authentication. Your password is encrypted and never stored in plain text.

------------------------------------------------------------

7. Children's Privacy

WalletCare is not intended for users under the age of 13. We do not knowingly collect personal information from children.

------------------------------------------------------------

8. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. Updates will be posted inside the app and include a revised "Last updated" date.

------------------------------------------------------------

9. Contact Us

If you have any questions about this Privacy Policy, contact:

Developer: Syamjith
Email: support@walletcare.app (demo email — replace with your real email before publishing)

------------------------------------------------------------

10. Your Consent

By using WalletCare, you consent to this Privacy Policy.
''',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}