import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:front_end/features/transactions/data/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<TransactionModel> transactionList = [
    TransactionModel(
      title: "Salary",
      subtitle: "Company Payment",
      amount: 3000,
      date: DateTime(2026, 2, 10),
      type: "income",
      accountType: "bank",
    ),
    TransactionModel(
      title: "Shopping",
      subtitle: "Clothing",
      amount: -200,
      date: DateTime(2026, 2, 9),
      type: "expense",
      accountType: "cash",
    ),
    TransactionModel(
      title: "Entertainment",
      subtitle: "Concert",
      amount: -120,
      date: DateTime(2026, 2, 9),
      type: "expense",
      accountType: "cash",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 30,
                bottom: 70,
                left: 30,
                right: 30,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Welcome Syamjith",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.bottomIndex.value = 3;
                    },
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white24,
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    const BalanceCard(),
                    const SizedBox(height: 5),
                    const QuickActionsSection(),
                    const SizedBox(height: 10),

                    /// Recent Transactions Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Recent Transactions",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              NavigationService.bottomIndex.value = 2;
                            },
                            child: Row(
                              children: [
                                Text(
                                  "See All",
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// Transactions Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cardShadow,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: transactionList.take(5).map((tx) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: TransactionCard(
                                title: tx.title,
                                subtitle: tx.date.toString().split(' ')[0],
                                amount: tx.amount.toStringAsFixed(0),
                                type: tx.type == "reserved"
                                    ? TransactionType.reserved
                                    : tx.amount < 0
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
            ),
          ],
        ),
      ),
    );
  }
}
