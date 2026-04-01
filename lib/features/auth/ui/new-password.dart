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
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

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

    if (success == true) {
      _showSnack("Password reset successful");
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (success == false) {
      _showSnack("New password cannot be the same as old password");
    }
  }

  void _showSnack(String msg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLight = theme.brightness == Brightness.light;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),

                  // ── ICON & HEADING ───────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: isLight ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            size: 34,
                            color: isLight ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Set New Password',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isLight ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLight ? Colors.black45 : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── NEW PASSWORD ─────────────────────────────────
                  _passwordField(
                    controller: passwordController,
                    hint: 'New Password',
                    isLight: isLight,
                  ),

                  const SizedBox(height: 14),

                  // ── CONFIRM PASSWORD ─────────────────────────────
                  _passwordField(
                    controller: confirmController,
                    hint: 'Confirm Password',
                    isLight: isLight,
                  ),

                  const SizedBox(height: 10),

                  // ── SHOW/HIDE TOGGLE ─────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => showPassword = !showPassword),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          showPassword ? 'Hide passwords' : 'Show passwords',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.black54 : Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Icon(
                          showPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 18,
                          color: isLight ? Colors.black54 : Colors.white54,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── SET PASSWORD BUTTON ──────────────────────────
                  SizedBox(
                    height: 54,
                    child: isLoading
                        ? Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: isLight ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: handleReset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isLight ? Colors.black : Colors.white,
                              foregroundColor:
                                  isLight ? Colors.white : Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Set Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ── BACK BUTTON ──────────────────────────────────
                  SizedBox(
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                      label: Text(
                        'Back',
                        style: TextStyle(
                          color: isLight ? Colors.black : Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isLight ? Colors.black26 : Colors.white24,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── SECURITY NOTE ────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 13,
                        color: isLight ? Colors.black38 : Colors.white38,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Your new password will be encrypted',
                        style: textTheme.bodySmall?.copyWith(
                          color: isLight ? Colors.black38 : Colors.white38,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool isLight,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showPassword,
      style: TextStyle(
        color: isLight ? Colors.black : Colors.white,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: isLight ? Colors.black38 : Colors.white38,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isLight ? Colors.black45 : Colors.white54,
          size: 20,
        ),
        filled: true,
        fillColor: isLight ? Colors.grey[100] : Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isLight ? Colors.black : Colors.white,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}