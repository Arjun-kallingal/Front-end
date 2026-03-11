import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  late final GoalService _goalService = GoalService(
    baseUrl: "http://localhost:5000/api", 
  );

  List<GoalModel> goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    setState(() => _isLoading = true);
    try {
      // 👇 THIS IS THE MISSING LINE! It defines 'data' by calling your service
      final data = await _goalService.getGoals(); 

      if (mounted) {
        setState(() {
          goals = data; // Now 'data' is defined and can be assigned to goals
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load goals. Please check your connection."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildLightHeader(),
            _buildDarkHeroCard(), // 👈 The new all-in-one dark card
            _buildAddGoalButton(),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                  : _buildGoalList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Financial Goals",
            style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // NEW: The all-in-one dark stats card
  Widget _buildDarkHeroCard() {
    // Calculate stats dynamically
    double totalSaved = goals.fold(0, (sum, item) => sum + item.currentAmount);
    int activeCount = goals.where((g) => g.currentAmount < g.targetAmount).length;
    int completedCount = goals.where((g) => g.currentAmount >= g.targetAmount).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)], // Your requested dark blue colors
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0052D4).withOpacity(0.3), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Saved", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text("\$${totalSaved.toStringAsFixed(0)}", 
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSubStat("Active Goals", activeCount.toString()),
              Container(width: 1, height: 40, color: Colors.white24), // A sleek vertical divider
              _buildSubStat("Completed", completedCount.toString()),
              Container(width: 1, height: 40, color: Colors.white24), // A sleek vertical divider
              _buildSubStat("Total Goals", goals.length.toString()),
            ],
          )
        ],
      ),
    );
  }

  // Helper for the small stats at the bottom of the dark card
  Widget _buildSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildAddGoalButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNewGoalScreen()),
          );
          if (refresh == true) _fetchGoals();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.05),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_circle_outline, color: Colors.blueAccent, size: 24),
              SizedBox(width: 8),
              Text(
                "Create New Goal",
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalList() {
    if (goals.isEmpty) {
      return Center(child: Text("No goals found", style: TextStyle(color: Colors.grey.shade400)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20), 
      itemCount: goals.length,
      itemBuilder: (context, index) => _buildGoalCard(goals[index]),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    return GestureDetector(
      onTap: () async {
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GoalDetailsScreen(goal: goal)),
        );
        if (refresh == true) _fetchGoals();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.ads_click, color: Colors.blueAccent, size: 26),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, 
                        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 17, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(goal.category.toUpperCase(), 
                          style: const TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Progress", style: TextStyle(color: Colors.black38, fontSize: 11)),
                    Text("${(goal.progress * 100).toInt()}%", 
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: Colors.blueAccent.withOpacity(0.05),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("\$${goal.currentAmount.toInt()} / \$${goal.targetAmount.toInt()}", 
                  style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: Colors.black38, size: 14),
                    const SizedBox(width: 4),
                    Text("${goal.daysLeft ?? 0} days left", style: const TextStyle(color: Colors.black38, fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_graph_rounded, color: Colors.green, size: 18),
                  const SizedBox(width: 10),
                  Text("\$${(goal.requiredDailySaving ?? 0).toStringAsFixed(2)} per day to reach goal",
                    style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}