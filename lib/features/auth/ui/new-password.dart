import 'package:flutter/material.dart';
import '../services/authentication_service.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<NewPasswordScreen> createState() =>
      _NewPasswordScreenState();
}

class _NewPasswordScreenState
    extends State<NewPasswordScreen> {
  final TextEditingController passwordController =
      TextEditingController();
  final TextEditingController confirmController =
      TextEditingController();

  bool showPassword = false;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> handleReset() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      _showSnack("Fill all fields");
      return;
    }

    if (password.length < 8) {
      _showSnack("Minimum 8 characters");
      return;
    }

    if (password != confirm) {
      _showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    final success =
        await AuthService.resetPassword(widget.resetToken, password);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      _showSnack("Password reset successful");
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      _showSnack("Reset failed. Try again");
    }
  }

  void _showSnack(String msg) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isDark ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final textTheme = theme.textTheme;
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
                    "Set New Password",
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [

                        Text(
                          'Create a New Password',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.email,
                          style: textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white70
                                : Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// PASSWORD FIELD
                        _passwordField(
                          controller: passwordController,
                          label: "New Password",
                          isDark: isDark,
                        ),

                        const SizedBox(height: 16),

                        /// CONFIRM FIELD
                        _passwordField(
                          controller: confirmController,
                          label: "Confirm Password",
                          isDark: isDark,
                        ),

                        const SizedBox(height: 30),

                        isLoading
                            ? CircularProgressIndicator(
                                color: isDark
                                    ? Colors.white
                                    : Colors.black,
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: handleReset,
                                  style:
                                      ElevatedButton.styleFrom(
                                    backgroundColor: isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  child: Text(
                                    "Set Password",
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
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
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
            showPassword
                ? Icons.visibility
                : Icons.visibility_off,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            setState(() {
              showPassword = !showPassword;
            });
          },
        ),
      ),
    );
  }
}