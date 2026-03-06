import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/local_storage_service.dart';
import 'features/auth/ui/login_screen.dart';
import 'navigation/navigation_service.dart';
import 'features/analytics/provider/analytics_provider.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Check if JWT exists
  final bool isLoggedIn = await LocalStorageService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],
      child: WalletCareApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class WalletCareApp extends StatelessWidget {
  final bool isLoggedIn;

  const WalletCareApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Moneycart',

      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),

      // ✅ Set initial route based on login state
      initialRoute: isLoggedIn ? '/main' : '/login',

      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainNavigation(),
        '/signup': (_) => const Scaffold(
              body: Center(child: Text('Signup Screen')),
            ),
        '/forgot-password': (_) => const Scaffold(
              body: Center(child: Text('Forgot Password')),
            ),
      },

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}