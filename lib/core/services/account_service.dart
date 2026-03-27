import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/account_model.dart';
import '../services/api_client.dart';    // ✅ JWT headers
import '../services/api_config.dart';    // ✅ centralized base URL

class AccountService {

  static String get baseUrl => "${ApiConfig.baseUrl}/api/account";

  // ================= GET ACCOUNTS =================

  static Future<Map<String, dynamic>> getAccountDashboard({String type = ""}) async {
    // ✅ No userId in URL — backend reads user from JWT
    Uri uri = Uri.parse('$baseUrl/balances');

    if (type.isNotEmpty && type.toUpperCase() != "ALL") {
      uri = uri.replace(queryParameters: {'type': type.toUpperCase()});
    }

    try {
      final headers = await ApiClient.getHeaders();  // ✅ Bearer token
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<AccountModel> accounts = (data['accounts'] as List)
            .map((acc) => AccountModel.fromJson(acc))
            .toList();

        return {'accounts': accounts};
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }
  }

  // ================= CREATE ACCOUNT =================

  static Future<void> createAccount({
    required String name,
    required String type,
  }) async {
    // ✅ No userId in body — backend extracts from JWT
    final headers = await ApiClient.getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'type': type.toUpperCase(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Could not create account: ${response.body}");
    }
  }

  // ================= SET PRIMARY =================

  static Future<bool> setPrimaryAccount(String accountId) async {
    try {
      final headers = await ApiClient.getHeaders();  // ✅ Bearer token

      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/primary'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Failed to set primary account: $e");
      return false;
    }
  }
}