import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';

class AuthService {

  /// REGISTER USER
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
  ) async {

    try {

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          "success": true,
          "message": data["message"]
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Registration failed"
        };
      }

    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e"
      };
    }
  }

  /// VERIFY OTP
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp,
  ) async {

    try {

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "OTP verification failed"
        };
      }

    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e"
      };
    }
  }

  /// RESEND OTP
  static Future<Map<String, dynamic>> resendOtp(
    String email,
  ) async {

    try {

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/resend-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Failed to resend OTP"
        };
      }

    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e"
      };
    }
  }
}