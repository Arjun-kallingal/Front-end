import 'package:flutter/material.dart';
import 'core/theme/dark_theme.dart';

class WalletCareApp extends StatelessWidget {
  const WalletCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: DarkTheme.theme,
      home: const Placeholder(), 
    );
  }
}