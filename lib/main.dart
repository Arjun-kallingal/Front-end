import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/services/local_storage_service.dart';

import 'features/auth/ui/login_screen.dart';
import 'features/auth/ui/splash_screen.dart';

import 'navigation/navigation_service.dart';

import 'features/analytics/provider/analytics_provider.dart';
import 'core/providers/user_profile_provider.dart';
import 'core/providers/transaction_provider.dart';
import 'core/providers/account_provider.dart';
import 'features/goals/provider/goal_provider.dart';

import 'features/profile/ui/security/otp_verification_screen.dart';
import 'features/profile/ui/security/reset_password_screen.dart';
import 'features/profile/ui/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
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
      title: 'WalletCare',

      /// THEMES
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),

      /// START SCREEN
      home: const SplashScreen(),

      /// ROUTES
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainNavigation(),
        '/otpVerification': (_) => const OtpVerificationScreen(),
        '/resetPassword': (_) => const ResetPasswordScreen(),
        '/profileSettings': (_) => const ProfileSettingsScreen(),
      },

      /// FIX TEXT SCALE
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
