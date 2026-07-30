import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/layer_model.dart';

class TransformHandlesOverlay extends StatefulWidget {
  final LayerModel layer;
  final double scale;
  final Function(double x, double y, double w, double h, {bool snap}) onTransformUpdate;
  final Function(double rotation) onRotateUpdate;
  final VoidCallback onTransformEnd;

  const TransformHandlesOverlay({
    super.key,
    required this.layer,
    this.scale = 1.0,
    required this.onTransformUpdate,
    required this.onRotateUpdate,
    required this.onTransformEnd,
  });

  @override
  State<TransformHandlesOverlay> createState() => _TransformHandlesOverlayState();
}

class _TransformHandlesOverlayState extends State<TransformHandlesOverlay> {
  Offset? _dragStart;
  double _initialX = 0;
  double _initialY = 0;
  double _initialW = 0;
  double _initialH = 0;

  static const double handleSize = 14.0;

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;
    final double effectiveScale = widget.scale > 0 ? widget.scale : 1.0;

    if (layer.isLocked) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 2.0),
          ),
          child: const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.lock, color: Colors.amber, size: 16),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Drag-to-move body container with opaque hit-testing for touch
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) {
              _dragStart = details.globalPosition;
              _initialX = layer.x;
              _initialY = layer.y;
            },
            onPanUpdate: (details) {
              if (_dragStart == null) return;
              final delta = (details.globalPosition - _dragStart!) / effectiveScale;
              widget.onTransformUpdate(
                _initialX + delta.dx,
                _initialY + delta.dy,
                layer.width,
                layer.height,
                snap: true,
              );
            },
            onPanEnd: (_) => widget.onTransformEnd(),
            child: Container(
              width: layer.width,
              height: layer.height,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.selectionOutline, width: 2.0),
                color: AppColors.selectionOutline.withOpacity(0.08),
              ),
            ),
          ),

          // Top Rotation Handle Line & Knob
          Positioned(
            left: layer.width / 2 - 1,
            top: -24,
            child: Container(width: 2, height: 24, color: AppColors.selectionOutline),
          ),
          Positioned(
            left: layer.width / 2 - 12,
            top: -36,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                final center = Offset(layer.x + layer.width / 2, layer.y + layer.height / 2);
                final touch = details.globalPosition;
                final angle = math.atan2(touch.dy - center.dy, touch.dx - center.dx) * (180 / math.pi) + 90;
                widget.onRotateUpdate(angle);
              },
              onPanEnd: (_) => widget.onTransformEnd(),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.selectionOutline,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // 8 Bounding Resize Handles
          _buildResizeHandle(Alignment.topLeft, (dx, dy) {
            widget.onTransformUpdate(_initialX + dx, _initialY + dy, _initialW - dx, _initialH - dy);
          }),
          _buildResizeHandle(Alignment.topRight, (dx, dy) {
            widget.onTransformUpdate(_initialX, _initialY + dy, _initialW + dx, _initialH - dy);
          }),
          _buildResizeHandle(Alignment.bottomLeft, (dx, dy) {
            widget.onTransformUpdate(_initialX + dx, _initialY, _initialW - dx, _initialH + dy);
          }),
          _buildResizeHandle(Alignment.bottomRight, (dx, dy) {
            widget.onTransformUpdate(_initialX, _initialY, _initialW + dx, _initialH + dy);
          }),
          _buildResizeHandle(Alignment.topCenter, (dx, dy) {
            widget.onTransformUpdate(_initialX, _initialY + dy, _initialW, _initialH - dy);
          }),
          _buildResizeHandle(Alignment.bottomCenter, (dx, dy) {
            widget.onTransformUpdate(_initialX, _initialY, _initialW, _initialH + dy);
          }),
          _buildResizeHandle(Alignment.centerLeft, (dx, dy) {
            widget.onTransformUpdate(_initialX + dx, _initialY, _initialW - dx, _initialH);
          }),
          _buildResizeHandle(Alignment.centerRight, (dx, dy) {
            widget.onTransformUpdate(_initialX, _initialY, _initialW + dx, _initialH);
          }),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(Alignment alignment, Function(double dx, double dy) onDelta) {
    final layer = widget.layer;
    final double effectiveScale = widget.scale > 0 ? widget.scale : 1.0;

    double left = 0;
    double top = 0;

    if (alignment == Alignment.topLeft) {
      left = -handleSize / 2;
      top = -handleSize / 2;
    } else if (alignment == Alignment.topRight) {
      left = layer.width - handleSize / 2;
      top = -handleSize / 2;
    } else if (alignment == Alignment.bottomLeft) {
      left = -handleSize / 2;
      top = layer.height - handleSize / 2;
    } else if (alignment == Alignment.bottomRight) {
      left = layer.width - handleSize / 2;
      top = layer.height - handleSize / 2;
    } else if (alignment == Alignment.topCenter) {
      left = layer.width / 2 - handleSize / 2;
      top = -handleSize / 2;
    } else if (alignment == Alignment.bottomCenter) {
      left = layer.width / 2 - handleSize / 2;
      top = layer.height - handleSize / 2;
    } else if (alignment == Alignment.centerLeft) {
      left = -handleSize / 2;
      top = layer.height / 2 - handleSize / 2;
    } else if (alignment == Alignment.centerRight) {
      left = layer.width - handleSize / 2;
      top = layer.height / 2 - handleSize / 2;
    }

    return Positioned(
      left: left - 6,
      top: top - 6,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          _dragStart = details.globalPosition;
          _initialX = layer.x;
          _initialY = layer.y;
          _initialW = layer.width;
          _initialH = layer.height;
        },
        onPanUpdate: (details) {
          if (_dragStart == null) return;
          final delta = (details.globalPosition - _dragStart!) / effectiveScale;
          onDelta(delta.dx, delta.dy);
        },
        onPanEnd: (_) => widget.onTransformEnd(),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.selectionOutline, width: 2.0),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
