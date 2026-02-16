import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';



import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/main.dart';

void main() {
  testWidgets('WalletCare app crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const WalletCareApp(),
      ),
    );

  
  testWidgets('WalletCare app loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const WalletCareApp());

    // Verify text is shown
    expect(find.text('Wallet Care App'), findsOneWidget);

    // Basic sanity check
    expect(find.byType(MaterialApp), findsOneWidget);
    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
});
}
