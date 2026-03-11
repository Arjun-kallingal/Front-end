import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';

class GoalDetailsScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailsScreen({super.key, required this.goal});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isDepositing = false;

  // Initialize service just like you did on the other screens
  late final GoalService _goalService = GoalService(
    baseUrl: "http://localhost:5000/api", // Make sure this matches your setup
    // getToken: () async => "YOUR_MOCK_TOKEN_HERE", 
  );

  // Keep track of the local goal state so UI updates immediately
  late double _currentAmount;

  @override
  void initState() {
    super.initState();
    _currentAmount = widget.goal.currentAmount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processDeposit() async {
    if (_amountController.text.isEmpty) return;

    final depositAmount = double.tryParse(_amountController.text) ?? 0;
    if (depositAmount <= 0) {
      _showSnackBar("Enter a valid amount", true);
      return;
    }

    setState(() => _isDepositing = true);

    final success = await _goalService.depositToGoal(widget.goal.id, depositAmount);

    if (mounted) {
      setState(() => _isDepositing = false);
      if (success) {
        setState(() {
          _currentAmount += depositAmount; // Update UI immediately
          _amountController.clear();
        });
        _showSnackBar("Funds added successfully!", false);
      } else {
        _showSnackBar("Failed to add funds. Check your balance.", true);
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
    // Recalculate progress based on local state updates
    double currentProgress = (_currentAmount / widget.goal.targetAmount).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHighContrastHeader(currentProgress),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Funds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 12),
                  _buildDepositCard(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHighContrastHeader(double progress) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    // Return true when popping to tell the previous screen to refresh the list!
                    onPressed: () => Navigator.pop(context, true), 
                  ),
                  Expanded(
                    child: Text(widget.goal.title,
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    const Text("Current Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      "₹${_currentAmount.toStringAsFixed(0)}", 
                      style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "of ₹${widget.goal.targetAmount.toStringAsFixed(0)} Target", 
                      style: const TextStyle(color: Colors.white54, fontSize: 14)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              hintText: "0.00",
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0052D4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isDepositing ? null : _processDeposit,
              child: _isDepositing 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Add to Goal", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}