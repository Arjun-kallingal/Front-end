import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart'; // ✅ add this

class GoalDetailsScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isDepositing = false;
  bool _isWithdrawing = false;

  // ✅ Replace hardcoded localhost with ApiConfig.baseUrl
  late final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  // ... rest of file is completely unchanged

  late double _currentAmount;

  List<dynamic> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.goal.currentAmount;
    _loadHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();

  }

  Future<void> _loadHistory() async {
    final history = await _goalService.getGoalHistory(widget.goal.id);

    if (mounted) {
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _processDeposit() async {
    if (_amountController.text.isEmpty) return;

    final depositAmount = double.tryParse(_amountController.text) ?? 0;

    if (depositAmount <= 0) {
      _showSnackBar("Enter a valid amount", true);
      return;
    }

    setState(() => _isDepositing = true);

    final success =
        await _goalService.depositToGoal(widget.goal.id, depositAmount);

    if (mounted) {
      setState(() => _isDepositing = false);

      if (success) {
        setState(() {
          _currentAmount += depositAmount;
          _amountController.clear();
        });

        _loadHistory();
        _showSnackBar("Funds added successfully!", false);
      } else {
        _showSnackBar("Failed to add funds", true);
      }
    }
  }

  Future<void> _processWithdraw() async {
    if (_amountController.text.isEmpty) return;

    final withdrawAmount = double.tryParse(_amountController.text) ?? 0;

    if (withdrawAmount <= 0) {
      _showSnackBar("Enter a valid amount", true);
      return;
    }

    if (withdrawAmount > _currentAmount) {
      _showSnackBar("Insufficient balance", true);
      return;
    }

    setState(() => _isWithdrawing = true);

    final success =
        await _goalService.withdrawFromGoal(widget.goal.id, withdrawAmount);

    if (mounted) {
      setState(() => _isWithdrawing = false);

      if (success) {
        setState(() {
          _currentAmount -= withdrawAmount;
          _amountController.clear();
        });

        _loadHistory();
        _showSnackBar("Amount withdrawn successfully!", false);
      } else {
        _showSnackBar("Withdraw failed", true);
      }
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        (_currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(progress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Funds",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDepositCard(),
                  const SizedBox(height: 25),
                  const Text(
                    "Transaction History",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryList(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context, true),
                  ),
                  Expanded(
                    child: Text(
                      widget.goal.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "₹${_currentAmount.toStringAsFixed(0)}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                "of ₹${widget.goal.targetAmount.toStringAsFixed(0)} Target",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: progress,
                minHeight: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepositCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            ],
            decoration: InputDecoration(
              prefixText: "₹ ",
              hintText: "0.00",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),


          TextField(
  controller: _descriptionController,
  maxLines: 1,
  style: const TextStyle(fontSize: 14), // smaller text
  decoration: InputDecoration(
    hintText: "Enter description (optional)",
    prefixIcon: const Icon(Icons.notes, size: 18), // smaller icon
    isDense: true, // ✅ reduces height
    contentPadding: const EdgeInsets.symmetric(
      vertical: 10, // 🔥 reduce this to control height
      horizontal: 12,
    ),
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), // optional: slightly smaller
      borderSide: BorderSide.none,
    ),
  ),
),

const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isDepositing ? null : _processDeposit,
                  child: const Text("Deposit"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red),
                  onPressed: _isWithdrawing ? null : _processWithdraw,
                  child: const Text("Withdraw"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_history.isEmpty) {
      return const Text("No transactions yet");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];

        final type = item['type'];
        final amount = item['amount'];

        DateTime date;
        if (item['createdAt'] != null) {
          date = DateTime.parse(item['createdAt']);
        } else {
          date = DateTime.now();
        }

        return ListTile(
          leading: Icon(
            type == "deposit" ? Icons.arrow_downward : Icons.arrow_upward,
            color: type == "deposit" ? Colors.green : Colors.red,
          ),
          title: Text(type == "deposit" ? "Deposit" : "Withdraw"),
          subtitle: Text(
            "${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
          ),
          trailing: Text("₹$amount"),
        );
      },
    );
  }
}