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

    List<AccountModel> fetchedAccounts = [];

    try {
      final Map<String, dynamic> accountData =
          await AccountService.getAccountDashboard();

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
          colorScheme.primary));
    }
    if (selectedCategory != "All") {
      chips.add(_buildChip(
          selectedCategory,
          () => setState(() => selectedCategory = "All"),
          chipBgColor,
          colorScheme.primary));
    }
    if (selectedAccountName != "All Accounts") {
      chips.add(_buildChip(selectedAccountName, () {
        setState(() => selectedAccountName = "All Accounts");
        _fetchData();
      }, chipBgColor, colorScheme.primary));
    }
    if (startDate != null && endDate != null) {
      final dateRange =
          "${DateFormat('MMM d').format(startDate!)} - ${DateFormat('MMM d').format(endDate!)}";
      chips.add(_buildChip(
          dateRange,
          () => setState(() {
                startDate = null;
                endDate = null;
              }),
          chipBgColor,
          colorScheme.primary));
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

  Widget _buildTransactionTile(
    TransactionModel tx,
    ThemeData theme,
    ColorScheme colorScheme,
    Color textSec,
    bool isCash,
  ) {
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
                    color: tx.isCancelled ? textSec : colorScheme.primary,
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
                  color: tx.isCancelled || tx.status == "VOIDED"
                      ? textSec
                      : moneyColor,
                  decoration: tx.status == "VOIDED"
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                      isCash
                          ? Icons.account_balance_wallet_rounded
                          : Icons.account_balance_rounded,
                      size: 11,
                      color: textSec.withOpacity(0.8)),
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
              // ── Cancelled badge ──
              if (tx.isCancelled) ...[
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cancel_outlined, size: 10, color: Colors.red),
                      SizedBox(width: 4),
                      Text(
                        "Cancelled",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
      ThemeData theme, ColorScheme colorScheme, bool isDark, Color textSec) {
    final list = _transactions;

    if (list.isEmpty && !_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Icon(Icons.receipt_long_outlined, size: 64, color: textSec),
          const SizedBox(height: 16),
          Center(
            child: Text("No transactions found",
                style: TextStyle(
                    fontSize: 16,
                    color: textSec,
                    fontWeight: FontWeight.w500)),
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
          return const SizedBox(height: 80);
        }

        final tx = list[i];
        final isCash = tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        // Group header logic
        bool showHeader = false;
        if (i == 0) {
          showHeader = true;
        } else {
          final prevTx = list[i - 1];
          final currentDay =
              DateTime(tx.date.year, tx.date.month, tx.date.day);
          final prevDay = DateTime(
              prevTx.date.year, prevTx.date.month, prevTx.date.day);
          if (!currentDay.isAtSameMomentAs(prevDay)) {
            showHeader = true;
          }
        }

        Widget tileContent = Column(
          children: [
            _buildTransactionTile(tx, theme, colorScheme, textSec, isCash),
            Divider(
                color: theme.dividerColor.withOpacity(0.05), height: 1),
          ],
        );

        if (showHeader) {
          String headerText;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          final txDate =
              DateTime(tx.date.year, tx.date.month, tx.date.day);

          if (txDate.isAtSameMomentAs(today)) {
            headerText = "Today";
          } else if (txDate.isAtSameMomentAs(yesterday)) {
            headerText = "Yesterday";
          } else if (txDate.year == now.year) {
            headerText = DateFormat('EEEE, dd MMM').format(tx.date);
          } else {
            headerText = DateFormat('dd MMM, yyyy').format(tx.date);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 28.0, bottom: 12.0, left: 4),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      headerText.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: headerText == "Today"
                            ? colorScheme.secondary
                            : textSec.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
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
        }

        return tileContent;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
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
                              contentPadding: const EdgeInsets.symmetric(
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
                              color: surfaceAlt,
                              borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.tune,
                              color: colorScheme.primary),
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