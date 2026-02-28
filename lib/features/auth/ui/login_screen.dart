import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:front_end/core/widgets/custom_button.dart';
import 'package:front_end/core/widgets/custom_text_field.dart';
import 'signup_screen.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;
  bool rememberError = false;

  ///  LOGIN API FUNCTION
  Future<void> loginUser() async {
    try {


final url = Uri.parse('http://10.0.2.2:5000/api/auth/login');
      // ⚠️ If using real device, replace with your PC IP
      // example: http://192.168.1.5:5000/api/auth/login
//http://localhost:5000/api/auth/login


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

      if (response.statusCode == 200) {
        ///  SUCCESS
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login successful"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(context, '/main');
      } else {
        ///  ERROR FROM SERVER
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ///  CONNECTION ERROR
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to connect to server"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
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
                        color: colors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Wallet Care',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Secure Financial Management',
                        style: textTheme.bodyMedium,
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

                /// PASSWORD
                Text(
                  'Password',
                  style: textTheme.labelLarge,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
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
                    prefixIcon: const Icon(Icons.lock_outline),
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
                  ),
                ),

                const SizedBox(height: 12),

                /// REMEMBER + FORGOT
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                              rememberError = false;
                            });
                          },
                        ),
                        Text(
                          'Remember me',
                          style: textTheme.bodyMedium,
                        ),
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
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    if (rememberError)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text(
                          'Please select Remember me',
                          style:
                              TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),

                /// SIGN IN
                CustomButton(
                  text: 'Sign In',
                  onPressed: () {
                    final isValid =
                        _formKey.currentState!.validate();

                    if (!rememberMe) {
                      setState(() {
                        rememberError = true;
                      });
                    }

                    if (isValid && rememberMe) {
                      loginUser(); 
                    }
                  },
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text(
                    'NEW TO WALLET CARE?',
                    style: textTheme.labelMedium,
                  ),
                ),

                const SizedBox(height: 30),

                /// CREATE ACCOUNT
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}