import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService =
      GoalService(baseUrl: "http://localhost:5000/api");

  List<GoalModel> _goals = [];
  List<GoalModel> _filteredGoals = [];
  bool _isLoading = false;

  List<GoalModel> get goals => _goals;
  List<GoalModel> get filteredGoals => _filteredGoals;
  bool get isLoading => _isLoading;

  Future<void> fetchGoals() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _goalService.getGoals();
      _goals = data;
      _filteredGoals = data;
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void searchGoals(String value) {
    _filteredGoals = _goals
        .where((g) =>
            g.title.toLowerCase().contains(value.toLowerCase()) ||
            g.category.toLowerCase().contains(value.toLowerCase()))
        .toList();

    notifyListeners();
  }

  void showActiveGoals() {
    _filteredGoals = _goals.where((g) => g.progress < 1).toList();
    notifyListeners();
  }

  void showCompletedGoals() {
    _filteredGoals = _goals.where((g) => g.progress >= 1).toList();
    notifyListeners();
  }

  void showAllGoals() {
    _filteredGoals = _goals;
    notifyListeners();
  }

  Future<bool> createGoal(GoalModel goal) async {
    final success = await _goalService.createGoal(goal);
    if (success) await fetchGoals();
    return success;
  }

  Future<bool> deleteGoal(String id) async {
    await _goalService.deleteGoal(id);
    await fetchGoals();
    return true;
  }

  Future<bool> deposit(String goalId, double amount) async {
    final success = await _goalService.depositToGoal(goalId, amount);
    if (success) await fetchGoals();
    return success;
  }

  Future<bool> withdraw(String goalId, double amount) async {
    final success = await _goalService.withdrawFromGoal(goalId, amount);
    if (success) await fetchGoals();
    return success;
  }

  Future<List<dynamic>> getHistory(String goalId) {
    return _goalService.getGoalHistory(goalId);
  }
}