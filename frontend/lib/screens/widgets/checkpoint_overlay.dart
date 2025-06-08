import 'package:flutter/material.dart';

class CheckpointOverlay extends StatelessWidget {
  final void Function(int checkpointIndex) onCheckpointTap;

  const CheckpointOverlay({super.key, required this.onCheckpointTap});

  @override
  Widget build(BuildContext context) {
    final List<Offset> checkpointPositions = [
      Offset(0.442, 0.856),
      Offset(0.585, 0.755),
      Offset(0.416, 0.674),
      Offset(0.7, 0.569),
      Offset(0.377, 0.502),
      Offset(0.542, 0.391),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: List.generate(checkpointPositions.length, (index) {
            final pos = checkpointPositions[index];
            return Positioned(
              left: width * pos.dx - (width * 0.04),
              top: height * pos.dy - (width * 0.04),
              child: _AnimatedPlayButton(
                width: width * 0.08,
                onTap: () => onCheckpointTap(index + 1),
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