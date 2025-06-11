import 'package:flutter/material.dart';

class LevelOverlay extends StatefulWidget {
  final int level;
  final VoidCallback onPlay;
  final VoidCallback onClose;

  const LevelOverlay({
    super.key,
    required this.level,
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
                'assets/images/LevelOverlay/red_square_depth.png',
                width: size.width * 0.6,
                height: size.width * 0.6,
                fit: BoxFit.fill,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Curved star row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, 15),
                        child: Image.asset(
                          'assets/images/empty_star.png',
                          width: 48,
                        ),
                      ),
                      Image.asset(
                        'assets/images/empty_star.png',
                        width: 64,
                      ),
                      Transform.translate(
                        offset: const Offset(0, 15),
                        child: Image.asset(
                          'assets/images/empty_star.png',
                          width: 48,
                        ),
                      ),
                    ],
                  ),
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
        // Responsive close button
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