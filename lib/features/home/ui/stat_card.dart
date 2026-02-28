import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final Color amountColor;
  final Color iconBg;
  final String subtitle;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.amountColor,
    required this.iconBg,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12), // slightly reduced padding
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ICON + TITLE
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: iconBg,
                  child: Icon(
                    icon,
                    color: amountColor,
                    size: 16,
                  ),
                ),

                const SizedBox(width: 6),

                /// FIX: prevents overflow
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// AMOUNT
            Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 6),

            /// SUBTITLE
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}