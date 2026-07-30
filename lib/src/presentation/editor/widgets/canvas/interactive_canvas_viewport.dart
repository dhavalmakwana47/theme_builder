import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_notifier.dart';
import '../../../../renderer/template_renderer.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/canvas_spec.dart';
import '../../../../core/constants/app_colors.dart';
import 'grid_ruler_painter.dart';
import 'transform_handles_overlay.dart';

class InteractiveCanvasViewport extends ConsumerStatefulWidget {
  final GlobalKey repaintBoundaryKey;
  final Function(Offset position) onCursorHover;

  const InteractiveCanvasViewport({
    super.key,
    required this.repaintBoundaryKey,
    required this.onCursorHover,
  });

  @override
  ConsumerState<InteractiveCanvasViewport> createState() =>
      _InteractiveCanvasViewportState();
}

class _InteractiveCanvasViewportState
    extends ConsumerState<InteractiveCanvasViewport> {
  late TransformationController _transformController;
  String? _lastFitKey;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _fitCanvasToViewport(double availW, double availH, CanvasSpec spec) {
    if (availW <= 0 || availH <= 0) return;

    final String fitKey = '${availW.toInt()}_${availH.toInt()}_${spec.width.toInt()}_${spec.height.toInt()}_${spec.presetName}';
    if (_lastFitKey == fitKey) return;

    _lastFitKey = fitKey;

    final double scale = math.min(
      (availW - 80) / spec.width,
      (availH - 80) / spec.height,
    ).clamp(0.05, 2.0);

    final double offsetX = (availW - (spec.width * scale)) / 2;
    final double offsetY = (availH - (spec.height * scale)) / 2;

    _transformController.value = Matrix4.identity()
      ..translate(offsetX, offsetY)
      ..scale(scale);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);
    final spec = state.template.canvasSpec;

    return LayoutBuilder(
      builder: (context, constraints) {
        _fitCanvasToViewport(
          constraints.maxWidth,
          constraints.maxHeight,
          spec,
        );

        final double currentScale = _transformController.value.getMaxScaleOnAxis();

        return MouseRegion(
          onHover: (event) {
            widget.onCursorHover(event.localPosition);
          },
          child: GestureDetector(
            onTap: () {
              if (state.activeTool == EditorTool.select) {
                notifier.clearSelection();
              }
            },
            child: Container(
              color: const Color(0xFF101014), // Deep workspace background
              child: InteractiveViewer(
                key: ValueKey('viewport_${spec.width}_${spec.height}_${spec.presetName}'),
                constrained: false, // Prevent InteractiveViewer from stretching canvas to window aspect ratio
                transformationController: _transformController,
                boundaryMargin: const EdgeInsets.all(1500),
                minScale: 0.05,
                maxScale: 5.0,
                panEnabled: true,
                scaleEnabled: true,
                onInteractionUpdate: (details) {
                  if (details.scale != 1.0) {
                    notifier.setZoom(_transformController.value.getMaxScaleOnAxis());
                  }
                },
                child: SizedBox(
                  width: spec.width,
                  height: spec.height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Prominent Canvas Artboard Container Highlighted with Pure White Border
                      Container(
                        width: spec.width,
                        height: spec.height,
                        decoration: BoxDecoration(
                          color: Color(spec.backgroundColorHex),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.white, // Crisp Bright White Border Highlight
                            width: 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.35),
                              blurRadius: 24,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 40,
                              spreadRadius: 8,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.hardEdge,
                          children: [
                            // Repaint Boundary wrapping template renderer
                            RepaintBoundary(
                              key: widget.repaintBoundaryKey,
                              child: TemplateRenderer(
                                template: state.template,
                                overrideVariables: state.isPreviewMode
                                    ? state.overrideVariables
                                    : null,
                              ),
                            ),

                            // Grid & Alignment Guide Overlay
                            Positioned.fill(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  painter: GridRulerPainter(
                                    canvasSpec: spec,
                                    activeGuides: state.activeGuides,
                                  ),
                                ),
                              ),
                            ),

                            // Interactive Selection & Transform Handles Overlay
                            if (!state.isPreviewMode)
                              ...state.template.layers.map((layer) {
                                final bool isSelected =
                                    state.selectedLayerIds.contains(layer.id);
                                if (!layer.isVisible) return const SizedBox.shrink();

                                return Positioned(
                                  left: layer.x,
                                  top: layer.y,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      notifier.selectLayer(layer.id);
                                    },
                                    child: isSelected
                                        ? TransformHandlesOverlay(
                                            layer: layer,
                                            scale: currentScale,
                                            onTransformUpdate: (x, y, w, h, {snap = false}) {
                                              notifier.updateLayerTransform(
                                                layerId: layer.id,
                                                x: x,
                                                y: y,
                                                width: w,
                                                height: h,
                                                snap: snap,
                                              );
                                            },
                                            onRotateUpdate: (rot) {
                                              notifier.updateLayerTransform(
                                                layerId: layer.id,
                                                rotation: rot,
                                              );
                                            },
                                            onTransformEnd: () {
                                              notifier.commitTransformHistory();
                                            },
                                          )
                                        : SizedBox(
                                            width: layer.width,
                                            height: layer.height,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),

                      // Artboard Floating White Badge (Top Left of Canvas)
                      Positioned(
                        top: -38,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 10),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.aspect_ratio, size: 13, color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                '${spec.presetName}  [ ${spec.width.toInt()} × ${spec.height.toInt()} px ]',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
