import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? Colors.white : Colors.black,
                      size: 20,
                    ),
                  ),

                  Expanded(
                    child: Text(
                      "Privacy Policy",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
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
                  horizontal: 20,
                  vertical: 20,
                ),
                child: SelectableText(
                  '''
Privacy Policy for WalletCare

Last updated: February 26, 2026

Syamjith ("we", "our", or "us") operates the WalletCare mobile application. This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our app.

By using WalletCare, you agree to this policy.

------------------------------------------------------------

1. Information We Collect

Personal Information
• Name
• Email address
• Login credentials (encrypted)

Financial Information
• Income and expense entries
• Transaction notes and categories

We do NOT collect bank passwords or PINs.

Technical Information
• Device information
• Usage logs
• Crash reports

------------------------------------------------------------

2. How We Use Your Information

• Manage your account
• Store financial transactions
• Improve app performance
• Provide support
• Secure authentication

------------------------------------------------------------

3. Data Security

We use:
• Encrypted passwords
• HTTPS communication
• Secure backend systems

No system is 100% secure.

------------------------------------------------------------

4. Data Sharing

We do NOT sell your data.

We share only when legally required or for infrastructure services.

------------------------------------------------------------

5. Your Rights

You can:
• Update your account
• Request deletion
• Stop using the app anytime

------------------------------------------------------------

6. Authentication

Secure email-based authentication is used.

------------------------------------------------------------

7. Children's Privacy

Not intended for users under 13.

------------------------------------------------------------

8. Policy Updates

Policy may be updated anytime.

------------------------------------------------------------

9. Contact

Developer: Syamjith  
Email: support@walletcare.app

------------------------------------------------------------

10. Consent

By using WalletCare, you agree to this policy.
''',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
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