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

/// 👇 ADD HERE (around this area)
void _openFilterOptions() {
  showModalBottomSheet(
    context: context,
    builder: (_) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Filter by Account"),

          ListTile(
            title: const Text("All"),
            onTap: () {
              selectedAccount = "All";
              _applyFilters();
              Navigator.pop(context);
            },
          ),

          ListTile(
            title: const Text("SBI"),
            onTap: () {
              selectedAccount = "SBI";
              _applyFilters();
              Navigator.pop(context);
            },
          ),

          ListTile(
            title: const Text("Cash"),
            onTap: () {
              selectedAccount = "Cash";
              _applyFilters();
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
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
                fontSize: 20,
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
    child: Row(
      children: [
        /// 🔍 SEARCH FIELD
        Expanded(
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
        ),

        const SizedBox(width: 10),

        /// ⚙️ FILTER BUTTON
        InkWell(
          onTap: _openFilterOptions,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune),
          ),
        ),
      ],
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
          "Active Goals",
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
  final date = goal.createdAt;
  final day = date.day.toString();
  final monthYear = "${date.year}.${date.month.toString().padLeft(2, '0')}";
  final weekday = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][date.weekday % 7];

  bool isCompleted = goal.progress >= 1;

  int daysRemaining =
      goal.daysLeft ?? goal.targetDate.difference(DateTime.now()).inDays;

  int completedDays =
      DateTime.now().difference(goal.createdAt).inDays;

  double progress = goal.progress;

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 📅 LEFT DATE
            Column(
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  monthYear,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    weekday,
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            /// 📊 MIDDLE CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// CATEGORY
                  Text(
                    goal.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 2),

                  /// TITLE
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// ACCOUNT
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        goal.accountName ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// PROGRESS BAR
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted
                          ? Colors.green
                          : const Color(0xFF0052D4),
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// STATUS SECTION (MERGED FEATURES)
                  if (isCompleted)
                    Text(
                      "Completed in $completedDays days 🎉",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$daysRemaining days left",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₹${(goal.requiredDailySaving ?? 0).toStringAsFixed(2)} per day",
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

            /// 💰 RIGHT SIDE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                /// AMOUNT (CURRENT / TARGET)
                Text(
                  "₹${goal.currentAmount.toInt()} / ₹${goal.targetAmount.toInt()}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.redAccent,
                  ),
                ),

                const SizedBox(height: 4),

                /// PERCENT / STATUS
                Text(
                  isCompleted
                      ? "Completed"
                      : "${(progress * 100).toInt()}%",
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isCompleted ? Colors.green : Colors.blueGrey,
                  ),
                ),

                /// MENU
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  onSelected: (value) async {
                    if (value == "delete") _deleteGoal(goal.id);

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
                        PopupMenuItem(
                            value: "delete", child: Text("Delete")),
                      ];
                    } else {
                      return const [
                        PopupMenuItem(
                            value: "edit", child: Text("Edit")),
                        PopupMenuItem(
                            value: "delete", child: Text("Delete")),
                      ];
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}