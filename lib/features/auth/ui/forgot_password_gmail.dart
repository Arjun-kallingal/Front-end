import 'package:flutter/material.dart';

import 'forgot-password-otp-verification.dart';
import '../services/authentication_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();

    setState(() => isLoading = true);

    final message = await AuthService.forgotPassword(email);

    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP")),
      );
      setState(() => isLoading = false);
      return;
    }

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("If the email exists, an OTP has been sent"),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(email: email),
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                    SizedBox(height: size.height * 0.05),

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
                            'Forgot Password?',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: isLight ? Colors.black : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'No worries, we\'ll send you a 6-digit OTP',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isLight ? Colors.black45 : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // ── EMAIL FIELD ──────────────────────────────────
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: isLight ? Colors.black : Colors.white,
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter your email";
                        }
                        if (!value.contains("@")) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(
                          color: isLight ? Colors.black38 : Colors.white38,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.mail_outline_rounded,
                          color: isLight ? Colors.black45 : Colors.white54,
                          size: 20,
                        ),
                        filled: true,
                        fillColor:
                            isLight ? Colors.grey[100] : Colors.grey[900],
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SEND OTP BUTTON ──────────────────────────────
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
                              onPressed: _sendOtp,
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
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 14),

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

                    const SizedBox(height: 32),

                    // ── OTP VALIDITY NOTE ────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isLight ? Colors.black38 : Colors.white38,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'OTP will be valid for 15 minutes',
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
