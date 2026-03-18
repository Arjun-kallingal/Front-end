import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';
import '../../../core/services/auth_storage.dart';

class ProfileService {

  static Future<bool> updateProfile(String name) async {

    try {

      final token = await AuthStorage.getToken();
      final email = await AuthStorage.getEmail();

      final response = await http.patch(
        Uri.parse("${ApiConfig.baseUrl}/api/user/profile"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "name": name,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {

        /// UPDATE LOCAL STORAGE
        await AuthStorage.saveUser(
          token: token ?? "",
          name: name,
          email: email ?? "",
          phone: "", // not used anymore
        );

        return true;
      }

      return false;

    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
}