import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';

class GoalService {
  final String baseUrl;

  GoalService({required this.baseUrl});

  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // "Authorization": "Bearer YOUR_TOKEN"
    };
  }

  /// GET ALL GOALS
  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/goals"),
            headers: _getHeaders(),
          )
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
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals"),
            headers: _getHeaders(),
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Create Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error during Creation: $e");
      return false;
    }
  }
  /// UPDATE GOAL
Future<bool> updateGoal(GoalModel goal) async {
  try {
    final response = await http
        .put(
          Uri.parse("$baseUrl/goals/${goal.id}"),
          headers: _getHeaders(),
          body: jsonEncode(goal.toJson()),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Update Failed: ${response.statusCode} - ${response.body}");
      return false;
    }
  } catch (e) {
    print("Network Error during Update: $e");
    return false;
  }
}

  /// DEPOSIT MONEY TO GOAL
  Future<bool> depositToGoal(String goalId, double amount) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/deposit"),
            headers: _getHeaders(),
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Deposit Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error during Deposit: $e");
      return false;
    }
  }

  /// WITHDRAW MONEY FROM GOAL
  Future<bool> withdrawFromGoal(String goalId, double amount) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/withdraw"),
            headers: _getHeaders(),
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Withdraw Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error during Withdraw: $e");
      return false;
    }
  }

  /// GET GOAL TRANSACTION HISTORY
  Future<List<dynamic>> getGoalHistory(String accountId) async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/goals/account/$accountId/history"),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return body['data'] ?? [];
      } else {
        print("History Fetch Failed: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching goal history: $e");
      return [];
    }
  }

  /// DELETE GOAL
  Future<bool> deleteGoal(String goalId) async {
    try {
      final response = await http
          .delete(
            Uri.parse("$baseUrl/goals/$goalId"),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print("Delete Failed: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error during Delete: $e");
      return false;
    }
  }
}