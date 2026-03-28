import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:front_end/navigation/navigation_service.dart';

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

    if (provider.error != null) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: provider.retry,
            child: const Text("Retry"),
          ),
        ),
      );
    }

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
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            NavigationService.bottomIndex.value = 0;
          },
        ),
        title: const Text(
          "Analytics & Reports",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Column(
        children: [

          /// HEADER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.centerRight,
                    child: _dropdownFilter(provider),
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

                  _incomeExpenseChart(provider),
                  const SizedBox(height: 20),

                  _monthlyTrend(provider),
                  const SizedBox(height: 20),

                  _categoryChart(provider),
                  const SizedBox(height: 20),

                  _goalProgress(provider),
                  const SizedBox(height: 20),

                  _summaryStatistics(provider),
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
    return DropdownButton<String>(
      value: selectedFilter,
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
    );
  }

  /// SUMMARY
  Widget _summaryItem(String title, double value) {
    Color color = Colors.black;

    if (title == "Income") color = Colors.green;
    if (title == "Expense") color = Colors.red;
    if (title == "Net") color = Colors.blue;

    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 5),
        Text(
          "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
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
          const Text("Income vs Expense"),

          const SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: provider.income,
                    color: Colors.green,
                  ),
                  PieChartSectionData(
                    value: provider.expense,
                    color: Colors.red,
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
                color: Colors.green,
              ),
              LineChartBarData(
                spots: provider.getExpenseSpots(),
                color: Colors.red,
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
                    color: Colors.red,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.name),
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
          _stat("Transactions", provider.totalTransactions.toString()),
          _stat("Savings Rate", "${provider.savingsRate.toStringAsFixed(1)}%"),
          _stat("Active Goals", provider.activeGoals.toString()),
          _stat("Completed Goals", provider.completedGoals.toString()),
        ],
      ),
    );
  }

  Widget _stat(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}