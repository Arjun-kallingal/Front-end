import 'dart:convert';
import 'package:http/http.dart' as http;

// Adjust these imports to match your project structure
import 'package:front_end/core/services/api_config.dart';
import '../../../../core/services/api_client.dart';
import '../data/analytics_model.dart';

class AnalyticsService {
  /// Fetches the main dashboard data (income, expense, charts)
  static Future<AnalyticsModel> getDashboardData({
    String accountId = "all", 
    String timeframe = "month"
  }) async {
    final headers = await ApiClient.getHeaders();
    final url = Uri.parse("${ApiConfig.baseUrl}/api/analytics/dashboard?timeframe=$timeframe&accountId=$accountId");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return AnalyticsModel.fromJson(json);
      } else {
        throw Exception(json['message'] ?? "Failed to parse dashboard data");
      }
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }

  /// Fetches the goal summary statistics (active/completed goals)
  static Future<Map<String, dynamic>> getGoalProgressStats() async {
    try {
      final headers = await ApiClient.getHeaders();
      final url = Uri.parse("${ApiConfig.baseUrl}/api/analytics/progress");

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return json['data'];
        }
      }
      return {}; 
    } catch (e) {
      print("AnalyticsService: Failed to fetch goal stats - $e");
      return {}; // Return empty map so it doesn't crash the main dashboard
    }
  }
}