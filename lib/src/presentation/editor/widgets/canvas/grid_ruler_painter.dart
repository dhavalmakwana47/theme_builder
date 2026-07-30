import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/snap_engine.dart';
import '../../../../domain/models/canvas_spec.dart';

class GridRulerPainter extends CustomPainter {
  final CanvasSpec canvasSpec;
  final List<SnapGuideLine> activeGuides;

  GridRulerPainter({
    required this.canvasSpec,
    required this.activeGuides,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw Blueprint Resolution Watermark Text in Center of Grid Canvas
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${size.width.toInt()} × ${size.height.toInt()}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.08),
          fontSize: (size.width * 0.11).clamp(28.0, 130.0),
          fontWeight: FontWeight.w900,
          letterSpacing: 4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // 2. Draw Dynamic Proportional Grid Matrix (10 Proportional Divisions)
    if (canvasSpec.showGrid) {
      final double stepX = size.width / 10.0;
      final double stepY = size.height / 10.0;

      final gridPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 1.0;

      final centerGridPaint = Paint()
        ..color = AppColors.accentPrimary.withOpacity(0.5)
        ..strokeWidth = 1.8;

      // Draw 10 Vertical Grid Division Lines
      for (int i = 0; i <= 10; i++) {
        final double x = i * stepX;
        final paint = (i == 5) ? centerGridPaint : gridPaint;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }

      // Draw 10 Horizontal Grid Division Lines
      for (int i = 0; i <= 10; i++) {
        final double y = i * stepY;
        final paint = (i == 5) ? centerGridPaint : gridPaint;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }

      // Outer Bright White Frame Outline
      final whiteBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), whiteBorder);
    }

    // 3. Paint Active Alignment & Snap Guide Lines
    final guidePaint = Paint()
      ..color = AppColors.guideLine
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final guide in activeGuides) {
      if (guide.isVertical) {
        canvas.drawLine(Offset(guide.position, 0), Offset(guide.position, size.height), guidePaint);
      } else {
        canvas.drawLine(Offset(0, guide.position), Offset(size.width, guide.position), guidePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridRulerPainter oldDelegate) => true;
}
