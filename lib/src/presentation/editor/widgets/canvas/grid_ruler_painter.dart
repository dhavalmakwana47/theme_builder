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
    if (canvasSpec.showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.gridLine
        ..strokeWidth = 1.0;

      final double grid = canvasSpec.gridSize;

      for (double x = 0; x <= size.width; x += grid) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }

      for (double y = 0; y <= size.height; y += grid) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Paint Alignment Guide Lines
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
