import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'filter_screen.dart';
// Make sure this import points to your FilterScreen file

class TransactionListScreen extends StatefulWidget {
  final String? initialAccountName; // Added to receive data from the dashboard

  const TransactionListScreen({super.key, this.initialAccountName});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final Color primaryRed = const Color(0xFFB81414);
  final Color goalBlue = const Color(0xFF1976D2);
  final Color textMuted = const Color(0xFF757575);

  /// FILTER VALUES
  String selectedType = "All Type";
  String selectedCategory = "All";
  late String selectedAccountName;
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  bool _isLoading = true;
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];

  @override
  void initState() {
    super.initState();
    selectedAccountName = widget.initialAccountName ?? "All Accounts";
    _fetchData();
  }

  /// FETCH DATA
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final userId = MockAuthService.currentUserId;

    if (userId.isEmpty) {
      if (mounted) _showSnackBar("User not logged in!", isError: true);
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Fetch accounts
      final Map<String, dynamic> accountData =
          await AccountService.getAccountDashboard(userId);

      // FIX: Safely extract the pre-parsed list without using .from()
      final List<AccountModel> fetchedAccounts =
          (accountData['accounts'] as List<dynamic>?)?.cast<AccountModel>() ??
              [];

      // 2. Resolve account name to ID
      String? resolvedAccountId;
      if (selectedAccountName != "All Accounts" && fetchedAccounts.isNotEmpty) {
        try {
          resolvedAccountId = fetchedAccounts
              .firstWhere((a) => a.name == selectedAccountName)
              .id;
        } catch (e) {
          debugPrint("Account name not found in list: $e");
          resolvedAccountId = null;
        }
      }

      // 3. Fetch transactions
      final historyData = await TransactionService.getHistory(userId,
          accountId: resolvedAccountId);

      if (mounted) {
        setState(() {
          _accounts = fetchedAccounts;
          _transactions = historyData.transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("HISTORY FETCH ERROR: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load history: $e", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// OPEN FILTER SCREEN
  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          selectedType: selectedType,
          selectedCategory: selectedCategory,
          selectedAccountName: selectedAccountName,
          startDate: startDate,
          endDate: endDate,
          availableAccounts: _accounts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedType = result["type"];
        selectedCategory = result["category"];
        selectedAccountName = result["account"];
        startDate = result["startDate"];
        endDate = result["endDate"];
      });
      _fetchData();
    }
  }

  Widget _getTransactionLeading(TransactionModel tx) {
    if (tx.direction == "GOAL_ALLOCATION") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: goalBlue.withOpacity(0.1),
        child: const Icon(Icons.ads_click, color: Colors.blue, size: 20),
      );
    }

    if (tx.type == "income") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green.withOpacity(0.1),
        child: const Icon(Icons.trending_up, color: Colors.green, size: 20),
      );
    }

    if (tx.type == "transfer") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.withOpacity(0.15),
        child: const Icon(Icons.sync_alt, color: Colors.grey, size: 20),
      );
    }

    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryRed.withOpacity(0.1),
      child: Icon(Icons.trending_down, color: primaryRed, size: 20),
    );
  }

  /// ACTIVE FILTER CHIPS
  Widget _buildActiveFilters() {
    List<Widget> chips = [];

    if (selectedType != "All Type") {
      chips.add(_buildChip(
          selectedType,
          () => setState(() {
                selectedType = "All Type";
              })));
    }

    if (selectedCategory != "All") {
      chips.add(_buildChip(
          selectedCategory,
          () => setState(() {
                selectedCategory = "All";
              })));
    }

    if (selectedAccountName != "All Accounts") {
      chips.add(_buildChip(selectedAccountName, () {
        setState(() => selectedAccountName = "All Accounts");
        _fetchData();
      }));
    }

    if (startDate != null && endDate != null) {
      String dateRange =
          "${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}";
      chips.add(_buildChip(
          dateRange,
          () => setState(() {
                startDate = null;
                endDate = null;
              })));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: chips),
      ),
    );
  }

  Widget _buildChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "History",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  /// SEARCH + FILTER BAR
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() => searchQuery = v),
                            decoration: InputDecoration(
                              hintText: "Search transactions...",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade600),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _openFilters,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  _buildActiveFilters(),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black87))
                  : RefreshIndicator(
                      color: Colors.black87,
                      onRefresh: () => _fetchData(),
                      child: _buildTransactionList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    final list = _transactions.where((tx) {
      final mSearch =
          tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              tx.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
      final mCat = selectedCategory == "All" || tx.category == selectedCategory;

      bool mType = true;
      if (selectedType == "Income") {
        mType = tx.type == "income";
      } else if (selectedType == "Expense") {
        mType = tx.type == "expense" && tx.direction != "GOAL_ALLOCATION";
      } else if (selectedType == "Reserved") {
        mType = tx.direction == "GOAL_ALLOCATION";
      } else if (selectedType == "Transfer") {
        mType = tx.type == "transfer";
      }

      bool mDate = true;
      if (startDate != null && endDate != null) {
        mDate = tx.date.isAfter(startDate!.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(endDate!.add(const Duration(days: 1)));
      }

      return mSearch && mCat && mType && mDate;
    }).toList();

    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No transactions found",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (context, index) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (context, i) {
        final tx = list[i];
        bool isIncome = tx.type == 'income';
        bool isReserved = tx.direction == "GOAL_ALLOCATION";
        Color moneyColor =
            isIncome ? Colors.green : (isReserved ? goalBlue : primaryRed);
        bool isCash = tx.accountName.toLowerCase().contains('cash');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              _getTransactionLeading(tx),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style: TextStyle(color: textMuted, fontSize: 12),
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text("•",
                              style: TextStyle(color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tx.subtitle,
                              style: TextStyle(color: textMuted, fontSize: 12),
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
                    
                    "₹${tx.amount.abs().toStringAsFixed(0)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: moneyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCash ? Icons.wallet : Icons.account_balance,
                        size: 12,
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
              )
            ],
          ),
        );
      },
    );
  }
}
