import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/editor_notifier.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/canvas_presets.dart';
import '../../../core/services/image_export_service.dart';
import '../../../domain/models/enums.dart';
import '../../template_manager/providers/template_list_notifier.dart';
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
            icon: Icons.view_headline_rounded,
            label: 'Dark Inferno Graphic',
            onTap: () async {
              final slotTemplate = ref.read(templateRepositoryProvider).create12SlotListTemplate();
              notifier.loadTemplate(slotTemplate);
              final saved = await ref.read(templateListProvider.notifier).saveTemplate(slotTemplate);
              if (saved != null) {
                notifier.loadTemplate(saved);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(saved != null
                        ? 'Loaded & saved 24-Slot Dark Sci-Fi Ember Inferno Graphic to Laravel API!'
                        : 'Loaded Dark Inferno Graphic locally'),
                    backgroundColor: saved != null ? AppColors.accentSuccess : AppColors.accentPrimary,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            icon: Icons.leaderboard_rounded,
            label: '12-Team Leaderboard',
            onTap: () async {
              final leaderboardTemplate = ref.read(templateRepositoryProvider).create12TeamLeaderboardTemplate();
              notifier.loadTemplate(leaderboardTemplate);
              final saved = await ref.read(templateListProvider.notifier).saveTemplate(leaderboardTemplate);
              if (saved != null) {
                notifier.loadTemplate(saved);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(saved != null
                        ? 'Loaded & saved 12-Team Pro Esports Leaderboard Graphic to Laravel API!'
                        : 'Loaded 12-Team Pro Esports Leaderboard Graphic locally'),
                    backgroundColor: saved != null ? AppColors.accentSuccess : AppColors.accentPrimary,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            icon: Icons.format_list_numbered_rounded,
            label: '16-Team Standings',
            onTap: () async {
              final standingsTemplate = ref.read(templateRepositoryProvider).create16TeamStandingsTemplate();
              notifier.loadTemplate(standingsTemplate);
              final saved = await ref.read(templateListProvider.notifier).saveTemplate(standingsTemplate);
              if (saved != null) {
                notifier.loadTemplate(saved);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(saved != null
                        ? 'Loaded & saved 16-Team Overall Standings to Laravel API!'
                        : 'Loaded 16-Team Overall Standings locally'),
                    backgroundColor: saved != null ? AppColors.accentSuccess : AppColors.accentPrimary,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            icon: Icons.star_rounded,
            label: 'Yellow Standings',
            onTap: () async {
              final yellowTemplate = ref.read(templateRepositoryProvider).create15TeamYellowStandingsTemplate();
              notifier.loadTemplate(yellowTemplate);
              final saved = await ref.read(templateListProvider.notifier).saveTemplate(yellowTemplate);
              if (saved != null) {
                notifier.loadTemplate(saved);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(saved != null
                        ? 'Loaded & saved 15-Team Yellow Pro Overall Standings to Laravel API!'
                        : 'Loaded 15-Team Yellow Pro Overall Standings locally'),
                    backgroundColor: saved != null ? AppColors.accentSuccess : AppColors.accentPrimary,
                  ),
                );
              }
            },
          ),
          _buildActionButton(
            icon: Icons.save,
            label: 'Save',
            onTap: () async {
              final saved = await ref.read(templateListProvider.notifier).saveTemplate(state.template);
              if (saved != null) {
                notifier.loadTemplate(saved);
              }
              if (context.mounted) {
                final listState = ref.read(templateListProvider);
                final errorMsg = listState.errorMessage ?? 'Check connection to Laravel API';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(saved != null ? 'Template saved to Laravel API!' : 'Save failed: $errorMsg'),
                    backgroundColor: saved != null ? AppColors.accentSuccess : Colors.redAccent,
                  ),
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
          _buildToolShortcut(Icons.crop_landscape, 'Rounded Rect', () => notifier.addLayer(LayerType.shape, shapeType: ShapeType.roundedRectangle)),
          _buildToolShortcut(Icons.circle_outlined, 'Circle', () => notifier.addLayer(LayerType.shape, shapeType: ShapeType.circle)),
          _buildToolShortcut(Icons.image_outlined, 'Image', () => notifier.addLayer(LayerType.image)),
          _buildToolShortcut(Icons.view_headline, 'Slot Row', () => notifier.addLayer(LayerType.slotRow)),
          _buildToolShortcut(Icons.qr_code_2, 'QR', () => notifier.addLayer(LayerType.qr)),
          _buildToolShortcut(Icons.stars, 'Badge', () => notifier.addLayer(LayerType.rankBadge)),

          const SizedBox(width: 16),

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

          const SizedBox(width: 8),
          const VerticalDivider(color: AppColors.borderDark, indent: 8, endIndent: 8),
          const SizedBox(width: 8),

          // Category Type Selector (Slot List vs Leaderboard)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.panelBackground,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: DropdownButton<String>(
              value: ['slot_list', 'leaderboard'].contains(state.template.categoryType)
                  ? state.template.categoryType
                  : 'slot_list',
              dropdownColor: AppColors.panelHeader,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: 'slot_list',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.grid_view_rounded, size: 14, color: AppColors.accentPrimary),
                      SizedBox(width: 6),
                      Text('Slot List'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'leaderboard',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.leaderboard_rounded, size: 14, color: Colors.amber),
                      SizedBox(width: 6),
                      Text('Leaderboard'),
                    ],
                  ),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  notifier.updateCategoryType(val);
                }
              },
            ),
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
    try {
      final String jsonStr = notifier.exportJson();
      final bytes = Uint8List.fromList(utf8.encode(jsonStr));

      String? path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save TournaX Template JSON',
        fileName: 'tournax_template.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (path != null) {
        if (!path.toLowerCase().endsWith('.json') && !kIsWeb) {
          path = '$path.json';
        }
        if (!kIsWeb) {
          final file = File(path);
          await file.writeAsBytes(bytes);
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exported JSON successfully${kIsWeb ? '' : ' to $path'}'),
              backgroundColor: AppColors.accentSuccess,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export JSON: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleImportJson(BuildContext context, EditorNotifier notifier) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        String? content;
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null && !kIsWeb) {
          content = await File(file.path!).readAsString();
        }

        if (content != null && content.isNotEmpty) {
          notifier.importJson(content);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Template imported successfully!'),
                backgroundColor: AppColors.accentSuccess,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import JSON: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleExportImage(BuildContext context) async {
    try {
      final bytes = await ImageExportService.capturePng(
        repaintBoundaryKey: repaintBoundaryKey,
        pixelRatio: 3.0,
      );

      if (bytes != null) {
        final savedPath = await ImageExportService.saveImageToFile(
          bytes: bytes,
          fileName: 'tournax_esports_graphic_3x.png',
        );
        if (context.mounted && savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kIsWeb
                  ? 'High-res PNG downloaded successfully!'
                  : 'Rendered 3x PNG saved to $savedPath'),
              backgroundColor: AppColors.accentSuccess,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
