import 'package:flutter/material.dart';
import 'quick_action_button.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          QuickActionButton(
            icon: Icons.send,
            label: 'Send',
          ),
          QuickActionButton(
            icon: Icons.call_received,
            label: 'Receive',
          ),
          QuickActionButton(
            icon: Icons.add,
            label: 'Add Money',
          ),
          QuickActionButton(
            icon: Icons.receipt_long,
            label: 'Bills',
          ),
        ],
      ),
    );
  }
}
