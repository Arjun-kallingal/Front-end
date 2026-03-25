import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:front_end/navigation/navigation_service.dart';

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

      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
        ),
        title: const Text(
          "Analytics & Reports",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(28),
              ),

              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _dropdownFilter(provider),
                    ],
                  ),

                  const SizedBox(height: 10),

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

  Widget _dropdownFilter(AnalyticsProvider provider) {

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(

        value: selectedFilter,

        dropdownColor: Colors.white,

        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),

        style: const TextStyle(color: Colors.black),

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

  Widget _summaryItem(String title, double value) {

    Color amountColor = Colors.black;

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
            color: Colors.black54,
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
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(

              PieChartData(

                centerSpaceRadius: 55,

                sectionsSpace: 2,

                sections: [

                  PieChartSectionData(
                    value: provider.income,
                    color: AppColors.chartIncome,
                    radius: 60,
                    showTitle: false,
                  ),

                  PieChartSectionData(
                    value: provider.expense,
                    color: AppColors.chartExpense,
                    radius: 60,
                    showTitle: false,
                  ),
                ],
              ),

              swapAnimationDuration:
              const Duration(milliseconds: 900),

              swapAnimationCurve: Curves.easeInOut,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              _legendItem(
                color: AppColors.chartIncome,
                text: "Income (${incomePercent.toStringAsFixed(0)}%)",
              ),

              const SizedBox(width: 30),

              _legendItem(
                color: AppColors.chartExpense,
                text: "Expense (${expensePercent.toStringAsFixed(0)}%)",
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
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _monthlyTrend(AnalyticsProvider provider) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Monthly Trend",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(

                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.withOpacity(.5)),
                    bottom: BorderSide(color: Colors.grey.withOpacity(.5)),
                  ),
                ),

                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(.3),
                      strokeWidth: 1,
                      dashArray: [6,4],
                    );
                  },
                ),

                titlesData: FlTitlesData(

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
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,

                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black54,
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

                lineBarsData: [

                  LineChartBarData(
                    spots: provider.getIncomeSpots(),
                    isCurved: true,
                    color: AppColors.chartIncome,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  ),

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
        ],
      ),
    );
  }

  Widget _categoryChart(AnalyticsProvider provider) {

    double maxValue = 0;

    for (var c in provider.categories) {
      if (c.amount > maxValue) {
        maxValue = c.amount;
      }
    }

    double maxY = ((maxValue / 200).ceil()) * 200;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Top Spending Categories",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 220,
            child: BarChart(

              BarChartData(

                minY: 0,
                maxY: maxY,

                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: Colors.grey.withOpacity(.5)),
                    bottom: BorderSide(color: Colors.grey.withOpacity(.5)),
                  ),
                ),

                titlesData: FlTitlesData(

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
                              color: Colors.black54,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 200,

                      getTitlesWidget: (value, meta) {

                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black54,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalProgress(AnalyticsProvider provider) {

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Goal Progress",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Column(
            children: provider.goals.map((goal) {

              double progressValue = goal.progress / 100;

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [

                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 20,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(
                                AppColors.chartIncome,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "${goal.progress.toInt()}/100",
                          style: const TextStyle(
                            color: Colors.black54,
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

  Widget _summaryStatistics(AnalyticsProvider provider) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "Summary Statistics",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          Row(
            children: [

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _summaryStatItem(
                      "Total Transactions",
                      provider.totalTransactions.toString(),
                      Colors.black,
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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    _summaryStatItem(
                      "Active Goals",
                      provider.activeGoals.toString(),
                      Colors.black,
                    ),

                    const SizedBox(height: 20),

                    _summaryStatItem(
                      "Completed Goals",
                      provider.debtRecords.toString(),
                      Colors.black,
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
            color: Colors.black54,
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

