import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import './widgets/checkpoint_overlay.dart';
import './widgets/score.dart';

class RoadMapScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const RoadMapScreen({super.key, required this.user});

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
                      'assets/images/map.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  CheckpointOverlay(
                    onCheckpointTap: (index) {
                      print("Tapped checkpoint $index"); 
                    },
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        if (user['type'] == 'student')
                          ScoreWidget(
                            userId: user['id']?.toString() ?? '',
                            nickname: user['nickname']?.toString() ?? 'User',
                            initialStars: (user['stars'] as int?) ?? 0,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: BottomNavBar(
                currentRoute: 'roadmap',
                user: user,
              ),
            ),
          ],
        ),
      ),
    );
  }
}