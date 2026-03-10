import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'action_button_card.dart';
import 'move_to_savings_card.dart';

// ✅ 1. Match the import to your actual file
import 'package:front_end/features/goals/ui/financial_goals_screen.dart'; 
import 'package:front_end/features/home/widget/add_transaction_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // ✅ 2. REMOVED the 'const' from here. 
        // You cannot have a const Column if its children (like _MoveToSavingsSection) are not const.
        children: [
          const _ActionButtonsRow(),
          const SizedBox(height: 16),
          const _MoveToSavingsSection(),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ActionButtonCard(
          icon: Icons.trending_up,
          label: "Add Income",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(initialIsExpense: false),
              ),
            );
          },
          iconBg: AppColors.incomeIconBg,
          iconColor: AppColors.incomeAmount,
        ),
        const SizedBox(width: 20),
        ActionButtonCard(
          icon: Icons.trending_down,
          label: "Add Expense",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(initialIsExpense: true),
              ),
            );
          },
          iconBg: AppColors.expenseIconBg,
          iconColor: AppColors.expenseAmount,
        ),
      ],
    );
  }
}

class _MoveToSavingsSection extends StatelessWidget {
  const _MoveToSavingsSection();

  @override
  Widget build(BuildContext context) {
    return MoveToSavingsCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // ✅ 3. USE THE CORRECT CLASS NAME: FinancialGoalsScreen
            // And ensure 'const' is removed here.
            builder: (_) => const FinancialGoalsScreen(), 
          ),
        );
      },
    );
  }
}