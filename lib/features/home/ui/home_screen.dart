import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:front_end/core/services/transaction_service.dart';
// 🎯 Import the updated model containing the Response wrapper
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/features/transactions/ui/widget/transaction_card.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // 🎯 UPDATED FETCH LOGIC
  Future<void> _fetchData() async {
    try {
      // getHistory now returns a TransactionHistoryResponse object
      final response = await TransactionService.getHistory(userId);
      
      if (mounted) {
        setState(() {
          // 🎯 We extract the list from the .transactions property
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchData,
                color: const Color(0xFFB81414),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      const BalanceCard(),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 70),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF620E0E), Color(0xFFB81414)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Welcome Syamjith", 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
          const Text("Recent Transactions", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    // 🎯 Logic to handle Reserved/Income/Expense visual types
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