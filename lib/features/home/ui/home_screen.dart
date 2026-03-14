import 'package:flutter/material.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:intl/intl.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentUserId;

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

      await context.read<TransactionProvider>().fetchTransactions(userId);
    } catch (e) {
      debugPrint("Auth Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),

      /// ADD TRANSACTION BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          if (refresh == true && _currentUserId != null) {
            await context
                .read<TransactionProvider>()
                .fetchTransactions(_currentUserId!);
          }
        },
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_currentUserId != null) {
              await context
                  .read<TransactionProvider>()
                  .fetchTransactions(_currentUserId!);
            }
          },
          color: Colors.black87,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),

                /// BALANCE CARD
                if (_currentUserId != null)
                  BalanceCard(userId: _currentUserId!),

                const SizedBox(height: 10),

                /// QUICK ACTIONS
                const QuickActionsSection(),

                const SizedBox(height: 20),

                /// RECENT HEADER
                _buildRecentHeader(),

                /// TRANSACTIONS
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
              letterSpacing: -0.5,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileSettingsScreen(),
                ),
              );
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

  /// RECENT HEADER
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

  /// TRANSACTION LIST (PROVIDER VERSION)
  Widget _buildTransactionList() {
    final provider = context.watch<TransactionProvider>();

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Colors.black87),
        ),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          provider.error!,
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    if (provider.transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          "No recent transactions",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final transactions = provider.transactions;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];

        bool isIncome = tx.type == "income";
        bool isReserved = tx.direction == "GOAL_ALLOCATION";

        Color moneyColor =
            isIncome ? Colors.green : (isReserved ? Colors.blue : Colors.red);

        bool isCash = tx.accountName.toLowerCase().contains('cash');

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

              /// TITLE + DATE + DESCRIPTION
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
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

                    /// DATE + DESCRIPTION
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text("•",
                              style: TextStyle(color: Colors.grey.shade400)),
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

                  /// ACCOUNT TYPE
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCash ? Icons.wallet : Icons.account_balance,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tx.accountName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
    if (tx.direction == "GOAL_ALLOCATION") return Colors.blue;
    if (tx.type == "income") return Colors.green;
    if (tx.type == "transfer") return Colors.grey;
    return Colors.red;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") return Icons.ads_click;
    if (tx.type == "income") return Icons.trending_up;
    if (tx.type == "transfer") return Icons.sync_alt;
    return Icons.trending_down;
  }
}
