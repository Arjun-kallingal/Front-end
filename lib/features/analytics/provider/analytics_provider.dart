import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/analytics_model.dart';

class AnalyticsState {
  final String selectedFilter;
  final List<AnalyticsModel> transactions;
  final bool isLoading;

  AnalyticsState({
    required this.selectedFilter,
    required this.transactions,
    this.isLoading = false,
  });

  AnalyticsState copyWith({
    String? selectedFilter,
    List<AnalyticsModel>? transactions,
    bool? isLoading,
  }) {
    return AnalyticsState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AnalyticsNotifier extends ChangeNotifier {
  AnalyticsState _state = AnalyticsState(selectedFilter: "All", transactions: []);

  AnalyticsState get state => _state;

  // --- Filtered Data ---
  List<AnalyticsModel> get filteredTransactions {
    if (_state.selectedFilter == "All") return _state.transactions;
    return _state.transactions
        .where((t) => t.type.toLowerCase() == _state.selectedFilter.toLowerCase())
        .toList();
  }

  // --- Logic for Summary Card ---
  double get totalIncome => filteredTransactions
      .where((t) => t.transactionType == 'INCOME')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpense => filteredTransactions
      .where((t) => t.transactionType == 'EXPENSE')
      .fold(0.0, (sum, item) => sum + item.amount.abs());

  double get balance => totalIncome - totalExpense;

  // --- Logic for Top Spending (Bar Chart) ---
  Map<String, double> get categoryData {
    Map<String, double> data = {};
    for (var t in filteredTransactions.where((t) => t.transactionType == 'EXPENSE')) {
      data[t.category] = (data[t.category] ?? 0) + t.amount.abs();
    }
    return data;
  }

  // --- Logic for Monthly Trend (Line Chart) ---
  List<FlSpot> getTrendSpots(bool isIncome) {
    // This groups transactions by month (0-11)
    Map<int, double> monthlySums = {};
    for (var t in filteredTransactions.where((t) => 
        (isIncome ? t.transactionType == 'INCOME' : t.transactionType == 'EXPENSE'))) {
      int month = t.date.month - 1; 
      monthlySums[month] = (monthlySums[month] ?? 0) + t.amount.abs();
    }
    
    return List.generate(6, (index) {
      return FlSpot(index.toDouble(), monthlySums[index + 7] ?? 0.0); // Showing last 6 months
    });
  }

  void changeFilter(String value) {
    _state = _state.copyWith(selectedFilter: value);
    notifyListeners();
  }

  // Add your API fetch logic here later to populate _state.transactions
}