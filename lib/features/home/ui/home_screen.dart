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
import 'package:front_end/features/transfer/transfer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransactionProvider>().fetchTransactions();
    });
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
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().fetchTransactions();
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
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, ThemeData theme, ColorScheme colorScheme, bool isDark) {
    final surfaceAlt = theme.inputDecorationTheme.fillColor ?? colorScheme.surface;
    final textSec = isDark ? const Color(0xFF8B90A7) : Colors.grey[600];

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
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: colorScheme.primary,
                ),
                onPressed: () {
                  // final provider = context.read<ThemeProvider>();
                  // provider.toggleTheme(!provider.isDark);
                },
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileSettingsScreen()),
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

  // ── SECTION LABEL ─────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF8B90A7) : Colors.grey[600],
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  // ── QUICK ACTION BUTTONS ──────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme, ThemeData theme) {
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
                MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialIsExpense: false)),
              ),
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
                MaterialPageRoute(builder: (_) => const AddTransactionScreen(initialIsExpense: true)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionButton(
              icon: Icons.swap_horiz_rounded,
              label: "Transfer",
              color: const Color.fromARGB(255, 238, 254, 3), 
              surfaceColor: colorScheme.surface,
              textColor: colorScheme.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransferScreen()),
              ),
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
              color: Colors.black.withOpacity(0.05),
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

  // ── RECENT HEADER ─────────────────────────────────────────────────────────

  Widget _buildRecentHeader(BuildContext context, ColorScheme colorScheme, ThemeData theme, bool isDark) {
    final surfaceAlt = theme.inputDecorationTheme.fillColor ?? colorScheme.surface;

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
            ),
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
                      color: colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: colorScheme.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TRANSACTION LIST ──────────────────────────────────────────────────────

  Widget _buildTransactionList(BuildContext context, ColorScheme colorScheme, ThemeData theme, bool isDark) {
    final provider = context.watch<TransactionProvider>();
    final textSec = isDark ? const Color(0xFF8B90A7) : Colors.grey[600];

    if (provider.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: CircularProgressIndicator(color: colorScheme.secondary, strokeWidth: 2),
        ),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            provider.error!,
            style: TextStyle(color: textSec, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (provider.transactions.isEmpty) {
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

    final transactions = provider.transactions;
    final count = transactions.length > 5 ? 5 : transactions.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      itemCount: count,
      itemBuilder: (context, index) =>
          _buildTile(context, transactions[index], colorScheme, theme, isDark),
    );
  }

  // 🔥 UPDATED _buildTile TO MATCH TRANSACTION LIST SCREEN
  Widget _buildTile(BuildContext context, TransactionModel tx, ColorScheme colorScheme, ThemeData theme, bool isDark) {
    final Color moneyColor = _getTransactionColor(tx);
    final bool isCash = tx.accountName.toLowerCase().contains('cash') ||
                        tx.accountName.toLowerCase().contains('wallet');
                        
    final textSec = isDark ? const Color(0xFF8B90A7) : Colors.grey[600]!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // Circular leading icon
              _getTransactionLeading(tx),
              const SizedBox(width: 16),
              
              // Title and subtitle area
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
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        // Keeping the date inline since Home Screen has no date headers
                        Text(
                          DateFormat('dd MMM').format(tx.date),
                          style: TextStyle(color: textSec, fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text('·', style: TextStyle(color: textSec)),
                        const SizedBox(width: 6),
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
              
              // Amount
              Text(
                "₹${tx.amount.abs().toStringAsFixed(2)}",
                style: TextStyle(
                  color: moneyColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Divider instead of a box border
        Divider(color: theme.dividerColor, height: 1),
      ],
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return "Good morning ☀️";
    if (h < 17) return "Good afternoon 👋";
    return "Good evening 🌙";
  }

  Color _getTransactionColor(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION") return AppColors.savingsPrimary;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION") return AppColors.progressGreen;
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION") return AppColors.chartIncome;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN") return AppColors.incomeAmount;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT") return AppColors.textSecondary;
    if (tx.type == "INCOME") return AppColors.incomeAmount;
    if (tx.type == "REVERSAL") return AppColors.warning;
    return AppColors.expenseAmount;
  }

  IconData _getTransactionIcon(TransactionModel tx) {
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_ALLOCATION") return Icons.savings_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION") return Icons.savings_outlined;
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION") return Icons.task_alt_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN") return Icons.call_received_rounded;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT") return Icons.call_made_rounded;
    if (tx.type == "INCOME") return Icons.trending_up_rounded;
    if (tx.type == "REVERSAL") return Icons.undo_rounded;
    return Icons.trending_down_rounded;
  }

  // 🔥 ADDED LEADING WIDGET HELPER
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