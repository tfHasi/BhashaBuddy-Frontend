import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';

class LeaderboardScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const LeaderboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/homescreen/background_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(color: const Color.fromARGB(59, 0, 0, 0)),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Text(
                      'Leaderboard for ${user['type'] == 'student' ? 'Student' : 'Admin'}',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: BottomNavBar(
                currentRoute: 'leaderboard',
                user: user,
              ),
            ),
          ],
        ),
      ),
    );
  }
}