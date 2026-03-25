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

  final TextEditingController _searchController = TextEditingController();

  /// FAQ DATA
  final List<Map<String, String>> _faqList = [
    {
      "q": "How do I reset my password?",
      "a": "Go to Settings > Account > Reset Password."
    },
    {
      "q": "How do I edit my profile?",
      "a": "Navigate to profile page and tap Edit."
    },
    {
      "q": "Is my data secure?",
      "a": "Yes, we use industry-standard encryption."
    },
  ];

  List<Map<String, String>> _filteredFaqs = [];

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _faqList;
  }

  /// EMAIL
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {
        'subject': 'App Support Request',
      },
    );

    try {
      await launchUrl(emailUri);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open email app")),
      );
    }
  }

  /// SEARCH
  void _searchFaq(String query) {
    final results = _faqList.where((faq) {
      final q = faq["q"]!.toLowerCase();
      final a = faq["a"]!.toLowerCase();
      return q.contains(query.toLowerCase()) ||
          a.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredFaqs = results;
      expandedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      appBar: AppBar(
        title: const Text("Help & Support"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
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

              /// CONTACT SUPPORT
              _supportTile(
                context: context,
                icon: Icons.email_outlined,
                title: "Contact Support",
                subtitle: "Reach out to our support team",
                onTap: _launchEmail,
              ),

              const SizedBox(height: 25),

              /// FAQ TITLE
              Text(
                "FAQs",
                key: faqKey,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// SEARCH FIELD (THEME CONTROLLED)
              TextField(
                controller: _searchController,
                onChanged: _searchFaq,
                decoration: const InputDecoration(
                  hintText: "Search FAQs...",
                  prefixIcon: Icon(Icons.search),
                ),
              ),

              const SizedBox(height: 20),

              /// FAQ LIST
              if (_filteredFaqs.isEmpty)
                Center(
                  child: Text(
                    "No results found",
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                ...List.generate(
                  _filteredFaqs.length,
                  (index) {
                    final faq = _filteredFaqs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _faqItem(
                        context,
                        index,
                        faq["q"]!,
                        faq["a"]!,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// SUPPORT TILE
  Widget _supportTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surface.withOpacity(0.6),
        ),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAQ ITEM
  Widget _faqItem(
    BuildContext context,
    int index,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);
    final bool isExpanded = expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface.withOpacity(0.6),
      ),
      child: ExpansionTile(
        key: PageStorageKey(index),
        initiallyExpanded: isExpanded,
        onExpansionChanged: (value) {
          setState(() {
            expandedIndex = value ? index : null;
          });
        },
        title: Text(
          question,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}