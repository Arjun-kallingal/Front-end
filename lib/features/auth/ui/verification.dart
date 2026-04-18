import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  void _handleInput(String value, int index) {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }

    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < digits.length && i < 6; i++) {
        _controllers[i].text = digits[i];
      }
      _focusNodes.last.requestFocus();
      return;
    }

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyCode() async {
    if (_isLoading) return;

    final code = _controllers.map((e) => e.text).join();

    if (code.length != 6) {
      setState(() => _errorMessage = "Please enter the 6 digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await AuthService.verifyOtp(widget.email, code);

      if (!mounted) return;

      if (data["accessToken"] != null) {
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
          MaterialPageRoute(builder: (_) => const MainNavigation()),
          (route) => false,
        );
      } else {
        setState(() =>
            _errorMessage = data["message"] ?? "OTP verification failed");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Unable to verify OTP. Try again.");
      debugPrint("VERIFY OTP ERROR: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

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
          SnackBar(content: Text(data["message"] ?? "OTP resent")),
        );
      } else {
        setState(() =>
            _errorMessage = data["message"] ?? "Failed to resend OTP");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = "Unable to resend OTP");
      debugPrint("RESEND OTP ERROR: $e");
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isLight = theme.brightness == Brightness.light;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.06),

                  // ── ICON & HEADING ───────────────────────────────
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
                            Icons.verified_user_outlined,
                            size: 34,
                            color: isLight ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Verify Your Email',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isLight ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the 6-digit OTP sent to',
                          style: textTheme.bodyMedium?.copyWith(
                            color: isLight ? Colors.black45 : Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.email,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isLight ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // ── OTP BOXES ────────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final boxWidth =
                          max(48.0, (constraints.maxWidth - 40) / 6);

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: boxWidth,
                            height: 58,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              autofillHints: const [AutofillHints.oneTimeCode],
                              textInputAction: index == 5
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: isLight ? Colors.black : Colors.white,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: isLight
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: isLight
                                        ? Colors.black12
                                        : Colors.white12,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color:
                                        isLight ? Colors.black : Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (v) {
                                _handleInput(v, index);
                                final code = _controllers
                                    .map((e) => e.text)
                                    .join();
                                if (code.length == 6 && !_isLoading) {
                                  _verifyCode();
                                }
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── ERROR MESSAGE ────────────────────────────────
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // ── RESEND ROW ───────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code?",
                        style: textTheme.bodySmall?.copyWith(
                          color: isLight ? Colors.black45 : Colors.white54,
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _resendOtp,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        child: Text(
                          'Resend',
                          style: textTheme.bodySmall?.copyWith(
                            color: isLight ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── VERIFY BUTTON ────────────────────────────────
                  SizedBox(
                    height: 54,
                    child: _isLoading
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
                            onPressed: _isLoading ? null : _verifyCode,
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
                              'Verify & Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  // ── BACK BUTTON ──────────────────────────────────
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
                        'Back',
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

                  // ── EXPIRY NOTE ──────────────────────────────────
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
                        'OTP expires in 1 minute',
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
    );
  }
}