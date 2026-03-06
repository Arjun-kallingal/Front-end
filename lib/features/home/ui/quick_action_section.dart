import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'action_button_card.dart';
import 'move_to_savings_card.dart';
import 'package:front_end/features/home/widget/add_income_screen.dart';
import 'package:front_end/features/home/widget/add_expense_screen.dart';
import 'package:front_end/features/goals/ui/financial_goals_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 24),
          _ActionButtonsRow(),
          SizedBox(height: 16),
          _MoveToSavingsSection(),
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
                builder: (_) => const AddIncomeScreen(),
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
                builder: (_) => const AddExpenseScreen(),
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
            builder: (_) => const FinancialGoalsScreen(),
          ),
        );
      },
    );
  }
}