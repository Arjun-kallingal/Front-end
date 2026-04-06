import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_config.dart';

class NotificationService {
  static String get baseUrl => "${ApiConfig.baseUrl}/api/notifications";

  static Future<List<dynamic>> fetchNotifications() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) { return []; }
  }

  // 🔥 NEW: PATCH request for a single notification
  static Future<bool> markAsRead(String id) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/$id/read'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> markAllAsRead() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.patch(Uri.parse('$baseUrl/read-all'), headers: headers);
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
  // ... existing code ...

  // 🔥 DELETE SINGLE (Separate Clear)
  static Future<bool> deleteNotification(String id) async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'), // Hits router.delete('/:id')
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // 🔥 DELETE ALL (Super Clear)
  static Future<bool> deleteAllNotifications() async {
    try {
      final headers = await ApiClient.getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/delete-all'), // Hits router.delete('/delete-all')
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
}
