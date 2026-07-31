import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/template_model.dart';
import '../../../renderer/template_renderer.dart';
import '../providers/template_list_notifier.dart';
import '../../editor/providers/editor_notifier.dart';
import '../../editor/screens/editor_screen.dart';

class TemplateManagerScreen extends ConsumerStatefulWidget {
  final Function(TemplateModel template)? onSelectTemplate;
  final VoidCallback? onClose;

  const TemplateManagerScreen({
    super.key,
    this.onSelectTemplate,
    this.onClose,
  });

  @override
  ConsumerState<TemplateManagerScreen> createState() => _TemplateManagerScreenState();
}

class _TemplateManagerScreenState extends ConsumerState<TemplateManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(templateListProvider.notifier).loadMore();
    }
  }

  void _openEditor(TemplateModel template) {
    if (widget.onSelectTemplate != null) {
      widget.onSelectTemplate!(template);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorScreen(initialTemplate: template),
      ),
    ).then((_) {
      // Refresh list on returning from editor
      ref.read(templateListProvider.notifier).fetchTemplates(isRefresh: true);
    });
  }

  void _createNewTemplate() {
    final blankTemplate = ref.read(templateRepositoryProvider).createSampleTemplate();
    _openEditor(blankTemplate);
  }

  void _showRenameDialog(TemplateModel template) {
    final controller = TextEditingController(text: template.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panelBackground,
        title: const Text('Rename Template', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter template name...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentPrimary)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.accentPrimary, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary),
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(templateListProvider.notifier).renameTemplate(template.id, newName);
              }
              Navigator.pop(context);
            },
            child: const Text('Rename', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(TemplateModel template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.panelBackground,
        title: const Text('Delete Template', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Text('Are you sure you want to delete "${template.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              ref.read(templateListProvider.notifier).deleteTemplate(template.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(templateListProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.panelHeader,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard_customize, color: AppColors.accentPrimary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              isMobile ? 'Template Dashboard' : 'TournaX Template Dashboard',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh Templates',
            onPressed: () => ref.read(templateListProvider.notifier).fetchTemplates(isRefresh: true),
          ),
          if (widget.onClose != null)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70),
              onPressed: widget.onClose,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.panelBackground,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search templates by name...',
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(templateListProvider.notifier).setSearchQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.panelHeader,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() {});
                ref.read(templateListProvider.notifier).setSearchQuery(val);
              },
            ),
          ),

          // Category Filter Bar (Default: Slot List)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            color: AppColors.panelBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    label: 'Slot List',
                    categoryKey: 'slot_list',
                    icon: Icons.grid_view_rounded,
                    selectedCategory: state.selectedCategory,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'Leaderboard',
                    categoryKey: 'leaderboard',
                    icon: Icons.leaderboard_rounded,
                    selectedCategory: state.selectedCategory,
                  ),
                  const SizedBox(width: 8),
                  _buildCategoryChip(
                    label: 'All Categories',
                    categoryKey: 'all',
                    icon: Icons.category_rounded,
                    selectedCategory: state.selectedCategory,
                  ),
                ],
              ),
            ),
          ),

          // Main Body
          Expanded(
            child: RefreshIndicator(
              color: AppColors.accentPrimary,
              backgroundColor: AppColors.panelHeader,
              onRefresh: () => ref.read(templateListProvider.notifier).fetchTemplates(isRefresh: true),
              child: _buildContent(state, isMobile),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentPrimary,
        onPressed: _createNewTemplate,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isMobile ? 'New' : 'New Template',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildContent(TemplateListState state, bool isMobile) {
    if (state.isLoading && state.templates.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentPrimary),
      );
    }

    if (state.errorMessage != null && state.templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Failed to load templates',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary),
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Retry', style: TextStyle(color: Colors.white)),
              onPressed: () => ref.read(templateListProvider.notifier).fetchTemplates(isRefresh: true),
            ),
          ],
        ),
      );
    }

    if (state.templates.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              children: [
                const Icon(Icons.space_dashboard_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 14),
                const Text(
                  'No templates found',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap the "+" button to create your first design template.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 2 : 4,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: state.templates.length + (state.isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.templates.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.accentPrimary, strokeWidth: 2),
            ),
          );
        }

        final template = state.templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(TemplateModel template) {
    final updatedDate = DateTime.tryParse(template.updatedAt) ?? DateTime.now();
    final dateStr = '${updatedDate.day}/${updatedDate.month}/${updatedDate.year}';

    return Card(
      color: AppColors.panelBackground,
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: InkWell(
        onTap: () => _openEditor(template),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Section
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFF09090B),
                      child: template.thumbnail != null && template.thumbnail!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: template.thumbnail!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) => FittedBox(
                                fit: BoxFit.contain,
                                child: TemplateRenderer(template: template),
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.contain,
                              child: TemplateRenderer(template: template),
                            ),
                    ),
                  ),

                  // Three-Dot Action Menu Overlay
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white, size: 18),
                        color: AppColors.panelHeader,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _openEditor(template);
                              break;
                            case 'duplicate':
                              ref.read(templateListProvider.notifier).duplicateTemplate(template.id);
                              break;
                            case 'rename':
                              _showRenameDialog(template);
                              break;
                            case 'delete':
                              _showDeleteDialog(template);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Duplicate', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'rename',
                            child: Row(
                              children: [
                                Icon(Icons.drive_file_rename_outline, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Rename', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: template.categoryType == 'leaderboard'
                              ? Colors.amber.withOpacity(0.2)
                              : AppColors.accentPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: template.categoryType == 'leaderboard'
                                ? Colors.amber.withOpacity(0.5)
                                : AppColors.accentPrimary.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          template.categoryType == 'leaderboard' ? 'Leaderboard' : 'Slot List',
                          style: TextStyle(
                            color: template.categoryType == 'leaderboard' ? Colors.amber : AppColors.accentPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${template.canvasSpec.width.toInt()}x${template.canvasSpec.height.toInt()} px',
                        style: const TextStyle(color: AppColors.accentPrimary, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${template.layers.length} Layers',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Updated: $dateStr',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String categoryKey,
    required IconData icon,
    required String selectedCategory,
  }) {
    final bool isSelected = selectedCategory == categoryKey;
    return ChoiceChip(
      showCheckmark: false,
      avatar: Icon(
        icon,
        size: 14,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppColors.accentPrimary,
      backgroundColor: AppColors.panelHeader,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? AppColors.accentPrimary : AppColors.borderDark,
        ),
      ),
      onSelected: (val) {
        if (val) {
          ref.read(templateListProvider.notifier).setSelectedCategory(categoryKey);
        }
      },
    );
  }
}
