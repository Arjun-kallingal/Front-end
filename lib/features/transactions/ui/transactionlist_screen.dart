import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/models/account_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/core/services/account_service.dart';
import 'filter_screen.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/providers/account_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import '../../goals/provider/goal_provider.dart';
class TransactionListScreen extends StatefulWidget {
  final String? initialAccountName;

  const TransactionListScreen({super.key, this.initialAccountName});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  // ── Filter state ──────────────────────────────────────────────────────────
  String selectedType = "All Type";
  String selectedCategory = "All";
  late String selectedAccountName;
  DateTime? startDate;
  DateTime? endDate;
  String searchQuery = "";

  // ── Data state ────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isFetchingMore = false;
  String? _nextCursor;
  List<TransactionModel> _transactions = [];
  List<AccountModel> _accounts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedAccountName = widget.initialAccountName ?? "All Accounts";
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

  // ── Full reload ───────────────────────────────────────────────────────────
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _nextCursor = null;
      _transactions = [];
    });

    try {
      final Map<String, dynamic> accountData =
          await AccountService.getAccountDashboard();
      final List<AccountModel> fetchedAccounts =
          (accountData['accounts'] as List<dynamic>?)?.cast<AccountModel>() ??
              [];

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
      );

      if (mounted) {
        setState(() {
          _accounts = fetchedAccounts;
          _transactions = historyData.transactions;
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

  // ── Load next page ────────────────────────────────────────────────────────
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
        lastId: _nextCursor,
      );

      if (mounted) {
        setState(() {
          _transactions.addAll(historyData.transactions);
          _nextCursor = historyData.nextCursor;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetchingMore = false);
    }
  }

  // 🔥 PREMIUM SNACKBAR (Floating with Rounded Corners)
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  // 🔥 PREMIUM ERROR DIALOG (Matches Account Screen UX)
  void _showErrorDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: colorScheme.surface,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.expenseAmount.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        color: AppColors.expenseAmount, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Okay",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  // ── Cancel/Reversal Logic (Premium Top-Right Cancel Dialog) ───────────────
  Future<void> _handleReversal(TransactionModel tx) async {
    final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          final colorScheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: colorScheme.surface,
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cancel Transaction?",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        icon: Icon(Icons.close_rounded,
                            color: colorScheme.onSurface.withOpacity(0.5)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "This will safely cancel the ₹${tx.amount.abs().toStringAsFixed(2)} transaction and instantly update your account balance.",
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expenseAmount,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Confirm Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });

    if (confirm == true) {
  setState(() => _isLoading = true);

  final result =
      await TransactionService.reverseTransaction(originalTx: tx);

 if (result['success']) {

  await Future.wait([
    context.read<TransactionProvider>().fetchTransactions(),
    context.read<AccountProvider>().loadAccounts(),
    context.read<GoalProvider>().fetchGoals(),
    context.read<AnalyticsProvider>().reload(),
  ]);

  // 🔥 refresh THIS screen list
  await _fetchData();

  _showSnackBar("Transaction cancelled successfully!");
}else {
    setState(() => _isLoading = false);

    _showErrorDialog(
      "Cancellation Failed",
      result['message'] ??
          "An error occurred while cancelling the transaction.",
    );
  }
}
  }

  // ── Filter screen ─────────────────────────────────────────────────────────
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

  // ── Helpers for Colors & Icons ────────────────────────────────────────────
  Color _getTransactionColor(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION")
      return AppColors.savingsPrimary;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION")
      return AppColors.progressGreen;
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION")
      return AppColors.chartIncome;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN")
      return AppColors.incomeAmount;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT")
      return AppColors.textSecondary;
    if (tx.type == "INCOME") return AppColors.incomeAmount;
    if (tx.type == "REVERSAL") return AppColors.warning;
    return AppColors.expenseAmount;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION")
      return Icons.savings_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION")
      return Icons.savings_outlined;
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION")
      return Icons.task_alt_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN")
      return Icons.call_received_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT")
      return Icons.call_made_rounded;
    if (tx.type == "INCOME") return Icons.trending_up_rounded;
    if (tx.type == "REVERSAL") return Icons.undo_rounded;
    return Icons.trending_down_rounded;
  }

  Widget _getTransactionLeading(TransactionModel tx) {
    final Color iconColor = _getTransactionColor(tx);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_getTransactionIcon(tx), color: iconColor, size: 20),
    );
  }

  // ── Active filter chips ───────────────────────────────────────────────────
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

  // ── Tile Builder Helper ───────────────────────────────────────────────────
  Widget _buildTransactionTile(TransactionModel tx, ThemeData theme,
      ColorScheme colorScheme, Color textSec, bool isCash) {
    final Color moneyColor = _getTransactionColor(tx);

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
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: colorScheme.primary,
                    decoration: tx.status == "VOIDED"
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(isCash ? Icons.wallet : Icons.account_balance,
                        size: 11, color: textSec),
                    const SizedBox(width: 4),
                    Text(
                      tx.accountName,
                      style: TextStyle(
                          fontSize: 12,
                          color: textSec,
                          fontWeight: FontWeight.w500),
                    ),
                    if (tx.subtitle.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text('·', style: TextStyle(color: textSec)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          tx.subtitle,
                          style: TextStyle(color: textSec, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
        ],
      ),
    );
  }

  // ── Transaction list ──────────────────────────────────────────────────────
  Widget _buildTransactionList(
      ThemeData theme, ColorScheme colorScheme, bool isDark, Color textSec) {
    final list = _transactions.where((tx) {
      final mSearch =
          tx.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
              tx.subtitle.toLowerCase().contains(searchQuery.toLowerCase());
      final mCategory = selectedCategory == "All" ||
          tx.category.toLowerCase() == selectedCategory.toLowerCase();
      final mAccount = selectedAccountName == "All Accounts" ||
          tx.accountName == selectedAccountName;

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

      bool mDate = true;
      if (startDate != null && endDate != null) {
        final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
        final start =
            DateTime(startDate!.year, startDate!.month, startDate!.day);
        final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
        mDate = txDate.isAfter(start.subtract(const Duration(days: 1))) &&
            txDate.isBefore(end.add(const Duration(days: 1)));
      }

      return mSearch && mCategory && mAccount && mType && mDate;
    }).toList();

    if (list.isEmpty) {
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
        // --- 1. Loading / End State ---
        if (i == list.length) {
          if (_isFetchingMore) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: CircularProgressIndicator(
                      color: colorScheme.secondary, strokeWidth: 2)),
            );
          }
          if (_nextCursor == null && list.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                  child: Text("You have reached the end",
                      style: TextStyle(color: textSec, fontSize: 13))),
            );
          }
          return const SizedBox.shrink();
        }

        final tx = list[i];
        final isCash = tx.accountName.toLowerCase().contains('cash') ||
            tx.accountName.toLowerCase().contains('wallet');

        // --- 2. Date Header Logic ---
        bool showHeader = false;
        if (i == 0) {
          showHeader = true;
        } else {
          final prevTx = list[i - 1];
          final currentDay = DateTime(tx.date.year, tx.date.month, tx.date.day);
          final prevDay =
              DateTime(prevTx.date.year, prevTx.date.month, prevTx.date.day);
          if (currentDay != prevDay) showHeader = true;
        }

        // --- 3. Custom Swipe Wrapper ---
        bool canReverse = tx.type != "REVERSAL" && tx.status != "VOIDED";

        Widget tileContent = Column(
          children: [
            _buildTransactionTile(tx, theme, colorScheme, textSec, isCash),
            Divider(color: theme.dividerColor, height: 1),
          ],
        );

        if (canReverse) {
          tileContent = SwipeToCancelTile(
            onCancelTap: () => _handleReversal(tx),
            child: tileContent,
          );
        }

        // --- 4. Return with Header (if needed) ---
        if (showHeader) {
          String headerText;
          final today = DateTime.now();
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

          if (txDate.year == today.year &&
              txDate.month == today.month &&
              txDate.day == today.day) {
            headerText = "Today";
          } else if (txDate.year == today.year &&
              txDate.month == today.month &&
              txDate.day == today.day - 1) {
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
              ),
              tileContent,
            ],
          );
        }

        return tileContent;
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textSec = isDark ? const Color(0xFF8B90A7) : Colors.grey[600]!;
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
                            onChanged: (v) => setState(() => searchQuery = v),
                            style: TextStyle(color: colorScheme.primary),
                            decoration: InputDecoration(
                              hintText: "Search transactions...",
                              hintStyle: TextStyle(color: textSec),
                              prefixIcon: Icon(Icons.search, color: textSec),
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

// ─────────────────────────────────────────────────────────────────────────────
// 🔥 CUSTOM PREMIUM SWIPE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class SwipeToCancelTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onCancelTap;

  const SwipeToCancelTile(
      {Key? key, required this.child, required this.onCancelTap})
      : super(key: key);

  @override
  State<SwipeToCancelTile> createState() => _SwipeToCancelTileState();
}

class _SwipeToCancelTileState extends State<SwipeToCancelTile> {
  double _dragExtent = 0.0;
  final double _maxDrag = 100.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta!;
          if (_dragExtent > 0) _dragExtent = 0; // Prevent swiping right
          if (_dragExtent < -_maxDrag - 20)
            _dragExtent = -_maxDrag - 20; // Add elastic resistance
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          // Snap open if dragged more than halfway, otherwise snap closed
          if (_dragExtent < -_maxDrag / 2) {
            _dragExtent = -_maxDrag;
          } else {
            _dragExtent = 0.0;
          }
        });
      },
      child: Stack(
        children: [
          // 1. Background (The Premium Button)
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity:
                    _dragExtent < -30 ? 1.0 : 0.0, // Fade in as user swipes
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    // Close the swipe drawer instantly upon clicking
                    setState(() => _dragExtent = 0.0);
                    // Fire the cancel dialog
                    widget.onCancelTap();
                  },
                  child: Container(
                    width: _maxDrag,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.expenseAmount.withOpacity(0.12),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.expenseAmount.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.expenseAmount, size: 14),
                        ),
                        const SizedBox(width: 6),
                        const Text("Cancel",
                            style: TextStyle(
                                color: AppColors.expenseAmount,
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Foreground (The actual transaction tile)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragExtent, 0, 0),
            child: Container(
              color: Theme.of(context)
                  .scaffoldBackgroundColor, // Ensure drag covers background
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}
