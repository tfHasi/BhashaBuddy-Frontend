import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import './widgets/score.dart';

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
        actions: [
          if (user['type'] == 'student')
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ScoreWidget(
                userId: user['id']?.toString() ?? '',
                nickname: user['nickname']?.toString() ?? 'User',
                initialStars: (user['stars'] as int?) ?? 0,
              ),
            ),
        ],
      ),
      body: Center(
        child: Text(
          'Settings for ${user['type'] == 'student' ? 'Student' : 'Admin'}',
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: 'settings',
        user: user,
      ),
    );
  }
}