import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(
            color: AppColors.primaryRed,
            width: 3,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: AppColors.cardShadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Wallet Balance',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _isBalanceVisible = !_isBalanceVisible;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Available Balance',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _isBalanceVisible ? '₹ 25,450.00' : '••••••••',
            style: textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 15),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 15),

          Text(
            'Reserved Amount',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _isBalanceVisible ? '₹ 1,550' : '••••••••',
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.savingsPrimary,
            ),
          ),

          const SizedBox(height: 15),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 15),

          // Total Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                _isBalanceVisible ? '₹ 27,000.00' : '••••••••',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
