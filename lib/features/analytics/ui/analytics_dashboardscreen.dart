import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/constants/app_colors.dart';
import '../provider/analytics_provider.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AnalyticsProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {

    final provider = context.watch<AnalyticsProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      backgroundColor: AppColors.bgPrimary,

      /// NEW APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analytics & Reports",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          /// NEW ANALYTICS CARD HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                children: [

                  /// FILTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _dropdownFilter(provider),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// NET / INCOME / EXPENSE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [

                      _summaryItem("Net", provider.balance),

                      _summaryItem("Income", provider.income),

                      _summaryItem("Expense", provider.expense),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// REST OF PAGE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(
                children: [

                  const SizedBox(height: 20),

                  _incomeExpenseChart(provider),

                  const SizedBox(height: 20),

                  _monthlyTrend(provider),

                  const SizedBox(height: 20),

                  _categoryChart(provider),

                  const SizedBox(height: 20),

                  _goalProgress(provider),

                  const SizedBox(height: 40),

                  _summaryStatistics(provider),

                  const SizedBox(height: 40),

                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// DROPDOWN
  Widget _dropdownFilter(AnalyticsProvider provider) {

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(

        value: selectedFilter,

        dropdownColor: AppColors.cardBg,

        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),

        style: const TextStyle(color: Colors.white),

        items: const [

          DropdownMenuItem(value: "All", child: Text("All")),
          DropdownMenuItem(value: "Cash", child: Text("Cash")),
          DropdownMenuItem(value: "Account", child: Text("Account")),
        ],

        onChanged: (value) {

          if (value == null) return;

          setState(() {
            selectedFilter = value;
          });

          provider.applyFilter(value);
        },
      ),
    );
  }

  /// SUMMARY TEXT
  Widget _summaryItem(String title, double value) {

    Color amountColor = Colors.white;

    if (title == "Income" || title == "Net") {
      amountColor = AppColors.chartIncome;
    }

    if (title == "Expense") {
      amountColor = AppColors.chartExpense;
    }

    return Column(
      children: [

        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  /// -------------------
  /// KEEP YOUR EXISTING CHART METHODS BELOW
  /// (incomeExpenseChart, monthlyTrend, categoryChart, etc.)
  /// -------------------
  /// DONUT CHART
  


Widget _incomeExpenseChart(AnalyticsProvider provider) {

  final total = provider.income + provider.expense;

  final incomePercent =
      total == 0 ? 0 : (provider.income / total) * 100;

  final expensePercent =
      total == 0 ? 0 : (provider.expense / total) * 100;

  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Text(
          "Income vs Expense",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 200,

          child: PieChart(

            PieChartData(

              /// donut hole
              centerSpaceRadius: 55,

              /// smooth loading animation
              sectionsSpace: 2,

              pieTouchData: PieTouchData(),

              sections: [

                /// INCOME
                PieChartSectionData(
                  value: provider.income,
                  color: AppColors.chartIncome,
                  radius: 60,
                  showTitle: false,
                ),

                /// EXPENSE
                PieChartSectionData(
                  value: provider.expense,
                  color: AppColors.chartExpense,
                  radius: 60,
                  showTitle: false,
                ),
              ],
            ),

            /// animation duration
            swapAnimationDuration:
                const Duration(milliseconds: 900),

            /// animation curve
            swapAnimationCurve: Curves.easeInOut,
          ),
        ),

        const SizedBox(height: 20),

        /// legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// income indicator
            Row(
              children: [

                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.chartIncome,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "Income (${incomePercent.toStringAsFixed(0)}%)",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 30),

            /// expense indicator
            Row(
              children: [

                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.chartExpense,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(
                  "Expense (${expensePercent.toStringAsFixed(0)}%)",
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}


Widget _legendItem({
  required Color color,
  required String text,
}) {
  return Row(
    children: [

      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),

      const SizedBox(width: 6),

      Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
    ],
  );
}

   ///////////Monthy Trend

Widget _monthlyTrend(AnalyticsProvider provider) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Monthly Trend",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(

              /// AXIS LINES (X & Y)
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.25),
                    width: 1,
                  ),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),

              /// DASH GRID LINES
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,

                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [6,4],
                  );
                },

                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [6,4],
                  );
                },
              ),

              /// TITLES
              titlesData: FlTitlesData(

                /// X AXIS
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,

                    getTitlesWidget: (value, meta) {

                      if (value.toInt() >= provider.monthly.length) {
                        return const SizedBox();
                      }

                      final month =
                          provider.monthly[value.toInt()].month;

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          month,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// Y AXIS
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,

                    getTitlesWidget: (value, meta) {

                      if (value == 0) {
                        return const Text(
                          "0",
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        );
                      }

                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              /// TOOLTIP
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black87,

                  getTooltipItems: (touchedSpots) {

                    return touchedSpots.map((spot) {

                      final isIncome = spot.barIndex == 0;

                      return LineTooltipItem(
                        "${isIncome ? "Income" : "Expense"}\n\$${spot.y.toStringAsFixed(0)}",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );

                    }).toList();
                  },
                ),
              ),

              /// LINES
              lineBarsData: [

                /// INCOME
                LineChartBarData(
                  spots: provider.getIncomeSpots(),
                  isCurved: true,
                  color: AppColors.chartIncome,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),

                /// EXPENSE
                LineChartBarData(
                  spots: provider.getExpenseSpots(),
                  isCurved: true,
                  color: AppColors.chartExpense,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            _legendItem(
              color: AppColors.chartIncome,
              text: "Income",
            ),

            const SizedBox(width: 30),

            _legendItem(
              color: AppColors.chartExpense,
              text: "Expense",
            ),
          ],
        ),
      ],
    ),
  );
}




//////////////////////



Widget _categoryChart(AnalyticsProvider provider) {

  /// find highest category amount
  double maxValue = 0;

  for (var c in provider.categories) {
    if (c.amount > maxValue) {
      maxValue = c.amount;
    }
  }

  /// round to nearest 200 for clean axis
  double maxY = ((maxValue / 200).ceil()) * 200;

  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// HEADER
        const Text(
          "Top Spending Categories",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          height: 220,
          child: BarChart(

            BarChartData(

              minY: 0,
              maxY: maxY,

              /// AXIS BORDER
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(
                    color: Colors.white.withOpacity(0.25),
                  ),
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.25),
                  ),
                  top: BorderSide.none,
                  right: BorderSide.none,
                ),
              ),

              /// GRID LINES
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,

                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [6,4],
                  );
                },

                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [6,4],
                  );
                },
              ),

              /// TITLES
              titlesData: FlTitlesData(

                /// CATEGORY NAMES
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,

                    getTitlesWidget: (value, meta) {

                      if (value.toInt() >= provider.categories.length) {
                        return const SizedBox();
                      }

                      final category =
                          provider.categories[value.toInt()].name;

                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// Y AXIS
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 200,
                    getTitlesWidget: (value, meta) {

                      if (value > maxY) {
                        return const SizedBox();
                      }

                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),

              /// TOOLTIP
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(

                  tooltipBgColor: Colors.black87,

                  getTooltipItem: (group, groupIndex, rod, rodIndex) {

                    final category =
                        provider.categories[group.x.toInt()].name;

                    return BarTooltipItem(
                      "$category\n\$${rod.toY.toStringAsFixed(0)}",
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),

              /// BAR DATA
              barGroups: List.generate(
                provider.categories.length,
                (index) {

                  final data = provider.categories[index];

                  return BarChartGroupData(
                    x: index,

                    barRods: [

                      BarChartRodData(
                        toY: data.amount,
                        width: 35,
                        borderRadius: BorderRadius.zero,
                        color: AppColors.chartExpense,
                      ),
                    ],
                  );
                },
              ),
            ),

            swapAnimationDuration:
                const Duration(milliseconds: 900),

            swapAnimationCurve: Curves.easeInOut,
          ),
        ),
      ],
    ),
  );
}


///////////



Widget _goalProgress(AnalyticsProvider provider) {

  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// HEADER ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Text(
              "Goal Progress",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/goals");
              },
              child: Row(
                children: const [
                  Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Column(
          children: provider.goals.map((goal) {

            /// convert percentage to progress value
            double progressValue = goal.progress / 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// GOAL NAME
                  Text(
                    goal.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      /// PROGRESS BAR
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressValue,
                            minHeight: 20,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.chartIncome,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// PROGRESS TEXT
                      Text(
                        "${goal.progress.toInt()}/100",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}


////////////////////////////


Widget _summaryStatistics(AnalyticsProvider provider) {
  return _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TITLE
        const Text(
          "Summary Statistics",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        Row(
          children: [

            /// LEFT COLUMN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _summaryStatItem(
                    "Total Transactions",
                    provider.totalTransactions.toString(),
                    Colors.white,
                  ),

                  const SizedBox(height: 20),

                  _summaryStatItem(
                    "Savings Rate",
                    "${provider.savingsRate}%",
                    AppColors.chartIncome,
                  ),
                ],
              ),
            ),

            /// RIGHT COLUMN
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _summaryStatItem(
                    "Active Goals",
                    provider.activeGoals.toString(),
                    Colors.white,
                  ),

                  const SizedBox(height: 20),

                  _summaryStatItem(
                    "Completed Goals",
                    provider.debtRecords.toString(),
                    Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


Widget _summaryStatItem(
  String title,
  String value,
  Color valueColor,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),

      const SizedBox(height: 6),

      Text(
        value,
        style: TextStyle(
          color: valueColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}


Widget _card({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}
}