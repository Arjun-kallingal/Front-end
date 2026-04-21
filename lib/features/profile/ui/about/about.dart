import 'package:flutter/material.dart';

class AboutGreenPouchScreen extends StatelessWidget {
  const AboutGreenPouchScreen({super.key});

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
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: color.onSurface),
        ),
        title: Text(
          "About GreenPouch",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color.onSurface,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: color.outline.withOpacity(0.15),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ─── App Icon ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.primary,
                    color.primary.withOpacity(0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 48,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // ─── App Name ─────────────────────────────────────────
            Text(
              "GreenPouch",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color.onSurface,
              ),
            ),

            const SizedBox(height: 6),

            // ─── Version ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Version 1.0.0",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Divider(
                height: 1,
                thickness: 0.5,
                color: color.outline.withOpacity(0.15)),

            const SizedBox(height: 24),

            // ─── Description ──────────────────────────────────────
            Text(
              "GreenPouch helps you track expenses, manage savings goals, "
              "and stay financially organized with a clean and secure experience.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.7,
                color: color.onSurface.withOpacity(0.65),
              ),
            ),

            const SizedBox(height: 40),

            // ─── Info Card ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.outline.withOpacity(0.12),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _infoRow(context, Icons.person_outline, "Developer", "Syamjith"),
                  Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.12)),
                  _infoRow(context, Icons.email_outlined, "Support",
                      "support@greenpouch.app"),
                  Divider(height: 1, thickness: 0.5, color: color.outline.withOpacity(0.12)),
                  _infoRow(context, Icons.language_outlined, "Platform",
                      "iOS & Android"),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // ─── Copyright ────────────────────────────────────────
            Text(
              "© 2026 GreenPouch. All rights reserved.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color.onSurface.withOpacity(0.35),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.onSurface.withOpacity(0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}