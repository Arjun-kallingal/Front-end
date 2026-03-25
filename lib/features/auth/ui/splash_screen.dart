import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _startApp();
  }

  /// 🔐 CHECK TOKEN VALIDITY (OPTIONAL BUT IMPORTANT)
  Future<bool> isTokenValid(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/profile'),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _startApp() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final token = await AuthStorage.getToken();
      final name = await AuthStorage.getName();
      final email = await AuthStorage.getEmail();

      if (!mounted) return;

      /// ❌ NO TOKEN → LOGIN
      if (token == null || token.isEmpty) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      /// 🔐 CHECK TOKEN VALIDITY
      final isValid = await isTokenValid(token);

      if (!mounted) return;

      if (!isValid) {
        /// TOKEN EXPIRED → LOGOUT
        await AuthStorage.logout();
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      /// ✅ RESTORE USER DATA
      context.read<UserProfileProvider>().setUser(
        userName: name ?? "",
        userEmail: email ?? "",
      );

      /// ✅ GO TO MAIN
      Navigator.pushReplacementNamed(context, '/main');

    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            /// APP NAME
            Text(
              "SproutPay",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),

            SizedBox(height: 30),

            /// LOADER
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}