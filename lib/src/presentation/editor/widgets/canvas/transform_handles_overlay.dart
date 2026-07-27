import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/layer_model.dart';

class TransformHandlesOverlay extends StatefulWidget {
  final LayerModel layer;
  final Function(double x, double y, double w, double h, {bool snap}) onTransformUpdate;
  final Function(double rotation) onRotateUpdate;
  final VoidCallback onTransformEnd;

  const TransformHandlesOverlay({
    super.key,
    required this.layer,
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

  static const double handleSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final layer = widget.layer;

    if (layer.isLocked) {
      return SizedBox(
        width: layer.width,
        height: layer.height,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.amber, width: 1.5),
          ),
          child: const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.lock, color: Colors.amber, size: 14),
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
          // Drag-to-move body container
          GestureDetector(
            onPanStart: (details) {
              _dragStart = details.globalPosition;
              _initialX = layer.x;
              _initialY = layer.y;
            },
            onPanUpdate: (details) {
              if (_dragStart == null) return;
              final delta = details.globalPosition - _dragStart!;
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
                border: Border.all(color: AppColors.selectionOutline, width: 1.5),
                color: AppColors.selectionOutline.withOpacity(0.04),
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
            left: layer.width / 2 - 6,
            top: -30,
            child: GestureDetector(
              onPanUpdate: (details) {
                final center = Offset(layer.x + layer.width / 2, layer.y + layer.height / 2);
                final touch = details.globalPosition;
                final angle = math.atan2(touch.dy - center.dy, touch.dx - center.dx) * (180 / math.pi) + 90;
                widget.onRotateUpdate(angle);
              },
              onPanEnd: (_) => widget.onTransformEnd(),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.selectionOutline,
                  shape: BoxShape.circle,
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
      left: left,
      top: top,
      child: GestureDetector(
        onPanStart: (details) {
          _dragStart = details.globalPosition;
          _initialX = layer.x;
          _initialY = layer.y;
          _initialW = layer.width;
          _initialH = layer.height;
        },
        onPanUpdate: (details) {
          if (_dragStart == null) return;
          final delta = details.globalPosition - _dragStart!;
          onDelta(delta.dx, delta.dy);
        },
        onPanEnd: (_) => widget.onTransformEnd(),
        child: Container(
          width: handleSize,
          height: handleSize,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.selectionOutline, width: 1.5),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
