import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? expandedIndex;
  final GlobalKey faqKey = GlobalKey();

  /// ================= SAFE EMAIL LAUNCHER =================
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {
        'subject': 'App Support Request',
      },
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.platformDefault,
        webOnlyWindowName: '_self',
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open email app"),
        ),
      );
    }
  }

  void _handleNavigation(String type) {
    if (type == "email") {
      _launchEmail();
    } else if (type == "chat") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Live Chat Coming Soon 💬")),
      );
    } else if (type == "faq") {
      if (faqKey.currentContext != null) {
        Scrollable.ensureVisible(
          faqKey.currentContext!,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

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
              padding: const EdgeInsets.only(top: 10, bottom: 10),
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
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Help & Support",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= BODY =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _supportTile(
                        context,
                        icon: Icons.email_outlined,
                        title: "Contact Support",
                        subtitle: "Reach out to our support team",
                        onTap: () => _handleNavigation("email"),
                      ),

                      const SizedBox(height: 16),

                      _supportTile(
                        context,
                        icon: Icons.chat_outlined,
                        title: "Live Chat",
                        subtitle: "Chat instantly with an agent",
                        onTap: () => _handleNavigation("chat"),
                      ),

                      const SizedBox(height: 16),

                      _supportTile(
                        context,
                        icon: Icons.question_answer_outlined,
                        title: "FAQs",
                        subtitle: "Find answers quickly",
                        onTap: () => _handleNavigation("faq"),
                      ),

                      const SizedBox(height: 30),

                      Text(
                        "Frequently Asked Questions",
                        key: faqKey,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _animatedFaq(
                        0,
                        "How do I reset my password?",
                        "Go to Settings > Account > Reset Password.",
                      ),

                      const SizedBox(height: 12),

                      _animatedFaq(
                        1,
                        "How do I edit my profile?",
                        "Navigate to profile page and tap Edit.",
                      ),

                      const SizedBox(height: 12),

                      _animatedFaq(
                        2,
                        "Is my data secure?",
                        "Yes, we use secure encryption to protect your data.",
                      ),
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

  /// ================= SUPPORT TILE =================
  Widget _supportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isDark ? Colors.white : Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ANIMATED FAQ =================
  Widget _animatedFaq(int index, String question, String answer) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isExpanded = expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: color.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        key: PageStorageKey(index),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (value) {
          setState(() {
            expandedIndex = value ? index : null;
          });
        },
        iconColor: isDark ? Colors.white : Colors.black,
        collapsedIconColor: isDark ? Colors.white : Colors.black,
        tilePadding:
            const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        children: [
          AnimatedOpacity(
            opacity: isExpanded ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              answer,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}