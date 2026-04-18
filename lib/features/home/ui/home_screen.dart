import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:front_end/core/constants/app_colors.dart';

import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/models/transaction_model.dart';
import 'package:front_end/core/services/transaction_service.dart';
import 'package:front_end/features/transfer/transfer.dart';
import 'package:front_end/core/providers/account_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import '../../goals/provider/goal_provider.dart';
// Notification imports from Snippet 1
import 'package:front_end/features/notifications/notification_screen.dart';
import 'package:front_end/core/providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProcessing = false;


  List<TransactionModel> _recentTransactions = [];
  bool _isLoadingRecent = true;
  String? _recentError;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await context.read<TransactionProvider>().fetchTransactions();
      context.read<TransactionProvider>().addListener(_onTransactionUpdate);

      // 🔥 INITIALIZE NOTIFICATIONS & SOCKET
      final notifProvider = context.read<NotificationProvider>();
      notifProvider.loadNotifications();
      notifProvider.initializeSocketListeners();
    });
    _loadRecentTransactions();
  }

  void _onTransactionUpdate() {
    print("🔥 TransactionProvider updated - reloading recent");
    if (mounted && !_isLoadingRecent) {
      _loadRecentTransactions();
    }
  }

  // 🔥 Dispose logic from Snippet 2
  @override
  void dispose() {
    context.read<TransactionProvider>().removeListener(_onTransactionUpdate);
    super.dispose();
  }

  Future<void> _loadRecentTransactions() async {
    setState(() {
      _isLoadingRecent = true;
      _recentError = null;
    });

    try {
      final latest = await TransactionService.getLatestTransactions();
      if (mounted) {
        setState(() {
          _recentTransactions = latest;
          _isLoadingRecent = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recentError = e.toString().replaceAll("Exception: ", "");
          _isLoadingRecent = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
                color: AppColors.darkTextPrimary, // From Snippet 2
                fontWeight: FontWeight.w600)),
        backgroundColor:
            isError ? AppColors.expenseAmount : AppColors.incomeAmount,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

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
                      color: AppColors.errorBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 36),
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
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary, // From Snippet 2
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
                  children: [
                    Expanded(
                      child: Text(
                        "Cancel Transaction?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted, // From Snippet 2
                      ),
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
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary, // From Snippet 2
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
                      foregroundColor: AppColors.darkTextPrimary, // From Snippet 2
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      "Confirm Cancel",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      setState(() => _isProcessing = true);

      final result =
          await TransactionService.reverseTransaction(originalTx: tx);

      if (result['success']) {
        await Future.wait([
          context.read<TransactionProvider>().fetchTransactions(),
          context.read<AccountProvider>().loadAccounts(),
          context.read<GoalProvider>().fetchGoals(),
          context.read<AnalyticsProvider>().reload(),
        ]);

        await _loadRecentTransactions();

        setState(() => _isProcessing = false);

        _showSnackBar("Transaction cancelled successfully!");
      } else {
        setState(() => _isProcessing = false);

        _showErrorDialog(
          "Cancellation Failed",
          result['message'] ??
              "An error occurred while cancelling the transaction.",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await context.read<TransactionProvider>().fetchTransactions();
                await _loadRecentTransactions();
                // 🔥 Combined refresh actions
                await context.read<NotificationProvider>().loadNotifications(); 
              },
              color: colorScheme.secondary,
              backgroundColor: colorScheme.surface,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(context, theme, colorScheme, isDark),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: BalanceCard(),
                    ),
                    const SizedBox(height: 28),
                    _buildSectionLabel("Quick Actions", isDark),
                    const SizedBox(height: 12),
                    _buildActionButtons(context, colorScheme, theme),
                    const SizedBox(height: 28),
                    _buildRecentHeader(context, colorScheme, theme, isDark),
                    const SizedBox(height: 8),
                    _buildTransactionList(context, colorScheme, theme, isDark),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),

            if (_isProcessing)
              Container(
                color: AppColors.darkBgPrimary.withOpacity(0.3), // From Snippet 2
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, bool isDark) {
    final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;
    final textSec = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted; // From Snippet 2

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Wallet",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                    TextSpan(
                      text: "Care",
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _greeting(),
                style: TextStyle(color: textSec, fontSize: 13),
              ),
            ],
          ),
          Row(
            children: [
              // ── 🔔 LIVE NOTIFICATION BELL (CONSUMER PATTERN) ── From Snippet 1
              Consumer<NotificationProvider>(
                builder: (context, notifProvider, child) {
                  final unreadCount = notifProvider.unreadCount;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationScreen()),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: colorScheme.primary,
                            size: 26,
                          ),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileSettingsScreen()),
                ),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surfaceAlt,
                    border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.40),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted, // From Snippet 2
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, ColorScheme colorScheme, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.trending_up,
              label: "Income",
              color: AppColors.incomeAmount,
              surfaceColor: colorScheme.surface,
              textColor: colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const AddTransactionScreen(initialIsExpense: false)),
              ).then((_) {
                context.read<TransactionProvider>().fetchTransactions();
                _loadRecentTransactions();
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionButton(
              icon: Icons.trending_down,
              label: "Expense",
              color: AppColors.expenseAmount,
              surfaceColor: colorScheme.surface,
              textColor: colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const AddTransactionScreen(initialIsExpense: true)),
              ).then((_) {
                context.read<TransactionProvider>().fetchTransactions();
                _loadRecentTransactions();
              }),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionButton(
              icon: Icons.swap_horiz_rounded,
              label: "Transfer",
              color: AppColors.transferColor,
              surfaceColor: colorScheme.surface,
              textColor: colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              ).then((_) {
                context.read<TransactionProvider>().fetchTransactions();
                _loadRecentTransactions();
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color surfaceColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.20), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBgPrimary.withOpacity(0.05), // From Snippet 2
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentHeader(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    final surfaceAlt =
        theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Activity",
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionListScreen()),
            ).then((_) {
              context.read<TransactionProvider>().fetchTransactions();
              _loadRecentTransactions();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "See all",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted, // From Snippet 2
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted), // From Snippet 2
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, ColorScheme colorScheme,
      ThemeData theme, bool isDark) {
    final textSec =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted; // From Snippet 2

    if (_isLoadingRecent) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: CircularProgressIndicator(
              color: colorScheme.secondary, strokeWidth: 2),
        ),
      );
    }

    if (_recentError != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            _recentError!,
            style: TextStyle(color: textSec, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, color: textSec, size: 40),
              const SizedBox(height: 12),
              Text(
                "No recent transactions",
                style: TextStyle(color: textSec, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) => _buildTile(
          context, _recentTransactions[index], colorScheme, theme, isDark),
    );
  }

  Widget _buildTile(BuildContext context, TransactionModel tx,
      ColorScheme colorScheme, ThemeData theme, bool isDark) {
    final Color moneyColor = _getTransactionColor(tx);
    final bool isCash = tx.accountName.toLowerCase().contains('cash') ||
        tx.accountName.toLowerCase().contains('wallet');
    final textSec =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted; // From Snippet 2

    bool canReverse = tx.type != "REVERSAL" && tx.status != "VOIDED";

    Widget tileContent = Column(
      children: [
        Padding(
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
                        color: colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: tx.status == "VOIDED"
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          isCash ? Icons.wallet : Icons.account_balance,
                          size: 11,
                          color: textSec,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tx.accountName,
                          style: TextStyle(
                            color: textSec,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text('·', style: TextStyle(color: textSec)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tx.subtitle,
                              style: TextStyle(color: textSec, fontSize: 12),
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${tx.amount.abs().toStringAsFixed(2)}",
                    style: TextStyle(
                      color: tx.status == "VOIDED" ? textSec : moneyColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      decoration: tx.status == "VOIDED"
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM, yyyy').format(tx.date),
                    style: TextStyle(
                      color: textSec,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: theme.dividerColor, height: 1),
      ],
    );

    if (canReverse) {
      tileContent = SwipeToCancelTile(
        onCancelTap: () => _handleReversal(tx),
        child: tileContent,
      );
    }

    return tileContent;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning ☀️";
    if (h < 17) return "Good afternoon 👋";
    return "Good evening 🌙";
  }

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
      return AppColors.dateLabel; // From Snippet 2
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
}

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
          if (_dragExtent > 0) _dragExtent = 0;
          if (_dragExtent < -_maxDrag - 20) _dragExtent = -_maxDrag - 20;
        });
      },
      onHorizontalDragEnd: (details) {
        setState(() {
          if (_dragExtent < -_maxDrag / 2) {
            _dragExtent = -_maxDrag;
          } else {
            _dragExtent = 0.0;
          }
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _dragExtent < -30 ? 1.0 : 0.0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() => _dragExtent = 0.0);
                    widget.onCancelTap();
                  },
                  child: Container(
                    width: _maxDrag,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      color: AppColors.errorBg, // From Snippet 2
                      borderRadius: BorderRadius.only(
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
                          decoration: const BoxDecoration(
                            color: AppColors.expenseIconBg, // From Snippet 2
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragExtent, 0, 0),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}