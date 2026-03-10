*import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/goal_model.dart';

class GoalService {
  final String baseUrl;

  // REMOVED: getToken parameter
  GoalService({required this.baseUrl});

  // --- PRIVATE HELPERS ---

  // Simplified: No async needed, no token needed
  Map<String, String> _getHeaders() {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  // --- SEPARATED FETCHING LOGIC ---

  Future<List<GoalModel>> getGoals() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/goals"),
        headers: _getHeaders(), // Calling simplified helper
      );

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        
        // Handles if the response is { "data": [...] } or just [...]
        List data = [];
        if (body is Map && body.containsKey('data')) {
          data = body['data'];
        } else if (body is List) {
          data = body;
        }

        return data.map((json) => GoalModel.fromJson(json)).toList();
      } else {
        print("Fetch Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Network Error during Fetch: $e");
      return [];
    }
  }

  // --- SEPARATED CREATION LOGIC ---

  Future<bool> createGoal(GoalModel goal) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/goals"),
        headers: _getHeaders(), // Calling simplified helper
        body: jsonEncode(goal.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Success: Goal created in database.");
        return true;
      } else {
        print("Create Failed: ${response.statusCode}");
        print("Backend Message: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Network Error during Creation: $e");
      return false;
    }
  }
}*