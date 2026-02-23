import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ActionButtonCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconBg;
  final Color iconColor;

  const ActionButtonCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔹 Icon
              CircleAvatar(
                radius: 22,
                backgroundColor: iconBg,
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),

              const SizedBox(height: 12),

              /// 🔹 Label
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}