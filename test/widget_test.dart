import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:front_end/main.dart';

void main() {
  testWidgets('WalletCare app loads correctly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const WalletCareApp());

    // Verify text is shown
    expect(find.text('Wallet Care App'), findsOneWidget);

    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
