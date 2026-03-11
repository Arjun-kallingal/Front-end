import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';

// Import your custom widgets
import 'balance_card.dart';
import 'quick_action_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentUserId;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUserAndData();
  }

  /// AUTH + DATA LOAD
  Future<void> _initializeUserAndData() async {
    try {
      final userId = await MockAuthService.simulateLogin();

      if (!mounted) return;

      setState(() {
        _currentUserId = userId;
      });

      await _fetchTransactions(userId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication failed. Please log in again.";
      });
    }
  }

  /// FETCH TRANSACTIONS
  Future<void> _fetchTransactions(String userId) async {
    if (userId.isEmpty) return;

    try {
      final response = await TransactionService.getHistory(userId);

      if (!mounted) return;

      setState(() {
        _recentTransactions = response.transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load transactions.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_currentUserId != null) {
              // This refreshes the transactions. 
              // The BalanceCard refreshes itself automatically!
              await _fetchTransactions(_currentUserId!);
            }
          },
          color: Colors.black87,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                
                // YOUR SMART BALANCE CARD IS PLUGGED IN HERE
                if (_currentUserId != null) BalanceCard(userId: _currentUserId!),
                
                const SizedBox(height: 10),
                const QuickActionsSection(), // Your custom quick actions row
                const SizedBox(height: 20),
                
                _buildRecentHeader(),
                _buildTransactionList(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "WalletCare",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: -0.5),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFF5F5F5),
              child: Icon(Icons.person_outline, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// RECENT TRANSACTIONS HEADER
  Widget _buildRecentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Recent Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          TextButton(
            onPressed: () {
              NavigationService.bottomIndex.value = 3; // Switch to History tab
            },
            child: const Text("See All", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// TRANSACTION LIST
  Widget _buildTransactionList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    if (_errorMessage != null) {
      return Padding(padding: const EdgeInsets.all(30), child: Text(_errorMessage!, style: const TextStyle(color: Colors.grey)));
    }

    if (_recentTransactions.isEmpty) {
      return const Padding(padding: EdgeInsets.all(30), child: Text("No recent transactions", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentTransactions.length > 5 ? 5 : _recentTransactions.length,
      itemBuilder: (context, index) {
        final tx = _recentTransactions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTransactionColor(tx).withOpacity(0.1),
            child: Icon(_getTransactionIcon(tx), color: _getTransactionColor(tx), size: 18),
          ),
          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(tx.subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: Text(
            "₹${tx.amount.abs().toStringAsFixed(0)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: _getTransactionColor(tx)),
          ),
        );
      },
    );
  }

  Color _getTransactionColor(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") return Colors.blueAccent;
    return tx.type == "income" ? Colors.green : Colors.red;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") return Icons.savings_outlined;
    return tx.type == "income" ? Icons.add_circle_outline : Icons.remove_circle_outline;
  }
}