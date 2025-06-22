import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'canvas_widget.dart';

class CanvasOverlay extends StatelessWidget {
  final void Function(Uint8List bytes) onSave;

  const CanvasOverlay({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DrawableCanvas(
              size: 64,
              onCapture: (bytes) {
                onSave(bytes);
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      ),
    );
  }
}