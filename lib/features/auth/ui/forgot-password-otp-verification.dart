import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/authentication_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? email;

  const OtpVerificationScreen({
    super.key,
    this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  Timer? timer;
  int resendSeconds = 60;
  bool canResend = false;

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {

    setState(() {
      resendSeconds = 60;
      canResend = false;
    });

    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {

      if (resendSeconds == 0) {
        t.cancel();

        setState(() {
          canResend = true;
        });

      } else {

        setState(() {
          resendSeconds--;
        });

      }

    });
  }

  void verifyOtp() {

    if (getOtp().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Verified (UI only)")),
    );
  }
void resendOtp() async {

  if (!canResend) return;

  if (widget.email == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email not found")),
    );
    return;
  }

  final success = await AuthService.resendOtp(widget.email!);

  if (!mounted) return;

  if (success) {

    for (var c in controllers) {
      c.clear();
    }

    focusNodes.first.requestFocus();

    startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("New OTP sent to email")),
    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to resend OTP")),
    );

  }
}

  Widget otpBox(int index) {

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {

            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).nextFocus();
            }

            if (value.isEmpty && index > 0) {
              FocusScope.of(context).previousFocus();
            }

          },
        ),
      ),
    );
  }

  @override
  void dispose() {

    timer?.cancel();

    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Icon(
                    Icons.security_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Verify OTP",
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Enter the 6-digit OTP sent to",
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 5),

                  /// SAFE EMAIL DISPLAY
                  Text(
                    widget.email ?? "your email",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: List.generate(6, (index) => otpBox(index)),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: verifyOtp,
                    child: const Text("Verify OTP"),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: canResend ? resendOtp : null,
                    child: Text(
                      canResend
                          ? "Resend OTP"
                          : "Resend OTP in $resendSeconds s",
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}