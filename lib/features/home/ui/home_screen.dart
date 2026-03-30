import 'package:flutter/material.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';
import 'balance_card.dart';
import 'package:intl/intl.dart';
import 'package:front_end/features/home/widget/add_transaction_screen.dart';
import 'package:front_end/features/transactions/ui/transactionlist_screen.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import 'package:front_end/core/models/transaction_model.dart';
import '../../../core/constants/app_colors.dart';
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
          if (refresh == true && mounted) {
            await context.read<TransactionProvider>().fetchTransactions();
          }
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().fetchTransactions();
          },
          color: colorScheme.primary,
          child: SingleChildScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  child: Column(
    children: [
      _buildHeader(context),
      const SizedBox(height: 10),
      const BalanceCard(),
      const SizedBox(height: 10),
      _buildActionButtons(context),
      const SizedBox(height: 10),
      _buildRecentHeader(context),
      _buildTransactionList(context),
    ],
  ),
)
        ),
      ),
    );
  }
Widget _buildActionButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [

        /// ADD INCOME
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(
                    initialIsExpense: false,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Income"),
          ),
        ),

        const SizedBox(width: 10),

        /// ADD EXPENSE
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTransactionScreen(
                    initialIsExpense: true,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.remove),
            label: const Text("Expense"),
          ),
        ),

        const SizedBox(width: 10),

        /// ADD TRANSFER
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransferScreen(),
                ),
              );
            },
            icon: const Icon(Icons.swap_horiz),
            label: const Text("Transfer"),
          ),
        ),
      ],
    ),
  );
}
  // ── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "WalletCare",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
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
            child: CircleAvatar(
              radius: 18,
              backgroundColor: colorScheme.surfaceVariant,
              child: Icon(
                Icons.person_outline,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── RECENT HEADER ─────────────────────────────────────────────────────────

  Widget _buildRecentHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Activity",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
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
            child: Row(
              children: [
                Text(
                  "See All",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TRANSACTION LIST ──────────────────────────────────────────────────────

  Widget _buildTransactionList(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<TransactionProvider>();

    if (provider.isLoading) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (provider.error != null) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          provider.error!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    if (provider.transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          "No recent transactions",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      );
    }

    final transactions = provider.transactions;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: transactions.length > 5 ? 5 : transactions.length,
      separatorBuilder: (_, __) => Divider(
        color: theme.dividerColor,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final tx = transactions[index];

        final bool isIncome = tx.type == 'INCOME';
        final bool isAllocation = tx.direction == 'GOAL_ALLOCATION';
        final bool isDealloc = tx.direction == 'GOAL_DEALLOCATION';
        final bool isCompletion = tx.direction == 'GOAL_COMPLETION';
        final bool isTransferIn = tx.direction == 'ACCOUNT_TRANSFER_IN';
        final bool isReversal = tx.type == 'REVERSAL';

        // Use AppColors semantic tokens — no raw hex inline
        final Color moneyColor = isIncome
            ? AppColors.incomeAmount
            : isAllocation
                ? AppColors.savingsPrimary
                : isDealloc
                    ? AppColors.progressGreen
                    : isCompletion
                        ? AppColors.chartIncome
                        : isTransferIn
                            ? AppColors.incomeAmount
                            : isReversal
                                ? AppColors.warning
                                : AppColors.expenseAmount;

        final bool isCash = tx.accountName.toLowerCase().contains('cash') ||
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
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(tx.date),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        if (tx.subtitle.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            "•",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.35),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tx.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${tx.amount.abs().toStringAsFixed(2)}",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tx.accountName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
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
      return Icons.savings;
    if (tx.type == "TRANSFER" && tx.direction == "GOAL_DEALLOCATION")
      return Icons.savings_outlined;
    if (tx.type == "EXPENSE" && tx.direction == "GOAL_COMPLETION")
      return Icons.task_alt;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_IN")
      return Icons.call_received;
    if (tx.type == "TRANSFER" && tx.direction == "ACCOUNT_TRANSFER_OUT")
      return Icons.call_made;
    if (tx.type == "INCOME") return Icons.trending_up;
    if (tx.type == "REVERSAL") return Icons.undo;
    return Icons.trending_down;
  }

  Widget _card({required BuildContext context, required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
