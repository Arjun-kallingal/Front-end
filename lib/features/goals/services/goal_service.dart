import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';
import 'package:front_end/core/services/api_client.dart';

class GoalService {
  final String baseUrl;

  GoalService({required this.baseUrl});

  /// ===============================
  /// ✅ GET ALL GOALS
  /// ===============================
  Future<List<GoalModel>> getGoals() async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .get(Uri.parse("$baseUrl/goals"), headers: headers)
          .timeout(const Duration(seconds: 10));

      print("GET Goals URL: $baseUrl/goals");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

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
      print("GET Goals Error: $e");
      throw Exception("Failed to fetch goals");
    }
  }

  /// ===============================
  /// ✅ CREATE GOAL
  /// ===============================
  Future<bool> createGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals"),
            headers: headers,
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print("CREATE Goal URL: $baseUrl/goals");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("CREATE Goal Error: $e");
      return false;
    }
  }

  /// ===============================
  /// ✅ UPDATE GOAL
  /// ===============================
  Future<bool> updateGoal(GoalModel goal) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .put(
            Uri.parse("$baseUrl/goals/${goal.id}"),
            headers: headers,
            body: jsonEncode(goal.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print("UPDATE Goal URL: $baseUrl/goals/${goal.id}");
      print("Status: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE Goal Error: $e");
      return false;
    }
  }

  /// ===============================
  /// ✅ DELETE GOAL
  /// ===============================
  Future<bool> deleteGoal(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .delete(
            Uri.parse("$baseUrl/goals/$goalId"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      print("DELETE Goal URL: $baseUrl/goals/$goalId");
      print("Status: ${response.statusCode}");

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("DELETE Goal Error: $e");
      return false;
    }
  }

  /// ===============================
  /// ✅ DEPOSIT TO GOAL
  /// ===============================
  Future<bool> depositToGoal(String goalId, double amount) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/deposit"),
            headers: headers,
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      print("DEPOSIT URL: $baseUrl/goals/$goalId/deposit");

      return response.statusCode == 200;
    } catch (e) {
      print("DEPOSIT Error: $e");
      return false;
    }
  }

  /// ===============================
  /// ✅ WITHDRAW FROM GOAL
  /// ===============================
  Future<bool> withdrawFromGoal(String goalId, double amount) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/withdraw"),
            headers: headers,
            body: jsonEncode({"amount": amount}),
          )
          .timeout(const Duration(seconds: 10));

      print("WITHDRAW URL: $baseUrl/goals/$goalId/withdraw");

      return response.statusCode == 200;
    } catch (e) {
      print("WITHDRAW Error: $e");
      return false;
    }
  }

  /// ===============================
  /// ✅ GET GOAL HISTORY (by goalId)
  /// ===============================
  Future<List<dynamic>> getGoalHistory(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .get(
            Uri.parse("$baseUrl/goals/$goalId/history"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        return body['data'] ?? [];
      }

      return [];
    } catch (e) {
      print("History Error: $e");
      return [];
    }
  }

  /// ===============================
  /// ✅ GET ACCOUNT GOAL HISTORY
  /// ===============================
  Future<List<dynamic>> getAccountGoalHistory(String accountId) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .get(
            Uri.parse("$baseUrl/goals/account/$accountId/history"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        return body['data'] ?? [];
      }

      return [];
    } catch (e) {
      print("Account History Error: $e");
      return [];
    }
  }
}