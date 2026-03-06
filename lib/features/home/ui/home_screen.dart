import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';

import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
// 🎯 1. Import your real AuthService instead of mock_auth
import 'package:front_end/core/services/mock_auth.dart'; 
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  // 🎯 2. You can remove userId from the constructor if you fetch it via Auth
  const HomeScreen({super.key});

  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- STATE ---
  String? _currentUserId;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 🎯 3. Start by verifying auth before fetching data
    _initializeUserAndData();
  }

  // 🎯 4. NEW AUTH LOGIC
   
      Future<void> _initializeUserAndData() async {
    try {
      // Use your mock method with the 1-second fake delay
      final userId = await MockAuthService.simulateLogin(); 
      
      if (mounted) {
        setState(() => _currentUserId = userId);
      }

      if (mounted) {
        setState(() => _currentUserId = userId);
      }

      // Proceed to fetch transaction data now that we have the real userId
      await _fetchData(userId);

    } catch (e) {
      debugPrint("Auth Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Authentication failed. Please log in again.";
        });
      }
    }
  }

 Future<void> _fetchData(String userId) async {
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to load transactions.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔥 FIXED: Completely rebuilt the broken widget tree
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _fetchData(_currentUserId ?? ''),
        color: const Color(0xFFB81414),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              BalanceCard(userId: _currentUserId ?? ''),
              const SizedBox(height: 10),
              const QuickActionsSection(),
              const SizedBox(height: 25),

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

  // ... _buildHeader and _buildRecentHeader remain the same ...
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF620E0E), 
          Color(0xFFB81414)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Wallet Care", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
          ),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              ),
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xFFB81414)),
            ),
          ),
        ],
      ),
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
    child: SizedBox(
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