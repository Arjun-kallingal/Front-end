import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Adjust these imports to match your project's exact folder structure
import '../data/analytics_model.dart';
import '../service/service.dart';

class AnalyticsProvider extends ChangeNotifier {
  // --- UI State ---
  bool isLoading = false;
  String? error;
  String filter = "All";

  // --- Summary Data ---
  double income = 0.0;
  double expense = 0.0;
  double balance = 0.0;

  // --- Statistics ---
  int totalTransactions = 0; // Note: Your backend doesn't send this yet, defaults to 0
  int activeGoals = 0;
  int completedGoals = 0;
  double savingsRate = 0.0;

  // --- Lists for UI & Charts ---
  List<CategoryData> categories = [];
  List<GoalData> goals = [];
  List<MonthlyData> monthly = [];

  /// Fetches all dashboard data and statistics simultaneously
  Future<void> fetchDashboard({String accountId = "all", String timeframe = "month"}) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      // 1. Fetch both sets of data concurrently using the Service
      final results = await Future.wait([
        AnalyticsService.getDashboardData(accountId: accountId, timeframe: timeframe),
        AnalyticsService.getGoalProgressStats(),
      ]);

      // 2. Unpack the Dashboard Data
      final analytics = results[0] as AnalyticsModel;
      income = analytics.income;
      expense = analytics.expense;
      balance = analytics.balance;
      categories = analytics.categories;
      goals = analytics.goals;
      monthly = analytics.monthly;
      
      // Calculate Savings Rate dynamically
      // Formula: ((Income - Expense) / Income) * 100
      savingsRate = income > 0 ? ((income - expense) / income * 100) : 0.0;
      if (savingsRate < 0) savingsRate = 0.0; // Prevent negative visual percentage

      // 3. Unpack the Goal Stats Data
      final goalStats = results[1] as Map<String, dynamic>;
      activeGoals = goalStats['activeGoals'] ?? 0;
      completedGoals = goalStats['completedGoals'] ?? 0;

    } catch (e) {
      error = e.toString().replaceAll("Exception: ", ""); // Clean up the error message
      print("AnalyticsProvider Error: $error"); 
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Handles dropdown filter changes from the UI
  void applyFilter(String type, {String? specificAccountId}) {
    filter = type;
    
    // Once you have real Account IDs, you can pass them here.
    // For now, it maps the UI selection to the backend logic.
    if (type == "All") {
      fetchDashboard(accountId: "all");
    } else if (type == "Cash") {
      // Replace "specificAccountId" with your actual Cash Account ID later
      fetchDashboard(accountId: specificAccountId ?? "all");
    } else if (type == "Account") {
      // Replace "specificAccountId" with your actual Bank Account ID later
      fetchDashboard(accountId: specificAccountId ?? "all");
    } else {
      fetchDashboard(accountId: "all");
    }
  }

  /// Generates the (X, Y) coordinates for the Income Line Chart
  List<FlSpot> getIncomeSpots() {
    if (monthly.isEmpty) {
      return [const FlSpot(0, 0)]; // Prevent fl_chart crash if no data exists
    }
    return List.generate(
      monthly.length,
      (index) => FlSpot(index.toDouble(), monthly[index].income),
    );
  }

  /// Generates the (X, Y) coordinates for the Expense Line Chart
  List<FlSpot> getExpenseSpots() {
    if (monthly.isEmpty) {
      return [const FlSpot(0, 0)]; // Prevent fl_chart crash if no data exists
    }
    return List.generate(
      monthly.length,
      (index) => FlSpot(index.toDouble(), monthly[index].expense),
    );
  }
}