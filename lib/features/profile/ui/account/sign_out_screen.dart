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
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isLight ? Colors.white : Colors.black,

      appBar: AppBar(
        backgroundColor: isLight ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Sign Out",
          style: TextStyle(
            color: isLight ? Colors.black : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(
          color: isLight ? Colors.black : Colors.white,
        ),
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
              color: isLight ? Colors.black : Colors.white,
            ),

            const SizedBox(height: 20),

            /// TEXT
            Text(
              "Are you sure you want to sign out?",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isLight ? Colors.black : Colors.white,
              ),
            ),

            const SizedBox(height: 40),

            /// SIGN OUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLight ? Colors.black : Colors.white,
                  foregroundColor:
                      isLight ? Colors.white : Colors.black,
                ),
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

            /// CANCEL BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isLight ? Colors.black : Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: isLight ? Colors.black : Colors.white,
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