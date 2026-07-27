import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/template_model.dart';
import '../../../renderer/template_renderer.dart';
import '../../editor/providers/editor_notifier.dart';

class TemplateManagerScreen extends ConsumerStatefulWidget {
  final Function(TemplateModel template) onSelectTemplate;
  final VoidCallback onClose;

  const TemplateManagerScreen({
    super.key,
    required this.onSelectTemplate,
    required this.onClose,
  });

  @override
  ConsumerState<TemplateManagerScreen> createState() => _TemplateManagerScreenState();
}

class _TemplateManagerScreenState extends ConsumerState<TemplateManagerScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<TemplateModel> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final repo = ref.read(templateRepositoryProvider);
    final list = await repo.getTemplates();
    setState(() {
      _templates = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _templates.where((t) {
      final matchesSearch = t.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || t.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.panelHeader,
        title: Row(
          children: [
            const Icon(Icons.dashboard_customize, color: AppColors.accentPrimary),
            const SizedBox(width: 8),
            const Text('TournaX Template Hub', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Create Blank Template', style: TextStyle(color: Colors.white)),
            onPressed: () {
              final newTemplate = ref.read(templateRepositoryProvider).createSampleTemplate();
              widget.onSelectTemplate(newTemplate);
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: widget.onClose,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search & Filter Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.panelBackground,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search tournament templates...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.panelHeader,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildCategoryChip('All'),
                      _buildCategoryChip('Tournament Overlay'),
                      _buildCategoryChip('Slot List'),
                      _buildCategoryChip('Winner Banner'),
                    ],
                  ),
                ),

                // Grid View of Templates
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text('No templates found', style: TextStyle(color: AppColors.textMuted)))
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return _buildTemplateCard(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(category, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12)),
        selectedColor: AppColors.accentPrimary,
        backgroundColor: AppColors.panelHeader,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }

  Widget _buildTemplateCard(TemplateModel template) {
    return Card(
      color: AppColors.panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: InkWell(
        onTap: () => widget.onSelectTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scaled Template Thumbnail Preview
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  color: const Color(0xFF09090B),
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: TemplateRenderer(
                      template: template,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${template.canvasSpec.width.toInt()}x${template.canvasSpec.height.toInt()} px • ${template.layers.length} Layers',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
