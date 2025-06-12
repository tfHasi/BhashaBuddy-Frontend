import 'package:flutter/material.dart';

class LevelOverlay extends StatefulWidget {
  final int level;
  final int stars;
  final VoidCallback onPlay;
  final VoidCallback onClose;

  const LevelOverlay({
    super.key,
    required this.level,
    required this.stars,
    required this.onPlay,
    required this.onClose,
  });

  @override
  State<LevelOverlay> createState() => _LevelOverlayState();
}

class _LevelOverlayState extends State<LevelOverlay> {
  bool _closeTapped = false;

  void _handleCloseTap() {
    setState(() => _closeTapped = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _closeTapped = false);
        widget.onClose();
      }
    });
  }

  // Helper method to build star row with actual progress
  Widget _buildStarRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 15),
          child: Image.asset(
            widget.stars >= 1 ? 'assets/images/yellow_star.png' : 'assets/images/empty_star.png',
            width: 48,
          ),
        ),
        Image.asset(
          widget.stars >= 2 ? 'assets/images/yellow_star.png' : 'assets/images/empty_star.png',
          width: 64,
        ),
        Transform.translate(
          offset: const Offset(0, 15),
          child: Image.asset(
            widget.stars >= 3 ? 'assets/images/yellow_star.png' : 'assets/images/empty_star.png',
            width: 48,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(color: Colors.black54),
        // Centered content
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/blue_square.png',
                width: size.width * 0.6,
                height: size.width * 0.6,
                fit: BoxFit.fill,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStarRow(),
                  const SizedBox(height: 40),
                  // Level label
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/yellow_input_button.png',
                        width: size.width * 0.4,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'Level ${widget.level}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 33, 33, 33),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Play button
                  GestureDetector(
                    onTap: widget.onPlay,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/images/yellow_round.png',
                          width: 56,
                        ),
                        Image.asset(
                          'assets/images/play_icon_dark.png',
                          width: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Align(
          alignment: const Alignment(0.6, -0.325), 
          child: GestureDetector(
            onTap: _handleCloseTap,
            child: Image.asset(
              _closeTapped
                  ? 'assets/images/blue_cross_tapped.png'
                  : 'assets/images/blue_cross_untapped.png',
              width: 32,
            ),
          ),
        ),
      ],
    );
  }
}