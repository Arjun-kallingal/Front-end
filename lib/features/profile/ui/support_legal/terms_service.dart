import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Your Terms of Service content goes here.\n\n"
          "Explain user responsibilities, account rules, limitations of liability, "
          "and conditions for using the app.",
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
