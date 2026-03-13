import 'package:flutter/material.dart';
import 'package:front_end/features/profile/services/change_password_service.dart';
import 'package:front_end/core/services/auth_storage.dart';

import 'package:http/http.dart' as http;

import 'package:front_end/core/services/api_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  String? currentPasswordError;

  /// SUCCESS ALERT
  void showSuccessAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  /// CHANGE PASSWORD
  void _changePassword() async {
    setState(() {
      currentPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await ChangePasswordService.changePassword(
        currentPasswordController.text.trim(),
        newPasswordController.text.trim(),
      );

      /// SAVE NEW TOKEN IF RETURNED
      if (result["accessToken"] != null) {
        final name = await AuthStorage.getName();
        final email = await AuthStorage.getEmail();

        await AuthStorage.saveUser(
          token: result["accessToken"],
          name: name ?? "",
          email: email ?? "",
          phone: "",
        );
      }

      /// SUCCESS ALERT
      showSuccessAlert(
        result["message"] ?? "Password updated successfully",
      );
    } catch (e) {
      final message = e.toString().replaceAll("Exception: ", "");

      /// SHOW FORM ERROR
      if (message.toLowerCase().contains("current password")) {
        setState(() {
          currentPasswordError = message;
        });

        _formKey.currentState!.validate();
      }
    }
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            /// FORM
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// CURRENT PASSWORD
                     _passwordField(
  controller: currentPasswordController,
  label: "Current Password",
  obscure: obscureCurrent,
  errorText: currentPasswordError,
  toggle: () {
    setState(() {
      obscureCurrent = !obscureCurrent;
    });
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter current password";
    }
    return currentPasswordError;
  },
),

/// FORGOT PASSWORD
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () async {
      final token = await AuthStorage.getToken();

      await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/user/forgot-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      Navigator.pushNamed(context, "/otpVerification");
    },
    child: const Text("Forgot Password?"),
  ),
),
                        const SizedBox(height: 10),

                        /// NEW PASSWORD
                        _passwordField(
                          controller: newPasswordController,
                          label: "New Password",
                          obscure: obscureNew,
                          toggle: () {
                            setState(() {
                              obscureNew = !obscureNew;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter new password";
                            }
                            if (value.length < 8) {
                              return "Password must be at least 8 characters";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        /// CONFIRM PASSWORD
                        _passwordField(
                          controller: confirmPasswordController,
                          label: "Confirm Password",
                          obscure: obscureConfirm,
                          toggle: () {
                            setState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm your password";
                            }
                            if (value != newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _changePassword,
                            child: const Text(
                              "Update Password",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    String? errorText,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    final color = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        filled: true,
        fillColor: color.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: color.primary,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}
