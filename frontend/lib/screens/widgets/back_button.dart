import 'package:flutter/material.dart';

class AnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedBackButton({Key? key, required this.onTap}) : super(key: key);

  @override
  _AnimatedBackButtonState createState() => _AnimatedBackButtonState();
}

class _AnimatedBackButtonState extends State<AnimatedBackButton> {
  bool _tapped = false;

  void _handleTap() {
    setState(() {
      _tapped = true;
    });

    // Delay to allow animation, then trigger actual action
    Future.delayed(Duration(milliseconds: 150), () {
      widget.onTap();
      setState(() {
        _tapped = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 150),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: _tapped
            ? Image.asset(
                'assets/images/red_back_button_small.png',
                key: ValueKey('small'),
                width: 36,
              )
            : Image.asset(
                'assets/images/red_back_button_large.png',
                key: ValueKey('large'),
                width: 36,
              ),
      ),
    );
  }
}