import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:front_end/core/services/api_client.dart';
import 'package:front_end/core/services/api_config.dart';    // ✅ centralized base URL
import 'package:front_end/core/models/transaction_model.dart';

class TransactionService {

  static String get _baseUrl => "${ApiConfig.baseUrl}/api/transaction";

  /// --- 1. FETCH HISTORY ---
  static Future<TransactionHistoryResponse> getHistory({
    String? accountId,
    String? category,
    String? lastId,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (accountId != null && accountId != "All Accounts") {
        queryParams['accountId'] = accountId;
      }

      if (category != null && category != "All Categories") {
        queryParams['category'] = category;
      }

      // ✅ No userId in URL — backend reads from JWT
      final uri = Uri.parse('$_baseUrl/history')
          .replace(queryParameters: queryParams);

      final headers = await ApiClient.getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return TransactionHistoryResponse.fromJson(body);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Please login again");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }

  /// --- 2. PROCESS TRANSACTION ---
  static Future<Map<String, dynamic>> processTransaction({
    required String accountId,
    required String amount,
    required String type,
    required String category,
    String? description,
    String direction = "NORMAL",
    required String idempotencyKey,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();

      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: headers,
        body: jsonEncode({
          // ✅ No userId in body — backend extracts from JWT
          "accountId":       accountId,
          "amount":          amount,
          "transactionType": type.toUpperCase(),
          "direction":       direction,
          "category":        category,
          "description":     description ?? "",
          "idempotencyKey":  const Uuid().v4(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 201,
        "message": data['error'] ??
            (response.statusCode == 201 ? "Success" : "Failed"),
        "data": data,
      };
    } catch (e) {
      return {"success": false, "message": "Network Failure: $e"};
    }
  }
}