import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/goal_model.dart';

class GoalService {
  final String baseUrl;
  final String token;

  GoalService({
    required this.baseUrl,
    required this.token,
  });

  Map<String, String> get headers => {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

  /// CREATE GOAL
  Future<GoalModel> createGoal(GoalModel goal) async {
    final response = await http.post(
      Uri.parse("$baseUrl/goals"),
      headers: headers,
      body: jsonEncode(goal.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return GoalModel.fromJson(data["data"]);
    } else {
      throw Exception(data["message"]);
    }
  }

  /// GET ALL GOALS
  Future<List<GoalModel>> getGoals() async {
    final response = await http.get(
      Uri.parse("$baseUrl/goals"),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return List<GoalModel>.from(
        data["data"].map((goal) => GoalModel.fromJson(goal)),
      );
    } else {
      throw Exception(data["message"]);
    }
  }

  /// UPDATE GOAL
  Future<GoalModel> updateGoal(String goalId, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse("$baseUrl/goals/$goalId"),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return GoalModel.fromJson(data["data"]);
    } else {
      throw Exception(data["message"]);
    }
  }

  /// DELETE GOAL
  Future<void> deleteGoal(String goalId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/goals/$goalId"),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data["message"]);
    }
  }

  /// DEPOSIT TO GOAL
  Future<GoalModel> depositToGoal(String goalId, double amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/goals/$goalId/deposit"),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return GoalModel.fromJson(data["data"]);
    } else {
      throw Exception(data["message"]);
    }
  }

  /// WITHDRAW FROM GOAL
  Future<void> withdrawFromGoal(String goalId, double amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/goals/$goalId/withdraw"),
      headers: headers,
      body: jsonEncode({
        "amount": amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data["message"]);
    }
  }

  /// GOAL SUMMARY
  Future<Map<String, dynamic>> getGoalSummary() async {
    final response = await http.get(
      Uri.parse("$baseUrl/goals/summary"),
      headers: headers,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["data"];
    } else {
      throw Exception(data["message"]);
    }
  }
}