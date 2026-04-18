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

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {'subject': 'App Support Request'},
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
      backgroundColor: color.surface,
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
    "Help & Support",
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

            // ─── Contact Support ────────────────────────────────────
            _sectionLabel(context, "Contact"),
            const SizedBox(height: 10),
            _supportTile(
              context: context,
              icon: Icons.email_outlined,
              title: "Contact Support",
              subtitle: "Reach out to our support team",
              onTap: _launchEmail,
            ),

            const SizedBox(height: 28),

            // ─── FAQs ───────────────────────────────────────────────
            _sectionLabel(context, "FAQs"),
            const SizedBox(height: 12),

            TextField(
              controller: _searchController,
              onChanged: _searchFaq,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: color.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Icon(Icons.search,
                    size: 20, color: color.onSurface.withOpacity(0.45)),
                filled: true,
                fillColor: color.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: color.outline.withOpacity(0.25), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (_filteredFaqs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 40,
                          color: color.onSurface.withOpacity(0.25)),
                      const SizedBox(height: 10),
                      Text(
                        "No results found",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(
                _filteredFaqs.length,
                (index) {
                  final faq = _filteredFaqs[index];
                  final isLast = index == _filteredFaqs.length - 1;
                  return Column(
                    children: [
                      _faqItem(context, index, faq["q"]!, faq["a"]!),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: 16,
                          endIndent: 16,
                          color: color.outline.withOpacity(0.2),
                        ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    return Text(
      label.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: color.onSurface.withOpacity(0.45),
      ),
    );
  }

  Widget _supportTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color.onSurface.withOpacity(0.7)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.onSurface.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 20, color: color.onSurface.withOpacity(0.25)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(
    BuildContext context,
    int index,
    String question,
    String answer,
  ) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final bool isExpanded = expandedIndex == index;

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey(index),
        initiallyExpanded: isExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        childrenPadding:
            const EdgeInsets.only(left: 4, right: 4, bottom: 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        onExpansionChanged: (value) {
          setState(() {
            expandedIndex = value ? index : null;
          });
        },
        trailing: AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color.onSurface.withOpacity(0.5),
          ),
        ),
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color.onSurface,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}