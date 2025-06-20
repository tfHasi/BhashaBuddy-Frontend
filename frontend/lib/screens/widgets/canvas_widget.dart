import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawableCanvas extends StatefulWidget {
  final double size;
  final void Function(Uint8List bytes) onCapture;

  const DrawableCanvas({
    super.key,
    this.size = 64.0,
    required this.onCapture,
  });

  @override
  State<DrawableCanvas> createState() => _DrawableCanvasState();
}

class _DrawableCanvasState extends State<DrawableCanvas> {
  final List<Offset?> _points = [];
  final GlobalKey _key = GlobalKey();

  void _addPoint(Offset point) => setState(() => _points.add(point));
  void _endStroke() => setState(() => _points.add(null));
  void _clear() => setState(() => _points.clear());

  Future<void> _capture() async {
    final boundary = _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) widget.onCapture(byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          key: _key,
          child: GestureDetector(
            onPanUpdate: (details) => _addPoint(details.localPosition),
            onPanEnd: (_) => _endStroke(),
            child: CustomPaint(
              painter: _Painter(_points),
              child: SizedBox(
                width: widget.size,
                height: widget.size,
              ),
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.clear), onPressed: _clear),
            IconButton(icon: const Icon(Icons.check), onPressed: _capture),
          ],
        ),
      ],
    );
  }
}

class _Painter extends CustomPainter {
  final List<Offset?> points;
  _Painter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}