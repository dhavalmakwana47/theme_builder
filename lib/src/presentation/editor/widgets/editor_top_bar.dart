import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import '../providers/editor_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/canvas_presets.dart';
import '../../../core/services/image_export_service.dart';
import '../../../domain/models/enums.dart';
import 'dialogs/variable_preview_dialog.dart';

class EditorTopBar extends ConsumerWidget {
  final GlobalKey repaintBoundaryKey;
  final VoidCallback onOpenTemplateManager;

  const EditorTopBar({
    super.key,
    required this.repaintBoundaryKey,
    required this.onOpenTemplateManager,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);

    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.panelHeader,
        border: Border(bottom: BorderSide(color: AppColors.borderDark, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Logo & App Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.auto_awesome_mosaic, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Text(
                'TournaX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentSecondary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentSecondary.withOpacity(0.5)),
                ),
                child: const Text(
                  'BUILDER',
                  style: TextStyle(color: AppColors.accentSecondary, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),
          const VerticalDivider(color: AppColors.borderDark, indent: 8, endIndent: 8),
          const SizedBox(width: 8),

          // File / Action Menus
          _buildActionButton(
            icon: Icons.folder_open,
            label: 'Templates',
            onTap: onOpenTemplateManager,
          ),
          _buildActionButton(
            icon: Icons.save,
            label: 'Save',
            onTap: () async {
              await ref.read(templateRepositoryProvider).saveTemplate(state.template);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template saved locally & synced!'), backgroundColor: AppColors.accentSuccess),
                );
              }
            },
          ),
          _buildActionButton(
            icon: Icons.file_download_outlined,
            label: 'Export JSON',
            onTap: () => _handleExportJson(context, notifier),
          ),
          _buildActionButton(
            icon: Icons.file_upload_outlined,
            label: 'Import JSON',
            onTap: () => _handleImportJson(context, notifier),
          ),
          _buildActionButton(
            icon: Icons.image_outlined,
            label: 'Export Image',
            onTap: () => _handleExportImage(context),
          ),

          const SizedBox(width: 8),
          const VerticalDivider(color: AppColors.borderDark, indent: 8, endIndent: 8),
          const SizedBox(width: 8),

          // Undo / Redo
          IconButton(
            icon: const Icon(Icons.undo, size: 18),
            color: state.canUndo ? Colors.white : AppColors.textMuted,
            onPressed: state.canUndo ? notifier.undo : null,
            tooltip: 'Undo (Ctrl+Z)',
          ),
          IconButton(
            icon: const Icon(Icons.redo, size: 18),
            color: state.canRedo ? Colors.white : AppColors.textMuted,
            onPressed: state.canRedo ? notifier.redo : null,
            tooltip: 'Redo (Ctrl+Y)',
          ),

          const SizedBox(width: 8),
          const VerticalDivider(color: AppColors.borderDark, indent: 8, endIndent: 8),
          const SizedBox(width: 8),

          // Quick Add Tool Buttons
          _buildToolShortcut(Icons.text_fields, 'Text', () => notifier.addLayer(LayerType.text)),
          _buildToolShortcut(Icons.crop_square, 'Rect', () => notifier.addLayer(LayerType.shape, shapeType: ShapeType.rectangle)),
          _buildToolShortcut(Icons.circle_outlined, 'Circle', () => notifier.addLayer(LayerType.shape, shapeType: ShapeType.circle)),
          _buildToolShortcut(Icons.qr_code_2, 'QR', () => notifier.addLayer(LayerType.qr)),
          _buildToolShortcut(Icons.stars, 'Badge', () => notifier.addLayer(LayerType.rankBadge)),

          const Spacer(),

          // Canvas Preset Selector
          DropdownButton<String>(
            value: CanvasPresets.presets.any((p) => p.name == state.template.canvasSpec.presetName)
                ? state.template.canvasSpec.presetName
                : CanvasPresets.presets.first.name,
            dropdownColor: AppColors.panelHeader,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: const SizedBox.shrink(),
            items: CanvasPresets.presets.map((preset) {
              return DropdownMenuItem<String>(
                value: preset.name,
                child: Text('${preset.name} (${preset.width.toInt()}x${preset.height.toInt()})'),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              final found = CanvasPresets.presets.firstWhere((p) => p.name == val);
              notifier.updateCanvasSpec(found.toSpec());
            },
          ),

          const SizedBox(width: 12),

          // Dynamic Variables Live Preview Toggle & Dialog
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const VariablePreviewDialog(),
              );
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: state.isPreviewMode ? AppColors.accentSecondary : AppColors.panelBackground,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: state.isPreviewMode ? AppColors.accentSecondary : AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isPreviewMode ? Icons.visibility : Icons.data_object,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isPreviewMode ? 'PREVIEW ON' : 'VARIABLES',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Zoom Controls
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            color: Colors.white,
            onPressed: notifier.zoomOut,
            tooltip: 'Zoom Out',
          ),
          Text(
            '${(state.zoomLevel * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            color: Colors.white,
            onPressed: notifier.zoomIn,
            tooltip: 'Zoom In',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildToolShortcut(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Icon(icon, size: 16),
        color: AppColors.textSecondary,
        tooltip: 'Add $label',
        onPressed: onTap,
      ),
    );
  }

  void _handleExportJson(BuildContext context, EditorNotifier notifier) async {
    final String jsonStr = notifier.exportJson();
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save TournaX Template JSON',
      fileName: 'tournax_template.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsString(jsonStr);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported JSON to $path'), backgroundColor: AppColors.accentSuccess),
        );
      }
    }
  }

  void _handleImportJson(BuildContext context, EditorNotifier notifier) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      notifier.importJson(content);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template imported successfully!'), backgroundColor: AppColors.accentSuccess),
        );
      }
    }
  }

  void _handleExportImage(BuildContext context) async {
    final bytes = await ImageExportService.capturePng(
      repaintBoundaryKey: repaintBoundaryKey,
      pixelRatio: 3.0,
    );

    if (bytes != null) {
      final savedPath = await ImageExportService.saveImageToFile(
        bytes: bytes,
        fileName: 'tournax_render_3x.png',
      );
      if (context.mounted && savedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rendered PNG saved to $savedPath'), backgroundColor: AppColors.accentSuccess),
        );
      }
    }
  }
}
