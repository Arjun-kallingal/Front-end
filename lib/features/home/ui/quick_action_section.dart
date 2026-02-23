import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'stat_card.dart';
import 'action_button_card.dart';
import 'move_to_savings_card.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          /// 🔹 Stat Cards Row
          Row(
            children: const [
              StatCard(
                icon: Icons.trending_up,
                title: "Income",
                amount: "\₹6,270",
                subtitle: "This month",
                amountColor: AppColors.incomeAmount,
                iconBg: AppColors.incomeIconBg,
              ),
              SizedBox(width: 12),
              StatCard(
                icon: Icons.trending_down,
                title: "Expense",
                amount: "\₹1,655",
                subtitle: "This month",
                amountColor: AppColors.expenseAmount,
                iconBg: AppColors.expenseIconBg,
              ),
              SizedBox(width: 12),
              StatCard(
                icon: Icons.savings,
                title: "Reserved",
                amount: "\₹800",
                subtitle: "This month",
                amountColor: AppColors.savingsPrimary,
                iconBg: AppColors.savingsIconBg,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔹 Action Buttons Row
          Row(
            children: [
              ActionButtonCard(
                icon: Icons.trending_up,
                label: "Add Income",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(isExpense: true),
                    ),
                  );
                },
                iconBg: AppColors.incomeIconBg,
                iconColor: AppColors.incomeAmount,
              ),
              const SizedBox(width: 12),
              ActionButtonCard(
                icon: Icons.trending_down,
                label: "Add Expense",
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddTransactionScreen(isExpense: false),
                    ),
                  );
                },
                iconBg: AppColors.expenseIconBg,
                iconColor: AppColors.expenseAmount,
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 Full Width Move To Savings
          MoveToSavingsCard(
            onTap: () {
            },
          ),
        ],
      ),
    );
  }
}
