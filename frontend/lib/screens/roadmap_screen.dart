import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import './widgets/checkpoint_overlay.dart';

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
                  // Map Background Image
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
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