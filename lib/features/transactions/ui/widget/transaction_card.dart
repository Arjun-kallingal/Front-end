import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/constants/app_colors.dart';

enum TransactionType { income, expense, reserved }

class TransactionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final DateTime date;
  final TransactionType type;

  const TransactionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
  });

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
    final amountColor = getAmountColor(context);
    final iconBg = getIconBg(context);

    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15),
      color: theme.cardColor,
      child: Row(
        children: [
          /// ICON
          CircleAvatar(
            radius: 22,
            backgroundColor: iconBg,
            child: Icon(
              icon,
              color: amountColor,
            ),
          ),

          const SizedBox(width: 15),

          /// TITLE + SUBTITLE + DATE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 3),

                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),

                const SizedBox(height: 2),

                /// DATE
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          /// AMOUNT
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: amountColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}