

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'core/theme/theme_provider.dart';
// import 'core/theme/light_theme.dart';
// import 'core/theme/dark_theme.dart';
// import 'features/auth/ui/login_screen.dart';
// import 'navigation/navigation_service.dart';
// import 'features/analytics/provider/analytics_provider.dart';
// import 'package:front_end/core/providers/user_profile_provider.dart';
// import 'package:front_end/features/auth/ui/splash_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
//         ChangeNotifierProvider(create: (_) => UserProfileProvider()),
//       ],
//       child: const WalletCareApp(),
//     ),
//   );
// }

// class WalletCareApp extends StatelessWidget {
//   const WalletCareApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = context.watch<ThemeProvider>();

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Moneycart',

//       theme: LightTheme.theme,
//       darkTheme: DarkTheme.theme,
//       themeMode: themeProvider.themeMode,
//       themeAnimationDuration: const Duration(milliseconds: 300),

//       // Splash is first screen
//       home: const SplashScreen(),

//       routes: {
//         '/login': (_) => const LoginScreen(),
//         '/main': (_) => const MainNavigation(),
//       },

//       builder: (context, child) {
//         return MediaQuery(
//           data: MediaQuery.of(context)
//               .copyWith(textScaler: const TextScaler.linear(1.0)),
//           child: child ?? const SizedBox(),
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/auth/ui/login_screen.dart';
import 'navigation/navigation_service.dart';
import 'features/analytics/provider/analytics_provider.dart';
import 'package:front_end/core/providers/user_profile_provider.dart';
import 'package:front_end/features/auth/ui/splash_screen.dart';
import 'package:front_end/features/profile/ui/security/otp_verification_screen.dart';
import 'package:front_end/features/profile/ui/security/reset_password_screen.dart';
import 'package:front_end/features/profile/ui/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
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
      title: 'Moneycart',

      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: themeProvider.themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),

      /// FIRST SCREEN
      home: const SplashScreen(),

      /// ROUTES
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainNavigation(),

        '/otpVerification': (_) => const OtpVerificationScreen(),
        '/resetPassword': (_) => const ResetPasswordScreen(),
         '/profileSettings': (_) => const ProfileSettingsScreen(),
        
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