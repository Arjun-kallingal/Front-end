import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';
import 'package:front_end/core/services/api_client.dart';
// import 'package:uuid/uuid.dart'; // Highly recommended for generating idempotencyKeys!

class GoalService {
  final String baseUrl;

  GoalService({required this.baseUrl});

  /// GET ALL GOALS
  Future<List<GoalModel>> getGoals(
      {int page = 1, int limit = 20, String? status}) async {
    try {
      final headers = await ApiClient.getHeaders();
      String query = "?page=$page&limit=$limit";
      if (status != null) query += "&status=$status";

      final response = await http
          .get(Uri.parse("$baseUrl/goals$query"), headers: headers)
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
      final headers = await ApiClient.getHeaders();
      final response = await http
          .post(
            Uri.parse("$baseUrl/goals"),
            headers: headers,
            body: jsonEncode(goal.toJson(isCreate: true)), // Make sure your model uses this flag!
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
      final headers = await ApiClient.getHeaders();
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

  /// DEPOSIT MONEY TO GOAL (The Expense)
  ///
  /// Requires [accountId] to deduct funds from, and [idempotencyKey] for safe retries.
  Future<Map<String, dynamic>> depositToGoal(
    String goalId,
    String accountId,
    double amount,
    String idempotencyKey, {
    String? transactedAt,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();

      final Map<String, dynamic> body = {
        "accountId": accountId,
        "amount": amount,
        "idempotencyKey": idempotencyKey,
        if (transactedAt != null) "transactedAt": transactedAt,
      };

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/deposit"),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(response.body);

      // Handle 200 (Success) or 409 (Duplicate, which is safely treated as a success)
      if (response.statusCode == 200 || response.statusCode == 409) {
        return {
          'success': true,
          'txid': decoded['txid'],
          'availableBalance': decoded['availableBalance'], // Pass this to UI to update account state instantly
          'isDuplicate': response.statusCode == 409
        };
      } else {
        return {
          'success': false, 
          'message': decoded['message'] ?? 'Deposit failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// WITHDRAW MONEY FROM GOAL (The Income)
  ///
  /// Requires [accountId] to send funds to, and [idempotencyKey] for safe retries.
  Future<Map<String, dynamic>> withdrawFromGoal(
    String goalId,
    String accountId,
    double amount,
    String idempotencyKey, {
    String? transactedAt,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      
      final Map<String, dynamic> body = {
        "accountId": accountId,
        "amount": amount,
        "idempotencyKey": idempotencyKey,
        if (transactedAt != null) "transactedAt": transactedAt,
      };

      final response = await http
          .post(
            Uri.parse("$baseUrl/goals/$goalId/withdraw"),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 409) {
        return {
          'success': true,
          'txid': decoded['txid'],
          'availableBalance': decoded['availableBalance'], 
          'isDuplicate': response.statusCode == 409
        };
      } else {
        return {
          'success': false, 
          'message': decoded['message'] ?? 'Withdrawal failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// DELETE GOAL
  /// 
  /// Simply deletes the goal from the database.
  Future<Map<String, dynamic>> deleteGoal(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http
          .delete(
            Uri.parse("$baseUrl/goals/$goalId"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final decoded = jsonDecode(response.body);
        return {'success': false, 'message': decoded['message'] ?? 'Delete failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  /// GET INDIVIDUAL GOAL TRANSACTION HISTORY
  Future<List<dynamic>> getGoalHistory(String goalId) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/goals/$goalId/history"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'] is List ? body['data'] : [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}