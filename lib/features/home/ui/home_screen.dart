import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:front_end/features/transactions/data/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
import 'package:front_end/features/goals/ui/financial_goals_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 🔹 Dummy Goals (Temporary Until Backend Ready)
  static final List<Map<String, dynamic>> demoGoals = [
    {
      "title": "Emergency Fund",
      "saved": 6500.0,
      "target": 10000.0,
      "color": Colors.red,
      "icon": Icons.track_changes,
    },
    {
      "title": "Vacation to Japan",
      "saved": 2800.0,
      "target": 5000.0,
      "color": Colors.blue,
      "icon": Icons.flight,
    },
  ];

  static final List<TransactionModel> transactionList = [
    TransactionModel(
      title: "Salary",
      subtitle: "Company Payment",
      amount: 3000,
      date: DateTime(2026, 2, 10),
      type: "income",
    ),
    TransactionModel(
      title: "Shopping",
      subtitle: "Clothing",
      amount: -200,
      date: DateTime(2026, 2, 9),
      type: "expense",
    ),
    TransactionModel(
      title: "Entertainment",
      subtitle: "Concert",
      amount: -120,
      date: DateTime(2026, 2, 9),
      type: "expense",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        titleSpacing: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Muhammed Irfan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const BalanceCard(),
            const SizedBox(height: 10),
            const QuickActionsSection(),
            const SizedBox(height: 25),

            /// ================================
            /// 🔥 FINANCIAL GOALS HEADER
            /// ================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Financial Goals",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FinancialGoalsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: const [
                        Text(
                          "View All",
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// ================================
            /// 🔥 HORIZONTAL GOALS LIST
            /// ================================
            SizedBox(
              height: 170,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: demoGoals.length,
                padding: const EdgeInsets.only(left: 30),
                itemBuilder: (context, index) {
                  final goal = demoGoals[index];

                  double saved = goal["saved"];
                  double target = goal["target"];
                  double progress = saved / target;
                  int percent = (progress * 100).toInt();

                  return Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: goal["color"]),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  goal["color"].withOpacity(0.2),
                              child: Icon(
                                goal["icon"],
                                color: goal["color"],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                goal["title"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation(goal["color"]),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${saved.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              "\$${target.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "$percent% Complete",
                          style: TextStyle(
                            color: goal["color"],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            /// 🔹 RECENT TRANSACTIONS HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.bottomIndex.value = 2;
                    },
                    child: Row(
                      children: const [
                        Text("See All",
                            style:
                                TextStyle(color: AppColors.textMuted)),
                        SizedBox(width: 4),
                        Icon(Icons.chevron_right,
                            color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// 🔹 RECENT TRANSACTIONS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: transactionList.take(5).map((tx) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 15),
                      child: TransactionCard(
                        title: tx.title,
                        subtitle:
                            tx.date.toString().split(' ')[0],
                        amount:
                            tx.amount.toStringAsFixed(0),
                        type: tx.amount < 0
                            ? TransactionType.expense
                            : TransactionType.income,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}