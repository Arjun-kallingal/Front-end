import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';
import 'package:front_end/navigation/navigation_service.dart';
import 'package:front_end/core/services/api_config.dart';

// ─── Theme Constants ──────────────────────────────────────────────────────────
class _GoalTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFDC2626);
  static const Color surface = Color(0xFFF8F9FB);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  /// Progress color changes based on completion %:
  /// <40% = danger, 40–70% = warning, 70–99% = primary, 100% = success
  static Color progressColor(double progress) {
    if (progress >= 1.0) return success;
    if (progress >= 0.7) return primary;
    if (progress >= 0.4) return warning;
    return danger;
  }

  /// Indian number formatting: ₹1,23,456 / ₹1.2L / ₹1.2Cr
  static String formatIndianCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    final intAmount = amount.toInt();
    final str = intAmount.toString();
    if (str.length <= 3) return '₹$str';
    final last3 = str.substring(str.length - 3);
    final remaining = str.substring(0, str.length - 3);
    final formatted = remaining.replaceAllMapped(
      RegExp(r'(\d{1,2})(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    return '₹$formatted,$last3';
  }

  /// FIX: Never returns negative days — clamps to 0
  static int safeDaysRemaining(DateTime targetDate, int? daysLeft) {
    final computed = daysLeft ?? targetDate.difference(DateTime.now()).inDays;
    return computed < 0 ? 0 : computed;
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() => _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState extends State<FinancialGoalsScreen>
    with TickerProviderStateMixin {
  late final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  List<GoalModel> goals = [];
  List<GoalModel> filteredGoals = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = true;
  String searchQuery = '';
  String selectedAccount = 'All';
  String selectedStatus = 'All';

  late AnimationController _listFadeController;
  late AnimationController _donutController;
  late Animation<double> _listFadeAnimation;
  late Animation<double> _donutAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();

    _listFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _listFadeAnimation = CurvedAnimation(
      parent: _listFadeController,
      curve: Curves.easeOut,
    );

    _donutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _donutAnimation = CurvedAnimation(
      parent: _donutController,
      curve: Curves.easeOutCubic,
    );

    _scrollController.addListener(() {
      final collapsed = _scrollController.offset > 60;
      if (collapsed != _isHeaderCollapsed) {
        setState(() => _isHeaderCollapsed = collapsed);
      }
    });

    _fetchGoals();
  }

  @override
  void dispose() {
    _listFadeController.dispose();
    _donutController.dispose();
    _scrollController.dispose();
    super.dispose();
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
        _listFadeController.forward(from: 0);
        _donutController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _GoalTheme.cardBg,
        title: const Text(
          "Delete Goal",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: _GoalTheme.textPrimary,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this goal? This action cannot be undone.",
          style: TextStyle(
            fontSize: 14,
            color: _GoalTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
                foregroundColor: _GoalTheme.textSecondary),
            child: const Text("Cancel",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _GoalTheme.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Delete",
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _goalService.deleteGoal(id);
        if (!mounted) return;
        _showSnackBar("Goal deleted successfully", isError: false);
        _fetchGoals();
      } catch (e) {
        _showSnackBar("Delete failed. Please try again.", isError: true);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(message,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        backgroundColor:
            isError ? _GoalTheme.danger : _GoalTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Computed aggregates ────────────────────────────────────────────────────
  double get _totalSaved => goals.fold(0, (s, g) => s + g.currentAmount);
  double get _totalTarget => goals.fold(0, (s, g) => s + g.targetAmount);
  int get _completedCount => goals.where((g) => g.progress >= 1).length;
  int get _activeCount => goals.where((g) => g.progress < 1).length;

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _GoalTheme.surface,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : RefreshIndicator(
                // FIX: pull-to-refresh
                onRefresh: _fetchGoals,
                color: _GoalTheme.primary,
                strokeWidth: 2.5,
                child: FadeTransition(
                  opacity: _listFadeAnimation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    slivers: [
                      // FIX: sticky header via SliverPersistentHeader
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _StickyHeaderDelegate(
                          minHeight: 62,
                          maxHeight: 122,
                          child: _buildStickyHeader(),
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildGoalsDonutChart()),
                      SliverToBoxAdapter(child: _buildAddGoalButton()),
                      SliverToBoxAdapter(child: _buildSearchBar()),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      SliverList(
                        delegate: SliverChildListDelegate(_buildGoalWidgets()),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ─── Loading ───────────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation(_GoalTheme.primary),
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text(
            "Loading your goals...",
            style: TextStyle(
              color: _GoalTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sticky Header ─────────────────────────────────────────────────────────
  // FIX: Proper back button using arrow_back_ios_new + haptic feedback
  // FIX: Shows total savings amount
  // FIX: Collapses gracefully on scroll
  Widget _buildStickyHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      color: _GoalTheme.surface,
      padding: EdgeInsets.fromLTRB(
        20,
        _isHeaderCollapsed ? 10 : 14,
        20,
        _isHeaderCollapsed ? 10 : 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back nav
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              NavigationService.bottomIndex.value = 0;
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _GoalTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: _GoalTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Dashboard",
                  style: TextStyle(
                    color: _GoalTheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Expanded vs collapsed title block
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _isHeaderCollapsed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            // Expanded header
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Financial Goals",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _GoalTheme.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${goals.length} goals · $_completedCount completed",
                          style: const TextStyle(
                            fontSize: 12,
                            color: _GoalTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Total savings pill
                    if (goals.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: _GoalTheme.successLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  _GoalTheme.success.withOpacity(0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _GoalTheme.formatIndianCurrency(_totalSaved),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _GoalTheme.success,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const Text(
                              "total saved",
                              style: TextStyle(
                                fontSize: 9,
                                color: _GoalTheme.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Collapsed header — single line
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Financial Goals",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _GoalTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (goals.isNotEmpty)
                    Text(
                      "${_GoalTheme.formatIndianCurrency(_totalSaved)} saved",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _GoalTheme.success,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Donut Chart ───────────────────────────────────────────────────────────
  // FIX: Empty state when 0 goals
  // FIX: Animated arcs on load
  // FIX: Percentage labels on chart
  // FIX: More compact layout (row-based)
  Widget _buildGoalsDonutChart() {
    final totalGoals = goals.length;
    final completed = _completedCount;
    final active = _activeCount;

    // Empty state
    if (totalGoals == 0) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            color: _GoalTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _GoalTheme.border),
          ),
          child: const Column(
            children: [
              Icon(Icons.flag_outlined,
                  color: _GoalTheme.primary, size: 32),
              SizedBox(height: 10),
              Text(
                "No goals yet",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _GoalTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Create your first goal below to get started",
                style: TextStyle(
                    fontSize: 12, color: _GoalTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    double completedPercent = completed / totalGoals;
    double activePercent = active / totalGoals;
    final totalPercent = completedPercent + activePercent;
    if (totalPercent > 0) {
      completedPercent = completedPercent / totalPercent;
      activePercent = activePercent / totalPercent;
    }

    final overallProgress =
        _totalTarget == 0 ? 0.0 : _totalSaved / _totalTarget;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _GoalTheme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _GoalTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated donut (compact: 100x100)
            AnimatedBuilder(
              animation: _donutAnimation,
              builder: (_, __) => SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: _DonutPainter(
                        completedPercent:
                            completedPercent * _donutAnimation.value,
                        activePercent:
                            activePercent * _donutAnimation.value,
                        animationValue: _donutAnimation.value,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalGoals.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _GoalTheme.textPrimary,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          "goals",
                          style: TextStyle(
                            fontSize: 9,
                            color: _GoalTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Stats column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompactLegend(
                    color: _GoalTheme.success,
                    label: "Completed",
                    count: completed,
                    percent: (completedPercent * 100).round(),
                  ),
                  const SizedBox(height: 8),
                  _buildCompactLegend(
                    color: _GoalTheme.primary,
                    label: "Active",
                    count: active,
                    percent: (activePercent * 100).round(),
                  ),
                  const SizedBox(height: 12),
                  // Overall savings bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Overall",
                        style: TextStyle(
                          fontSize: 11,
                          color: _GoalTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${(overallProgress * 100).clamp(0, 100).toInt()}%",
                        style: const TextStyle(
                          fontSize: 11,
                          color: _GoalTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _donutAnimation,
                    builder: (_, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: overallProgress * _donutAnimation.value,
                        minHeight: 6,
                        backgroundColor: _GoalTheme.border,
                        valueColor: AlwaysStoppedAnimation(
                          _GoalTheme.progressColor(overallProgress),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _GoalTheme.formatIndianCurrency(_totalSaved),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _GoalTheme.textPrimary,
                        ),
                      ),
                      Text(
                        "of ${_GoalTheme.formatIndianCurrency(_totalTarget)}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: _GoalTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactLegend({
    required Color color,
    required String label,
    required int count,
    required int percent,
  }) {
    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _GoalTheme.textSecondary,
            ),
          ),
        ),
        Text(
          "$count",
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _GoalTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            "$percent%",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Add Goal Button ───────────────────────────────────────────────────────
  Widget _buildAddGoalButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ElevatedButton(
        onPressed: () async {
          HapticFeedback.lightImpact();
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CreateNewGoalScreen()),
          );
          if (refresh == true) _fetchGoals();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _GoalTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 20),
            SizedBox(width: 8),
            Text(
              "Create New Goal",
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _GoalTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _GoalTheme.border),
        ),
        child: TextField(
          onChanged: _searchGoals,
          style: const TextStyle(
            fontSize: 14,
            color: _GoalTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded,
                color: _GoalTheme.textSecondary, size: 20),
            hintText: "Search goals...",
            hintStyle: TextStyle(
                color: _GoalTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // ─── Goal List ─────────────────────────────────────────────────────────────
  List<Widget> _buildGoalWidgets() {
    final List<Widget> widgets = [];
    final ongoingGoals =
        filteredGoals.where((g) => g.progress < 1).toList();
    final completedGoals =
        filteredGoals.where((g) => g.progress >= 1).toList();

    if (filteredGoals.isEmpty) {
      widgets.add(_buildEmptyState());
      return widgets;
    }

    if (ongoingGoals.isNotEmpty) {
      widgets.add(_buildSectionHeader(
          "Active Goals",
          count: ongoingGoals.length,
          color: _GoalTheme.primary));
      widgets.addAll(ongoingGoals
          .asMap()
          .entries
          .map((e) => _buildGoalCard(e.value, index: e.key)));
    }

    if (completedGoals.isNotEmpty) {
      widgets.add(_buildSectionHeader(
          "Completed Goals",
          count: completedGoals.length,
          color: _GoalTheme.success));
      widgets.addAll(completedGoals
          .asMap()
          .entries
          .map((e) => _buildGoalCard(e.value, index: e.key)));
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title,
      {required int count, required Color color}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _GoalTheme.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
                color: _GoalTheme.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.search_off_rounded,
                size: 32, color: _GoalTheme.primary),
          ),
          const SizedBox(height: 14),
          const Text("No goals found",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _GoalTheme.textPrimary)),
          const SizedBox(height: 6),
          const Text(
            "Try a different search term or create a new goal",
            style: TextStyle(
                fontSize: 13, color: _GoalTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Goal Card ─────────────────────────────────────────────────────────────
  Widget _buildGoalCard(GoalModel goal, {int index = 0}) {
    final bool isCompleted = goal.progress >= 1;
    final double progress = goal.progress.clamp(0.0, 1.0);

    // FIX: correct days remaining — never negative
    final int daysRemaining =
        _GoalTheme.safeDaysRemaining(goal.targetDate, goal.daysLeft);

    // FIX: progress-driven color (red → amber → blue → green)
    final Color progressColor = _GoalTheme.progressColor(progress);
    final Color bgColor = progressColor.withOpacity(0.08);

    final String accountName = (goal.accountName == null ||
            goal.accountName == 'Unknown' ||
            goal.accountName!.isEmpty)
        ? "Main Account"
        : goal.accountName!;

    // FIX: prediction text with proper fallback
    String predictionText;
    if (isCompleted) {
      predictionText = "Completed 🎉";
    } else if (goal.requiredDailySaving != null &&
        goal.requiredDailySaving! > 0) {
      predictionText =
          "${_GoalTheme.formatIndianCurrency(goal.requiredDailySaving!)}/day";
    } else if (daysRemaining > 0) {
      final remaining = goal.targetAmount - goal.currentAmount;
      final perDay = remaining / daysRemaining;
      predictionText =
          "${_GoalTheme.formatIndianCurrency(perDay)}/day needed";
    } else {
      predictionText = "Past due date";
    }

    final bool isUrgent = !isCompleted && daysRemaining <= 7;

    // Card slide+fade in per index
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 280 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        decoration: BoxDecoration(
          color: _GoalTheme.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color:
                isUrgent ? _GoalTheme.warning.withOpacity(0.4) : _GoalTheme.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            // FIX: softer ripple, no jarring flash
            splashColor: progressColor.withOpacity(0.07),
            highlightColor: progressColor.withOpacity(0.03),
            onTap: () async {
              HapticFeedback.selectionClick();
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => GoalDetailsScreen(goal: goal)),
              );
              if (refresh == true) _fetchGoals();
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top row ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCompleted
                              ? Icons.emoji_events_rounded
                              : Icons.track_changes_rounded,
                          color: progressColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _GoalTheme.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 11,
                                  color: _GoalTheme.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    accountName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: _GoalTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _GoalTheme.surface,
                                    borderRadius:
                                        BorderRadius.circular(5),
                                    border: Border.all(
                                        color: _GoalTheme.border),
                                  ),
                                  child: Text(
                                    goal.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: _GoalTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_horiz_rounded,
                            color: _GoalTheme.textSecondary, size: 20),
                        padding: EdgeInsets.zero,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        color: _GoalTheme.cardBg,
                        onSelected: (value) async {
                          if (value == "delete") _confirmDelete(goal.id);
                          if (value == "edit") {
                            final refresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateNewGoalScreen(
                                    existingGoal: goal),
                              ),
                            );
                            if (refresh == true) _fetchGoals();
                          }
                        },
                        itemBuilder: (context) => isCompleted
                            ? [
                                PopupMenuItem(
                                    value: "delete",
                                    child: _menuItem(
                                        Icons.delete_outline_rounded,
                                        "Delete",
                                        _GoalTheme.danger)),
                              ]
                            : [
                                PopupMenuItem(
                                    value: "edit",
                                    child: _menuItem(
                                        Icons.edit_outlined,
                                        "Edit",
                                        _GoalTheme.textPrimary)),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                    value: "delete",
                                    child: _menuItem(
                                        Icons.delete_outline_rounded,
                                        "Delete",
                                        _GoalTheme.danger)),
                              ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Amounts — FIX: Indian currency formatting ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _GoalTheme.formatIndianCurrency(
                                  goal.currentAmount),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: _GoalTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const TextSpan(
                              text: " saved",
                              style: TextStyle(
                                fontSize: 12,
                                color: _GoalTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "of ${_GoalTheme.formatIndianCurrency(goal.targetAmount)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: _GoalTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ── Progress bar — FIX: dynamic color ──
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: _GoalTheme.border,
                            valueColor: AlwaysStoppedAnimation(
                                progressColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${(progress * 100).clamp(0, 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(
                      height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 10),

                  // ── Bottom row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Prediction chip
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? _GoalTheme.successLight
                                : progressColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.bolt_rounded,
                                size: 12,
                                color: isCompleted
                                    ? _GoalTheme.success
                                    : progressColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  predictionText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isCompleted
                                        ? _GoalTheme.success
                                        : progressColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // FIX: days remaining — never negative, urgent warning
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.done_all_rounded
                                : isUrgent
                                    ? Icons.warning_amber_rounded
                                    : Icons.schedule_rounded,
                            size: 12,
                            color: isCompleted
                                ? _GoalTheme.success
                                : isUrgent
                                    ? _GoalTheme.warning
                                    : _GoalTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCompleted
                                ? "Done"
                                : daysRemaining == 0
                                    ? "Due today"
                                    : "${daysRemaining}d left",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCompleted
                                  ? _GoalTheme.success
                                  : isUrgent
                                      ? _GoalTheme.warning
                                      : _GoalTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ],
    );
  }
}

// ─── Sticky Header Delegate ───────────────────────────────────────────────────
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  const _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      child;

  @override
  bool shouldRebuild(_StickyHeaderDelegate old) =>
      maxHeight != old.maxHeight ||
      minHeight != old.minHeight ||
      child != old.child;
}

// ─── Animated Donut Painter ───────────────────────────────────────────────────
class _DonutPainter extends CustomPainter {
  final double completedPercent;
  final double activePercent;
  final double animationValue;

  const _DonutPainter({
    required this.completedPercent,
    required this.activePercent,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 7;
    const strokeWidth = 10.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect, 0, 2 * math.pi, false,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double startAngle = -math.pi / 2;

    // Completed arc
    if (completedPercent > 0) {
      final sweep = 2 * math.pi * completedPercent;
      canvas.drawArc(
        rect, startAngle, sweep, false,
        Paint()
          ..color = const Color(0xFF059669)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      // Percentage label — only show once animation is nearly done
      if (animationValue > 0.85 && completedPercent > 0.08) {
        final midAngle = startAngle + sweep / 2;
        _drawLabel(
          canvas,
          center,
          radius + strokeWidth + 10,
          midAngle,
          "${(completedPercent * 100).toInt()}%",
          const Color(0xFF059669),
        );
      }

      startAngle += sweep;
    }

    // Active arc
    if (activePercent > 0) {
      final sweep = 2 * math.pi * activePercent;
      canvas.drawArc(
        rect, startAngle, sweep, false,
        Paint()
          ..color = const Color(0xFF2563EB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      if (animationValue > 0.85 && activePercent > 0.08) {
        final midAngle = startAngle + sweep / 2;
        _drawLabel(
          canvas,
          center,
          radius + strokeWidth + 10,
          midAngle,
          "${(activePercent * 100).toInt()}%",
          const Color(0xFF2563EB),
        );
      }
    }
  }

  void _drawLabel(Canvas canvas, Offset center, double r, double angle,
      String text, Color color) {
    final x = center.dx + r * math.cos(angle);
    final y = center.dy + r * math.sin(angle);
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.completedPercent != completedPercent ||
      old.activePercent != activePercent ||
      old.animationValue != animationValue;
}