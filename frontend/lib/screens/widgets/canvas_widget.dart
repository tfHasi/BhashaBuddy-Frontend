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
  bool _hasDrawing = false;

  void _addPoint(Offset point) {
    setState(() {
      _points.add(point);
      _hasDrawing = true;
    });
  }

  void _endStroke() => setState(() => _points.add(null));

  void _clear() {
    setState(() {
      _points.clear();
      _hasDrawing = false;
    });
  }

  Future<void> _capture() async {
    final boundary = _key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        widget.onCapture(byteData.buffer.asUint8List());
        setState(() => _hasDrawing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: RepaintBoundary(
            key: _key,
            child: GestureDetector(
              onPanUpdate: (details) => _addPoint(details.localPosition),
              onPanEnd: (_) => _endStroke(),
              child: CustomPaint(
                painter: _CanvasPainter(_points),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: _clear,
              tooltip: 'Clear',
            ),
            IconButton(
              icon: const Icon(Icons.check, size: 18),
              onPressed: _hasDrawing ? _capture : null,
              tooltip: 'Capture',
              color: _hasDrawing ? Colors.green : Colors.grey,
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _hasDrawing ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<Offset?> points;

  _CanvasPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}