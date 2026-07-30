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
import '../../../domain/models/template_model.dart';
import '../../../core/constants/app_colors.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final TemplateModel? initialTemplate;

  const EditorScreen({
    super.key,
    this.initialTemplate,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final FocusNode _keyboardFocusNode = FocusNode();
  Offset _cursorPosition = Offset.zero;
  bool _showTemplateManager = false;
  bool _showRightPanelMobile = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editorNotifierProvider.notifier).loadTemplate(widget.initialTemplate!);
      });
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    // Ignore global keyboard shortcuts when editing text fields
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null && primaryFocus.context != null) {
      if (primaryFocus.context!.widget is EditableText) {
        return;
      }
    }

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
    // Delete Key -> Delete Selected Layer
    else if (event.logicalKey == LogicalKeyboardKey.delete) {
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return RawKeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        endDrawer: isMobile
            ? Drawer(
                backgroundColor: AppColors.panelBackground,
                child: SafeArea(
                  child: Column(
                    children: const [
                      Expanded(flex: 6, child: PropertyInspector()),
                      Divider(color: AppColors.borderDark, height: 1),
                      Expanded(flex: 4, child: LayersPanel()),
                    ],
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
          children: [
            // Top Menu Bar
            EditorTopBar(
              repaintBoundaryKey: _repaintBoundaryKey,
              onOpenTemplateManager: () => setState(() => _showTemplateManager = true),
            ),

            // Main Editor Workspace (Responsive 3-Panel Layout)
            Expanded(
              child: Stack(
                children: [
                  Row(
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

                      // Desktop Right Sidebar (Hidden on Mobile unless toggled)
                      if (!isMobile)
                        Container(
                          width: 300,
                          decoration: const BoxDecoration(
                            color: AppColors.panelBackground,
                            border: Border(left: BorderSide(color: AppColors.borderDark, width: 1)),
                          ),
                          child: Column(
                            children: const [
                              Expanded(flex: 6, child: PropertyInspector()),
                              Divider(color: AppColors.borderDark, height: 1),
                              Expanded(flex: 4, child: LayersPanel()),
                            ],
                          ),
                        ),

                      if (isMobile && _showRightPanelMobile)
                        Container(
                          width: screenWidth * 0.75,
                          decoration: const BoxDecoration(
                            color: AppColors.panelBackground,
                            border: Border(left: BorderSide(color: AppColors.borderDark, width: 1)),
                          ),
                          child: Column(
                            children: const [
                              Expanded(flex: 6, child: PropertyInspector()),
                              Divider(color: AppColors.borderDark, height: 1),
                              Expanded(flex: 4, child: LayersPanel()),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Floating Inspector Toggle Button for Mobile
                  if (isMobile)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        backgroundColor: AppColors.accentPrimary,
                        child: Icon(
                          _showRightPanelMobile ? Icons.close : Icons.tune,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _showRightPanelMobile = !_showRightPanelMobile;
                          });
                        },
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
    ),
  );
  }
}
