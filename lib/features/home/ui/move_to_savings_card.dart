import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MoveToSavingsCard extends StatelessWidget {
  final VoidCallback onTap;

  const MoveToSavingsCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            /// 🔹 Icon
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.savingsIconBg,
              child: Icon(
                Icons.flag,
                color: AppColors.savingsPrimary,
              ),
            ),

            const SizedBox(width: 12),

            /// 🔹 Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Move to Goals",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            /// 🔹 Arrow
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}