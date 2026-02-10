import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'forgot_password.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
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
              Text('Email Address', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'alex@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 20),

              /// PASSWORD
              Text('Password', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
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
             Row(
  children: [
    Checkbox(
      value: rememberMe,
      onChanged: (value) {
        setState(() {
          rememberMe = value ?? false;
        });
      },
    ),
    const Text('Remember me'),
    const Spacer(),
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ForgotPasswordScreen(),
          ),
        );
      },
      child: const Text('Forgot password?'),
    ),
  ],
),

              /// SIGN IN
              ElevatedButton(
                onPressed: () {},
                child: const Text('Sign In'),
              ),

              const SizedBox(height: 30),

              Center(
                child: Text(
                  'NEW TO WALLET CARE?',
                  style: textTheme.labelMedium,
                ),
              ),

              const SizedBox(height: 12),

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
    );
  }
}
