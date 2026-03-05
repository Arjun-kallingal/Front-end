import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';

class LoginVerificationOtpScreen extends StatefulWidget {
  const LoginVerificationOtpScreen({super.key});

  @override
  State<LoginVerificationOtpScreen> createState() =>
      _LoginVerificationOtpScreenState();
}

class _LoginVerificationOtpScreenState
    extends State<LoginVerificationOtpScreen> {

  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;

  void verifyOtp() async {

    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => loading = false);

    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP Verification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [

              const SizedBox(height: 40),

              Icon(
                Icons.security,
                size: 70,
                color: theme.colorScheme.primary,
              ),

              const SizedBox(height: 20),

              Text(
                "Enter Verification Code",
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              Text(
                "We sent a code to your email",
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 30),

              CustomTextField(
                hintText: "Enter OTP",
                controller: otpController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter OTP";
                  }
                  if (value.length < 6) {
                    return "Invalid OTP";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 30),

              CustomButton(
                text: loading ? "Verifying..." : "Verify",
                onPressed: loading ? null : verifyOtp,
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  // resend otp
                },
                child: const Text("Resend Code"),
              )
            ],
          ),
        ),
      ),
    );
  }
}