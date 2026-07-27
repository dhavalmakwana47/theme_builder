import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/editor_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/enums.dart';

class EditorLeftSidebar extends ConsumerWidget {
  const EditorLeftSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);

    return Container(
      width: 48,
      decoration: const BoxDecoration(
        color: AppColors.panelBackground,
        border: Border(right: BorderSide(color: AppColors.borderDark, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),

          _buildToolItem(
            tool: EditorTool.select,
            icon: Icons.near_me,
            tooltip: 'Select Tool (V)',
            activeTool: state.activeTool,
            onTap: () => notifier.selectTool(EditorTool.select),
          ),
          _buildToolItem(
            tool: EditorTool.hand,
            icon: Icons.pan_tool,
            tooltip: 'Hand / Pan Tool (H / Space)',
            activeTool: state.activeTool,
            onTap: () => notifier.selectTool(EditorTool.hand),
          ),

          const Divider(color: AppColors.borderDark, height: 16, indent: 8, endIndent: 8),

          _buildToolItem(
            tool: EditorTool.text,
            icon: Icons.text_fields,
            tooltip: 'Text Tool (T)',
            activeTool: state.activeTool,
            onTap: () {
              notifier.selectTool(EditorTool.text);
              notifier.addLayer(LayerType.text);
            },
          ),
          _buildToolItem(
            tool: EditorTool.rectangle,
            icon: Icons.rectangle_outlined,
            tooltip: 'Rectangle Tool (R)',
            activeTool: state.activeTool,
            onTap: () {
              notifier.selectTool(EditorTool.rectangle);
              notifier.addLayer(LayerType.shape, shapeType: ShapeType.rectangle);
            },
          ),
          _buildToolItem(
            tool: EditorTool.circle,
            icon: Icons.circle_outlined,
            tooltip: 'Circle Tool (C)',
            activeTool: state.activeTool,
            onTap: () {
              notifier.selectTool(EditorTool.circle);
              notifier.addLayer(LayerType.shape, shapeType: ShapeType.circle);
            },
          ),
          _buildToolItem(
            tool: EditorTool.qr,
            icon: Icons.qr_code_2,
            tooltip: 'QR Code Tool (Q)',
            activeTool: state.activeTool,
            onTap: () {
              notifier.selectTool(EditorTool.qr);
              notifier.addLayer(LayerType.qr);
            },
          ),
          _buildToolItem(
            tool: EditorTool.barcode,
            icon: Icons.barcode_reader,
            tooltip: 'Barcode Tool (B)',
            activeTool: state.activeTool,
            onTap: () {
              notifier.selectTool(EditorTool.barcode);
              notifier.addLayer(LayerType.barcode);
            },
          ),

          const Divider(color: AppColors.borderDark, height: 16, indent: 8, endIndent: 8),

          // Presets Popup Menu
          PopupMenuButton<LayerType>(
            tooltip: 'Add Tournament Badge / Component',
            dropdownColor: AppColors.panelHeader,
            icon: const Icon(Icons.workspace_premium, size: 20, color: AppColors.textSecondary),
            onSelected: (type) => notifier.addLayer(type),
            itemBuilder: (context) => [
              _buildMenuItem(LayerType.playerAvatar, 'Player Avatar'),
              _buildMenuItem(LayerType.teamLogo, 'Team Logo Shield'),
              _buildMenuItem(LayerType.rankBadge, 'Rank Badge (#1)'),
              _buildMenuItem(LayerType.prizeBadge, 'Prize Badge (\$5k)'),
              _buildMenuItem(LayerType.slotRow, 'Slot Row'),
              _buildMenuItem(LayerType.playerCard, 'Player Card'),
              _buildMenuItem(LayerType.winnerBanner, 'Winner Banner'),
              _buildMenuItem(LayerType.tournamentHeader, 'Tournament Header'),
            ],
          ),

          const Spacer(),

          _buildToolItem(
            tool: EditorTool.zoom,
            icon: Icons.zoom_in,
            tooltip: 'Zoom Tool (Z)',
            activeTool: state.activeTool,
            onTap: notifier.zoomIn,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  PopupMenuItem<LayerType> _buildMenuItem(LayerType type, String label) {
    return PopupMenuItem(
      value: type,
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }

  Widget _buildToolItem({
    required EditorTool tool,
    required IconData icon,
    required String tooltip,
    required EditorTool activeTool,
    required VoidCallback onTap,
  }) {
    final bool isSelected = activeTool == tool;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppColors.accentPrimary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
