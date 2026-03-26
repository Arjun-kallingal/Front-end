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

class _AnalyticsDashboardScreenState
    extends State<AnalyticsDashboardScreen> {
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<AnalyticsProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    /// ✅ ERROR UI
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Something went wrong",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: provider.retry,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    /// ✅ LOADING
    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// ✅ MAIN UI
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

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

          /// HEADER CARD
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

                  /// SUMMARY
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

          /// BODY
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

  /// FILTER
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

          setState(() => selectedFilter = value);

          provider.fetchAll(
            timeframe: value == "All" ? "month" : "week",
            force: true,
          );
        },
      ),
    );
  }

  /// SUMMARY ITEM
  Widget _summaryItem(String title, double value) {
    Color color = Colors.white;

    if (title == "Income" || title == "Net") {
      color = AppColors.chartIncome;
    } else if (title == "Expense") {
      color = AppColors.chartExpense;
    }

    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 6),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  /// PIE CHART
  Widget _incomeExpenseChart(AnalyticsProvider provider) {
    return _card(
      child: Column(
        children: [
          const Text("Income vs Expense",
              style: TextStyle(color: Colors.white)),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: provider.income,
                    color: AppColors.chartIncome,
                  ),
                  PieChartSectionData(
                    value: provider.expense,
                    color: AppColors.chartExpense,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LINE CHART
  Widget _monthlyTrend(AnalyticsProvider provider) {
    return _card(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: provider.getIncomeSpots(),
                isCurved: true,
                color: AppColors.chartIncome,
              ),
              LineChartBarData(
                spots: provider.getExpenseSpots(),
                isCurved: true,
                color: AppColors.chartExpense,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// BAR CHART
  Widget _categoryChart(AnalyticsProvider provider) {
    return _card(
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            barGroups: List.generate(
              provider.categories.length,
              (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: provider.categories[i].amount,
                    color: AppColors.chartExpense,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// GOALS
  Widget _goalProgress(AnalyticsProvider provider) {
    return _card(
      child: Column(
        children: provider.goals.map((g) {
          return Column(
            children: [
              Text(g.name, style: const TextStyle(color: Colors.white)),
              LinearProgressIndicator(value: g.progress / 100),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// SUMMARY
  Widget _summaryStatistics(AnalyticsProvider provider) {
    return _card(
      child: Column(
        children: [
          _summaryStat("Transactions",
              provider.totalTransactions.toString()),
          _summaryStat("Savings Rate",
              "${provider.savingsRate.toStringAsFixed(1)}%"),
          _summaryStat("Active Goals",
              provider.activeGoals.toString()),
          _summaryStat("Completed Goals",
              provider.completedGoals.toString()), // ✅ FIXED
        ],
      ),
    );
  }

  Widget _summaryStat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}