import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/custom_button.dart';
import 'check_email_screen.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckEmailScreen(
          email: emailController.text,
        ),
      ),
    );
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

                    /// ICON
                    Icon(
                      Icons.shield_outlined,
                      size: 56,
                      color: colors.primary,
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// SUBTITLE
                    Text(
                      'No worries, we’ll send you reset instructions',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 30),

                    /// CARD
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

                            /// EMAIL FIELD
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  v != null && v.contains('@')
                                      ? null
                                      : 'Enter valid email',
                              decoration: const InputDecoration(
                                hintText: 'alex@example.com',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// SEND RESET LINK
                            CustomButton(
                              text: 'Send OTP',
                              onPressed: _sendResetLink,
                            ),

                            const SizedBox(height: 16),

                            /// BACK TO LOGIN
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

                    /// FOOTER INFO
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Password reset link will be valid for 15 minutes',
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
