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

  void _handleCheckpointTap(int levelIndex) {
    setState(() {
      _selectedLevel = levelIndex;
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
    // TODO: Navigate to task screen for selected level
  }

  Map<int, int> _calculateLevelStars(Map<String, dynamic> user) {
    final completedTasks = user['completed_tasks'] as List<dynamic>? ?? [];

    Map<int, int> levelStars = {
      for (int i = 1; i <= 6; i++) i: 0,
    };

    for (final task in completedTasks) {
      final levelId = task['level_id'];
      if (levelId != null && levelId.startsWith('level_')) {
        final levelNum = int.tryParse(levelId.split('_')[1]);
        if (levelNum != null && levelStars.containsKey(levelNum)) {
          levelStars[levelNum] = levelStars[levelNum]! + 1;
        }
      }
    }

    return levelStars;
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
                    levelStars: _calculateLevelStars(user),
                  ),
                  Positioned(
                    top: 20,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                        if (user['type'] == 'student')
                          ScoreWidget(
                            userId: user['id']?.toString() ?? '',
                            nickname: user['nickname']?.toString() ?? 'User',
                            initialStars: (user['total_stars'] as int?) ?? 0,
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