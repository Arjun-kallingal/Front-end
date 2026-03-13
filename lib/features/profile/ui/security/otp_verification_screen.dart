
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  String getOtp() => controllers.map((e) => e.text).join();

  /// HANDLE OTP PASTE
  void pasteOtp(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        controllers[i].text = value[i];
      }
      FocusScope.of(context).unfocus();
    }
  }

  /// VERIFY OTP
  Future<void> verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final token = await AuthStorage.getToken();

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/otp/verify/private"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({
          "otp": getOtp(),
          "purpose": "reset_password"
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final resetToken = data["resetToken"];

        Navigator.pushReplacementNamed(
          context,
          "/resetPassword",
          arguments: resetToken,
        );
      } else {
        String message = data["message"] ?? "OTP verification failed";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error. Please try again.")),
      );
    }
  }

  /// RESEND OTP
  Future<void> resendOtp() async {
    final token = await AuthStorage.getToken();

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/user/forgot-password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {

        for (var c in controllers) {
          c.clear();
        }

        focusNodes.first.requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "New OTP sent to your email"),
          ),
        );
      } else {
        String message = data["message"] ?? "Unable to resend OTP";

        if (message.contains("COOLDOWN_ACTIVE")) {
          message = "Please wait before requesting another OTP";
        }

        if (message.contains("MAX_RESEND_EXHAUSTED")) {
          message =
              "You have reached the maximum resend attempts. Try again later.";
        }

        if (message.contains("OTP expired")) {
          message = "OTP expired. Please request a new one.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Network error. Please try again."),
        ),
      );
    }
  }

  /// OTP INPUT BOX
  Widget otpBox(int index) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: const InputDecoration(
            counterText: "",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          validator: (value) {
            if (getOtp().length < 6) {
              return "Enter a valid 6-digit OTP";
            }
            return null;
          },
          onChanged: (value) {

            /// HANDLE PASTE (full OTP)
            if (value.length == 6) {
              pasteOtp(value);
              return;
            }

            /// MOVE FORWARD
            if (value.isNotEmpty && index < 5) {
              FocusScope.of(context).nextFocus();
            }

            /// MOVE BACKWARD
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

    return Scaffold(
      appBar: AppBar(title: const Text("OTP Verification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              const SizedBox(height: 40),

              const Text(
                "Enter the 6-digit OTP sent to your email",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              Row(
                children: List.generate(6, (index) => otpBox(index)),
              ),

              const SizedBox(height: 20),

              /// RESEND OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the OTP? "),
                  TextButton(
                    onPressed: resendOtp,
                    child: const Text("Resend OTP"),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : verifyOtp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 8),

              /// BACK BUTTON
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

