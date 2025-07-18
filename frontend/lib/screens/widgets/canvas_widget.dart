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
  final List<Offset?> points = [];
  final GlobalKey key = GlobalKey();
  bool hasDrawing = false;
  
  // Scale factor for better drawing experience
  static const double scaleFactor = 4.0;

  void _addPoint(Offset point) {
    setState(() {
      points.add(point);
      hasDrawing = true;
    });
  }

  void _clear() => setState(() {
    points.clear();
    hasDrawing = false;
  });

  Future<void> _capture() async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary != null) {
      // Capture at scale factor then resize to exact target size
      final image = await boundary.toImage(pixelRatio: scaleFactor);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        // Resize to exact target size
        final codec = await ui.instantiateImageCodec(
          byteData.buffer.asUint8List(),
          targetWidth: widget.size.toInt(),
          targetHeight: widget.size.toInt(),
        );
        final frame = await codec.getNextFrame();
        final resizedByteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
        
        if (resizedByteData != null) {
          widget.onCapture(resizedByteData.buffer.asUint8List());
          setState(() => hasDrawing = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displaySize = widget.size * scaleFactor;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
            color: Colors.white,
          ),
          child: RepaintBoundary(
            key: key,
            child: GestureDetector(
              onPanUpdate: (details) => _addPoint(details.localPosition),
              onPanEnd: (_) => setState(() => points.add(null)),
              child: CustomPaint(
                painter: _CanvasPainter(points),
                child: SizedBox(
                  width: displaySize,
                  height: displaySize,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
              onPressed: hasDrawing ? _capture : null,
              tooltip: 'Capture',
              color: hasDrawing ? Colors.green : Colors.grey,
            ),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasDrawing ? Colors.orange : Colors.grey,
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
      ..strokeWidth = 12.0
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