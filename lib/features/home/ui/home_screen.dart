import 'package:flutter/material.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'package:intl/intl.dart';

import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/models/transaction_model.dart';
import '../../analytics/provider/analytics_provider.dart';
import '../../../core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    // ✅ No userId needed — JWT handles identity
    Future.microtask(() {
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 252, 252),

      // ── ADD TRANSACTION BUTTON ─────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );

          // ✅ No userId check needed
          if (refresh == true && mounted) {
            await context.read<TransactionProvider>().fetchTransactions();
          }
        },
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // ✅ No userId check needed
            await context.read<TransactionProvider>().fetchTransactions();
          },
          color: Colors.black87,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),

                // ── BALANCE CARD ─────────────────────────────────────────
                const BalanceCard(),   // ✅ No userId passed

                const SizedBox(height: 10),


                _buildRecentHeader(),
                _buildTransactionList(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────

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


  // ── RECENT HEADER ─────────────────────────────────────────────────────────

  Widget _buildRecentHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(
              fontSize:   16,
              fontWeight: FontWeight.w700,
              color:      Colors.black87,
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
                    color:      Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.blueAccent),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TRANSACTION LIST ──────────────────────────────────────────────────────

  Widget _buildTransactionList() {
    final provider = context.watch<TransactionProvider>();

    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(provider.error!, style: const TextStyle(color: Colors.grey)),
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
      separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (context, index) {
        final tx = transactions[index];

        final bool isIncome     = tx.type == 'INCOME';
        final bool isAllocation = tx.direction == 'GOAL_ALLOCATION';
        final bool isDealloc    = tx.direction == 'GOAL_DEALLOCATION';
        final bool isCompletion = tx.direction == 'GOAL_COMPLETION';
        final bool isTransferIn = tx.direction == 'ACCOUNT_TRANSFER_IN';
        final bool isReversal   = tx.type == 'REVERSAL';

        final Color moneyColor = isIncome     ? Colors.green
                               : isAllocation ? const Color(0xFF1976D2)
                               : isDealloc    ? Colors.purple
                               : isCompletion ? Colors.teal
                               : isTransferIn ? Colors.green
                               : isReversal   ? Colors.orange
                               : const Color(0xFFB81414);

        final bool isCash =
            tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize:   15,
                      ),
                      maxLines:  1,
                      overflow:  TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text("•", style: TextStyle(color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tx.subtitle,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${tx.amount.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:   15,
                      color:      moneyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isCash ? Icons.wallet : Icons.account_balance, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        tx.accountName,
                        style: TextStyle(
                          fontSize:   12,
                          color:      Colors.grey.shade800,
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

  // ── HELPERS ───────────────────────────────────────────────────────────────

  Color _getTransactionColor(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION")    return const Color(0xFF1976D2);
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION")  return Colors.purple;
    if (tx.type == "EXPENSE"  && tx.direction == "GOAL_COMPLETION")    return Colors.teal;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN") return Colors.green;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT") return Colors.grey;
    if (tx.type == "INCOME")   return Colors.green;
    if (tx.type == "REVERSAL") return Colors.orange;
    return const Color(0xFFB81414);
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION")     return Icons.savings;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION")   return Icons.savings_outlined;
    if (tx.type == "EXPENSE"  && tx.direction == "GOAL_COMPLETION")     return Icons.task_alt;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN") return Icons.call_received;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT") return Icons.call_made;
    if (tx.type == "INCOME")   return Icons.trending_up;
    if (tx.type == "REVERSAL") return Icons.undo;
    return Icons.trending_down;
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color:        const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}