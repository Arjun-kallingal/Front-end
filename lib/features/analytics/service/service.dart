import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:front_end/core/services/api_config.dart';
import '../../../../core/services/api_client.dart';
import '../data/analytics_model.dart';

class AnalyticsService {
  /// Fetches the dashboard data using dynamic query parameters
  /// timeframe: 'Day', 'Week', 'Month', 'Year'
  /// accountId: 'all' or a specific MongoDB ObjectId
  static Future<AnalyticsModel> getDashboardData({
    String accountId = "all", 
    String timeframe = "Month"
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      
      // Build the URL with the new query parameters
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/api/analytics/dashboard?timeframe=$timeframe&accountId=$accountId"
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        if (json['success'] == true) {
          // Pass the JSON to the factory constructor in your model
          return AnalyticsModel.fromJson(json);
        } else {
          throw Exception(json['message'] ?? "Failed to parse dashboard data");
        }
      } else {
        // Handle unauthorized or server errors
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      // Re-throw so the Provider can catch it and update the 'error' state
      throw Exception("AnalyticsService: $e");
    }
  }
}