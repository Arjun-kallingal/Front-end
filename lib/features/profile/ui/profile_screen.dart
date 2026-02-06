import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
          backgroundColor: Colors.red,
          centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: open settings
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Profile & Settings'),
      ),
    );
  }
}
