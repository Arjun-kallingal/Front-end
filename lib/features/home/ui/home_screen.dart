import 'package:flutter/material.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'balance_card.dart';
import 'quick_action_section.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';

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

      await _fetchData(userId);
    } catch (e) {
      debugPrint("Auth Error: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication failed. Please log in again.";
      });
    }
  }

  /// FETCH TRANSACTIONS
  Future<void> _fetchData(String userId) async {
    if (userId.isEmpty) return;

    try {
      final response = await TransactionService.getHistory(userId);

      if (!mounted) return;

      setState(() {
        _recentTransactions = response.transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Home Fetch Error: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load transactions.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            if (_currentUserId != null) {
              await _fetchData(_currentUserId!);
            }
          },
          color: const Color.fromARGB(255, 247, 245, 245),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                BalanceCard(userId: _currentUserId ?? ''),
                const SizedBox(height: 10),
                const QuickActionsSection(),
                const SizedBox(height: 20),
                _buildRecentHeader(theme),
                // _buildTransactionList(theme),
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 235, 231, 231),
            Color.fromARGB(255, 246, 243, 243)
          ],
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
                color: Color.fromARGB(255, 250, 7, 7),
                fontWeight: FontWeight.bold,
                fontSize: 20),
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
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Color(0xFFB81414),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// RECENT HEADER
  Widget _buildRecentHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Recent Transactions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              NavigationService.bottomIndex.value = 3;
            },
            child: const Text(
              "See All",
              style: TextStyle(color: Color(0xFFB81414)),
            ),
          ),
        ],
      ),
    );
  }

  /// TRANSACTION LIST
//   Widget _buildTransactionList(ThemeData theme) {
//     if (_isLoading) {
//       return const Padding(
//         padding: EdgeInsets.all(30),
//         child: CircularProgressIndicator(
//           color: Color(0xFFB81414),
//         ),
//       );
//     }

//     if (_errorMessage != null) {
//       return Padding(
//         padding: const EdgeInsets.all(20),
//         child: Text(_errorMessage!),
//       );
//     }

//     if (_recentTransactions.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.all(20),
//         child: Text("No transactions yet"),
//       );
//     }

//     return Column(
//       children: _recentTransactions
//           .take(5)
//           .map(
//             (tx) => TransactionCard(
//               title: tx.title,
//               subtitle: tx.subtitle,
//               amount: "₹${tx.amount.abs().toStringAsFixed(0)}",
//               date: tx.date,
//               type: tx.direction == "GOAL_ALLOCATION"
//                   ? TransactionType.reserved
//                   : (tx.type == "income"
//                       ? TransactionType.income
//                       : TransactionType.expense),
//             ),
//           )
//           .toList(),
//     );
//   }
}
