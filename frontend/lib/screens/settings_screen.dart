import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  SettingsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Center(
        child: Text('Settings for ${user['nickname'] ?? 'Admin'}'),
      ),
    );
  }
}