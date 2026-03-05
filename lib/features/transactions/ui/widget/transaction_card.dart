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

  /// ✅ AMOUNT COLOR
  Color getAmountColor(BuildContext context) {
    switch (type) {
      case TransactionType.income:
        return AppColors.incomeAmount;
      case TransactionType.reserved:
        return AppColors.info;
      case TransactionType.expense:
        return AppColors.expenseAmount;
    }
  }

  /// ✅ ICON
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

  /// ✅ ICON BACKGROUND
  Color getIconBg(BuildContext context) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final amountColor = getAmountColor(context);
    final iconBg = getIconBg(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔵 ICON
          CircleAvatar(
            radius: 22,
            backgroundColor: iconBg,
            child: Icon(
              icon,
              color: amountColor,
            ),
          ),

          const SizedBox(width: 15),

          /// 📝 TITLE & SUBTITLE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          /// 💰 AMOUNT
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}