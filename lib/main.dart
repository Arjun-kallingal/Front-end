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

      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,

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
    );
  }
}
