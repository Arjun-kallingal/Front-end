import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_config.dart';
import '../../../core/services/auth_storage.dart';

class ProfileService {

  static Future<bool> updateProfile(String name, String mobile) async {

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
          "phone": mobile,
        }),
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {

        /// SAVE UPDATED DATA LOCALLY
        await AuthStorage.saveUser(
          token: token ?? "",
          name: name,
          email: email ?? "",
          phone: mobile,
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



              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: ElevatedButton(
              //     onPressed: () async {
              //       await AuthStorage.logout();

              //       context.read<UserProfileProvider>().clearUser();

              //       Navigator.pushAndRemoveUntil(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => const LoginScreen(),
              //         ),
              //         (route) => false,
              //       );
              //     },
              //     child: const Text("Sign Out"),
              //   ),
              // ),