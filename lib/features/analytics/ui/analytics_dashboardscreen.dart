import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../provider/analytics_provider.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(analyticsProvider.notifier);

    final income = notifier.totalIncome;
    final expense = notifier.totalExpense;
    final balance = notifier.balance;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Red container Head
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF3B3B),
                      Color(0xFFB91C1C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Analytics & Reports",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem("Net", "₹ $balance", Colors.greenAccent),
                        _summaryItem("Income", "₹ $income", Colors.greenAccent),
                        _summaryItem("Expense", "₹ $expense", Colors.white),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //Income & Expence donut graph
              _sectionTitle("Income vs Expense"),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _darkCardDecoration(),
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
                              value: income,
                              color: Colors.green,
                              radius: 60,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: expense,
                              color: Colors.red,
                              radius: 60,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legend("Income", income, Colors.green),
                        const SizedBox(width: 30),
                        _legend("Expense", expense, Colors.red),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Monthly Trend
              _sectionTitle("Monthly Trend"),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _darkCardDecoration(),
                child: SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 4000),
                            FlSpot(1, 4500),
                            FlSpot(2, 4800),
                            FlSpot(3, 4300),
                            FlSpot(4, 5000),
                          ],
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                        ),
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 3000),
                            FlSpot(1, 3500),
                            FlSpot(2, 3800),
                            FlSpot(3, 3200),
                            FlSpot(4, 4100),
                          ],
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Top Spending
              _sectionTitle("Top Spending Categories"),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _darkCardDecoration(),
                child: SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      barGroups: [
                        _bar(0, 1200),
                        _bar(1, 300),
                        _bar(2, 200),
                        _bar(3, 100),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Debt Overview
              _sectionTitle("Debt Overview"),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _darkCardDecoration(),
                child: Row(
                  children: [
                    Expanded(
                      child: _debtCard("To Receive", "₹1,000", Colors.green),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _debtCard("To Pay", "₹1,200", Colors.red),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Summary Starts
              _sectionTitle("Summary Statistics"),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: _darkCardDecoration(),
                child: Column(
                  children: const [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Transactions", style: TextStyle(color: Colors.white70)),
                        Text("10", style: TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Savings Rate", style: TextStyle(color: Colors.white70)),
                        Text("74%", style: TextStyle(color: Colors.green, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers

  BoxDecoration _darkCardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _legend(String text, double value, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          "$text: ₹${value.toStringAsFixed(0)}",
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.red,
          width: 18,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _debtCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}