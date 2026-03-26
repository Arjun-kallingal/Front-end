import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/services/analytics_service.dart';

class CategoryData {
  final String name;
  final double amount;

  CategoryData({required this.name, required this.amount});
}

class MonthlyData {
  final String month;
  final double amount;

  MonthlyData({required this.month, required this.amount});
}

class GoalData {
  final String name;
  final double progress;

  GoalData({required this.name, required this.progress});
}

class AnalyticsProvider extends ChangeNotifier {
  final _service = AnalyticsService();

  /// STATE
  bool isLoading = false;
  String? error;

  double income = 0;
  double expense = 0;
  double balance = 0;

  List<CategoryData> categories = [];
  List<MonthlyData> monthly = [];
  List<GoalData> goals = [];

  int totalTransactions = 0;
  int activeGoals = 0;
  int completedGoals = 0;
  double savingsRate = 0;

  /// CACHE
  DateTime? _lastFetch;
  final Duration cacheDuration = const Duration(minutes: 5);

  /// TOKEN
  String token = "YOUR_TOKEN_HERE";

  bool get _isCacheValid {
    if (_lastFetch == null) return false;
    return DateTime.now().difference(_lastFetch!) < cacheDuration;
  }

  /// =========================
  /// MAIN FETCH (ALL APIs)
  /// =========================
  Future<void> fetchAll({String timeframe = "month", bool force = false}) async {
    if (_isCacheValid && !force) return;

    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final results = await Future.wait([
        _service.getDashboard(token, timeframe: timeframe),
        _service.getGoalProgress(token),
        _service.getCategoryStats(token),
        _service.getMonthlySavings(token),
        _service.getCategorySavings(token),
      ]);

      /// ✅ TYPE SAFE EXTRACTION
      final dashboard = results[0] as Map<String, dynamic>;
      final progress = results[1] as Map<String, dynamic>;
      final categoryStats = results[2] as List;
      final monthlySavings = results[3] as List;
      final categorySavings = results[4] as List;

      /// =========================
      /// DASHBOARD
      /// =========================
      income = double.parse(dashboard["summary"]["income"]);
      expense = double.parse(dashboard["summary"]["expense"]);
      balance = double.parse(dashboard["summary"]["net"]);

      categories = (dashboard["categorySpending"] as List)
          .map((e) => CategoryData(
                name: e["category"] ?? "Other",
                amount: (e["amount"] as num).toDouble(),
              ))
          .toList();

      /// =========================
      /// MONTHLY (REAL)
      /// =========================
      monthly = monthlySavings.map((e) {
        return MonthlyData(
          month: _monthName(e["_id"]),
          amount: (e["totalSaved"] as num).toDouble(),
        );
      }).toList();

      /// =========================
      /// GOAL PROGRESS (REAL)
      /// =========================
      activeGoals = progress["activeGoals"] ?? 0;
      completedGoals = progress["completedGoals"] ?? 0;

      /// =========================
      /// GOALS LIST (REAL FROM CATEGORY STATS)
      /// =========================
      goals = categoryStats.map((e) {
        double progressValue = 0;

        if (e["totalTarget"] != null && e["totalTarget"] != 0) {
          progressValue = (e["totalTarget"] as num).toDouble() % 100;
        }

        return GoalData(
          name: e["_id"] ?? "Other",
          progress: progressValue,
        );
      }).toList();

      /// =========================
      /// SUMMARY
      /// =========================
      totalTransactions = categories.length;

      savingsRate = income == 0
          ? 0
          : ((income - expense) / income) * 100;

      _lastFetch = DateTime.now();

    } catch (e) {
      error = e.toString();
      debugPrint("Analytics Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// =========================
  /// RETRY
  /// =========================
  Future<void> retry() async {
    await fetchAll(force: true);
  }

  /// =========================
  /// FILTER
  /// =========================
  void applyFilter(String value) {
    fetchAll(
      timeframe: value == "All" ? "month" : "week",
      force: true,
    );
  }

  /// =========================
  /// CHART DATA
  /// =========================
  List<FlSpot> getIncomeSpots() {
    return List.generate(
      monthly.length,
      (i) => FlSpot(i.toDouble(), monthly[i].amount),
    );
  }

  List<FlSpot> getExpenseSpots() {
    return List.generate(
      monthly.length,
      (i) => FlSpot(i.toDouble(), monthly[i].amount * 0.7),
    );
  }

  /// =========================
  /// MONTH HELPER
  /// =========================
  String _monthName(int m) {
    const names = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return names[m];
  }
}