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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 ICON + AMOUNT (Same Row)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconBg,
                child: Icon(icon, color: amountColor, size: 18),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// 🔹 TITLE BELOW
          Text(
            amount,
            style:  TextStyle(
              color:amountColor,
              fontWeight: FontWeight.bold,
                  fontSize: 25,
            ),
          ),
           const SizedBox(height: 30),

          /// 🔹 Subtitle (This month)
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}}