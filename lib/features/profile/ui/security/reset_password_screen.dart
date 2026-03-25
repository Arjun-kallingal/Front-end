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

    final theme = Theme.of(context);
    final color = theme.colorScheme;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: color.surface,
          title: Text(
            "Success",
            style: TextStyle(color: color.onSurface),
          ),
          content: Text(
            "Password updated successfully",
            style: TextStyle(color: color.onSurface),
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
                style: TextStyle(color: color.primary),
              ),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: color.surface,
          title: Text(
            "Error",
            style: TextStyle(color: color.onSurface),
          ),
          content: Text(
            data["message"],
            style: TextStyle(color: color.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(color: color.primary),
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
              color: color.background,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: color.onBackground,
                    ),
                  ),
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color.onBackground,
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
                        ),

                        const SizedBox(height: 30),

                        /// BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                                isLoading ? null : resetPassword,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color:
                                        theme.colorScheme.onPrimary,
                                  )
                                : const Text("Reset Password"),
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
  }) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: color.onSurface),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: color.onSurface,
          ),
          onPressed: toggle,
        ),
      ),
    );
  }
}