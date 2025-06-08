import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  SettingsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AnimatedBackButton(
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text('Settings for ${user['nickname'] ?? 'Admin'}'),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: 'settings',
        user: user,
      ),
    );
  }
}