import 'package:flutter/material.dart';
import '../../services/progress_service.dart';

class CheckpointOverlay extends StatelessWidget {
  final void Function(int checkpointIndex) onCheckpointTap;
  final Map<int, int> levelStars;
  final Map<String, dynamic>? levelsData;
  
  const CheckpointOverlay({
    super.key,
    required this.onCheckpointTap,
    required this.levelStars,
    this.levelsData,
  });

  // Use ProgressService for consistent unlocking logic
  bool _isLevelUnlocked(int level) {
    if (levelsData != null) {
      return ProgressService.isLevelUnlocked(
        levelsData!['unlocked_levels'] ?? {}, 
        level
      );
    } else {
      // Fallback to original logic if no levels data
      if (level == 1) return true;
      final previousLevelStars = levelStars[level - 1] ?? 0;
      return previousLevelStars >= 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Offset> checkpointPositions = [
      Offset(0.442, 0.856), // Level 1
      Offset(0.585, 0.755), // Level 2
      Offset(0.416, 0.674), // Level 3
      Offset(0.7, 0.569),   // Level 4
      Offset(0.377, 0.502), // Level 5
      Offset(0.542, 0.391), // Level 6
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: List.generate(checkpointPositions.length, (index) {
            final pos = checkpointPositions[index];
            final level = index + 1;
            final isUnlocked = _isLevelUnlocked(level);

            return Positioned(
              left: width * pos.dx - (width * 0.04),
              top: height * pos.dy - (width * 0.04),
              child: isUnlocked
                  ? _AnimatedPlayButton(
                      width: width * 0.08,
                      onTap: () => onCheckpointTap(level),
                    )
                  : Image.asset(
                      'assets/images/lock.png',
                      width: width * 0.08,
                    ),
            );
          }),
        );
      },
    );
  }
}

class _AnimatedPlayButton extends StatefulWidget {
  final double width;
  final VoidCallback onTap;

  const _AnimatedPlayButton({required this.width, required this.onTap});

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton> {
  bool _tapped = false;

  void _handleTap() {
    setState(() => _tapped = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _tapped = false);
        widget.onTap();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: Image.asset(
          _tapped
              ? 'assets/images/play_button_small.png'
              : 'assets/images/play_button_large.png',
          width: widget.width,
          key: ValueKey<bool>(_tapped),
        ),
      ),
    );
  }
}