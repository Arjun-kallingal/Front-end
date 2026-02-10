import 'package:flutter/material.dart';
import 'quick_action_button.dart';


class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          QuickActionButton(
            icon: Icons.arrow_downward,
            label: 'Income (Month)',
          ),
          QuickActionButton(
            icon: Icons.arrow_upward,
            label: 'Expense (Month)',
          ),
          QuickActionButton(
            icon: Icons.savings,
            label: 'Saved',
          ),
          QuickActionButton(
            icon: Icons.add,
            label: 'Add Income',
          ),
          QuickActionButton(
            icon: Icons.remove,
            label: 'Add Expense',
          ),
        ],
      ),
    );
  }
}
