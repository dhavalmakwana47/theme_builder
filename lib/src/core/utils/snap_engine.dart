import 'package:flutter/material.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/canvas_spec.dart';

class SnapGuideLine {
  final bool isVertical;
  final double position;

  const SnapGuideLine({required this.isVertical, required this.position});
}

class SnapResult {
  final Offset snappedOffset;
  final List<SnapGuideLine> activeGuides;

  const SnapResult({required this.snappedOffset, required this.activeGuides});
}

abstract class SnapEngine {
  static const double snapThreshold = 6.0;

  static SnapResult calculateSnap({
    required Offset targetOffset,
    required Size targetSize,
    required CanvasSpec canvasSpec,
    required List<LayerModel> otherLayers,
    required String activeLayerId,
  }) {
    double dx = targetOffset.dx;
    double dy = targetOffset.dy;
    final List<SnapGuideLine> guides = [];

    // 1. Grid Snapping
    if (canvasSpec.snapToGrid) {
      final double grid = canvasSpec.gridSize;
      final double remX = dx % grid;
      if (remX < snapThreshold) {
        dx = dx - remX;
      } else if (grid - remX < snapThreshold) {
        dx = dx + (grid - remX);
      }

      final double remY = dy % grid;
      if (remY < snapThreshold) {
        dy = dy - remY;
      } else if (grid - remY < snapThreshold) {
        dy = dy + (grid - remY);
      }
    }

    // 2. Object Snapping & Center Canvas Snapping
    if (canvasSpec.snapToObjects) {
      final double canvasCenterX = canvasSpec.width / 2;
      final double canvasCenterY = canvasSpec.height / 2;
      final double targetCenterX = dx + targetSize.width / 2;
      final double targetCenterY = dy + targetSize.height / 2;

      // Canvas Center X
      if ((targetCenterX - canvasCenterX).abs() < snapThreshold) {
        dx = canvasCenterX - targetSize.width / 2;
        guides.add(SnapGuideLine(isVertical: true, position: canvasCenterX));
      }

      // Canvas Center Y
      if ((targetCenterY - canvasCenterY).abs() < snapThreshold) {
        dy = canvasCenterY - targetSize.height / 2;
        guides.add(SnapGuideLine(isVertical: false, position: canvasCenterY));
      }

      // Snapping against other layers
      for (final layer in otherLayers) {
        if (layer.id == activeLayerId || !layer.isVisible) continue;

        final double otherLeft = layer.x;
        final double otherRight = layer.x + layer.width;
        final double otherCenterX = layer.x + layer.width / 2;

        final double otherTop = layer.y;
        final double otherBottom = layer.y + layer.height;
        final double otherCenterY = layer.y + layer.height / 2;

        // Alignment: Left to Left
        if ((dx - otherLeft).abs() < snapThreshold) {
          dx = otherLeft;
          guides.add(SnapGuideLine(isVertical: true, position: otherLeft));
        }
        // Alignment: Center to Center X
        else if ((targetCenterX - otherCenterX).abs() < snapThreshold) {
          dx = otherCenterX - targetSize.width / 2;
          guides.add(SnapGuideLine(isVertical: true, position: otherCenterX));
        }
        // Alignment: Right to Right
        else if ((dx + targetSize.width - otherRight).abs() < snapThreshold) {
          dx = otherRight - targetSize.width;
          guides.add(SnapGuideLine(isVertical: true, position: otherRight));
        }

        // Alignment: Top to Top
        if ((dy - otherTop).abs() < snapThreshold) {
          dy = otherTop;
          guides.add(SnapGuideLine(isVertical: false, position: otherTop));
        }
        // Alignment: Center to Center Y
        else if ((targetCenterY - otherCenterY).abs() < snapThreshold) {
          dy = otherCenterY - targetSize.height / 2;
          guides.add(SnapGuideLine(isVertical: false, position: otherCenterY));
        }
        // Alignment: Bottom to Bottom
        else if ((dy + targetSize.height - otherBottom).abs() < snapThreshold) {
          dy = otherBottom - targetSize.height;
          guides.add(SnapGuideLine(isVertical: false, position: otherBottom));
        }
      }
    }

    return SnapResult(
      snappedOffset: Offset(dx, dy),
      activeGuides: guides,
    );
  }
}
