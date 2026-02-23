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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Syamjith',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 30),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {},
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.colorScheme.surface,
                child: Icon(
                  Icons.person,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),

            const BalanceCard(),

            const SizedBox(height: 5),

            const QuickActionsSection(),

            const SizedBox(height: 10),

            /// 🔹 RECENT TRANSACTIONS HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
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
                            color: theme.colorScheme.onBackground
                                .withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          color: theme.colorScheme.onBackground
                              .withOpacity(0.6),
                        ),
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
    );
  }
}