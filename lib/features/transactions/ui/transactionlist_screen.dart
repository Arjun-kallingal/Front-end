import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/account_service.dart';
import 'package:front_end/core/services/mock_auth.dart';
import 'filter_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final String? initialAccountName;

  const TransactionListScreen({super.key, this.initialAccountName});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final Color primaryRed = const Color(0xFFB81414);
  final Color goalBlue   = const Color(0xFF1976D2);
  final Color textMuted  = const Color(0xFF757575);

  // ── Filter state ──────────────────────────────────────────────────────────
  String selectedType        = "All Type";
  String selectedCategory    = "All";
  late String selectedAccountName;
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  // ── Data state ────────────────────────────────────────────────────────────
  bool _isLoading      = true;
  bool _isFetchingMore = false;
  String? _nextCursor;
  List<TransactionModel> _transactions = [];
  List<AccountModel>     _accounts     = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedAccountName = widget.initialAccountName ?? "All Accounts";
    _fetchData();

    // Trigger next page when user is 200px from the bottom
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ── Full reload ───────────────────────────────────────────────────────────

  Future<void> _fetchData() async {
    setState(() {
      _isLoading    = true;
      _nextCursor   = null;
      _transactions = [];
    });

    final userId = MockAuthService.currentUserId;
    if (userId.isEmpty) {
      if (mounted) _showSnackBar("User not logged in!", isError: true);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final Map<String, dynamic> accountData =
          await AccountService.getAccountDashboard(userId);

      final List<AccountModel> fetchedAccounts =
          (accountData['accounts'] as List<dynamic>?)?.cast<AccountModel>() ??
              [];

      String? resolvedAccountId;
      if (selectedAccountName != "All Accounts" &&
          fetchedAccounts.isNotEmpty) {
        try {
          resolvedAccountId = fetchedAccounts
              .firstWhere((a) => a.name == selectedAccountName)
              .id;
        } catch (e) {
          debugPrint("Account name not found: $e");
          resolvedAccountId = null;
        }
      }

      final historyData = await TransactionService.getHistory(
        userId,
        accountId: resolvedAccountId,
      );

      if (mounted) {
        setState(() {
          _accounts     = fetchedAccounts;
          _transactions = historyData.transactions;
          _nextCursor   = historyData.nextCursor;
          _isLoading    = false;
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

  // ── Load next page ────────────────────────────────────────────────────────

  Future<void> _fetchMore() async {
    if (_isFetchingMore || _nextCursor == null) return;

    setState(() => _isFetchingMore = true);

    try {
      final userId = MockAuthService.currentUserId;

      String? resolvedAccountId;
      if (selectedAccountName != "All Accounts" && _accounts.isNotEmpty) {
        try {
          resolvedAccountId = _accounts
              .firstWhere((a) => a.name == selectedAccountName)
              .id;
        } catch (_) {}
      }

      final historyData = await TransactionService.getHistory(
        userId,
        accountId: resolvedAccountId,
        lastId:    _nextCursor,
      );

      if (mounted) {
        setState(() {
          _transactions.addAll(historyData.transactions);
          _nextCursor     = historyData.nextCursor;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
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

  // ── Filter screen ─────────────────────────────────────────────────────────

  void _openFilters() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          selectedType:        selectedType,
          selectedCategory:    selectedCategory,
          selectedAccountName: selectedAccountName,
          startDate:           startDate,
          endDate:             endDate,
          availableAccounts:   _accounts,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedType        = result["type"];
        selectedCategory    = result["category"];
        selectedAccountName = result["account"];
        startDate           = result["startDate"];
        endDate             = result["endDate"];
      });
      _fetchData();
    }
  }

  // ── Transaction leading icon ──────────────────────────────────────────────

  Widget _getTransactionLeading(TransactionModel tx) {
    // Goal allocation — money moved into goal
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: goalBlue.withOpacity(0.1),
        child: const Icon(Icons.savings, color: Colors.blue, size: 20),
      );
    }

    // Goal deallocation — money returned from goal to available
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.purple.withOpacity(0.1),
        child: const Icon(Icons.savings_outlined,
            color: Colors.purple, size: 20),
      );
    }

    // Goal completion — goal fully funded
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.teal.withOpacity(0.1),
        child: const Icon(Icons.task_alt, color: Colors.teal, size: 20),
      );
    }

    // Transfer in — money received from another account
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green.withOpacity(0.1),
        child: const Icon(Icons.call_received,
            color: Colors.green, size: 20),
      );
    }

    // Transfer out — money sent to another account
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.withOpacity(0.15),
        child: const Icon(Icons.call_made, color: Colors.grey, size: 20),
      );
    }

    if (tx.type == "INCOME") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.green.withOpacity(0.1),
        child: const Icon(Icons.trending_up, color: Colors.green, size: 20),
      );
    }

    if (tx.type == "REVERSAL") {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.orange.withOpacity(0.1),
        child: const Icon(Icons.undo, color: Colors.orange, size: 20),
      );
    }

    // EXPENSE — default
    return CircleAvatar(
      radius: 22,
      backgroundColor: primaryRed.withOpacity(0.1),
      child: Icon(Icons.trending_down, color: primaryRed, size: 20),
    );
  }

  // ── Active filter chips ───────────────────────────────────────────────────

  Widget _buildActiveFilters() {
    final List<Widget> chips = [];

    if (selectedType != "All Type") {
      chips.add(_buildChip(
        selectedType,
        () => setState(() => selectedType = "All Type"),
      ));
    }

    if (selectedCategory != "All") {
      chips.add(_buildChip(
        selectedCategory,
        () => setState(() => selectedCategory = "All"),
      ));
    }

    if (selectedAccountName != "All Accounts") {
      chips.add(_buildChip(selectedAccountName, () {
        setState(() => selectedAccountName = "All Accounts");
        _fetchData();
      }));
    }

    if (startDate != null && endDate != null) {
      final dateRange =
          "${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}";
      chips.add(_buildChip(
        dateRange,
        () => setState(() {
          startDate = null;
          endDate   = null;
        }),
      ));
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
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────────────────────

  Widget _buildTransactionList() {
    final list = _transactions.where((tx) {
      // Search
      final mSearch =
          tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          tx.subtitle.toLowerCase().contains(searchQuery.toLowerCase());

      // Category
      final mCategory = selectedCategory == "All" ||
          tx.category.toLowerCase() == selectedCategory.toLowerCase();

      // Account
      final mAccount = selectedAccountName == "All Accounts" ||
          tx.accountName == selectedAccountName;

      // Type
      bool mType;
      switch (selectedType) {
        case "Income":
          mType = tx.type == "INCOME";
          break;
        case "Expense":
          mType = tx.type == "EXPENSE" &&
              tx.direction != "GOAL_ALLOCATION" &&
              tx.direction != "GOAL_COMPLETION";
          break;
        case "Reserved":
          mType = tx.direction == "GOAL_ALLOCATION";
          break;
        case "Transfer":
          mType = tx.type == "TRANSFER";
          break;
        default:
          mType = true;
      }

      // Date
      bool mDate = true;
      if (startDate != null && endDate != null) {
        final txDate =
            DateTime(tx.date.year, tx.date.month, tx.date.day);
        final start =
            DateTime(startDate!.year, startDate!.month, startDate!.day);
        final end =
            DateTime(endDate!.year, endDate!.month, endDate!.day);
        mDate =
            txDate.isAfter(start.subtract(const Duration(days: 1))) &&
            txDate.isBefore(end.add(const Duration(days: 1)));
      }

      return mSearch && mCategory && mAccount && mType && mDate;
    }).toList();

    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              "No transactions found",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length + 1, // +1 for bottom loader
      separatorBuilder: (_, __) =>
          Divider(color: Colors.grey.shade200, height: 1),
      itemBuilder: (context, i) {
        // Bottom item — spinner or end message
        if (i == list.length) {
          if (_isFetchingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.black87,
                  strokeWidth: 2,
                ),
              ),
            );
          }
          if (_nextCursor == null && list.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  "You have reached the end",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        final tx = list[i];

        final bool isIncome     = tx.type == 'INCOME';
        final bool isAllocation = tx.direction == 'GOAL_ALLOCATION';
        final bool isDealloc    = tx.direction == 'GOAL_DEALLOCATION';
        final bool isCompletion = tx.direction == 'GOAL_COMPLETION';
        final bool isTransferIn = tx.direction == 'ACCOUNT_TRANSFER_IN';
        final bool isReversal   = tx.type == 'REVERSAL';

        final Color moneyColor = isIncome     ? Colors.green
                               : isAllocation ? goalBlue
                               : isDealloc    ? Colors.purple
                               : isCompletion ? Colors.teal
                               : isTransferIn ? Colors.green
                               : isReversal   ? Colors.orange
                               : primaryRed;

        final bool isCash =
            tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style:
                              TextStyle(color: textMuted, fontSize: 12),
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text("•",
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tx.subtitle,
                              style: TextStyle(
                                  color: textMuted, fontSize: 12),
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
                      fontSize: 15,
                      color: moneyColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCash
                            ? Icons.wallet
                            : Icons.account_balance,
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            size: 18),
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
                            onChanged: (v) =>
                                setState(() => searchQuery = v),
                            decoration: InputDecoration(
                              hintText: "Search transactions...",
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500),
                              prefixIcon: Icon(Icons.search,
                                  color: Colors.grey.shade600),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      vertical: 12),
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
                          child: const Icon(Icons.tune,
                              color: Colors.black87),
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
                      child: CircularProgressIndicator(
                          color: Colors.black87))
                  : RefreshIndicator(
                      color: Colors.black87,
                      onRefresh: _fetchData,
                      child: _buildTransactionList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}