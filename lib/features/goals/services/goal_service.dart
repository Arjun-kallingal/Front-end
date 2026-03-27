import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';
import 'package:front_end/core/services/api_client.dart'; // ✅ JWT headers

class GoalService {
  final String baseUrl;

  GoalService({required this.baseUrl});

  // ✅ Removed _getHeaders() — ApiClient.getHeaders() handles JWT automatically

  /// GET ALL GOALS
  Future<List<GoalModel>> getGoals() async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .get(Uri.parse("$baseUrl/goals"), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        List data = [];
        if (body is Map && body.containsKey('data')) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        }
        return data.map((json) => GoalModel.fromJson(json)).toList();
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to fetch goals: $e");
    }
  }

  /// CREATE GOAL
  Future<bool> createGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals"),
            headers: headers,
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// UPDATE GOAL
  Future<bool> updateGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .put(
            Uri.parse("$baseUrl/goals/${goal.id}"),
            headers: headers,
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// DEPOSIT MONEY TO GOAL
  Future<bool> depositToGoal(String goalId, double amount) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/deposit"),
            headers: headers,
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// WITHDRAW MONEY FROM GOAL
  Future<bool> withdrawFromGoal(String goalId, double amount) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/withdraw"),
            headers: headers,
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// GET GOAL TRANSACTION HISTORY
  Future<List<dynamic>> getGoalHistory(String accountId) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .get(
            Uri.parse("$baseUrl/goals/account/$accountId/history"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// DELETE GOAL
  Future<bool> deleteGoal(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders(); // ✅
      final response = await http
          .delete(
            Uri.parse("$baseUrl/goals/$goalId"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}