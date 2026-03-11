import 'package:flutter/material.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:intl/intl.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
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
                if (_currentUserId != null)
                  BalanceCard(userId: _currentUserId!),

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
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: -0.5),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen()));
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
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionListScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Row(
              children: [
                Text(
                  "See All",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.blueAccent,
                ),
              ],
            ),
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
        child: Center(
          child: CircularProgressIndicator(color: Colors.black87),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          "No recent transactions",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount:
          _recentTransactions.length > 5 ? 5 : _recentTransactions.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (context, index) {
        final tx = _recentTransactions[index];

        bool isIncome = tx.type == "income";
        bool isReserved = tx.direction == "GOAL_ALLOCATION";

        Color moneyColor =
            isIncome ? Colors.green : (isReserved ? Colors.blue : Colors.red);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              /// ICON
              CircleAvatar(
                radius: 22,
                backgroundColor: _getTransactionColor(tx).withOpacity(0.1),
                child: Icon(
                  _getTransactionIcon(tx),
                  color: _getTransactionColor(tx),
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              /// TITLE + DATE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "•",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tx.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// AMOUNT + ACCOUNT
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${isIncome ? '+' : '-'}₹${tx.amount.abs().toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: moneyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      tx.accountType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getTransactionColor(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") {
      return Colors.blue;
    }

    if (tx.type == "income") {
      return Colors.green;
    }

    if (tx.type == "transfer") {
      return Colors.grey;
    }

    return Colors.red;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") {
      return Icons.flag;
    }

    if (tx.type == "income") {
      return Icons.trending_up;
    }

    if (tx.type == "transfer") {
      return Icons.sync_alt;
    }

    return Icons.trending_down;
  }
}
