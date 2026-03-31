import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_config.dart';

class TransferService {

  static String get baseUrl =>
      "${ApiConfig.baseUrl}/api/transaction";

  static Future<void> accountTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String category,
    required String description,
    required String idempotencyKey,
  }) async {

    final headers = await ApiClient.getHeaders();

    final response = await http.post(
      Uri.parse("$baseUrl/account-transfer"),
      headers: headers,
      body: jsonEncode({
        "fromAccountId": fromAccountId,
        "toAccountId": toAccountId,
        "amount": amount,
        "category": category,
        "description": description,
        "idempotencyKey": idempotencyKey,
      }),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 409) {
      throw Exception("Transfer failed: ${response.body}");
    }
  }
}