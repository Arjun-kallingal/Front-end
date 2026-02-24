import 'package:flutter/material.dart';
import 'package:front_end/core/constants/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password Changed Successfully"),
        ),
      );

      Navigator.pop(context);
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                  top: 20, bottom: 80, left: 16, right: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 98, 14, 14),
                    Color.fromARGB(255, 184, 20, 20),
                  ],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
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
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= FORM SECTION =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
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
                        context,
                        controller: currentPasswordController,
                        label: "Current Password",
                        obscure: obscureCurrent,
                        toggle: () {
                          setState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Enter current password";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      /// NEW PASSWORD
                      _passwordField(
                        context,
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
                        context,
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// ================= CUSTOM PASSWORD FIELD =================
 Widget _passwordField(
  BuildContext context, {
  required TextEditingController controller,
  required String label,
  required bool obscure,
  required VoidCallback toggle,
  required String? Function(String?) validator,
}) {
  final color = Theme.of(context).colorScheme;

  return TextFormField(
    controller: controller,
    obscureText: obscure,
    enableSuggestions: false,
    autocorrect: false,
    keyboardType: TextInputType.visiblePassword,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: color.background,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: color.primary,
          width: 1.5,
        ),
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