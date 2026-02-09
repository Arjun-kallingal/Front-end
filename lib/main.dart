import 'package:flutter/material.dart';
import 'navigation/navigation_service.dart';

void main() {
  runApp(const WalletCareApp());
}

class WalletCareApp extends StatelessWidget {
  const WalletCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(), // 👈 connected to another UI
    );
  }
}
