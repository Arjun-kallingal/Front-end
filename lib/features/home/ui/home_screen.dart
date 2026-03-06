import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
import 'package:front_end/core/models/transaction_model.dart';

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

  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  final String userId = "699e8fea9a6c85ac1f0970eb";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// FETCH TRANSACTIONS
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

              /// Recent Transactions
              _buildRecentHeader(),

              _buildTransactionList(),

              const SizedBox(height: 40),
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
      padding: const EdgeInsets.only(top: 10,bottom: 10),
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

  /// RECENT TRANSACTIONS HEADER
  Widget _buildRecentHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Recent Transactions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

 Widget _buildTransactionList() {
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
                            amount:
                                "₹${tx.amount.abs().toStringAsFixed(0)}",
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
