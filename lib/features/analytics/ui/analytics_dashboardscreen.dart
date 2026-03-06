import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/analytics_provider.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Listen to the Notifier
    final notifier = context.watch<AnalyticsNotifier>();
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // 2. Get Calculated Data from Provider
    final income = notifier.totalIncome;
    final expense = notifier.totalExpense;
    final balance = notifier.balance;
    final selectedFilter = notifier.state.selectedFilter;

    // Calculated Summary Stats
    final int totalTransactions = notifier.filteredTransactions.length;
    final double savingRate = income == 0 ? 0.0 : ((income - expense) / income) * 100;
    
    // Note: You can add these to your model/provider later for full accuracy
    const int activeGoals = 4;
    const int debtRecords = 6;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER SECTION
              _header(context, textTheme, balance, income, expense, selectedFilter, notifier),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // INCOME VS EXPENSE DONUT
                    _sectionTitle(context, "Income vs Expense"),
                    const SizedBox(height: 20),
                    _donutChart(income, expense),

                    const SizedBox(height: 40),

                    // MONTHLY TREND LINE CHART
                    _sectionTitle(context, "Monthly Trend"),
                    const SizedBox(height: 20),
                    _monthlyTrendChart(notifier),

                    const SizedBox(height: 40),

                    // TOP CATEGORIES BAR CHART
                    _sectionTitle(context, "Top Spending Categories"),
                    const SizedBox(height: 20),
                    _topSpendingChart(notifier),

                    const SizedBox(height: 40),

                    // GOALS PROGRESS
                    _sectionTitle(context, "Goals Progress"),
                    const SizedBox(height: 20),
                    _goalsChart(),

                    const SizedBox(height: 40),

                    // DEBT OVERVIEW
                    _sectionTitle(context, "Debt Overview"),
                    const SizedBox(height: 20),
                    _debtOverview(),

                    const SizedBox(height: 40),

                    // SUMMARY STATISTICS
                    _sectionTitle(context, "Summary Statistics"),
                    const SizedBox(height: 20),
                    _summaryStatistics(
                      context,
                      totalTransactions,
                      activeGoals,
                      savingRate,
                      debtRecords,
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER & FILTER =================

  Widget _header(BuildContext context, TextTheme textTheme, double balance,
      double income, double expense, String selectedFilter, AnalyticsNotifier notifier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        ),
        gradient: LinearGradient(
          colors: [Color(0xFF620E0E), Color(0xFF8E0B0B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Analytics & Reports",
                  style: textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: 22)),
              _dropdown(context, selectedFilter, notifier),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _summaryItem(context, "Net", "₹ ${balance.toStringAsFixed(0)}",
                    balance >= 0 ? AppColors.success : AppColors.error),
                _summaryItem(context, "Income", "₹ ${income.toStringAsFixed(0)}", AppColors.chartIncome),
                _summaryItem(context, "Expense", "₹ ${expense.toStringAsFixed(0)}", AppColors.chartExpense),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(BuildContext context, String selected, AnalyticsNotifier notifier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(51, 128, 33, 33),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: selected,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1E1E1E),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        style: const TextStyle(color: Colors.white),
        items: const ["All", "Cash", "Account"]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (value) {
          if (value != null) notifier.changeFilter(value);
        },
      ),
    );
  }

  // ================= CHARTS =================

  Widget _donutChart(double income, double expense) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                        value: income == 0 ? 1 : income,
                        color: AppColors.chartIncome,
                        radius: 60,
                        showTitle: false),
                    PieChartSectionData(
                        value: expense == 0 ? 1 : expense,
                        color: AppColors.chartExpense,
                        radius: 60,
                        showTitle: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(color: AppColors.chartIncome, text: "Income"),
                const SizedBox(width: 30),
                _legendItem(color: AppColors.chartExpense, text: "Expense"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthlyTrendChart(AnalyticsNotifier notifier) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      const months = ['Aug', 'Sep', 'Oct', 'Nov', 'Dec', 'Jan'];
                      if (val.toInt() >= 0 && val.toInt() < months.length) {
                        return Text(months[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.white54));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: notifier.getTrendSpots(true), // DYNAMIC INCOME
                  isCurved: true,
                  color: AppColors.chartIncome,
                  barWidth: 3,
                ),
                LineChartBarData(
                  spots: notifier.getTrendSpots(false), // DYNAMIC EXPENSE
                  isCurved: true,
                  color: AppColors.chartExpense,
                  barWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topSpendingChart(AnalyticsNotifier notifier) {
    final data = notifier.categoryData;
    if (data.isEmpty) return const Center(child: Text("No data for this filter"));
    
    return _barChart(
      data.keys.toList(),
      data.values.toList(),
      data.values.reduce((a, b) => a > b ? a : b) + 500,
      AppColors.chartExpense,
    );
  }

  Widget _goalsChart() {
    return _barChart(['Vacation', 'Car', 'Emergency'], [65, 55, 80], 100, Colors.blue);
  }

  Widget _barChart(List<String> labels, List<double> values, double maxY, Color color) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) {
                      if (val.toInt() >= 0 && val.toInt() < labels.length) {
                        return Text(labels[val.toInt()], style: const TextStyle(fontSize: 10, color: Colors.white54));
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              barGroups: List.generate(values.length, (i) => BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(toY: values[i], color: color, width: 20, borderRadius: BorderRadius.circular(4))],
              )),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HELPERS & STATS =================

  Widget _debtOverview() {
    return Row(
      children: [
        Expanded(child: _debtCard("To Receive", "₹1,000", Colors.green)),
        const SizedBox(width: 15),
        Expanded(child: _debtCard("To Pay", "₹1,200", Colors.red)),
      ],
    );
  }

  Widget _debtCard(String title, String amount, Color color) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _summaryStatistics(BuildContext context, int total, int active, double rate, int debt) {
    return Card(
      color: const Color(0xFF1E1E1E),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _statBox("Total Transactions", total.toString()),
                _statBox("Active Goals", active.toString()),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _statBox("Saving Rate", "${rate.toStringAsFixed(1)}%", color: AppColors.success),
                _statBox("Debt Records", debt.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String title, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 5),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _summaryItem(BuildContext context, String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _legendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}