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
  late final GoalService _goalService =
      GoalService(baseUrl: "http://localhost:5000/api");

  List<GoalModel> goals = [];
  List<GoalModel> filteredGoals = [];
  bool _isLoading = true;
    String searchQuery = '';
  String selectedAccount = 'All';
  String selectedStatus = 'All'; // All, Active, Completed

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
        filteredGoals = data;
        _isLoading = false;
      });
      _applyFilters(); 
    }
  } catch (e) {
    setState(() => _isLoading = false);
  }
}

// 👇 CORRECT PLACE (INSIDE CLASS)
void _applyFilters() {
  setState(() {
    filteredGoals = goals.where((g) {
      final matchesSearch =
          g.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          g.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (g.accountName ?? '').toLowerCase().contains(searchQuery.toLowerCase());

      final matchesAccount =
          selectedAccount == 'All' || g.accountName == selectedAccount;

      final matchesStatus = selectedStatus == 'All' ||
          (selectedStatus == 'Active' && g.progress < 1) ||
          (selectedStatus == 'Completed' && g.progress >= 1);

      return matchesSearch && matchesAccount && matchesStatus;
    }).toList();
  });
}
  
  

  void _searchGoals(String value) {
  searchQuery = value;
  _applyFilters();
}

  Future<void> _deleteGoal(String id) async {
    try {
      await _goalService.deleteGoal(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Goal deleted")),
      );

      _fetchGoals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildLightHeader()),
                  SliverToBoxAdapter(child: _buildDarkHeroCard()),
                  SliverToBoxAdapter(child: _buildAddGoalButton()),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  const SliverToBoxAdapter(child: SizedBox(height: 10)),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      _buildGoalWidgets(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLightHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 9),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
          ),
          const Text(
            "Financial Goals",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkHeroCard() {
    double totalSaved =
        filteredGoals.fold(0, (sum, item) => sum + item.currentAmount);

    int activeCount =
        filteredGoals.where((g) => g.currentAmount < g.targetAmount).length;

    int completedCount =
        filteredGoals.where((g) => g.currentAmount >= g.targetAmount).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0052D4), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Saved",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            "₹${totalSaved.toStringAsFixed(0)}",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    _buildSubStat("Active Goals", activeCount.toString(), onTap: () {
     selectedStatus = "Active";
_applyFilters();
    }),

    _buildSubStat("Completed", completedCount.toString(), onTap: () {
      selectedStatus = "Completed";
_applyFilters();
    }),

    _buildSubStat("Total Goals", goals.length.toString(), onTap: () {
      selectedStatus = "All";
_applyFilters();
    }),
  ],
)
        ],
      ),
    );
  }

  Widget _buildSubStat(String label, String value, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    ),
  );
}

  Widget _buildAddGoalButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: InkWell(
        onTap: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateNewGoalScreen(),
            ),
          );
          if (refresh == true) _fetchGoals();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                "Create New Goal",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          onChanged: _searchGoals,
          decoration: const InputDecoration(
            icon: Icon(Icons.search),
            hintText: "Search goals...",
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGoalWidgets() {
  List<Widget> widgets = [];

  // Ongoing goals (<100%)
  final ongoingGoals =
      filteredGoals.where((g) => g.progress < 1).toList();

  if (ongoingGoals.isNotEmpty) {
    widgets.add(
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Text(
          "Ongoing Goals",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );

    widgets.addAll(ongoingGoals.map((goal) => _buildGoalCard(goal)));
  }

  // Completed goals (100%)
  final completedGoals =
      filteredGoals.where((g) => g.progress >= 1).toList();

  if (completedGoals.isNotEmpty) {
    widgets.add(
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text(
          "Completed Goals",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );

    widgets.addAll(completedGoals.map((goal) => _buildGoalCard(goal)));
  }

  return widgets;
}

  Widget _buildGoalCard(GoalModel goal) {
    double progress = goal.progress;
    bool isCompleted = progress >= 1;
    int percent = (progress * 100).toInt();

    int daysRemaining =
        goal.daysLeft ?? goal.targetDate.difference(DateTime.now()).inDays;
    int completedDays =
    DateTime.now().difference(goal.createdAt).inDays;

    return GestureDetector(
      onTap: () async {
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GoalDetailsScreen(goal: goal),
          ),
        );
        if (refresh == true) _fetchGoals();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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
                  child: const Icon(Icons.flag, color: Colors.blueAccent),
                ),
                const SizedBox(width: 15),
               Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        goal.title,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold),
      ),

      const SizedBox(height: 6),

      Text(
        goal.category,
        style: const TextStyle(color: Colors.grey),
      ),

      const SizedBox(height: 6),

      // ✅ NOW INSIDE COLUMN (CORRECT)
      Row(
        children: [
          const Icon(Icons.account_balance_wallet,
              size: 14, color: Colors.blueGrey),
          const SizedBox(width: 5),
          Text(
            goal.accountName ?? "Unknown Account",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ],
  ),
),
                PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert),
  onSelected: (value) async {
    if (value == "delete") {
      _deleteGoal(goal.id);
    }
    if (value == "edit") {
      final refresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateNewGoalScreen(existingGoal: goal),
        ),
      );
      if (refresh == true) _fetchGoals();
    }
  },
  itemBuilder: (context) {
    if (isCompleted) {
      return const [
        PopupMenuItem(value: "delete", child: Text("Delete")),
      ];
    } else {
      return const [
        PopupMenuItem(value: "edit", child: Text("Edit")),
        PopupMenuItem(value: "delete", child: Text("Delete")),
      ];
    }
  },
),
              ],
            ),

            const SizedBox(height: 15),

            Row(
  children: [
    Expanded(
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        borderRadius: BorderRadius.circular(10),
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation(
          isCompleted ? Colors.green : const Color(0xFF0052D4),
        ),
      ),
    ),
    const SizedBox(width: 10),

    isCompleted
        ? Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          )
        : Text(
            "$percent%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0052D4),
            ),
          )
  ],
),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
  isCompleted
      ? "₹${goal.currentAmount.toInt()}"
      : "₹${goal.currentAmount.toInt()} / ₹${goal.targetAmount.toInt()}",
  style: const TextStyle(fontWeight: FontWeight.w600),
),
               Text(
  isCompleted
      ? "Completed in $completedDays days"
      : "$daysRemaining days left",
  style: const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  ),
),
              ],
            ),

            const SizedBox(height: 12),

  
  if (isCompleted)
  Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F4F9),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            "Successfully completed 🎉",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  )
else
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
        Expanded(
          child: Text(
            "₹${(goal.requiredDailySaving ?? 0).toStringAsFixed(2)} per day to reach goal",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  ),
          ],
        ),
      ),
    );
  }
}