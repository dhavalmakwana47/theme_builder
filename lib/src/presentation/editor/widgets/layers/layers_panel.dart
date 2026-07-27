import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_notifier.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/layer_model.dart';
import '../../../../domain/models/enums.dart';

class LayersPanel extends ConsumerWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);

    // Render layers reversed so top layers appear at the top of the stack panel
    final reversedLayers = List<LayerModel>.from(state.template.layers.reversed);

    return Container(
      color: AppColors.panelBackground,
      child: Column(
        children: [
          // Panel Title & Quick Actions
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: AppColors.panelHeader,
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              children: [
                const Icon(Icons.layers, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                const Text(
                  'LAYERS',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, size: 14),
                  color: AppColors.textSecondary,
                  tooltip: 'Duplicate Selected Layer (Ctrl+D)',
                  onPressed: notifier.duplicateSelectedLayers,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 14),
                  color: AppColors.accentDanger,
                  tooltip: 'Delete Selected Layer (Delete)',
                  onPressed: notifier.deleteSelectedLayers,
                ),
              ],
            ),
          ),

          // Reorderable Layers List
          Expanded(
            child: reversedLayers.isEmpty
                ? const Center(
                    child: Text('No layers in template', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: reversedLayers.length,
                    onReorder: (oldIndex, newIndex) {
                      // Adjust indices for reversed list
                      final int actualOldIndex = state.template.layers.length - 1 - oldIndex;
                      int actualNewIndex = state.template.layers.length - newIndex;
                      notifier.reorderLayers(actualOldIndex, actualNewIndex);
                    },
                    itemBuilder: (context, index) {
                      final layer = reversedLayers[index];
                      final bool isSelected = state.selectedLayerIds.contains(layer.id);

                      return _buildLayerRow(
                        key: ValueKey(layer.id),
                        layer: layer,
                        isSelected: isSelected,
                        onTap: () => notifier.selectLayer(layer.id),
                        onToggleVisibility: () => notifier.toggleLayerVisibility(layer.id),
                        onToggleLock: () => notifier.toggleLayerLock(layer.id),
                        onRename: (name) => notifier.renameLayer(layer.id, name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerRow({
    required Key key,
    required LayerModel layer,
    required bool isSelected,
    required VoidCallback onTap,
    required VoidCallback onToggleVisibility,
    required VoidCallback onToggleLock,
    required Function(String) onRename,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Container(
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? AppColors.accentPrimary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Visibility Eye Toggle
            InkWell(
              onTap: onToggleVisibility,
              child: Icon(
                layer.isVisible ? Icons.visibility : Icons.visibility_off,
                size: 15,
                color: layer.isVisible ? Colors.white70 : AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 8),

            // Layer Type Icon
            Icon(_getLayerIcon(layer.type), size: 15, color: AppColors.accentSecondary),
            const SizedBox(width: 8),

            // Layer Name
            Expanded(
              child: Text(
                layer.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Lock Toggle Padlock
            InkWell(
              onTap: onToggleLock,
              child: Icon(
                layer.isLocked ? Icons.lock : Icons.lock_open,
                size: 14,
                color: layer.isLocked ? Colors.amber : AppColors.textMuted.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 6),

            // Reorder Drag Handle
            const Icon(Icons.drag_handle, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.text:
        return Icons.text_fields;
      case LayerType.image:
        return Icons.image;
      case LayerType.svg:
        return Icons.code;
      case LayerType.shape:
        return Icons.shape_line;
      case LayerType.qr:
        return Icons.qr_code;
      case LayerType.barcode:
        return Icons.barcode_reader;
      default:
        return Icons.layers;
    }
  }
}
