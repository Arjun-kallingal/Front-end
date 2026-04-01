import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:front_end/features/auth/ui/verification.dart';
import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool agreeTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms & Privacy Policy'),
        ),
      );
      return;
    }

    if (isLoading) return;

    setState(() => isLoading = true);

    try {
      final data = await AuthService.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (data["success"] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData prefixIcon,
    required bool isLight,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isLight ? Colors.black38 : Colors.white38,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isLight ? Colors.black45 : Colors.white54,
        size: 20,
      ),
      filled: true,
      fillColor: isLight ? Colors.grey[100] : Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textTheme = theme.textTheme;
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.04),

                    // ── LOGO & HEADING ───────────────────────────────
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
                              Icons.shield_outlined,
                              size: 34,
                              color: isLight ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Create Account',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Start your financial journey',
                            style: textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.black45 : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // ── FULL NAME ────────────────────────────────────
                    TextFormField(
                      controller: nameController,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full Name is required';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Full Name',
                        prefixIcon: Icons.person_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── EMAIL ────────────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Email Address',
                        prefixIcon: Icons.mail_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── PASSWORD (no eye icon) ────────────────────────
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── CONFIRM PASSWORD (no eye icon) ────────────────
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: _fieldDecoration(
                        hint: 'Confirm Password',
                        prefixIcon: Icons.lock_outline_rounded,
                        isLight: isLight,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── SHARED SHOW/HIDE TOGGLE ──────────────────────
                    // ── SHARED SHOW/HIDE TOGGLE ──────────────────────
                    GestureDetector(
                      onTap: () => setState(() {
                        obscurePassword = !obscurePassword;
                        obscureConfirmPassword = !obscureConfirmPassword;
                      }),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end, // 👈 right-aligned
                        children: [
                          Text(
                            obscurePassword
                                ? 'Show passwords'
                                : 'Hide passwords',
                            style: textTheme.bodySmall?.copyWith(
                              color: isLight ? Colors.black54 : Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: isLight ? Colors.black54 : Colors.white54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── TERMS CHECKBOX ───────────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: agreeTerms,
                            activeColor: isLight ? Colors.black : Colors.white,
                            checkColor: isLight ? Colors.white : Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            side: BorderSide(
                              color: isLight ? Colors.black38 : Colors.white38,
                            ),
                            onChanged: (v) =>
                                setState(() => agreeTerms = v ?? false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy',
                            style: textTheme.bodySmall?.copyWith(
                              color: isLight ? Colors.black54 : Colors.white54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── CREATE ACCOUNT BUTTON ────────────────────────
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
                              onPressed: isLoading ? null : _submit,
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
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 28),

                    // ── DIVIDER ──────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isLight ? Colors.black12 : Colors.white12,
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ALREADY HAVE AN ACCOUNT?',
                            style: textTheme.labelSmall?.copyWith(
                              color: isLight ? Colors.black38 : Colors.white38,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isLight ? Colors.black12 : Colors.white12,
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── BACK TO SIGN IN ──────────────────────────────
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
                          'Back to Sign In',
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

                    const SizedBox(height: 28),

                    // ── SECURITY BADGE ───────────────────────────────
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
                          'Your information is secure and encrypted',
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
      ),
    );
  }
}
