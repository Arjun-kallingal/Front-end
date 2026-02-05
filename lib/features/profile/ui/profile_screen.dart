import 'package:flutter/material.dart';
import 'package:front_end/core/widgets/base_app_bar.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(
        title: 'Profile',
        actions: [
          Icon(Icons.settings),
        ],
      ),
      body: const Center(child: Text('Profile & Settings')),
    );
  }
}
