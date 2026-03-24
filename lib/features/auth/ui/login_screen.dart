import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password_gmail.dart';
import '../../../core/services/api_config.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  /// LOGIN API FUNCTION
  Future<void> loginUser() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["accessToken"] != null) {
        final token = data["accessToken"];
        final user = data["user"];

        final name = user["name"];
        final email = user["email"];
await AuthStorage.saveUser(
  token: data["accessToken"],
  refreshToken: data["refreshToken"] ?? "", // SAFE
  name: name,
  email: email,
);

        context.read<UserProfileProvider>().setUser(
              userName: name,
              userEmail: email,
            );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login successful"),
            backgroundColor: Colors.black,
          ),
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to connect to server"),
          backgroundColor: Colors.black,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                /// LOGO
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 64,
                        color: isLight ? Colors.black : Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Wallet Care',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLight ? Colors.black : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Secure Financial Management',
                        style: textTheme.bodyMedium?.copyWith(
                          color:
                              isLight ? Colors.black54 : Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

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

                /// PASSWORD LABEL
                Text(
                  'Password',
                  style: textTheme.labelLarge?.copyWith(
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                /// PASSWORD FIELD
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  style: TextStyle(
                    color: isLight ? Colors.black : Colors.white,
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
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: isLight
                          ? Colors.black54
                          : Colors.white54,
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: isLight
                          ? Colors.black54
                          : Colors.white54,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isLight
                            ? Colors.black54
                            : Colors.white54,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor:
                        isLight ? Colors.grey[100] : Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// FORGOT PASSWORD
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color:
                              isLight ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                /// SIGN IN BUTTON
                CustomButton(
                  text: 'Sign In',
                  onPressed: () {
                    final isValid =
                        _formKey.currentState!.validate();

                    if (isValid) {
                      loginUser();
                    }
                  },
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    'NEW TO WALLET CARE?',
                    style: textTheme.labelMedium?.copyWith(
                      color:
                          isLight ? Colors.black54 : Colors.white70,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                /// CREATE ACCOUNT
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isLight
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      color:
                          isLight ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}