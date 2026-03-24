import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/api_config.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/features/auth/ui/login_screen.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> deleteAccount() async {
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter your password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final token = await AuthStorage.getToken();

      /// 🔴 TOKEN CHECK
      if (token == null) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session expired. Please login again")),
        );
        return;
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/user/account'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (!mounted) return;

      if (response.statusCode == 200) {
        await AuthStorage.logout();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data["message"] ??
                  "Account scheduled for deletion. Login within 14 days to restore.",
            ),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Delete failed")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error")),
      );
    }
  }

  /// ✅ CONFIRMATION DIALOG
  Future<void> confirmDelete() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
          "Are you sure you want to delete your account?\n\n"
          "Your account will be permanently deleted after 14 days.\n"
          "You can restore it anytime by logging in again within this period.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
      appBar: AppBar(
        title: const Text("Delete Account"),
        centerTitle: true,
        backgroundColor: isLight ? Colors.white : Colors.black,
        foregroundColor: isLight ? Colors.black : Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isLight ? Colors.grey[200] : Colors.grey[800],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                size: 60,
                color: isLight ? Colors.black : Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            /// TITLE
            Text(
              "Delete Your Account",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black : Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            /// UPDATED DESCRIPTION ✅
            Text(
              "This will deactivate your account.\n\n"
              "It will be permanently deleted after 14 days unless you log in again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isLight ? Colors.black54 : Colors.white70,
              ),
            ),

            const SizedBox(height: 30),

            /// PASSWORD FIELD
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: TextStyle(
                color: isLight ? Colors.black : Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Enter your password",
                hintStyle: TextStyle(
                  color: isLight ? Colors.black54 : Colors.white54,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: isLight ? Colors.black54 : Colors.white54,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: isLight ? Colors.black54 : Colors.white54,
                  ),
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: isLight ? Colors.grey[100] : Colors.grey[900],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isLight ? Colors.black : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// DELETE BUTTON WITH CONFIRMATION
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLight ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : confirmDelete,
                child: isLoading
                    ? CircularProgressIndicator(
                        color:
                            isLight ? Colors.white : Colors.black,
                        strokeWidth: 2,
                      )
                    : Text(
                        "Delete Account",
                        style: TextStyle(
                          color:
                              isLight ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            /// CANCEL BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isLight ? Colors.black : Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: isLight ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}