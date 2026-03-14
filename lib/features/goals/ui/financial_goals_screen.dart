import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';
import 'package:front_end/navigation/navigation_service.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  // Service initialized without token as per your previous requirement
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
      final data = await _goalService.getGoals();
      if (mounted) {
        setState(() {
          goals = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Light White/Grey background
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateNewGoalScreen()),
          );
          if (refresh == true) _fetchGoals();
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: Column(
        children: [
          _buildHighContrastHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : _buildGoalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighContrastHeader() {
    double totalTarget = goals.fold(0, (sum, item) => sum + item.targetAmount);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)], // Blue to Black Gradient
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
               icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
              ),
              const Text("Financial Goals",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _headerStat("Active Goals", goals.length.toString()),
                _headerStat("Total Target", "\$${totalTarget.toStringAsFixed(0)}"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGoalList() {
    if (goals.isEmpty) {
      return Center(child: Text("No goals found", style: TextStyle(color: Colors.grey.shade400)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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