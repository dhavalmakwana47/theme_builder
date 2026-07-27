import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';

class AssetManagerScreen extends StatefulWidget {
  final Function(String assetUrl) onSelectAsset;

  const AssetManagerScreen({
    super.key,
    required this.onSelectAsset,
  });

  @override
  State<AssetManagerScreen> createState() => _AssetManagerScreenState();
}

class _AssetManagerScreenState extends State<AssetManagerScreen> {
  String _selectedTab = 'Images';
  final List<String> _sampleAssets = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
    'https://picsum.photos/400/300?random=5',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: SizedBox(
        width: 700,
        height: 500,
        child: Column(
          children: [
            // Title & Tabs Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.panelHeader,
              child: Row(
                children: [
                  const Icon(Icons.perm_media, color: AppColors.accentPrimary),
                  const SizedBox(width: 8),
                  const Text('Asset Gallery Manager', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary),
                    icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                    label: const Text('Upload Local Asset', style: TextStyle(color: Colors.white)),
                    onPressed: _pickLocalAsset,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tab Selector Chips
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildTabChip('Images'),
                  _buildTabChip('SVG Vectors'),
                  _buildTabChip('Fonts'),
                  _buildTabChip('Backgrounds'),
                ],
              ),
            ),

            // Asset Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: _sampleAssets.length,
                itemBuilder: (context, index) {
                  final url = _sampleAssets[index];
                  return InkWell(
                    onTap: () {
                      widget.onSelectAsset(url);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderDark),
                        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label) {
    final isSelected = _selectedTab == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 12)),
        selectedColor: AppColors.accentPrimary,
        backgroundColor: AppColors.panelHeader,
        onSelected: (_) => setState(() => _selectedTab = label),
      ),
    );
  }

  Future<void> _pickLocalAsset() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      widget.onSelectAsset(result.files.single.path!);
      if (mounted) Navigator.pop(context);
    }
  }
}
