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
  final color = theme.colorScheme;

  return Scaffold(
    backgroundColor: color.background,

    appBar: AppBar(
      title: const Text("Delete Account"),
      centerTitle: true,
    ),

    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [

          /// ICON
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.surface.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.delete_outline,
              size: 60,
              color: color.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          /// TITLE
          Text(
            "Delete Your Account",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          /// DESCRIPTION
          Text(
            "This will deactivate your account.\n\n"
            "It will be permanently deleted after 14 days unless you log in again.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          const SizedBox(height: 30),

          /// PASSWORD FIELD (THEME CONTROLLED)
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: "Enter your password",
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          /// DELETE BUTTON (FROM THEME)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : confirmDelete,
              child: isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    )
                  : const Text("Delete Account"),
            ),
          ),

          const SizedBox(height: 12),

          /// CANCEL BUTTON (FROM THEME)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ),
        ],
      ),
    ),
  );
}
}