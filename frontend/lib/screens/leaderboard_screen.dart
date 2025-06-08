import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';

class LeaderboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  LeaderboardScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AnimatedBackButton(
          onTap: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Leaderboard for ${user['type'] == 'student' ? 'Student' : 'Admin'}',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentRoute: 'leaderboard',
        user: user,
      ),
    );
  }
}
