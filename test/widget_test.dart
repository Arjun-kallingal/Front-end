import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:front_end/core/theme/theme_provider.dart';
import 'package:front_end/main.dart';

void main() {
  testWidgets('WalletCare app builds without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const WalletCareApp(),
      ),
    );

    // Basic sanity check
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}