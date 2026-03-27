import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/core/services/auth_storage.dart';
import 'package:front_end/features/auth/ui/login_screen.dart';

class SignOutScreen extends StatelessWidget {
  const SignOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Scaffold(
      backgroundColor: color.background,

      /// ✅ AppBar (theme controlled)
      appBar: AppBar(
        title: const Text("Sign Out"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// ICON
            Icon(
              Icons.logout,
              size: 70,
              color: color.onSurface,
            ),

            const SizedBox(height: 20),

            /// TEXT
            Text(
              "Are you sure you want to sign out?",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 40),

            /// SIGN OUT BUTTON (from theme)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthStorage.logout();

                  context.read<UserProfileProvider>().clearUser();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  "Sign Out",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// CANCEL BUTTON (from theme)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}