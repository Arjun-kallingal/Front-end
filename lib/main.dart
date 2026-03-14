import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/local_storage_service.dart';

import 'features/auth/ui/login_screen.dart';
import 'navigation/navigation_service.dart';

import 'features/analytics/provider/analytics_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check JWT token from local storage
  final bool isLoggedIn = await LocalStorageService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [

        /// Theme Provider
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        /// Analytics Provider
        ChangeNotifierProvider(
          create: (_) => AnalyticsProvider(),
        ),

      ],
      child: WalletCareApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class WalletCareApp extends StatelessWidget {

  final bool isLoggedIn;

  const WalletCareApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {

    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moneycart',

      /// THEMES
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,

      themeAnimationDuration: const Duration(milliseconds: 300),

      /// ROUTES
      initialRoute: isLoggedIn ? '/main' : '/login',

      routes: {

        /// Login
        '/login': (_) => const LoginScreen(),

        /// Main Navigation (Bottom Navigation)
        '/main': (_) => const MainNavigation(),

        /// Signup placeholder
        '/signup': (_) => const Scaffold(
          body: Center(
            child: Text('Signup Screen'),
          ),
        ),

        /// Forgot password placeholder
        '/forgot-password': (_) => const Scaffold(
          body: Center(
            child: Text('Forgot Password'),
          ),
        ),
      },

      /// Prevent system font scaling breaking UI
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}