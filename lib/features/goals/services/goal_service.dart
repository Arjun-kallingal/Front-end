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
    };
  }

  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/goals"),
        headers: _getHeaders(),
      ).timeout(const Duration(seconds: 10));

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

  Future<bool> createGoal(GoalModel goal) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/goals"),
        headers: _getHeaders(),
        body: jsonEncode(goal.toJson()),
      ).timeout(const Duration(seconds: 10));

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
  // Add this inside lib/services/goal_service.dart
  Future<bool> depositToGoal(String goalId, double amount) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/goals/$goalId/deposit"),
        headers: _getHeaders(),
        body: jsonEncode({"amount": amount}), // Backend expects { amount: Number }
      ).timeout(const Duration(seconds: 10));

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
}