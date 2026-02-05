import 'package:flutter/material.dart';
import '../../../core/widgets/base_app_bar.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'Wallet',
      ),
    
      body: const Center(child: Text('Wallet Screen')),
    );
  }
}
