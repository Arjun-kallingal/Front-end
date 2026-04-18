import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../data/goal_model.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:provider/provider.dart';
import '../provider/goal_provider.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen> {
  String searchQuery = '';
  String selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<GoalProvider>().fetchGoals();
    });
  }

  void _searchGoals(String value) {
    searchQuery = value;
    context.read<GoalProvider>().searchGoals(value);
  }

  // 🛠️ Dynamic Delete Confirmation with Premium UI
  Future<void> _confirmDelete(GoalModel goal) async {
    final bool isCompleted = goal.status == 'completed';
    final bool hasFunds = goal.currentAmount > 0;

    String dialogTitle;
    String dialogMessage;

    // 1. Determine the correct messaging
    if (isCompleted) {
      dialogTitle = "Delete Completed Goal";
      dialogMessage = "You've already conquered this goal! 🏆\n\nAre you sure you want to remove it from your history? This action cannot be undone.";
    } else if (hasFunds) {
      dialogTitle = "Delete Active Goal";
      dialogMessage = "This goal currently holds ₹${goal.currentAmount.toInt()}.\n\nIf these funds are still in your possession, remember to withdraw them to your main account to keep your tracking accurate.\n\nAre you sure you want to proceed?";
    } else {
      dialogTitle = "Delete Active Goal";
      dialogMessage = "You are currently working towards this goal.\n\nDeleting it will erase your progress tracking. Are you sure you want to proceed?";
    }

    // 2. Show the Premium Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          title: Text(
            dialogTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: Text(
            dialogMessage,
            style: TextStyle(
              height: 1.5, 
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Cancel", 
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade700, 
                        fontSize: 15, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // 3. Execute Delete if Confirmed
    if (confirm == true) {
      final provider = context.read<GoalProvider>();
      final success = await provider.deleteGoal(goal.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Goal deleted successfully." : "Delete failed. Please try again.",
            style: const TextStyle(fontSize: 15),
          ),
          backgroundColor: success ? null : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    final provider = context.watch<GoalProvider>();
    final goals = provider.goals;
    final filteredGoals = provider.filteredGoals;
    final isLoading = provider.isLoading;

    final ongoingGoals = filteredGoals.where((g) => g.status != 'completed').toList();
    final completedGoals = filteredGoals.where((g) => g.status == 'completed').toList();

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF8FAFC),
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text("Financial Goals",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: colorScheme.onSurface, size: 22),
            onPressed: () => NavigationService.bottomIndex.value = 0),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final refresh = await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateNewGoalScreen()));
          if (refresh == true) context.read<GoalProvider>().fetchGoals();
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        label: const Text("New Goal",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : RefreshIndicator(
              onRefresh: () async => context.read<GoalProvider>().fetchGoals(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (goals.isNotEmpty)
                      _buildGoalsOverviewCard(goals, colorScheme, isDark),
                    const SizedBox(height: 8),
                    _buildSearchBar(colorScheme, isDark),
                    const SizedBox(height: 12),
                    if (ongoingGoals.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionHeader("ACTIVE GOALS", isDark),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: ongoingGoals
                              .map((goal) => _buildSleekGoalCard(
                                  goal, colorScheme, isDark))
                              .toList(),
                        ),
                      ),
                    ],
                    if (filteredGoals.isEmpty && !isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                            child: Text("No goals found. Start planning today!",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500))),
                      ),
                    if (completedGoals.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSectionHeader("COMPLETED GOALS", isDark),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: completedGoals
                              .map((goal) => _buildSleekGoalCard(
                                  goal, colorScheme, isDark))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  // ==================== UI COMPONENTS ====================

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color:
                    isDark ? const Color(0xFF8B90A7) : Colors.grey.shade500)));
  }
Widget _buildSearchBar(ColorScheme colorScheme, bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: _searchGoals,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface),
        decoration: InputDecoration(
          isDense: true,
          icon: Icon(
            Icons.search_rounded,
            size: 20, 
            color: isDark ? Colors.white54 : Colors.grey.shade600
          ),
          hintText: "Search goals...",
          hintStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.grey.shade600),
          
          // These lines completely disable the global border theme
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
  Widget _buildGoalsOverviewCard(
      List<GoalModel> goals, ColorScheme colorScheme, bool isDark) {
    final totalGoals = goals.length;
    
    final completed = goals.where((g) => g.status == 'completed').length;
    final active = totalGoals - completed;

    double completedPercent = totalGoals == 0 ? 0.0 : completed / totalGoals;
    double activePercent = totalGoals == 0 ? 0.0 : active / totalGoals;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade100, width: 1.5),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 90,
            width: 90,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(90, 90),
                  painter: _DonutPainter(
                    completedPercent: completedPercent,
                    activePercent: activePercent,
                    bgColor: isDark ? Colors.white10 : Colors.grey.shade100,
                    completedColor: const Color(0xFF10B981),
                    activeColor: const Color(0xFF3B82F6),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      totalGoals.toString(),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                          height: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Goals",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactLegend(
                    color: const Color(0xFF10B981),
                    label: "Completed",
                    value: completed,
                    isDark: isDark),
                const SizedBox(height: 14),
                _buildCompactLegend(
                    color: const Color(0xFF3B82F6),
                    label: "Active",
                    value: active,
                    isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegend(
      {required Color color,
      required String label,
      required int value,
      required bool isDark}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey.shade600)),
          ],
        ),
        Text(value.toString(),
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0F172A))),
      ],
    );
  }

  Widget _buildSleekGoalCard(
      GoalModel goal, ColorScheme colorScheme, bool isDark) {
    
    final bool isCompleted = goal.status == 'completed';
    final double progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    
    final int daysRemaining =
        goal.daysLeft ?? goal.targetDate.difference(DateTime.now()).inDays;

    final Color cardBgColor = isCompleted
        ? const Color(0xFFECFDF5)
        : const Color(0xFFEFF6FF);
    final Color cardBorderColor = isCompleted
        ? const Color(0xFFA7F3D0)
        : const Color(0xFFBFDBFE);
    final Color watermarkColor = isCompleted
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFDBEAFE);

    final Color accentColor = isCompleted
        ? const Color(0xFF10B981)
        : const Color(0xFF3B82F6);
    final Color iconBgColor = isCompleted
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFDBEAFE);
    final Color badgeTextColor = isCompleted
        ? const Color(0xFF065F46)
        : const Color(0xFF1E40AF);

    final Color textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color textSecondary = isDark ? Colors.white70 : const Color(0xFF64748B);
    final Color textTertiary = isDark ? Colors.white54 : const Color(0xFF94A3B8);

    final Color finalCardBgColor = isDark ? const Color(0xFF1E1E2C) : cardBgColor;
    final Color finalBorderColor = isDark ? Colors.white10 : cardBorderColor;
    final Color finalWatermarkColor =
        isDark ? Colors.white.withOpacity(0.02) : watermarkColor;
    final Color finalIconBgColor =
        isDark ? accentColor.withOpacity(0.15) : iconBgColor;

    String predictionText;
    if (isCompleted) {
      predictionText = "Goal Reached 🎉";
    } else if (goal.requiredDailySaving != null &&
        goal.requiredDailySaving! > 0) {
      predictionText =
          "₹${goal.requiredDailySaving!.toStringAsFixed(0)}/day required";
    } else {
      predictionText = "On track";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: finalCardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: finalBorderColor, width: 1.0),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: accentColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GoalDetailsScreen(goal: goal)));
            if (refresh == true) context.read<GoalProvider>().fetchGoals();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    isCompleted
                        ? Icons.military_tech_rounded
                        : Icons.radar_rounded,
                    size: 140,
                    color: finalWatermarkColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                                color: finalIconBgColor,
                                borderRadius: BorderRadius.circular(14)),
                            child: Icon(
                                isCompleted
                                    ? Icons.emoji_events_rounded
                                    : Icons.track_changes_rounded,
                                color: accentColor,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.category_rounded,
                                        size: 14, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        goal.category,
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text("•",
                                        style: TextStyle(
                                            color: textTertiary, fontSize: 13)),
                                    const SizedBox(width: 6),
                                    Text(DateFormat('MMM dd, yyyy').format(goal.targetDate),
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: textSecondary,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _buildGoalMenu(
                              goal, isCompleted, isDark, textTertiary),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Saved",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                "₹${goal.currentAmount.toInt()}",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: textPrimary,
                                    letterSpacing: -0.5),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Target",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary)),
                              const SizedBox(height: 4),
                              Text(
                                "₹${goal.targetAmount.toInt()}",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                                valueColor: AlwaysStoppedAnimation(accentColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          SizedBox(
                            width: 45,
                            child: Text(
                              "${(progress * 100).toInt()}%",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color: finalIconBgColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              predictionText,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? accentColor : badgeTextColor),
                            ),
                          ),
                          if (!isCompleted)
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 15, color: textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  "${daysRemaining > 0 ? daysRemaining : 0} days left",
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: textSecondary),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalMenu(
      GoalModel goal, bool isCompleted, bool isDark, Color iconColor) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: iconColor, size: 22),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
      onSelected: (value) async {
        if (value == "delete") _confirmDelete(goal); 
        
        if (value == "edit") {
          final refresh = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CreateNewGoalScreen(existingGoal: goal)));
          if (refresh == true) context.read<GoalProvider>().fetchGoals();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
            value: "edit",
            child: Text("Edit Goal", style: TextStyle(fontSize: 15))),
        PopupMenuItem(
            value: "delete",
            child: Text("Delete Goal",
                style: TextStyle(color: Colors.red, fontSize: 15))),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double completedPercent;
  final double activePercent;
  final Color bgColor;
  final Color completedColor;
  final Color activeColor;

  _DonutPainter({
    required this.completedPercent,
    required this.activePercent,
    required this.bgColor,
    required this.completedColor,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 12.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * 3.1416, false, bgPaint);

    double startAngle = -3.1416 / 2;

    if (completedPercent > 0) {
      final completedPaint = Paint()
        ..color = completedColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = 2 * 3.1416 * completedPercent;
      canvas.drawArc(rect, startAngle, sweep, false, completedPaint);
      startAngle += sweep;
    }

    if (activePercent > 0) {
      if (completedPercent > 0 && activePercent < 1.0) startAngle += 0.05;

      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweep = (2 * 3.1416 * activePercent) -
          (completedPercent > 0 && activePercent < 1.0 ? 0.05 : 0);
      if (sweep > 0) {
        canvas.drawArc(rect, startAngle, sweep, false, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}