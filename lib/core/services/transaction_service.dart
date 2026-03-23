import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:front_end/core/services/api_client.dart';
import 'package:front_end/core/models/transaction_model.dart';

class TransactionService {
  static String get _baseUrl {
    return "http://localhost:5000/api/transaction";
  }

  /// --- 1. FETCH HISTORY ---
  static Future<TransactionHistoryResponse> getHistory(
    String userId, {
    String? accountId,
    String? category,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (accountId != null && accountId != "All Accounts") {
        queryParams['accountId'] = accountId;
      }

      if (category != null && category != "All Categories") {
        queryParams['category'] = category;
      }

      final uri = Uri.parse('$_baseUrl/history/$userId')
          .replace(queryParameters: queryParams);

      print("TRANSACTION API CALL: $uri");

      /// ✅ GET HEADERS WITH TOKEN
      final headers = await ApiClient.getHeaders();

      final response = await http.get(
        uri,
        headers: headers,
      );

      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return TransactionHistoryResponse.fromJson(body);
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Please login again");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("TRANSACTION SERVICE ERROR: $e");
      throw Exception("Connection Error: $e");
    }
  }

  /// --- 2. PROCESS TRANSACTION ---
  static Future<Map<String, dynamic>> processTransaction({
    required String userId,
    required String accountId,
    required String amount,
    required String type,
    required String category,
    String? description,
    String direction = "NORMAL",
  }) async {
    try {
      /// ✅ GET HEADERS WITH TOKEN
      final headers = await ApiClient.getHeaders();

      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: headers,
        body: jsonEncode({
          "userId": userId,
          "accountId": accountId,
          "amount": amount,
          "transactionType": type.toUpperCase(),
          "direction": direction,
          "category": category,
          "description": description ?? "",
          "idempotencyKey": const Uuid().v4(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 201,
        "message": data['error'] ??
            (response.statusCode == 201 ? "Success" : "Failed"),
        "data": data
      };
    } catch (e) {
      return {"success": false, "message": "Network Failure: $e"};
    }
  }
}