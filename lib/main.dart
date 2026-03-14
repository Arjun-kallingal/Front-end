import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/local_storage_service.dart';
import 'features/auth/ui/login_screen.dart';
import 'navigation/navigation_service.dart';
import 'features/analytics/provider/analytics_provider.dart';
import 'core/providers/user_profile_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/account_provider.dart';
import 'features/goals/provider/goal_provider.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// CHECK LOGIN STATUS
  final bool isLoggedIn = await LocalStorageService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),

        /// ✅ TRANSACTION PROVIDER ADDED
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
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
      title: 'WalletCare',

      /// THEMES
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),

      /// INITIAL ROUTE BASED ON LOGIN
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

      /// GLOBAL TEXT SCALE FIX
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