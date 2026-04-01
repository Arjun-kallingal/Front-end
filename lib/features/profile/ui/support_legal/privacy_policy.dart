import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
     appBar: AppBar(
  backgroundColor: color.surface,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  automaticallyImplyLeading: false,
  titleSpacing: 0,
  leading: IconButton(
    onPressed: () => Navigator.pop(context),
    padding: EdgeInsets.zero,
    icon: Icon(
      Icons.arrow_back_ios_new,
      size: 18,
      color: color.onSurface,
    ),
  ),
  title: Text(
    "Privacy Policy",
    style: theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      color: color.onSurface,
    ),
  ),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Last Updated ──────────────────────────────────────
            Text(
              "Last updated: February 26, 2026",
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.onSurface.withOpacity(0.45),
              ),
            ),

            const SizedBox(height: 20),

            _section(context, "1. Information We Collect", [
              _subsection(context, "Personal Information", [
                "Name",
                "Email address",
                "Login credentials (encrypted)",
              ]),
              _subsection(context, "Financial Information", [
                "Income and expense entries",
                "Transaction notes and categories",
                "We do NOT collect bank passwords or PINs.",
              ]),
              _subsection(context, "Technical Information", [
                "Device information",
                "Usage logs",
                "Crash reports",
              ]),
            ]),

            _section(context, "2. How We Use Your Information", [
              _bulletList(context, [
                "Manage your account",
                "Store financial transactions",
                "Improve app performance",
                "Provide support",
                "Secure authentication",
              ]),
            ]),

            _section(context, "3. Data Security", [
              _prose(context,
                  "We use encrypted passwords, HTTPS communication, and secure backend systems. No system is 100% secure."),
            ]),

            _section(context, "4. Data Sharing", [
              _prose(context,
                  "We do NOT sell your data. We share only when legally required or for infrastructure services."),
            ]),

            _section(context, "5. Your Rights", [
              _bulletList(context, [
                "Update your account",
                "Request deletion",
                "Stop using the app anytime",
              ]),
            ]),

            _section(context, "6. Authentication", [
              _prose(context, "Secure email-based authentication is used."),
            ]),

            _section(context, "7. Children's Privacy", [
              _prose(context, "Not intended for users under 13."),
            ]),

            _section(context, "8. Policy Updates", [
              _prose(context, "This policy may be updated anytime."),
            ]),

            _section(context, "9. Contact", [
              _prose(context, "Developer: Syamjith\nEmail: support@walletcare.app"),
            ]),

            _section(context, "10. Consent", [
              _prose(context,
                  "By using WalletCare, you agree to this policy."),
            ]),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
          const SizedBox(height: 4),
          Divider(
            height: 1,
            thickness: 0.5,
            color: color.outline.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _subsection(
      BuildContext context, String label, List<String> points) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 6),
          ...points.map((p) => _bulletRow(context, p)),
        ],
      ),
    );
  }

  Widget _bulletList(BuildContext context, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points.map((p) => _bulletRow(context, p)).toList(),
    );
  }

  Widget _bulletRow(BuildContext context, String text) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: color.onSurface.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prose(BuildContext context, String text) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        height: 1.7,
        color: color.onSurface.withOpacity(0.75),
      ),
    );
  }
}