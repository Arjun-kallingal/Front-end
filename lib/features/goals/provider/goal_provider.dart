import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService;

  // Dependency Injection allows for easier testing
  GoalProvider({GoalService? goalService})
      : _goalService = goalService ?? GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  List<GoalModel> _goals = [];
  List<GoalModel> _filteredGoals = [];
  
  bool _isLoading = false;
  String? _error; // Exposes errors to the UI

  List<GoalModel> get goals => _goals;
  List<GoalModel> get filteredGoals => _filteredGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _goalService.getGoals();
      _goals = data;
      _filteredGoals = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
    // 1. Cache the goal in case the server fails
    final goalIndex = _goals.indexWhere((g) => g.id == id);
    if (goalIndex == -1) return false;
    final cachedGoal = _goals[goalIndex];

    // 2. Optimistic UI update
    _goals.removeAt(goalIndex);
    _filteredGoals.removeWhere((g) => g.id == id);
    notifyListeners();

    // 3. Network call
    final success = await _goalService.deleteGoal(id);
    
    // 4. Rollback on failure
    if (!success) {
      _goals.insert(goalIndex, cachedGoal);
      _filteredGoals = List.from(_goals); 
      notifyListeners();
    }
    
    return success;
  }

  Future<List<dynamic>> getHistory(String goalId) {
    return _goalService.getGoalHistory(goalId);
  }
}