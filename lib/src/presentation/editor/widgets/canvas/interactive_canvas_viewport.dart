import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_notifier.dart';
import '../../../../renderer/template_renderer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/enums.dart';
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
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);
    final spec = state.template.canvasSpec;

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
          color: AppColors.backgroundDark,
          child: InteractiveViewer(
            transformationController: _transformController,
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.05,
            maxScale: 5.0,
            panEnabled: state.activeTool == EditorTool.hand,
            scaleEnabled: true,
            onInteractionUpdate: (details) {
              if (details.scale != 1.0) {
                notifier.setZoom(_transformController.value.getMaxScaleOnAxis());
              }
            },
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(100),
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: SizedBox(
                    width: spec.width,
                    height: spec.height,
                    child: Stack(
                      clipBehavior: Clip.none,
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
                                onTap: () {
                                  notifier.selectLayer(layer.id);
                                },
                                child: isSelected
                                    ? TransformHandlesOverlay(
                                        layer: layer,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
