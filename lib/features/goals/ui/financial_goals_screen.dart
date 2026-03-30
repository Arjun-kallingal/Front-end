import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/services/api_config.dart'; // ✅ add this

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  // ✅ Replace hardcoded localhost with ApiConfig.baseUrl
  late final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  // ... rest of file is unchanged

  List<GoalModel> goals = [];
  List<GoalModel> filteredGoals = [];
  Map<String, dynamic> _summary = {};
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
                (g.accountName ?? '')
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());

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
  Future<void> _confirmDelete(String id) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Delete Goal"),
        content: const Text(
          "Are you sure you want to delete this goal?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
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
                  SliverToBoxAdapter(child: _buildGoalsDonutChart()),
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
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => NavigationService.bottomIndex.value = 0,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 14, color: Colors.blueAccent),
                SizedBox(width: 4),
                Text("Dashboard",
                    style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
        ],
      ),
    );
  }

  Widget _buildGoalsDonutChart() {
  final totalGoals = goals.length;
  final completed =
      goals.where((g) => g.progress >= 1).length;
  final active =
      goals.where((g) => g.progress < 1).length;

  double completedPercent =
    totalGoals == 0 ? 0.0 : completed / totalGoals;

double activePercent =
    totalGoals == 0 ? 0.0 : active / totalGoals;

// ✅ NORMALIZE (VERY IMPORTANT)
final totalPercent = completedPercent + activePercent;

if (totalPercent > 0) {
  completedPercent = completedPercent / totalPercent;
  activePercent = activePercent / totalPercent;
}

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
const Text(
  "Goal Progress",
  style: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Colors.black,
    letterSpacing: -0.5,
  ),
),

const SizedBox(height: 16),


          // 🎯 MULTI COLOR DONUT
          Center(
  child: SizedBox(
    height: 180,
    width: 180,
    child: Stack(
      alignment: Alignment.center,
      children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _DonutPainter(
                    completedPercent: completedPercent,
                    activePercent: activePercent,
                  ),
                ),
    
                // CENTER TEXT
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalGoals.toString(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Total Goals",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
          const SizedBox(height: 20),

          _buildLegendRow(
            color: Colors.green,
            label: "Completed",
            value: completed,
          ),

          const SizedBox(height: 12),

          _buildLegendRow(
            color: Colors.blue.shade300,
            label: "Active",
            value: active,
          ),
        ],
      ),
    ),
  );
}
Widget _buildLegendRow({
  required Color color,
  required String label,
  required int value,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
    final ongoingGoals = filteredGoals.where((g) => g.progress < 1).toList();

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
    final completedGoals = filteredGoals.where((g) => g.progress >= 1).toList();

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
    final bool isCompleted = goal.progress >= 1;
    final int daysRemaining =
        goal.daysLeft ?? goal.targetDate.difference(DateTime.now()).inDays;
    final double progress = goal.progress;

    // Dynamic colors based on goal status
    final Color primaryColor =
        isCompleted ? Colors.green : const Color(0xFF0052D4);
    final Color bgColor = primaryColor.withOpacity(0.08);

    // Safe fallback for account name using the freshly fixed backend payload
    final String accountName = (goal.accountName == null ||
            goal.accountName == 'Unknown' ||
            goal.accountName!.isEmpty)
        ? "Main Account"
        : goal.accountName!;
        final remainingAmount = goal.targetAmount - goal.currentAmount;
final int safeDays = daysRemaining > 0 ? daysRemaining : 1;

final double perDay = remainingAmount / safeDays;
final double perWeek = perDay * 7;

String predictionText;

if (isCompleted) {
  predictionText = "Completed 🎉";
} else if (goal.requiredDailySaving != null &&
    goal.requiredDailySaving! > 0) {
  predictionText =
      "₹${goal.requiredDailySaving!.toStringAsFixed(0)}/day to reach goal";
} else {
  predictionText = "No plan available";
}

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            final refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GoalDetailsScreen(goal: goal),
              ),
            );
            if (refresh == true) _fetchGoals();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── TOP ROW: Icon, Title, Account, Menu ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isCompleted ? Icons.emoji_events : Icons.track_changes,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  size: 14, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  accountName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text("•",
                                  style:
                                      TextStyle(color: Colors.grey.shade300)),
                              const SizedBox(width: 6),
                              Text(
                                goal.category,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) async {
                        if (value == "delete") _confirmDelete(goal.id);
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
                                value: "delete", child: Text("Delete"))
                          ];
                        } else {
                          return const [
                            PopupMenuItem(value: "edit", child: Text("Edit")),
                            PopupMenuItem(
                                value: "delete",
                                child: Text("Delete",
                                    style: TextStyle(color: Colors.red))),
                          ];
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ─── MIDDLE: Progress Bar & Math ───
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${goal.currentAmount.toInt()} saved",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      "Target: ₹${goal.targetAmount.toInt()}",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

Row(
  children: [
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.grey.shade100,
          valueColor: AlwaysStoppedAnimation(primaryColor),
        ),
      ),
    ),
    const SizedBox(width: 10),
    Text(
      "${(progress * 100).clamp(0, 100).toInt()}%",
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
    ),
  ],
),
                
                const SizedBox(height: 14),

                // ─── BOTTOM ROW: Status Chip & Percentage ───
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // 🔮 Prediction (LEFT SIDE)
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? "Completed 🎉" : predictionText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.blue.shade700,
        ),
      ),
    ),

    // ⏳ Days Left (RIGHT SIDE)
    Text(
      isCompleted
          ? "Done"
          : "${daysRemaining > 0 ? daysRemaining : 0} days left",
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    ),
  ],
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _DonutPainter extends CustomPainter {
  final double completedPercent;
  final double activePercent;

  _DonutPainter({
    required this.completedPercent,
    required this.activePercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const strokeWidth = 14.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, 2 * 3.1416, false, bgPaint);

    double startAngle = -3.1416 / 2;

    // 🟢 Completed (Light Green)
    if (completedPercent > 0) {
      final completedPaint = Paint()
        ..color = const Color(0xFF6EE7B7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final sweep = 2 * 3.1416 * completedPercent;

      canvas.drawArc(rect, startAngle, sweep, false, completedPaint);

      startAngle += sweep;
    }

    // 🔵 Active (Light Blue)
    if (activePercent > 0) {
      final activePaint = Paint()
        ..color = const Color(0xFF93C5FD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      final sweep = 2 * 3.1416 * activePercent;

      canvas.drawArc(rect, startAngle, sweep, false, activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}