import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final newPasswordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  bool showNewPassword = false;
  bool showConfirmPassword = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final resetToken =
        ModalRoute.of(context)!.settings.arguments as String;

    final token = await AuthStorage.getToken();

    setState(() => isLoading = true);

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/user/reset-password"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "resetToken": resetToken,
        "newPassword": newPasswordController.text
      }),
    );

    final data = jsonDecode(response.body);

    setState(() => isLoading = false);

    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor:
              isDark ? Colors.black : Colors.white,
          title: Text(
            "Success",
            style: TextStyle(
              color:
                  isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            "Password updated successfully",
            style: TextStyle(
              color:
                  isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/profileSettings",
                  (route) => false,
                );
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor:
              isDark ? Colors.black : Colors.white,
          title: Text(
            "Error",
            style: TextStyle(
              color:
                  isDark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            data["message"],
            style: TextStyle(
              color:
                  isDark ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: isDark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              color: isDark ? Colors.black : Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            /// ================= BODY =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        /// NEW PASSWORD
                        _passwordField(
                          controller: newPasswordController,
                          label: "New Password",
                          obscure: !showNewPassword,
                          toggle: () {
                            setState(() {
                              showNewPassword =
                                  !showNewPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null ||
                                value.length < 8) {
                              return "Minimum 8 characters";
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),

                        const SizedBox(height: 20),

                        /// CONFIRM PASSWORD
                        _passwordField(
                          controller:
                              confirmPasswordController,
                          label: "Confirm Password",
                          obscure: !showConfirmPassword,
                          toggle: () {
                            setState(() {
                              showConfirmPassword =
                                  !showConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value !=
                                newPasswordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                          isDark: isDark,
                        ),

                        const SizedBox(height: 30),

                        /// BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : resetPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: isDark
                                        ? Colors.black
                                        : Colors.white,
                                  )
                                : Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.black
                                          : Colors.white,
                                    ),
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
    required VoidCallback toggle,
    required String? Function(String?) validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor:
            isDark ? Colors.black : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}