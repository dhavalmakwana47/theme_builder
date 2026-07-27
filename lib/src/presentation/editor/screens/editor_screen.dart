import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editor_notifier.dart';
import '../widgets/editor_top_bar.dart';
import '../widgets/editor_left_sidebar.dart';
import '../widgets/editor_bottom_bar.dart';
import '../widgets/canvas/interactive_canvas_viewport.dart';
import '../widgets/inspector/property_inspector.dart';
import '../widgets/layers/layers_panel.dart';
import '../../template_manager/screens/template_manager_screen.dart';
import '../../../core/constants/app_colors.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final FocusNode _keyboardFocusNode = FocusNode();
  Offset _cursorPosition = Offset.zero;
  bool _showTemplateManager = false;

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final notifier = ref.read(editorNotifierProvider.notifier);
    final isControlPressed = event.isControlPressed || event.isMetaPressed;
    final state = ref.read(editorNotifierProvider);

    // Ctrl + Z -> Undo
    if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyZ && !event.isShiftPressed) {
      notifier.undo();
    }
    // Ctrl + Shift + Z or Ctrl + Y -> Redo
    else if ((isControlPressed && event.isShiftPressed && event.logicalKey == LogicalKeyboardKey.keyZ) ||
        (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyY)) {
      notifier.redo();
    }
    // Ctrl + D -> Duplicate
    else if (isControlPressed && event.logicalKey == LogicalKeyboardKey.keyD) {
      notifier.duplicateSelectedLayers();
    }
    // Delete or Backspace -> Delete Selected Layer
    else if (event.logicalKey == LogicalKeyboardKey.delete || event.logicalKey == LogicalKeyboardKey.backspace) {
      notifier.deleteSelectedLayers();
    }
    // Arrow Key Nudges
    else if (state.primarySelectedLayer != null) {
      final layer = state.primarySelectedLayer!;
      final double step = event.isShiftPressed ? 10.0 : 1.0;

      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        notifier.updateLayerTransform(layerId: layer.id, x: layer.x - step);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        notifier.updateLayerTransform(layerId: layer.id, x: layer.x + step);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        notifier.updateLayerTransform(layerId: layer.id, y: layer.y - step);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        notifier.updateLayerTransform(layerId: layer.id, y: layer.y + step);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showTemplateManager) {
      return TemplateManagerScreen(
        onSelectTemplate: (template) {
          ref.read(editorNotifierProvider.notifier).loadTemplate(template);
          setState(() => _showTemplateManager = false);
        },
        onClose: () => setState(() => _showTemplateManager = false),
      );
    }

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Column(
          children: [
            // Top Menu Bar
            EditorTopBar(
              repaintBoundaryKey: _repaintBoundaryKey,
              onOpenTemplateManager: () => setState(() => _showTemplateManager = true),
            ),

            // Main Editor Workspace (3-Panel Photoshop Layout)
            Expanded(
              child: Row(
                children: [
                  // Left Tool Palette Sidebar
                  const EditorLeftSidebar(),

                  // Center Interactive Viewport
                  Expanded(
                    child: InteractiveCanvasViewport(
                      repaintBoundaryKey: _repaintBoundaryKey,
                      onCursorHover: (pos) => setState(() => _cursorPosition = pos),
                    ),
                  ),

                  // Right Sidebar Panel Split (Properties & Layers)
                  Container(
                    width: 320,
                    decoration: const BoxDecoration(
                      color: AppColors.panelBackground,
                      border: Border(left: BorderSide(color: AppColors.borderDark, width: 1)),
                    ),
                    child: Column(
                      children: const [
                        // Property Inspector (Top 60%)
                        Expanded(
                          flex: 6,
                          child: PropertyInspector(),
                        ),
                        Divider(color: AppColors.borderDark, height: 1),
                        // Layers Stack Panel (Bottom 40%)
                        Expanded(
                          flex: 4,
                          child: LayersPanel(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Status Bar
            EditorBottomBar(cursorPosition: _cursorPosition),
          ],
        ),
      ),
    );
  }
}
