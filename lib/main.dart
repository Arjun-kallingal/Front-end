import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';


import 'features/auth/ui/login_screen.dart';
import 'navigation/navigation_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WalletCareApp(),
    ),
  );
}

class WalletCareApp extends StatelessWidget {
  const WalletCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ==============================
      // THEMES
      // ==============================
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,

      // Smooth theme animation
      themeAnimationDuration: const Duration(milliseconds: 300),

      // ==============================
      // ROUTING
      // ==============================
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
        '/signup': (context) => const Scaffold(
              body: Center(child: Text('Signup Screen')),
            ),
        '/forgot-password': (context) => const Scaffold(
              body: Center(child: Text('Forgot Password')),
            ),
      },

      // ==============================
      // GLOBAL BUILDER (Optional but recommended)
      // ==============================
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
