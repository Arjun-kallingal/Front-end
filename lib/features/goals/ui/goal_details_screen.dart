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

  static const _blue = Color(0xFF0052D4);

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
        Navigator.pop(context, true); // ✅ returns true
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
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                Text(
                  isDeposit ? "Deposit Funds" : "Withdraw Funds",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  isDeposit
                      ? "Reserve money toward this goal."
                      : "Return money to your main account.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: amountController,
                  autofocus: true,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    prefixText: "₹ ",
                    prefixStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500),
                    hintText: "0.00",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: isDeposit ? _blue : Colors.red, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDeposit ? _blue : Colors.red.shade600,
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
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
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
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        (_currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);
    final bool isCompleted = progress >= 1.0;
    final Color progressColor = isCompleted ? Colors.green : _blue;
    final int daysLeft = widget.goal.daysLeft ??
        widget.goal.targetDate.difference(DateTime.now()).inDays;
    final double remaining = (widget.goal.targetAmount - _currentAmount)
        .clamp(0.0, widget.goal.targetAmount);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // Light clean background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text("Goal Details",
            style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _buildSummaryCard(progress, progressColor, isCompleted,
                      daysLeft, remaining)),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: "Deposit",
                          icon: Icons.add_rounded,
                          color: _blue,
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
                          color: Colors.red.shade600,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("History",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey.shade800)),
                ),
              ),
              SliverToBoxAdapter(child: _buildHistoryList()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: const Center(
                  child: CircularProgressIndicator(color: Colors.black87)),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double progress, Color progressColor,
      bool isCompleted, int daysLeft, double remaining) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // was 20
        border: Border.all(color: Colors.grey.shade200), // add subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes,
                      size: 16, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    widget.goal.category.toUpperCase(),
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                    isCompleted
                        ? "Completed"
                        : "${daysLeft > 0 ? daysLeft : 0} days left",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10, // smaller
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.goal.title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 18, // was 20
              fontWeight: FontWeight.w700, // slightly lighter
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
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DAILY SAVING NEEDED",
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${(widget.goal.requiredDailySaving ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "per day to reach on time",
                          style: TextStyle(
                            color: Colors.orange.shade700,
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
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(width: 6),
              Text(
                "/ ₹${NumberFormat('#,##,###').format(widget.goal.targetAmount.toInt())}",
                style: TextStyle(
                    color: Colors.grey.shade500,
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
                    backgroundColor: Colors.grey.shade100,
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
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
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
                  color: Colors.grey.shade400,
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

        final isAllocation =
            direction.contains('ALLOCATION') && !direction.contains('DEALLOC');
        final Color dotColor = isAllocation ? Colors.green : Colors.black87;
        final IconData dotIcon = isAllocation ? Icons.add : Icons.remove;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
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
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy • h:mm a').format(date),
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Text(
                "${isAllocation ? '+' : '-'}₹$amount",
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800, color: dotColor),
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
    return SizedBox(
      height: 46,
      child: outlined
          ? OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: disabled ? Colors.grey.shade300 : color, width: 1.5),
                foregroundColor: disabled ? Colors.grey.shade400 : color,
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
                backgroundColor: disabled ? Colors.grey.shade300 : color,
                foregroundColor: Colors.white,
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
