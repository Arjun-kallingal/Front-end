import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

enum TransactionType { income, expense, reserved }

class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final TransactionType type;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
  });

  
  // AMOUNT COLOR
  
  Color get amountColor {
    switch (type) {
      case TransactionType.income:
        return AppColors.incomeAmount;
      case TransactionType.reserved:
        return AppColors.info;
      case TransactionType.expense:
        return AppColors.expenseAmount;
    }
  }

  
  // ICON
  
  IconData get icon {
    switch (type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.reserved:
        return Icons.swap_horiz;
      case TransactionType.expense:
        return Icons.trending_down;
    }
  }

  
  // ICON BACKGROUND
  
  Color get iconBg {
    switch (type) {
      case TransactionType.income:
        return AppColors.incomeIconBg;
      case TransactionType.reserved:
        return AppColors.savingsIconBg;
      case TransactionType.expense:
        return AppColors.expenseIconBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          
          // ICON
          
          CircleAvatar(
            backgroundColor: iconBg,
            child: Icon(
              icon,
              color: amountColor,
            ),
          ),

          const SizedBox(width: 15),

          
          // TITLE & SUBTITLE
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.dateLabel,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          
          // AMOUNT
          
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
