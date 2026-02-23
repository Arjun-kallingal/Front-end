import 'package:flutter/material.dart';

class SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor; // Optional color

  const SummaryItem({
    super.key,
    required this.title,
    required this.value,
    this.valueColor, // Optional
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor ?? theme.textTheme.titleMedium?.color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}