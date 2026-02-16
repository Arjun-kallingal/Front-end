import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/theme_provider.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().theme,
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





// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'core/theme/theme_provider.dart';
// import 'features/auth/ui/login_screen.dart';
// import 'features/home/ui/home_screen.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => ThemeProvider(),
//       child: const WalletCareApp(),
//     ),
//   );
// }

// class WalletCareApp extends StatelessWidget {
//   const WalletCareApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: context.watch<ThemeProvider>().theme,
//       initialRoute: '/login',
//       routes: {
//         '/login': (context) => const LoginScreen(),
//         '/home': (context) => const HomeScreen(),
//         '/signup': (context) => const Scaffold(
//               body: Center(child: Text('Signup Screen')),
//             ),
//         '/forgot-password': (context) => const Scaffold(
//               body: Center(child: Text('Forgot Password')),
//             ),
//       },
//     );
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'core/theme/theme_provider.dart';
// // import 'navigation/navigation_service.dart';



// // void main() {
// //   runApp(
// //     ChangeNotifierProvider(
// //        create: (_) => ThemeProvider(),
// //       child: const WalletCareApp(),
// //     ),
// //   );
// // }
// // class WalletCareApp extends StatelessWidget {
// //   const WalletCareApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //      return
// //     MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       theme: context.watch<ThemeProvider>().theme,
// //        home: MainNavigation(),
      
      
// //     );
// //   }
// // }
