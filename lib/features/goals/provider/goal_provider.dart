import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService =
      GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

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
    _goals.removeWhere((g) => g.id == id);
    _filteredGoals.removeWhere((g) => g.id == id);
    notifyListeners();
    await _goalService.deleteGoal(id);
    return true;
  }

  Future<List<dynamic>> getHistory(String goalId) {
    return _goalService.getGoalHistory(goalId);
  }
}
