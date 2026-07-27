import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editor_notifier.dart';
import '../../../core/constants/app_colors.dart';

class EditorBottomBar extends ConsumerWidget {
  final Offset cursorPosition;

  const EditorBottomBar({
    super.key,
    required this.cursorPosition,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final selectedLayer = state.primarySelectedLayer;
    final spec = state.template.canvasSpec;

    return Container(
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.panelHeader,
        border: Border(top: BorderSide(color: AppColors.borderDark, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Canvas Dimensions
          Icon(Icons.aspect_ratio, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            '${spec.width.toInt()} x ${spec.height.toInt()} px (${spec.presetName})',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(color: AppColors.borderDark, indent: 4, endIndent: 4),
          const SizedBox(width: 16),

          // Cursor Coordinates
          Icon(Icons.mouse, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            'X: ${cursorPosition.dx.toInt()} px | Y: ${cursorPosition.dy.toInt()} px',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(color: AppColors.borderDark, indent: 4, endIndent: 4),
          const SizedBox(width: 16),

          // Selected Layer Summary
          Icon(Icons.layers_outlined, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            selectedLayer != null
                ? 'Selected: "${selectedLayer.name}" (${selectedLayer.width.toInt()}x${selectedLayer.height.toInt()})'
                : 'No selection',
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w500),
          ),

          const Spacer(),

          // History & Performance Info
          Text(
            'Layers: ${state.template.layers.length} | History Step: ${state.historyIndex + 1}/${state.historyStack.length}',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
          const SizedBox(width: 16),
          const VerticalDivider(color: AppColors.borderDark, indent: 4, endIndent: 4),
          const SizedBox(width: 16),

          // Zoom percentage
          Text(
            'Zoom: ${(state.zoomLevel * 100).toInt()}%',
            style: const TextStyle(color: AppColors.accentPrimary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
