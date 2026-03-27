import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:front_end/navigation/navigation_service.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/account_provider.dart'; // ✅ Imports your real accounts
import '../provider/analytics_provider.dart';           // ✅ Imports your analytics data

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  // We use "all" by default to match the backend expectation
  String selectedAccountId = "all";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      // 1. Load the analytics data
      context.read<AnalyticsProvider>().fetchDashboard();
      
      // 2. Load the accounts so the dropdown has real data to display!
      context.read<AccountProvider>().loadAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final accountProvider = context.watch<AccountProvider>();

    // --- Loading State ---
    if (analyticsProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    // --- Error State ---
    if (analyticsProvider.error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  analyticsProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                  onPressed: () => analyticsProvider.fetchDashboard(accountId: selectedAccountId),
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    // --- Main UI ---
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
        ),
        title: const Text(
          "Analytics & Reports",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- Top Summary Card & Dropdown ---
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
                      _dropdownFilter(analyticsProvider, accountProvider),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summaryItem("Net", analyticsProvider.balance),
                      _summaryItem("Income", analyticsProvider.income),
                      _summaryItem("Expense", analyticsProvider.expense),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // --- Charts Scrollable Area ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => analyticsProvider.fetchDashboard(accountId: selectedAccountId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _incomeExpenseChart(analyticsProvider),
                    const SizedBox(height: 20),
                    _monthlyTrend(analyticsProvider),
                    const SizedBox(height: 20),
                    
                    if (analyticsProvider.categories.isNotEmpty) ...[
                      _categoryChart(analyticsProvider),
                      const SizedBox(height: 20),
                    ],
                    
                    if (analyticsProvider.goals.isNotEmpty) ...[
                      _goalProgress(analyticsProvider),
                      const SizedBox(height: 20),
                    ],
                    
                    _summaryStatistics(analyticsProvider),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================================
  // WIDGETS
  // ==========================================

  Widget _dropdownFilter(AnalyticsProvider analyticsProvider, AccountProvider accountProvider) {
    // Combine both cash and bank accounts into one list for the dropdown
    final allAccounts = [
      ...accountProvider.cashAccounts,
      ...accountProvider.bankAccounts
    ];

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selectedAccountId,
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        items: [
          const DropdownMenuItem(value: "all", child: Text("All Accounts")),
          ...allAccounts.map((acc) {
            return DropdownMenuItem(
              value: acc.id, // Sends the real MongoDB ID to your backend
              child: Text(acc.name), // Shows the user-friendly name
            );
          }).toList(),
        ],
        onChanged: (value) {
          if (value == null) return;
          
          setState(() {
            selectedAccountId = value;
          });
          
          // Fetch new data instantly when account changes
          analyticsProvider.fetchDashboard(accountId: value);
        },
      ),
    );
  }

  Widget _summaryItem(String title, double value) {
    Color amountColor = Colors.black;
    if (title == "Income" || title == "Net") amountColor = AppColors.chartIncome;
    if (title == "Expense") amountColor = AppColors.chartExpense;

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 13),
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
    final incomePercent = total == 0 ? 0 : (provider.income / total) * 100;
    final expensePercent = total == 0 ? 0 : (provider.expense / total) * 100;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Income vs Expense",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: total == 0 
              ? const Center(child: Text("No transaction data yet", style: TextStyle(color: Colors.grey)))
              : PieChart(
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
                  swapAnimationDuration: const Duration(milliseconds: 900),
                  swapAnimationCurve: Curves.easeInOut,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(color: AppColors.chartIncome, text: "Income (${incomePercent.toStringAsFixed(0)}%)"),
              const SizedBox(width: 30),
              _legendItem(color: AppColors.chartExpense, text: "Expense (${expensePercent.toStringAsFixed(0)}%)"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black54, fontSize: 13)),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: provider.monthly.isEmpty
                ? const Center(child: Text("Not enough data", style: TextStyle(color: Colors.grey)))
                : LineChart(
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
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(.3),
                          strokeWidth: 1,
                          dashArray: [6, 4],
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= provider.monthly.length || value.toInt() < 0) {
                                return const SizedBox();
                              }
                              final month = provider.monthly[value.toInt()].month;
                              final shortMonth = month.length > 3 ? month.substring(0, 3) : month;
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(shortMonth, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox();
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.black54, fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: provider.getIncomeSpots(),
                          isCurved: true,
                          color: AppColors.chartIncome,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                        LineChartBarData(
                          spots: provider.getExpenseSpots(),
                          isCurved: true,
                          color: AppColors.chartExpense,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
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
      if (c.amount > maxValue) maxValue = c.amount;
    }
    double maxY = maxValue > 0 ? ((maxValue / 200).ceil()) * 200 : 200;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Spending Categories",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                        if (value.toInt() >= provider.categories.length) return const SizedBox();
                        final category = provider.categories[value.toInt()].name;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            category.length > 5 ? "${category.substring(0, 5)}.." : category,
                            style: const TextStyle(color: Colors.black54, fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: maxY > 0 ? (maxY / 4) : 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.black54, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                          width: 25,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Column(
            children: provider.goals.map((goal) {
              double progressValue = goal.progress / 100;
              if (progressValue > 1.0) progressValue = 1.0; 

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: AlwaysStoppedAnimation(AppColors.chartIncome),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text("${goal.progress.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.black54, fontSize: 12)),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryStatItem("Total Transactions", provider.totalTransactions == 0 ? "--" : provider.totalTransactions.toString(), Colors.black),
                    const SizedBox(height: 20),
                    _summaryStatItem("Savings Rate", "${provider.savingsRate.toStringAsFixed(1)}%", AppColors.chartIncome),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _summaryStatItem("Active Goals", provider.activeGoals.toString(), Colors.black),
                    const SizedBox(height: 20),
                    _summaryStatItem("Completed Goals", provider.completedGoals.toString(), Colors.black),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStatItem(String title, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: valueColor, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}