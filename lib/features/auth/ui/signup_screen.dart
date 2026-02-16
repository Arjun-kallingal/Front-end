import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to the Terms & Privacy Policy'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          email: emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    const SizedBox(height: 12),
                    const Icon(Icons.shield_outlined, size: 56),
                    const SizedBox(height: 16),

                    Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'Start your financial journey',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),

                    const SizedBox(height: 28),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [

                            /// FULL NAME
                            CustomTextField(
                              hintText: 'Full Name',
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Full Name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            /// EMAIL
                            CustomTextField(
                              hintText: 'Email Address',
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            /// PASSWORD
                            CustomTextField(
                              hintText: 'Password',
                              controller: passwordController,
                              obscureText: obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            /// CONFIRM PASSWORD
                            CustomTextField(
                              hintText: 'Confirm Password',
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscureConfirmPassword =
                                        !obscureConfirmPassword;
                                  });
                                },
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
                            ),

                            const SizedBox(height: 16),

                            /// TERMS CHECKBOX
                            Row(
                              children: [
                                Checkbox(
                                  value: agreeTerms,
                                  onChanged: (v) {
                                    setState(() {
                                      agreeTerms = v ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Text(
                                    'I agree to the Terms of Service and Privacy Policy',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            /// BUTTON
                            CustomButton(
                              text: 'Create Account',
                              onPressed: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Column(
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Sign In'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Your information is secure and encrypted',
                          style: theme.textTheme.bodySmall,
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
