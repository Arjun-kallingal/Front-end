import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account_model.dart';

class AccountService {
  static const String baseUrl =
      "http://localhost:5000/api/account/balances"; 
  // ⚠️ use your real backend URL
  // 10.0.2.2 = Android Emulator localhost

  static Future<List<AccountModel>> getAccounts(
    String userId, {
    String? type,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/$userId");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['accounts'] == null) {
          return [];
        }

        final List accountsJson = data['accounts'];

        return accountsJson
            .map((json) => AccountModel.fromJson(json))
            .toList();
      } else {
        print("API Error: ${response.statusCode}");
        print(response.body);
        return [];
      }
    } catch (e) {
      print("GET ACCOUNTS ERROR: $e");
      return [];
    }
  }

  static Future<void> createAccount({
    required String userId,
    required String name,
    required String type,
    required double initialBalance,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "name": name,
        "type": type,
        "initialBalance": initialBalance,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to create account");
    }
  }
}