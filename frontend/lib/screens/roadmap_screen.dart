import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import './widgets/checkpoint_overlay.dart';
import './widgets/score.dart';
import './widgets/level_overlay.dart';

class RoadMapScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const RoadMapScreen({super.key, required this.user});

  @override
  State<RoadMapScreen> createState() => _RoadMapScreenState();
}

class _RoadMapScreenState extends State<RoadMapScreen> {
  bool _showOverlay = false;
  int _selectedLevel = 1;

  void _handleCheckpointTap(int index) {
    setState(() {
      _selectedLevel = index;
      _showOverlay = true;
    });
  }

  void _closeOverlay() {
    setState(() {
      _showOverlay = false;
    });
  }

  void _startLevel() {
    _closeOverlay();
    print("Starting level $_selectedLevel");
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

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
                    onCheckpointTap: _handleCheckpointTap,
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
                  if (_showOverlay)
                    LevelOverlay(
                      level: _selectedLevel,
                      onPlay: _startLevel,
                      onClose: _closeOverlay,
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