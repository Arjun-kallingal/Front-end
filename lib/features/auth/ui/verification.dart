import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/navigation/navigation_service.dart';

import '../services/auth_service.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// HANDLE OTP INPUT + PASTE
  void _handleInput(String value, int index) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    // PASTE SUPPORT
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');

      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }

      _focusNodes.last.requestFocus();
      return;
    }

    // MOVE FORWARD
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    // MOVE BACKWARD
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  /// VERIFY OTP
  Future<void> _verifyCode() async {
    if (_isLoading) return;

    final code = _controllers.map((e) => e.text).join();

    if (code.length != 6) {
      setState(() {
        _errorMessage = "Please enter the 6 digit code";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService.verifyOtp(
        widget.email,
        code,
      );

      if (!mounted) return;

      /// ✅ FIXED SUCCESS CHECK
      if (data["accessToken"] != null) {
        final token = data["accessToken"];
        final user = data["user"] ?? {};

       await AuthStorage.saveUser(
  token: data["accessToken"],
 refreshToken: data["refreshToken"] ?? "",
  name: user["name"] ?? "",
  email: user["email"] ?? "",
);
        context.read<UserProfileProvider>().setUser(
              userName: user["name"] ?? "",
              userEmail: user["email"] ?? "",
            );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigation(),
          ),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage =
              data["message"] ?? "OTP verification failed";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Unable to verify OTP. Try again.";
      });

      debugPrint("VERIFY OTP ERROR: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// RESEND OTP
  Future<void> _resendOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService.resendOtp(widget.email);

      if (!mounted) return;

      if (data["success"] == true) {
        for (var c in _controllers) {
          c.clear();
        }

        _focusNodes.first.requestFocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "OTP resent"),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              data["message"] ?? "Failed to resend OTP";
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = "Unable to resend OTP";
      });

      debugPrint("RESEND OTP ERROR: $e");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Icon(
                    Icons.verified_user_outlined,
                    size: 56,
                    color: colors.primary,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    "Verify Your Email",
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Enter the 6 digit OTP sent to",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// OTP INPUT
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final boxWidth =
                          max(50.0, (constraints.maxWidth - 40) / 6);

                      return Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: boxWidth,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType:
                                  TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              autofillHints: const [
                                AutofillHints.oneTimeCode
                              ],
                              textInputAction: index == 5
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly
                              ],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurface,
                              ),
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: colors.surface,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (v) {
                                _handleInput(v, index);

                                final code = _controllers
                                    .map((e) => e.text)
                                    .join();

                                /// ✅ PREVENT DOUBLE CALL
                                if (code.length == 6 && !_isLoading) {
                                  _verifyCode();
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Didn't receive the code?"),
                      TextButton(
                        onPressed:
                            _isLoading ? null : _resendOtp,
                        child: const Text("Resend"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  const SizedBox(height: 16),

                  CustomButton(
                    text: _isLoading
                        ? "Verifying..."
                        : "Verify & Continue",
                    onPressed:
                        _isLoading ? null : _verifyCode,
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "OTP expires in 1 minute",
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall,
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