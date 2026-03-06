import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
import 'package:front_end/core/models/transaction_model.dart';

import 'package:front_end/features/goals/ui/financial_goals_screen.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE ---
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  // Use your dynamic User ID here
  final String userId = "699e8fea9a6c85ac1f0970eb";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 🎯 FETCH LOGIC
  Future<void> _fetchData() async {
    try {
      final response = await TransactionService.getHistory(userId);

      if (mounted) {
        setState(() {
          _recentTransactions = response.transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Home Fetch Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔥 FIXED: Completely rebuilt the broken widget tree
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFFB81414),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 10),
              const BalanceCard(),
              const SizedBox(height: 10),
              const QuickActionsSection(),
              const SizedBox(height: 25),

              // Goals Section (Extracted into a clean method)
              _buildFinancialGoals(context),

              const SizedBox(height: 15),

              // Dynamic Transactions Section
              _buildRecentHeader(theme),
              _buildTransactionList(theme),

              const SizedBox(height: 40), // Extra padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  String getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";

    for (var n in names) {
      if (n.isNotEmpty) {
        initials += n[0];
      }
    }

    return initials.toUpperCase();
  }
  // --- UI HELPER METHODS ---

  Widget _buildHeader(BuildContext context) {
    final user = context.watch<UserProfileProvider>();

    String userName = user.name;
    String? profileImage = user.image;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF620E0E), Color(0xFFB81414)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Wallet Care",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          /// PROFILE BUTTON
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: const Color.fromARGB(255, 98, 14, 14),

              /// If profile image exists
              backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                  ? NetworkImage(profileImage)
                  : null,

              /// If image not exists show initials
              child: (profileImage == null || profileImage.isEmpty)
                  ? Text(
                      getInitials(userName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialGoals(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    Text("View All",
                        style: TextStyle(color: AppColors.textMuted)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: HomeScreen.demoGoals.length,
            padding: const EdgeInsets.only(left: 30),
            itemBuilder: (context, index) {
              final goal = HomeScreen.demoGoals[index];

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
                          // 🔥 FIXED: Replaced deprecated withOpacity
                          backgroundColor: goal["color"].withValues(alpha: 0.2),
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
                      // 🔥 FIXED: Replaced deprecated withOpacity
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(goal["color"]),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("\$${saved.toStringAsFixed(0)}",
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        Text("\$${target.toStringAsFixed(0)}",
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
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
      ],
    );
  }

  Widget _buildRecentHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
              onPressed: () => NavigationService.bottomIndex.value = 2,
              child: const Text("See All",
                  style: TextStyle(color: Color(0xFFB81414)))),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        width: double.infinity,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFB81414),
                ),
              )
            : _recentTransactions.isEmpty
                ? const Center(
                    child: Text("No transactions yet"),
                  )
                : Column(
                    children: _recentTransactions
                        .take(5)
                        .map((tx) => TransactionCard(
                              title: tx.title,
                              subtitle: tx.subtitle,
                              amount: "₹${tx.amount.abs().toStringAsFixed(0)}",
                              date: tx.date,
                              type: tx.direction == "GOAL_ALLOCATION"
                                  ? TransactionType.reserved
                                  : (tx.type == "income"
                                      ? TransactionType.income
                                      : TransactionType.expense),
                            ))
                        .toList(),
                  ),
      ),
    );
  }
}
