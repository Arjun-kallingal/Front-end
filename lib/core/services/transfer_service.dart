import 'dart:convert';
import 'package:http/http.dart' as http;

class TransferService {
  static const String baseUrl = "http://localhost:5000/api/transaction"; // Emulator-safe

  static Future<void> accountTransfer({
    required String token,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required String category,
    required String description,
    required String idempotencyKey,
  }) async {
    final url = Uri.parse("$baseUrl/account-transfer");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "fromAccountId": fromAccountId,
        "toAccountId": toAccountId,
        "amount": amount,
        "category": category,
        "description": description,
        "idempotencyKey": idempotencyKey,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 409) {
      throw Exception("Transfer failed: ${response.body}");
    }
  }
}