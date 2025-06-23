import 'package:flutter/material.dart';
import './widgets/bottom_navbar.dart';
import './widgets/back_button.dart';
import './widgets/checkpoint_overlay.dart';
import './widgets/score.dart';
import './widgets/level_overlay.dart';
import '../services/progress_service.dart';
import './task_screen.dart';

class RoadMapScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const RoadMapScreen({super.key, required this.user});
  @override
  State<RoadMapScreen> createState() => _RoadMapScreenState();
}

class _RoadMapScreenState extends State<RoadMapScreen> {
  bool _showOverlay = false;
  int _selectedLevel = 1;
  Map<String, dynamic>? _progressData;
  Map<String, dynamic>? _levelsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  // Load progress data when screen initializes
  Future<void> _loadProgressData() async {
    final studentUid = widget.user['uid']?.toString();
    if (studentUid == null) return;
    try {
      final progress = await ProgressService.getProgress(studentUid);
      final levels = await ProgressService.getAvailableLevels(studentUid);
      setState(() {
        _progressData = progress;
        _levelsData = levels;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading progress data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleCheckpointTap(int levelIndex) {
    // Check if level is unlocked using ProgressService
    if (_levelsData != null && 
        ProgressService.isLevelUnlocked(_levelsData!['unlocked_levels'] ?? {}, levelIndex)) {
      setState(() {
        _selectedLevel = levelIndex;
        _showOverlay = true;
      });
    }
  }

  void _closeOverlay() {
    setState(() {
      _showOverlay = false;
    });
  }

  void _startLevel() async {
    _closeOverlay();
    
    // Navigate to TaskScreen and wait for result
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(
          level: _selectedLevel,
          user: widget.user,
        ),
      ),
    );
    
    // Refresh progress data when returning from TaskScreen
    _loadProgressData();
  }

  // ProgressService helper methods
  Map<int, int> _calculateLevelStars() {
    if (_progressData == null) {
      return {for (int i = 1; i <= 6; i++) i: 0};
    }

    Map<int, int> levelStars = {};
    for (int i = 1; i <= 6; i++) {
      levelStars[i] = ProgressService.getLevelStars(_progressData!, i);
    }

    return levelStars;
  }

  // Get total stars using ProgressService
  int _getTotalStars() {
    return _progressData != null 
        ? ProgressService.getTotalStars(_progressData!)
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    // Show loading indicator while fetching data
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                    levelStars: _calculateLevelStars(),
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
                            userId: user['uid']?.toString() ?? '',
                            nickname: user['nickname']?.toString() ?? 'User',
                            initialStars: _getTotalStars(),
                          ),
                      ],
                    ),
                  ),
                  if (_showOverlay)
                    LevelOverlay(
                      level: _selectedLevel,
                      stars: _calculateLevelStars()[_selectedLevel] ?? 0,
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