import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/account_service.dart';
import 'filter_screen.dart';
import 'package:front_end/core/constants/app_colors.dart';

class TransactionListScreen extends StatefulWidget {
  final String? accountId;

  const TransactionListScreen({super.key, this.accountId});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String selectedType = "All Type";
  String selectedCategory = "All";
  String selectedAccountName = "All Accounts";
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _isFirstLoad = true;
  String? _nextCursor;
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_isLoading && !_isFetchingMore) {
          _fetchMore();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _nextCursor = null;
      _transactions = [];
    });

    // 1. Declare the variable HERE, at the top of the function
    List<AccountModel> fetchedAccounts = [];

    try {
      final Map<String, dynamic> accountData =
          await AccountService.getAccountDashboard();

      // 2. Assign the value (don't use 'final' or 'List' here again)
      fetchedAccounts =
          (accountData['accounts'] as List<dynamic>?)?.cast<AccountModel>() ??
              [];

      if (_isFirstLoad &&
          widget.accountId != null &&
          fetchedAccounts.isNotEmpty) {
        try {
          selectedAccountName =
              fetchedAccounts.firstWhere((a) => a.id == widget.accountId).name;
        } catch (e) {
          debugPrint("Account ID not found in list: $e");
        }
        _isFirstLoad = false;
      }

      String? resolvedAccountId;
      // 3. Now this block can see 'fetchedAccounts' perfectly!
      if (selectedAccountName != "All Accounts" && fetchedAccounts.isNotEmpty) {
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
        accountId: resolvedAccountId,
        category: selectedCategory,
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
      );

      if (mounted) {
        setState(() {
          _accounts = fetchedAccounts;
          _transactions = historyData.transactions;
          // Apply the sort we discussed to keep the Today -> Yesterday order
          _transactions.sort((a, b) => b.date.compareTo(a.date));
          _nextCursor = historyData.nextCursor;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("HISTORY FETCH ERROR: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load history.", isError: true);
      }
    }
  }

  Future<void> _fetchMore() async {
    if (_isFetchingMore || _nextCursor == null) return;
    setState(() => _isFetchingMore = true);

    try {
      String? resolvedAccountId;
      if (selectedAccountName != "All Accounts" && _accounts.isNotEmpty) {
        try {
          resolvedAccountId =
              _accounts.firstWhere((a) => a.name == selectedAccountName).id;
        } catch (_) {}
      }

      final historyData = await TransactionService.getHistory(
        accountId: resolvedAccountId,
        category: selectedCategory,
        type: selectedType,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        lastId: _nextCursor,
      );

      if (mounted) {
        setState(() {
          _transactions.addAll(historyData.transactions);
          // Re-sort the entire list after adding new items
          _transactions.sort((a, b) => b.date.compareTo(a.date));

          _nextCursor = historyData.nextCursor;
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
        content: Text(message,
            style: const TextStyle(
                color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

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
      final newAccount = result["account"] as String;
      final accountChanged = newAccount != selectedAccountName;

      setState(() {
        selectedType = result["type"] as String;
        selectedCategory = result["category"] as String;
        selectedAccountName = newAccount;
        startDate = result["startDate"] as DateTime?;
        endDate = result["endDate"] as DateTime?;
      });

      // Re-fetch from server only when the account filter changes,
      // because account filtering is done server-side.
      // All other filters (type, category, date, search) are client-side.
      if (accountChanged) {
        _fetchData();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // FILTERING LOGIC (client-side)
  // ---------------------------------------------------------------------------

  /// Returns true if [tx] passes the type filter.
  bool _matchesType(TransactionModel tx) {
    switch (selectedType) {
      case "All Type":
        return true;

      case "Income":
        // Only standard income transactions
        return tx.type == "INCOME";

      case "Expense":
        // Expense, but exclude goal allocations / completions which are
        // shown under their own "Reserved" bucket.
        return tx.type == "EXPENSE" &&
            tx.direction != "GOAL_ALLOCATION" &&
            tx.direction != "GOAL_COMPLETION";

      case "Reserved":
        // Anything that moves money into or out of the reserve/goal envelope
        return tx.direction == "GOAL_ALLOCATION" ||
            tx.direction == "GOAL_DEALLOCATION" ||
            tx.direction == "GOAL_COMPLETION" ||
            tx.direction == "RESERVED_IN" ||
            tx.direction == "RESERVED_OUT";

      case "Transfer":
        return tx.type == "TRANSFER" ||
            tx.direction == "ACCOUNT_TRANSFER_IN" ||
            tx.direction == "ACCOUNT_TRANSFER_OUT";

      default:
        return true;
    }
  }

  /// Returns true if [tx] passes the category filter.
  bool _matchesCategory(TransactionModel tx) {
    if (selectedCategory == "All") return true;
    // Case-insensitive exact match
    return tx.category.toLowerCase() == selectedCategory.toLowerCase();
  }

  /// Returns true if [tx] passes the account filter.
  bool _matchesAccount(TransactionModel tx) {
    if (selectedAccountName == "All Accounts") return true;
    return tx.accountName == selectedAccountName;
  }

  /// Returns true if [tx] falls within the selected date range.
  /// Supports open-ended ranges (only startDate or only endDate set).
  bool _matchesDate(TransactionModel tx) {
    if (startDate == null && endDate == null) return true;

    final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

    if (startDate != null && endDate != null) {
      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      return !txDate.isBefore(start) && !txDate.isAfter(end);
    }

    if (startDate != null) {
      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
      return !txDate.isBefore(start);
    }

    // endDate != null only
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
    return !txDate.isAfter(end);
  }

  /// Returns true if [tx] matches the search query.
  bool _matchesSearch(TransactionModel tx) {
    if (searchQuery.isEmpty) return true;
    final q = searchQuery.toLowerCase();
    return tx.title.toLowerCase().contains(q) ||
        tx.subtitle.toLowerCase().contains(q) ||
        tx.category.toLowerCase().contains(q) ||
        tx.accountName.toLowerCase().contains(q);
  }

  /// Master filter – combines all sub-filters.
  List<TransactionModel> get _filteredTransactions {
    return _transactions.where((tx) {
      return _matchesType(tx) &&
          _matchesCategory(tx) &&
          _matchesAccount(tx) &&
          _matchesDate(tx) &&
          _matchesSearch(tx);
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  Color _getTransactionColor(TransactionModel tx) {
    switch (tx.direction) {
      case "GOAL_ALLOCATION":
        return AppColors.savingsPrimary;
      case "GOAL_DEALLOCATION":
        return AppColors.progressGreen;
      case "GOAL_COMPLETION":
        return AppColors.chartIncome;
      case "ACCOUNT_TRANSFER_IN":
        return AppColors.incomeAmount;
      case "ACCOUNT_TRANSFER_OUT":
        return AppColors.dateLabel;
      case "RESERVED_IN":
        return AppColors.warning;
      case "RESERVED_OUT":
        return AppColors.incomeAmount;
      case "REVERSAL":
        return AppColors.warning;
    }

    if (tx.type == "INCOME") return AppColors.incomeAmount;
    if (tx.type == "EXPENSE") return AppColors.expenseAmount;
    if (tx.type == "REVERSAL") return AppColors.warning;
    if (tx.type == "TRANSFER") return AppColors.dateLabel;

    return AppColors.expenseAmount;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    switch (tx.direction) {
      case "GOAL_ALLOCATION":
        return Icons.savings_rounded;
      case "GOAL_DEALLOCATION":
        return Icons.savings_outlined;
      case "GOAL_COMPLETION":
        return Icons.task_alt_rounded;
      case "ACCOUNT_TRANSFER_IN":
        return Icons.call_received_rounded;
      case "ACCOUNT_TRANSFER_OUT":
        return Icons.call_made_rounded;
      case "RESERVED_IN":
        return Icons.lock_outline_rounded;
      case "RESERVED_OUT":
        return Icons.lock_open_rounded;
      case "REVERSAL":
        return Icons.undo_rounded;
    }

    switch (tx.type) {
      case "INCOME":
        return Icons.trending_up_rounded;
      case "EXPENSE":
        return Icons.trending_down_rounded;
      case "TRANSFER":
        return Icons.swap_horiz_rounded;
      case "REVERSAL":
        return Icons.undo_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Widget _getTransactionLeading(TransactionModel tx) {
    final color = _getTransactionColor(tx);
    final icon = _getTransactionIcon(tx);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 0.8, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        );
      },
    );
  }

  Widget _buildActiveFilters(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final List<Widget> chips = [];
    final chipBgColor =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    if (selectedType != "All Type") {
      chips.add(_buildChip(
        selectedType,
        () => setState(() => selectedType = "All Type"),
        chipBgColor,
        colorScheme.primary,
      ));
    }
    if (selectedCategory != "All") {
      chips.add(_buildChip(
        selectedCategory,
        () => setState(() => selectedCategory = "All"),
        chipBgColor,
        colorScheme.primary,
      ));
    }
    if (selectedAccountName != "All Accounts") {
      chips.add(_buildChip(
        selectedAccountName,
        () {
          setState(() => selectedAccountName = "All Accounts");
          _fetchData(); // account filter is server-side, must re-fetch
        },
        chipBgColor,
        colorScheme.primary,
      ));
    }

    // Show a date chip for every combination: only start, only end, or both
    if (startDate != null || endDate != null) {
      final String dateLabel;
      if (startDate != null && endDate != null) {
        dateLabel =
            "${DateFormat('MMM d').format(startDate!)} – ${DateFormat('MMM d').format(endDate!)}";
      } else if (startDate != null) {
        dateLabel = "From ${DateFormat('MMM d').format(startDate!)}";
      } else {
        dateLabel = "Until ${DateFormat('MMM d').format(endDate!)}";
      }

      chips.add(_buildChip(
        dateLabel,
        () => setState(() {
          startDate = null;
          endDate = null;
        }),
        chipBgColor,
        colorScheme.primary,
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

  Widget _buildChip(
      String label, VoidCallback onRemove, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        deleteIcon: Icon(Icons.close, size: 16, color: textColor),
        onDeleted: onRemove,
        backgroundColor: bgColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), side: BorderSide.none),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionModel tx, ThemeData theme,
      ColorScheme colorScheme, Color textSec, bool isCash) {
    final Color moneyColor = _getTransactionColor(tx);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _getTransactionLeading(tx),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.primary,
                    decoration: tx.status == "VOIDED"
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (tx.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    tx.subtitle,
                    style: TextStyle(
                      color: textSec,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "₹${tx.amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: tx.status == "VOIDED" ? textSec : moneyColor,
                  decoration:
                      tx.status == "VOIDED" ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
<<<<<<< HEAD
                    isCash
                        ? Icons.account_balance_wallet_rounded
                        : Icons.account_balance_rounded,
                    size: 11,
                    color: textSec.withOpacity(0.8),
                  ),
=======
                      isCash
                          ? Icons.account_balance_wallet_rounded
                          : Icons.account_balance_rounded,
                      size: 11,
                      color: textSec.withOpacity(0.8)),
>>>>>>> 54294a87c30e67186da1073454db82b0ff8bf0d5
                  const SizedBox(width: 4),
                  Text(
                    tx.accountName,
                    style: TextStyle(
                      fontSize: 11,
                      color: textSec.withOpacity(0.8),
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
  }

  Widget _buildTransactionList(
      ThemeData theme, ColorScheme colorScheme, bool isDark, Color textSec) {
<<<<<<< HEAD
    final list = _filteredTransactions;

    if (list.isEmpty) {
=======
    // 1. USE THE LIST DIRECTLY (Server already filtered this for you)
    final list = _transactions;

    if (list.isEmpty && !_isLoading) {
>>>>>>> 54294a87c30e67186da1073454db82b0ff8bf0d5
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.receipt_long_outlined, size: 64, color: textSec),
          const SizedBox(height: 16),
          Center(
            child: Text("No transactions found",
                style: TextStyle(
                    fontSize: 16, color: textSec, fontWeight: FontWeight.w500)),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: list.length + 1,
      itemBuilder: (context, i) {
        if (i == list.length) {
          if (_isFetchingMore) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(
                      color: colorScheme.secondary, strokeWidth: 2)),
            );
          }
          return const SizedBox(height: 80); // Bottom padding
        }

        final tx = list[i];
        final isCash = tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        // 2. LOGIC FOR HEADERS (Group by transactedAt)
        bool showHeader = false;
        if (i == 0) {
          showHeader = true;
        } else {
          final prevTx = list[i - 1];

          // Normalize both to midnight to compare just the "Calendar Day"
          final currentDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final prevDay =
              DateTime(prevTx.date.year, prevTx.date.month, prevTx.date.day);

          // Use !isAtSameMomentAs for a bulletproof comparison
          if (!currentDay.isAtSameMomentAs(prevDay)) {
            showHeader = true;
          }
        }

        Widget tileContent = Column(
          children: [
            _buildTransactionTile(tx, theme, colorScheme, textSec, isCash),
            Divider(color: theme.dividerColor.withOpacity(0.05), height: 1),
          ],
        );
      if (showHeader) {
  String headerText;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

<<<<<<< HEAD
        if (showHeader) {
          String headerText;
          final today = DateTime.now();
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final todayDate =
              DateTime(today.year, today.month, today.day);
          final yesterdayDate = todayDate.subtract(const Duration(days: 1));

          if (txDate == todayDate) {
            headerText = "Today";
          } else if (txDate == yesterdayDate) {
            headerText = "Yesterday";
          } else {
            headerText = DateFormat('dd MMM, yyyy').format(tx.date);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: Text(
                  headerText,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textSec),
                ),
=======
  // 1. Logic for Smart Date Labels
  if (txDate.isAtSameMomentAs(today)) {
    headerText = "Today";
  } else if (txDate.isAtSameMomentAs(yesterday)) {
    headerText = "Yesterday";
  } else if (txDate.year == now.year) {
    headerText = DateFormat('EEEE, dd MMM').format(tx.date); // e.g., "Friday, 17 Apr"
  } else {
    headerText = DateFormat('dd MMM, yyyy').format(tx.date); // e.g., "17 Apr, 2025"
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 28.0, bottom: 12.0, left: 4),
        child: Row(
          children: [
            // A small dot to represent the timeline point
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.5),
                shape: BoxShape.circle,
>>>>>>> 54294a87c30e67186da1073454db82b0ff8bf0d5
              ),
            ),
            const SizedBox(width: 10),
            Text(
              headerText.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                // Using a slightly more vibrant color for the "Today" header
                color: headerText == "Today" 
                    ? colorScheme.secondary 
                    : textSec.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 8),
            // A subtle line that fills the rest of the width
            Expanded(
              child: Divider(
                color: theme.dividerColor.withOpacity(0.05),
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      tileContent,
    ],
  );
}        return tileContent;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
    final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        icon: Icon(Icons.arrow_back_ios_new,
                            size: 18, color: colorScheme.primary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "History",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: colorScheme.primary,
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
                              color: surfaceAlt,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextField(
                            onChanged: (v) =>
                                setState(() => searchQuery = v),
                            style: TextStyle(color: colorScheme.primary),
                            decoration: InputDecoration(
                              hintText: "Search transactions...",
                              hintStyle: TextStyle(color: textSec),
                              prefixIcon:
                                  Icon(Icons.search, color: textSec),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
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
                              color: surfaceAlt,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.tune, color: colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                  _buildActiveFilters(theme, colorScheme, isDark),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.secondary))
                  : RefreshIndicator(
                      color: colorScheme.secondary,
                      backgroundColor: colorScheme.surface,
                      onRefresh: _fetchData,
                      child: _buildTransactionList(
                          theme, colorScheme, isDark, textSec),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
