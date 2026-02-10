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
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                children: const [
                  Icon(Icons.account_balance_wallet),
                  SizedBox(width: 8),
                  Text(
                    'Wallet Balance',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  _isBalanceVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
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

          const Text(
            'Available Balance',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w200),
          ),

          const SizedBox(height: 5),

          Text(
            _isBalanceVisible ? '₹ 25,450.00' : '••••••••',
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Divider(color: AppColors.divider),

          const SizedBox(height: 15),

          const Text(
            'Reserved Amount',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w200),
          ),

          const SizedBox(height: 5),

          Text(
            _isBalanceVisible ? '₹ 1,550' : '••••••••',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 15),

          Divider(color: AppColors.divider),

          const SizedBox(height: 15),

          // ✅ Total Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                _isBalanceVisible ? '₹ 27,000.00' : '••••••••',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
