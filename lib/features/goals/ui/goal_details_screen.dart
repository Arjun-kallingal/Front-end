import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/providers/account_provider.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/transaction_provider.dart';
import '../provider/goal_provider.dart';
import '../../analytics/provider/analytics_provider.dart';
import 'package:front_end/core/constants/app_colors.dart';

class GoalDetailsScreen extends StatefulWidget {
  final GoalModel goal;
  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  bool _isLoading = false;
  late double _currentAmount;
  List<dynamic> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.goal.currentAmount;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _goalService.getGoalHistory(widget.goal.id);
      if (mounted) setState(() => _history = history);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _processTransaction(double amount, bool isDeposit) async {
    setState(() => _isLoading = true);
    final nowUtc = DateTime.now().toUtc().toIso8601String();

    try {
      final bool success = isDeposit
          ? await _goalService.depositToGoal(widget.goal.id, amount,
              transactedAt: nowUtc)
          : await _goalService.withdrawFromGoal(widget.goal.id, amount,
              transactedAt: nowUtc);

      if (!mounted) return;

      if (success) {
        setState(() => _currentAmount += isDeposit ? amount : -amount);

        if (mounted) {
          await Future.wait([
            context.read<AccountProvider>().loadAccounts(),
            context.read<TransactionProvider>().fetchTransactions(),
            context.read<GoalProvider>().fetchGoals(),
            context.read<AnalyticsProvider>().reload(),
          ]);
        }

        await _loadHistory();

        _showSnackBar(isDeposit
            ? "Funds deposited successfully!"
            : "Withdrawal successful!");
        Navigator.pop(context, true);
      } else {
        _showSnackBar(isDeposit ? "Deposit failed" : "Withdrawal failed",
            isError: true);
      }
    } catch (e) {
      if (mounted) _showSnackBar("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showTransactionBottomSheet(BuildContext context, bool isDeposit) {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg =
            isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary;
        final textPrimary =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final textSecondary =
            isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        final inputFill =
            isDark ? AppColors.darkBgElevated : AppColors.lightBgSecondary;
        final inputBorder =
            isDark ? AppColors.darkBorder : AppColors.lightBorder;
        final handleColor =
            isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
        final depositColor = AppColors.savingsPrimary;
        final withdrawColor = AppColors.expenseAmount;

        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Text(
                  isDeposit ? "Deposit Funds" : "Withdraw Funds",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  isDeposit
                      ? "Reserve money toward this goal."
                      : "Return money to your main account.",
                  style: TextStyle(color: textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary),
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    prefixStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textSecondary),
                    hintText: "0.00",
                    hintStyle: TextStyle(color: textSecondary),
                    filled: true,
                    fillColor: inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: isDeposit ? depositColor : withdrawColor,
                          width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDeposit ? depositColor : withdrawColor,
                      foregroundColor: AppColors.darkTextPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0;
                      if (amount <= 0) return;
                      Navigator.pop(ctx);
                      _processTransaction(amount, isDeposit);
                    },
                    child: Text(
                      isDeposit ? "Confirm Deposit" : "Confirm Withdrawal",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final double progress =
        (_currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);
    final bool isCompleted = progress >= 1.0;
    final Color progressColor =
        isCompleted ? AppColors.success : AppColors.savingsPrimary;
    final int daysLeft = widget.goal.daysLeft ??
        widget.goal.targetDate.difference(DateTime.now()).inDays;
    final double remaining = (widget.goal.targetAmount - _currentAmount)
        .clamp(0.0, widget.goal.targetAmount);

    final scaffoldBg =
        isDark ? AppColors.darkBgPrimary : const Color(0xFFF4F5F7);
    final appBarBg =
        isDark ? AppColors.darkBgPrimary : const Color(0xFFF4F5F7);
    final appBarTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: appBarTextColor, size: 18),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text("Goal Details",
            style: TextStyle(
                color: appBarTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _buildSummaryCard(progress, progressColor,
                      isCompleted, daysLeft, remaining, isDark)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: "Deposit",
                          icon: Icons.add_rounded,
                          color: AppColors.savingsPrimary,
                          disabled: isCompleted,
                          onTap: () =>
                              _showTransactionBottomSheet(context, true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: "Withdraw",
                          icon: Icons.remove_rounded,
                          color: AppColors.expenseAmount,
                          outlined: true,
                          disabled: _currentAmount <= 0,
                          onTap: () =>
                              _showTransactionBottomSheet(context, false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Text("History",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ),
              ),
              SliverToBoxAdapter(child: _buildHistoryList(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          if (_isLoading)
            Container(
              color: isDark
                  ? AppColors.darkBgPrimary.withOpacity(0.6)
                  : AppColors.lightBgPrimary.withOpacity(0.6),
              child: Center(
                  child: CircularProgressIndicator(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double progress, Color progressColor,
      bool isCompleted, int daysLeft, double remaining, bool isDark) {
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary;
    final cardBorder =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, size: 16, color: textMuted),
                  const SizedBox(width: 6),
                  Text(
                    widget.goal.category.toUpperCase(),
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successBg
                      : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    isCompleted
                        ? "Completed"
                        : "${daysLeft > 0 ? daysLeft : 0} days left",
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.goal.title,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          if (!isCompleted &&
              widget.goal.requiredDailySaving != null &&
              widget.goal.requiredDailySaving! > 0) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.dailySavingBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DAILY SAVING NEEDED",
                          style: TextStyle(
                            color: AppColors.dailySavingText,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${(widget.goal.requiredDailySaving ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: AppColors.dailySavingText,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "per day to reach on time",
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 24),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "₹${NumberFormat('#,##,###').format(_currentAmount.toInt())}",
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(width: 6),
              Text(
                "/ ₹${NumberFormat('#,##,###').format(widget.goal.targetAmount.toInt())}",
                style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor:
                        isDark ? AppColors.darkProgressBg : AppColors.lightProgressBg,
                    valueColor: AlwaysStoppedAnimation(progressColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${(progress * 100).clamp(0, 100).toInt()}%",
                style: TextStyle(
                    color: progressColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 12),
            Text(
              "₹${NumberFormat('#,##,###').format(remaining.toInt())} left to reach your goal",
              style: TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryList(bool isDark) {
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgPrimary;
    final cardBorder =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconBg =
        isDark ? AppColors.darkBgElevated : AppColors.lightBgSecondary;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    if (_isLoadingHistory) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()));
    }
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text("No transactions yet",
              style: TextStyle(
                  color: textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final direction = (item['direction'] ?? '').toString();
        final amount = item['amount']?.toString() ?? '0';
        final rawDate = item['transactedAt'] ?? item['createdAt'];

        DateTime date = DateTime.now();
        if (rawDate != null) {
          try {
            date = DateTime.parse(rawDate.toString()).toLocal();
          } catch (_) {}
        }

        final isAllocation = direction.contains('ALLOCATION') &&
            !direction.contains('DEALLOC');
        final Color dotColor =
            isAllocation ? AppColors.success : textPrimary;
        final IconData dotIcon =
            isAllocation ? Icons.add : Icons.remove;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(dotIcon, color: dotColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAllocation ? "Deposit" : "Withdrawal",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(date),
                      style: TextStyle(
                          color: textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                "${isAllocation ? '+' : '-'}₹$amount",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: dotColor),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final bool disabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 46,
      child: outlined
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: disabled
                        ? (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder)
                        : color,
                    width: 1.5),
                foregroundColor: disabled
                    ? (isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted)
                    : color,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: disabled ? null : onTap,
              icon: Icon(icon, size: 18),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            )
          : ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: disabled
                    ? (isDark
                        ? AppColors.darkBgElevated
                        : AppColors.lightBgElevated)
                    : color,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: disabled ? null : onTap,
              icon: Icon(icon, size: 18),
              label: Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ),
    );
  }
}