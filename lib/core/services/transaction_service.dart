import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:front_end/core/models/transaction_model.dart';

class TransactionService {
  // 💡 Tip: 10.0.2.2 for Android Emulator, localhost for iOS/Web
  static const String _baseUrl = "http://localhost:5000/api/transaction";

  /// --- 1. FETCH HISTORY (REFINED) ---
  /// Now supports accountId and category filtering via query parameters.
  static Future<TransactionHistoryResponse> getHistory(
    String userId, {
    String? accountId,
    String? category,
  }) async {
    try {
      // 🎯 Build the URI with dynamic query parameters
      final Map<String, String> queryParams = {};
      
      if (accountId != null && accountId != "All Accounts") {
        queryParams['accountId'] = accountId;
      }
      
      // We pass category to the backend to reduce payload size
      if (category != null && category != "All Categories") {
        queryParams['category'] = category;
      }

      final uri = Uri.parse('$_baseUrl/history/$userId').replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        
        // Note: Even if you removed the UI for balance, the model likely 
        // still expects these fields. Keep the parsing logic to avoid crashes.
        return TransactionHistoryResponse.fromJson(body);
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }

  /// --- 2. PROCESS TRANSACTION ---
  /// Sends an atomic request to the ledger controller
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
      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "accountId": accountId,
          "amount": amount,
          "transactionType": type.toUpperCase(),
          "direction": direction,
          "category": category,
          "description": description ?? "",
          // 🛡️ IdempotencyKey prevents double-charging on laggy connections
          "idempotencyKey": const Uuid().v4(),
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "success": response.statusCode == 201,
        "message": data['error'] ?? (response.statusCode == 201 ? "Success" : "Failed"),
        "data": data
      };
    } catch (e) {
      return {"success": false, "message": "Network Failure: $e"};
    }
  }
}