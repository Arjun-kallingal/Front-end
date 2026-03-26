import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/account_model.dart';
// import '../models/global_summary.dart'; // Uncomment if you have this file

class AccountService {
  // Web-safe platform checking
  static String get baseUrl {
     

    return "http://localhost:5000/api/account"; 
  
}
  static Future<Map<String, dynamic>> getAccountDashboard(String userId, {String type = ""}) async {
    Uri uri = Uri.parse('$baseUrl/balances/$userId');
    
    if (type.isNotEmpty && type.toUpperCase() != "ALL") {
      uri = uri.replace(queryParameters: {'type': type.toUpperCase()});
    }

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<AccountModel> accounts = (data['accounts'] as List)
            .map((acc) => AccountModel.fromJson(acc))
            .toList();

        // GlobalSummary summary = GlobalSummary.fromJson(data['globalSummary'] ?? {});

        return {
          'accounts': accounts,
          // 'summary': summary, 
        };
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection Failed: $e");
    }
  }

  static Future<void> createAccount({
    required String userId,
    required String name,
    required String type,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'name': name,
        'type': type.toUpperCase(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Could not create account: ${response.body}");
    }
  }

  static Future<bool> setPrimaryAccount(String accountId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$accountId/primary'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Failed to set primary account: $e");
      return false;
    }
  }
}