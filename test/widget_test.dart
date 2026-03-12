// import 'package:flutter_test/flutter_test.dart';
// import 'package:provider/provider.dart';

// import 'package:front_end/main.dart';
// import 'package:front_end/core/theme/theme_provider.dart';
// import 'package:front_end/features/analytics/provider/analytics_provider.dart';

// void main() {
//   testWidgets('WalletCare app loads correctly',
//       (WidgetTester tester) async {

//     await tester.pumpWidget(
//       MultiProvider(
//         providers: [
//           ChangeNotifierProvider(create: (_) => ThemeProvider()),
//           ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
//         ],
//         child: const WalletCareApp(
//           isLoggedIn: false, // ✅ ADD THIS
//         ),
//       ),
//     );

//     await tester.pumpAndSettle();

//     expect(find.byType(WalletCareApp), findsOneWidget);
//   });
// }

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:front_end/main.dart';
import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/features/analytics/provider/analytics_provider.dart';

void main() {
  testWidgets('WalletCare app loads correctly', (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AnalyticsNotifier()),
        ],
        child: const WalletCareApp(), 
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WalletCareApp), findsOneWidget);
  });
}