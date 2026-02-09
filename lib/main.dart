import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'features/auth/ui/login_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().theme,
      home: const LoginScreen(),
      routes: {
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
