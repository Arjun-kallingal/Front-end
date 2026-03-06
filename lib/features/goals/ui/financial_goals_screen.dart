import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'create_new_goal.dart';
import 'goal_details_screen.dart';

class FinancialGoalsScreen extends StatefulWidget {
  const FinancialGoalsScreen({super.key});

  @override
  State<FinancialGoalsScreen> createState() =>
      _FinancialGoalsScreenState();
}

class _FinancialGoalsScreenState
    extends State<FinancialGoalsScreen> {

  final List<Map<String, dynamic>> goals = [];

  final TextEditingController _searchController =
      TextEditingController();

  String searchQuery = "";

  double get totalTarget =>
      goals.fold(0.0, (sum, g) => sum + (g["target"] ?? 0.0));

  int get totalGoals => goals.length;

  List<Map<String, dynamic>> get filteredGoals {
    if (searchQuery.isEmpty) {
      return goals;
    }

    return goals.where((goal) {
      final title =
          goal["title"].toString().toLowerCase();
      final category =
          goal["category"].toString().toLowerCase();

      return title.contains(searchQuery.toLowerCase()) ||
          category.contains(searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToCreateGoal() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateNewGoalScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        goals.add(result);
      });
    }
  }

  void _deleteGoal(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Delete Goal",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this goal?",
          style: TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              setState(() {
                goals.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [

          /// HEADER
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.fromLTRB(
                      20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFB31217),
                    Color(0xFFE52D27),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(35),
                  bottomRight:
                      Radius.circular(35),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  /// TOP ROW
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.white
                                .withOpacity(
                                    0.15),
                        child: IconButton(
                          icon: const Icon(
                              Icons.arrow_back,
                              color:
                                  Colors.white),
                          onPressed: () =>
                              Navigator.pop(
                                  context),
                        ),
                      ),
                      const Text(
                        "Financial Goals",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor:
                            Colors.white,
                        child: IconButton(
                          icon: const Icon(
                              Icons.add,
                              color:
                                  Colors.red),
                          onPressed:
                              _navigateToCreateGoal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// SUMMARY CARD
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                                horizontal:
                                    20,
                                vertical:
                                    25),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withOpacity(
                              0.08),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  25),
                      border: Border.all(
                        color: Colors
                            .white
                            .withOpacity(
                                0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [

                        /// ACTIVE GOALS
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              "Active Goals",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    8),
                            Text(
                              totalGoals
                                  .toString(),
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize:
                                    28,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),

                        /// TOTAL TARGET
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                          children: [
                            const Text(
                              "Total Target",
                              style:
                                  TextStyle(
                                color: Colors
                                    .white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                height:
                                    8),
                            Text(
                              "\$${totalTarget.toStringAsFixed(0)}",
                              style:
                                  const TextStyle(
                                color: Colors
                                    .white,
                                fontSize:
                                    28,
                                fontWeight:
                                    FontWeight
                                        .bold,
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
          ),

          /// SEARCH BAR
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                          20, 15, 20,
                          0),
              child: Container(
                decoration:
                    BoxDecoration(
                  color:
                      AppColors.cardBg,
                  borderRadius:
                      BorderRadius
                          .circular(20),
                  border: Border.all(
                      color: AppColors
                          .cardBorder),
                ),
                child: TextField(
                  controller:
                      _searchController,
                  onChanged:
                      (value) {
                    setState(() {
                      searchQuery =
                          value;
                    });
                  },
                  style:
                      const TextStyle(
                    color: AppColors
                        .textPrimary,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        "Search goals...",
                    hintStyle:
                        const TextStyle(
                      color: AppColors
                          .textSecondary,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons.search,
                      color: AppColors
                          .textSecondary,
                    ),
                    border:
                        InputBorder.none,
                    contentPadding:
                        const EdgeInsets
                            .symmetric(
                                vertical:
                                    15),
                  ),
                ),
              ),
            ),
          ),

          /// GOALS LIST
          SliverPadding(
            padding:
                const EdgeInsets.all(
                    20),
            sliver:
                filteredGoals.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            "No goals found",
                            style:
                                TextStyle(
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context,
                              index) {
                            final goal =
                                filteredGoals[
                                    index];

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                          bottom:
                                              20),
                              child:
                                  GestureDetector(
                                onTap:
                                    () async {
                                  await Navigator
                                      .push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          GoalDetailsScreen(
                                        goal:
                                            goal,
                                      ),
                                    ),
                                  );
                                  setState(
                                      () {});
                                },
                                child:
                                    _goalCard(
                                  goal:
                                      goal,
                                  index: goals
                                      .indexOf(
                                          goal),
                                ),
                              ),
                            );
                          },
                          childCount:
                              filteredGoals
                                  .length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  /// GOAL CARD (UNCHANGED)
  Widget _goalCard({
    required Map<String, dynamic>
        goal,
    required int index,
  }) {
    double saved =
        goal["saved"] ?? 0.0;
    double target =
        goal["target"] ?? 0.0;
    DateTime deadline =
        goal["deadline"];
    String category =
        goal["category"] ??
            "General";

    double progress =
        target == 0
            ? 0
            : (saved / target);

    int percent =
        (progress * 100)
            .clamp(0, 100)
            .toInt();

    int daysLeft = deadline
        .difference(DateTime.now())
        .inDays;

    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
            color:
                AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color:
                AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [

          Row(
            children: [
              Icon(goal["icon"],
                  color:
                      goal["color"]),
              const SizedBox(
                  width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      goal["title"],
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            AppColors
                                .textPrimary,
                      ),
                    ),
                    const SizedBox(
                        height: 4),
                    Text(
                      category,
                      style:
                          TextStyle(
                        fontSize: 12,
                        color: goal[
                            "color"],
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons
                      .delete_outline,
                  color: Colors.red,
                ),
                onPressed: () =>
                    _deleteGoal(index),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                "\$${saved.toStringAsFixed(0)} saved",
                style: TextStyle(
                  color:
                      goal["color"],
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
              Text(
                "$percent%",
                style: TextStyle(
                  color:
                      goal["color"],
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: progress.clamp(
                0.0, 1.0),
            minHeight: 8,
            backgroundColor:
                Colors.grey
                    .withOpacity(0.2),
            valueColor:
                AlwaysStoppedAnimation(
                    goal["color"]),
          ),

          const SizedBox(height: 10),

          Text(
            "Deadline: ${DateFormat("dd MMM yyyy").format(deadline)}"
            " • ${daysLeft >= 0 ? "$daysLeft days left" : "Expired"}",
            style: const TextStyle(
              fontSize: 12,
              color: AppColors
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}