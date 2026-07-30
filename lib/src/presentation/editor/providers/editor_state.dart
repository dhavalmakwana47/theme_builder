import 'package:flutter/material.dart';
import '../../../domain/models/template_model.dart';
import '../../../domain/models/layer_model.dart';
import '../../../domain/models/enums.dart';
import '../../../core/utils/snap_engine.dart';

class EditorState {
  final TemplateModel template;
  final List<String> selectedLayerIds;
  final EditorTool activeTool;
  final double zoomLevel; // 0.1 to 5.0
  final Offset panOffset;
  final List<TemplateModel> historyStack;
  final int historyIndex;
  final bool isPreviewMode;
  final Map<String, String> overrideVariables;
  final List<SnapGuideLine> activeGuides;
  final List<LayerModel> clipboardLayers;

  const EditorState({
    required this.template,
    this.selectedLayerIds = const [],
    this.activeTool = EditorTool.select,
    this.zoomLevel = 0.5, // 50% default fit
    this.panOffset = const Offset(100, 40),
    this.historyStack = const [],
    this.historyIndex = 0,
    this.isPreviewMode = false,
    this.overrideVariables = const {},
    this.activeGuides = const [],
    this.clipboardLayers = const [],
  });

  bool get canUndo => historyIndex > 0;
  bool get canRedo => historyIndex < historyStack.length - 1;

  LayerModel? get primarySelectedLayer {
    if (selectedLayerIds.isEmpty || template.layers.isEmpty) return null;
    try {
      return template.layers.firstWhere(
        (l) => l.id == selectedLayerIds.last,
        orElse: () => template.layers.first,
      );
    } catch (_) {
      return null;
    }
  }

  EditorState copyWith({
    TemplateModel? template,
    List<String>? selectedLayerIds,
    EditorTool? activeTool,
    double? zoomLevel,
    Offset? panOffset,
    List<TemplateModel>? historyStack,
    int? historyIndex,
    bool? isPreviewMode,
    Map<String, String>? overrideVariables,
    List<SnapGuideLine>? activeGuides,
    List<LayerModel>? clipboardLayers,
  }) {
    return EditorState(
      template: template ?? this.template,
      selectedLayerIds: selectedLayerIds ?? this.selectedLayerIds,
      activeTool: activeTool ?? this.activeTool,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      panOffset: panOffset ?? this.panOffset,
      historyStack: historyStack ?? this.historyStack,
      historyIndex: historyIndex ?? this.historyIndex,
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      overrideVariables: overrideVariables ?? this.overrideVariables,
      activeGuides: activeGuides ?? this.activeGuides,
      clipboardLayers: clipboardLayers ?? this.clipboardLayers,
    );
  }
}
