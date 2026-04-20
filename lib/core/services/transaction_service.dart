import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:front_end/core/services/api_client.dart';
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/models/transaction_model.dart';

class TransactionService {
  static String get _baseUrl => "${ApiConfig.baseUrl}/api/transaction";

  /// --- 1. FETCH HISTORY ---
  static Future<TransactionHistoryResponse> getHistory({
    String? accountId,
    String? category,
    String? lastId,
    DateTime? startDate,     // <-- NEW
    DateTime? endDate,       // <-- NEW
    String? searchQuery,     // <-- NEW
    String? type,            // <-- NEW
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (accountId != null && accountId != "All Accounts") {
        queryParams['accountId'] = accountId;
      }
      if (category != null && category != "All Categories" && category != "All") {
        queryParams['category'] = category;
      }
      if (lastId != null) {
        queryParams['lastId'] = lastId;
      }
      // Add new date filters (convert DateTime to ISO string for backend)
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['searchQuery'] = searchQuery;
      }
      if (type != null && type != "All Type") {
        queryParams['type'] = type;
      }

      final uri = Uri.parse('$_baseUrl/history').replace(queryParameters: queryParams);
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
    String direction = "STANDARD",
    String? idempotencyKey,
    String? transactedAt,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      final effectiveKey = idempotencyKey ?? const Uuid().v4();

      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: headers,
        body: jsonEncode({
          "accountId": accountId,
          "amount": amount,
          "transactionType": type.toUpperCase(),
          "direction": direction,
          "category": category,
          "description": description ?? "",
          "idempotencyKey": effectiveKey,
          "transactedAt": transactedAt,
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

  /// --- 3. REVERSE TRANSACTION ---
  static Future<Map<String, dynamic>> reverseTransaction({
    required TransactionModel originalTx,
    String? reason,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();

      final body = jsonEncode({
        "accountId": originalTx.accountId,
        "amount": originalTx.amount.abs().toString(),
        "transactionType": "REVERSAL",
        "direction": "REVERSAL",
        "category": originalTx.category,
        "description": reason ?? "Reversing ${originalTx.title}",
        "idempotencyKey":
            "rev-${originalTx.id}-${DateTime.now().millisecondsSinceEpoch}",
        "parentTransactionId": originalTx.id,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/process'),
        headers: headers,
        body: body,
      );

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 201,
        "message": data['error'] ??
            (response.statusCode == 201 ? "Success" : "Failed"),
      };
    } catch (e) {
      return {"success": false, "message": "Network Failure: $e"};
    }
  }

  /// --- 4. FETCH LATEST TRANSACTIONS ---
  static Future<List<TransactionModel>> getLatestTransactions() async {
    try {
      final uri = Uri.parse('$_baseUrl/latest');
      final headers = await ApiClient.getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List dataList = body['data'] ?? [];

        return dataList.map((item) => TransactionModel.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized - Please login again");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Error: $e");
    }
  }

  static Future<Map<String, dynamic>> reserveFunds({
    required String accountId,
    required String amount,
    required String action, // "RESERVE" or "RELEASE"
    required String category,
    String? description,
    String? idempotencyKey,
  }) async {
    try {
      final headers = await ApiClient.getHeaders();
      // Ensure we always have a unique key to prevent double-reserving funds
      final effectiveKey = idempotencyKey ?? const Uuid().v4();

      final response = await http.post(
        Uri.parse('$_baseUrl/reserve'),
        headers: headers,
        body: jsonEncode({
          "accountId": accountId,
          "amount": amount,
          "action": action.toUpperCase(),
          "category": category,
          "description": description ?? "",
          "idempotencyKey": effectiveKey,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        // Accept both 201 (Created) and 409 (Duplicate/Idempotent Success)
        "success": response.statusCode == 201 ||
            (response.statusCode == 409 && data['success'] == true),
        "message": data['error'] ??
            (response.statusCode == 201 ? "Success" : "Already processed"),
        "data": data,
      };
    } catch (e) {
      return {"success": false, "message": "Network Failure: $e"};
    }
  }
}
