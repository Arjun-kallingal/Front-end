import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/services/api_config.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  bool isLoading = false;

  String getOtp() => controllers.map((e) => e.text).join();

  void pasteOtp(String value) {
    if (value.length == 6) {
      for (int i = 0; i < 6; i++) {
        controllers[i].text = value[i];
      }
      FocusScope.of(context).unfocus();
    }
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP failed")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Network error. Please try again.")),
      );
    }
  }

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
            content: Text(data["message"] ?? "New OTP sent"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  data["message"] ?? "Unable to resend OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Network error. Please try again.")),
      );
    }
  }

  Widget otpBox(int index, ThemeData theme) {
    final color = theme.colorScheme;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: TextFormField(
          controller: controllers[index],
          focusNode: focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            counterText: "",
            filled: true,
            fillColor: color.surface, // ✅ THEME CONTROLLED
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
          ),
          validator: (value) {
            if (getOtp().length < 6) {
              return "Invalid OTP";
            }
            return null;
          },
          onChanged: (value) {
            if (value.length == 6) {
              pasteOtp(value);
              return;
            }

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
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12),
              color: color.background, // ✅ THEME
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: color.onBackground,
                    ),
                  ),
                  Text(
                    "OTP Verification",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.onBackground,
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const SizedBox(height: 40),

                      Text(
                        "Enter the 6-digit OTP sent to your email",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: List.generate(
                          6,
                          (index) => otpBox(index, theme),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the OTP? ",
                            style: TextStyle(
                              color: color.onBackground,
                            ),
                          ),
                          TextButton(
                            onPressed: resendOtp,
                            child: Text(
                              "Resend OTP",
                              style: TextStyle(
                                color: color.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : verifyOtp,
                          child: isLoading
                              ? CircularProgressIndicator(
                                  color: color.onPrimary,
                                )
                              : Text(
                                  "Verify OTP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: color.onPrimary,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: color.onBackground,
                        ),
                        label: Text(
                          "Back",
                          style: TextStyle(
                            color: color.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}