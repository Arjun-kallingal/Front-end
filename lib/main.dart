import 'package:flutter/material.dart';
import '/navigation/main_navigation.dart';

void main() {
  runApp(const WalletCareApp());
}

class WalletCareApp extends StatelessWidget {
  const WalletCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigation(),
    );
  }
}
