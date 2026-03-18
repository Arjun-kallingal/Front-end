import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/custom_button.dart';

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

  final email = emailController.text.trim();

  setState(() {
    isLoading = true;
  });

  final message = await AuthService.forgotPassword(email);

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });

  if (message == "OTP sent successfully") {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          email: email,
        ),
      ),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Email doesn't exist"),
      ),
    );

  }
}
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    const SizedBox(height: 20),

                    Icon(
                      Icons.shield_outlined,
                      size: 56,
                      color: colors.primary,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'No worries, we’ll send you a 6-digit OTP',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 30),

                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [

                            Text(
                              'Email Address',
                              style: textTheme.labelLarge,
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {

                                if (value == null || value.isEmpty) {
                                  return "Enter your email";
                                }

                                if (!value.contains("@")) {
                                  return "Enter a valid email";
                                }

                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: "Enter your email",
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),

                            const SizedBox(height: 20),

                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : CustomButton(
                                    text: 'Send OTP',
                                    onPressed: _sendOtp,
                                  ),

                            const SizedBox(height: 16),

                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back to Sign In'),
                            ),

                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Icon(Icons.lock_outline, size: 14),

                        const SizedBox(width: 6),

                        Text(
                          'OTP will be valid for 15 minutes',
                          style: textTheme.bodySmall,
                        ),

                      ],
                    ),

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