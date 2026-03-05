import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
// 🎯 1. Import your real AuthService instead of mock_auth
import 'package:front_end/core/services/mock_auth.dart'; 
import 'balance_card.dart';
import 'quick_action_section.dart';

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

    // Show a loading screen while resolving Auth state
    if (_currentUserId == null && _isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator(color: Color(0xFFB81414))),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                // 🎯 6. Update onRefresh to use the current user ID
                onRefresh: () => _fetchData(_currentUserId!), 
                color: const Color(0xFFB81414),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      // 🎯 Pass the dynamically fetched ID down to children
                      BalanceCard(userId: _currentUserId!), 
                      const QuickActionsSection(),
                      const SizedBox(height: 10),
                      _buildRecentHeader(theme),
                      _buildTransactionList(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)
          ),
          GestureDetector(
            onTap: () => NavigationService.bottomIndex.value = 3,
            child: const CircleAvatar(
              backgroundColor: Colors.white24, 
              child: Icon(Icons.person, color: Colors.white)
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
          const Text(
            "Recent Transactions", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          TextButton(
            onPressed: () => NavigationService.bottomIndex.value = 2, 
            child: const Text("See All", style: TextStyle(color: Color(0xFFB81414)))
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 8)],
        ),
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFB81414)))
          : _errorMessage != null // 🎯 Added error handling UI
            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
            : _recentTransactions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("No transactions yet")),
                )
              : Column(
                  children: _recentTransactions.take(5).map((tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: TransactionCard(
                      title: tx.title,
                      subtitle: tx.subtitle,
                      amount: "₹${tx.amount.abs().toStringAsFixed(0)}",
                      type: tx.direction == "GOAL_ALLOCATION" 
                          ? TransactionType.reserved 
                          : (tx.type == "income" ? TransactionType.income : TransactionType.expense),
                    ),
                  )).toList(),
                ),
      ),
    );
  }
}