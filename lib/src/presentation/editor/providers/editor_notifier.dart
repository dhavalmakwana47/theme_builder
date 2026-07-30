import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'editor_state.dart';
import '../../../domain/models/template_model.dart';
import '../../../domain/models/layer_model.dart';
import '../../../domain/models/layer_style.dart';
import '../../../domain/models/canvas_spec.dart';
import '../../../domain/models/enums.dart';
import '../../../data/repositories/template_repository.dart';
import '../../../core/utils/snap_engine.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepositoryImpl();
});

final editorNotifierProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  final repo = ref.watch(templateRepositoryProvider);
  return EditorNotifier(repo: repo);
});

class EditorNotifier extends StateNotifier<EditorState> {
  final TemplateRepository repo;
  static const _uuid = Uuid();

  EditorNotifier({required this.repo})
      : super(EditorState(template: repo.createSampleTemplate())) {
    _initHistory();
  }

  void _initHistory() {
    state = state.copyWith(
      historyStack: [state.template],
      historyIndex: 0,
    );
  }

  void _pushHistory(TemplateModel newTemplate) {
    final updatedStack = state.historyStack.sublist(0, state.historyIndex + 1)
      ..add(newTemplate);
    state = state.copyWith(
      template: newTemplate,
      historyStack: updatedStack,
      historyIndex: updatedStack.length - 1,
    );
  }

  // --- UNDO / REDO ---

  void undo() {
    if (state.canUndo) {
      final newIndex = state.historyIndex - 1;
      state = state.copyWith(
        template: state.historyStack[newIndex],
        historyIndex: newIndex,
      );
    }
  }

  void redo() {
    if (state.canRedo) {
      final newIndex = state.historyIndex + 1;
      state = state.copyWith(
        template: state.historyStack[newIndex],
        historyIndex: newIndex,
      );
    }
  }

  // --- SELECTION & TOOLS ---

  void selectTool(EditorTool tool) {
    state = state.copyWith(activeTool: tool);
  }

  void selectLayer(String layerId, {bool multiSelect = false}) {
    if (multiSelect) {
      final current = List<String>.from(state.selectedLayerIds);
      if (current.contains(layerId)) {
        current.remove(layerId);
      } else {
        current.add(layerId);
      }
      state = state.copyWith(selectedLayerIds: current);
    } else {
      state = state.copyWith(selectedLayerIds: [layerId]);
    }
  }

  void clearSelection() {
    state = state.copyWith(selectedLayerIds: []);
  }

  // --- LAYER MANAGEMENT ---

  void addLayer(LayerType type, {ShapeType shapeType = ShapeType.rectangle}) {
    final String layerId = _uuid.v4();
    final double centerX = state.template.canvasSpec.width / 2 - 100;
    final double centerY = state.template.canvasSpec.height / 2 - 50;

    String defaultName = type.displayName;
    if (type == LayerType.shape) {
      defaultName = '${shapeType.displayName} Shape';
    }

    LayerModel newLayer = LayerModel(
      id: layerId,
      name: '$defaultName ${state.template.layers.length + 1}',
      type: type,
      shapeType: shapeType,
      x: centerX,
      y: centerY,
      width: type == LayerType.text ? 300 : (type == LayerType.qr ? 200 : 200),
      height: type == LayerType.text ? 60 : (type == LayerType.qr ? 200 : 120),
      zIndex: state.template.layers.length,
      style: type == LayerType.text
          ? const LayerStyle(fontSize: 28, textColorHex: 0xFFFFFFFF)
          : const LayerStyle(fillColorHex: 0xFF3B82F6),
    );

    final updatedLayers = [...state.template.layers, newLayer];
    final updatedTemplate = state.template.copyWith(layers: updatedLayers);

    _pushHistory(updatedTemplate);
    state = state.copyWith(selectedLayerIds: [layerId]);
  }

  void updateLayer(LayerModel updatedLayer) {
    final layers = state.template.layers.map((l) {
      return l.id == updatedLayer.id ? updatedLayer : l;
    }).toList();

    _pushHistory(state.template.copyWith(layers: layers));
  }

  void updateLayerTransform({
    required String layerId,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    bool snap = false,
  }) {
    final index = state.template.layers.indexWhere((l) => l.id == layerId);
    if (index == -1) return;
    final currentLayer = state.template.layers[index];

    double finalX = x ?? currentLayer.x;
    double finalY = y ?? currentLayer.y;
    double finalW = width ?? currentLayer.width;
    double finalH = height ?? currentLayer.height;
    List<SnapGuideLine> activeGuides = [];

    if (snap && (x != null || y != null)) {
      final snapResult = SnapEngine.calculateSnap(
        targetOffset: Offset(finalX, finalY),
        targetSize: Size(finalW, finalH),
        canvasSpec: state.template.canvasSpec,
        otherLayers: state.template.layers,
        activeLayerId: layerId,
      );

      finalX = snapResult.snappedOffset.dx;
      finalY = snapResult.snappedOffset.dy;
      activeGuides = snapResult.activeGuides;
    }

    final updated = currentLayer.copyWith(
      x: finalX,
      y: finalY,
      width: finalW.clamp(10.0, 5000.0),
      height: finalH.clamp(10.0, 5000.0),
      rotation: rotation ?? currentLayer.rotation,
    );

    final layers = state.template.layers.map((l) => l.id == layerId ? updated : l).toList();
    state = state.copyWith(
      template: state.template.copyWith(layers: layers),
      activeGuides: activeGuides,
    );
  }

  void commitTransformHistory() {
    _pushHistory(state.template);
    state = state.copyWith(activeGuides: []);
  }

  void updateLayerStyle(String layerId, LayerStyle style) {
    final layers = state.template.layers.map((l) {
      return l.id == layerId ? l.copyWith(style: style) : l;
    }).toList();

    _pushHistory(state.template.copyWith(layers: layers));
  }

  void deleteSelectedLayers() {
    if (state.selectedLayerIds.isEmpty) return;

    final layers = state.template.layers.where((l) {
      return !state.selectedLayerIds.contains(l.id);
    }).toList();

    _pushHistory(state.template.copyWith(layers: layers));
    state = state.copyWith(selectedLayerIds: []);
  }

  void duplicateSelectedLayers() {
    if (state.selectedLayerIds.isEmpty) return;

    final newLayers = <LayerModel>[];
    final newSelection = <String>[];

    for (final id in state.selectedLayerIds) {
      final index = state.template.layers.indexWhere((l) => l.id == id);
      if (index == -1) continue;
      final orig = state.template.layers[index];
      final String copyId = _uuid.v4();
      final copy = orig.copyWith(
        id: copyId,
        name: '${orig.name} (Copy)',
        x: orig.x + 30,
        y: orig.y + 30,
        zIndex: state.template.layers.length + newLayers.length,
      );
      newLayers.add(copy);
      newSelection.add(copyId);
    }

    final updatedLayers = [...state.template.layers, ...newLayers];
    _pushHistory(state.template.copyWith(layers: updatedLayers));
    state = state.copyWith(selectedLayerIds: newSelection);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    final layers = List<LayerModel>.from(state.template.layers);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);

    // Reassign Z-indices
    for (int i = 0; i < layers.length; i++) {
      layers[i] = layers[i].copyWith(zIndex: i);
    }

    _pushHistory(state.template.copyWith(layers: layers));
  }

  void toggleLayerLock(String layerId) {
    final layers = state.template.layers.map((l) {
      return l.id == layerId ? l.copyWith(isLocked: !l.isLocked) : l;
    }).toList();
    _pushHistory(state.template.copyWith(layers: layers));
  }

  void toggleLayerVisibility(String layerId) {
    final layers = state.template.layers.map((l) {
      return l.id == layerId ? l.copyWith(isVisible: !l.isVisible) : l;
    }).toList();
    _pushHistory(state.template.copyWith(layers: layers));
  }

  void renameLayer(String layerId, String newName) {
    final layers = state.template.layers.map((l) {
      return l.id == layerId ? l.copyWith(name: newName) : l;
    }).toList();
    _pushHistory(state.template.copyWith(layers: layers));
  }

  // --- ALIGNMENT CONTROLS ---

  void alignSelectedLayers(String mode) {
    if (state.selectedLayerIds.isEmpty) return;

    final double specW = state.template.canvasSpec.width;
    final double specH = state.template.canvasSpec.height;

    final layers = state.template.layers.map((l) {
      if (!state.selectedLayerIds.contains(l.id)) return l;

      double newX = l.x;
      double newY = l.y;

      switch (mode) {
        case 'left':
          newX = 0;
          break;
        case 'center_x':
          newX = (specW - l.width) / 2;
          break;
        case 'right':
          newX = specW - l.width;
          break;
        case 'top':
          newY = 0;
          break;
        case 'middle_y':
          newY = (specH - l.height) / 2;
          break;
        case 'bottom':
          newY = specH - l.height;
          break;
      }

      return l.copyWith(x: newX, y: newY);
    }).toList();

    _pushHistory(state.template.copyWith(layers: layers));
  }

  // --- CANVAS & VIEWPORT ---

  void updateCanvasSpec(CanvasSpec spec) {
    final updatedLayers = state.template.layers.map((layer) {
      if (layer.name.toLowerCase().contains('background') && layer.type == LayerType.shape) {
        return layer.copyWith(width: spec.width, height: spec.height);
      }
      return layer;
    }).toList();

    _pushHistory(state.template.copyWith(canvasSpec: spec, layers: updatedLayers));
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoomLevel: zoom.clamp(0.1, 5.0));
  }

  void zoomIn() => setZoom(state.zoomLevel + 0.1);
  void zoomOut() => setZoom(state.zoomLevel - 0.1);
  void resetZoom() => setZoom(0.5);

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  // --- DYNAMIC VARIABLES & PREVIEW ---

  void togglePreviewMode() {
    state = state.copyWith(isPreviewMode: !state.isPreviewMode);
  }

  void updateOverrideVariable(String key, String value) {
    final current = Map<String, String>.from(state.overrideVariables);
    current[key] = value;
    state = state.copyWith(overrideVariables: current);
  }

  // --- IMPORT & EXPORT JSON ---

  String exportJson() {
    return repo.exportToJson(state.template);
  }

  void importJson(String jsonStr) {
    final imported = repo.importFromJson(jsonStr);
    _pushHistory(imported);
    state = state.copyWith(selectedLayerIds: []);
  }

  void loadTemplate(TemplateModel template) {
    _pushHistory(template);
    state = state.copyWith(selectedLayerIds: []);
  }
}
