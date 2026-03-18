import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../data/analytics_model.dart';

class AnalyticsProvider extends ChangeNotifier {

  bool isLoading = false;
  String? error;

  /// Current filter
  String filter = "All";

  double income = 0;
  double expense = 0;
  double balance = 0;

int totalTransactions = 0;
int activeGoals = 0;
int debtRecords = 0;
double savingsRate = 0;

  List<CategoryData> categories = [];
  List<GoalData> goals = [];
  List<MonthlyData> monthly = [];

  /// Demo categories for UI preview if backend returns empty
  final List<CategoryData> demoCategories = [
    CategoryData(name: "Food", amount: 850),
    CategoryData(name: "Travel", amount: 420),
    CategoryData(name: "Shopping", amount: 600),
    CategoryData(name: "Bills", amount: 300),
    CategoryData(name: "Entertainment", amount: 250),
  ];

  /// Demo goals for UI preview
  final List<GoalData> demoGoals = [
    GoalData(name: "Emergency Fund", progress: 45),
    GoalData(name: "Vacation Trip", progress: 70),
    GoalData(name: "New Laptop", progress: 30),
  ];

  /// Fetch analytics dashboard
  Future<void> fetchDashboard({String? type}) async {

/////////// existing mock data for donut & monthly trend

    income = 6000;
    expense = 3500;
    balance = 2500;

  totalTransactions = 10;
activeGoals = 4;
debtRecords = 4;
savingsRate = 74;

    monthly = [
      MonthlyData(month: "Jan", income: 2000, expense: 1200),
      MonthlyData(month: "Feb", income: 2500, expense: 1500),
      MonthlyData(month: "Mar", income: 3000, expense: 1800),
      MonthlyData(month: "Apr", income: 2800, expense: 1600),
    ];

///////////////

    try {

      isLoading = true;
      error = null;
      notifyListeners();

      /// Build URL with filter
      String url = "https://your-api.com/analytics";

      if (type != null) {
        url = "$url?type=$type";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load analytics");
      }

      final jsonData = jsonDecode(response.body);

      final analytics = AnalyticsModel.fromJson(jsonData);

      income = analytics.income;
      expense = analytics.expense;
      balance = analytics.balance;

      categories = analytics.categories;
      goals = analytics.goals;
      monthly = analytics.monthly;

      /// if backend sends empty categories, show demo categories
      if (categories.isEmpty) {
        categories = demoCategories;
      }

      /// if backend sends empty goals, show demo goals
      if (goals.isEmpty) {
        goals = demoGoals;
      }

    } catch (e) {

      error = e.toString();

      /// if API fails completely, still show demo categories
      if (categories.isEmpty) {
        categories = demoCategories;
      }

      /// also show demo goals
      if (goals.isEmpty) {
        goals = demoGoals;
      }

    }

    isLoading = false;
    notifyListeners();
  }

  /// Called from dropdown in UI
  void applyFilter(String type) {

    filter = type;

    if (type == "All") {
      fetchDashboard();
    }

    else if (type == "Cash") {
      fetchDashboard(type: "CASH");
    }

    else if (type == "Account") {
      fetchDashboard(type: "ACCOUNT");
    }
  }

  /// Line chart income data
  List<FlSpot> getIncomeSpots() {

    return List.generate(
      monthly.length,
      (index) => FlSpot(
        index.toDouble(),
        monthly[index].income,
      ),
    );
  }

  /// Line chart expense data
  List<FlSpot> getExpenseSpots() {

    return List.generate(
      monthly.length,
      (index) => FlSpot(
        index.toDouble(),
        monthly[index].expense,
      ),
    );
  }
}