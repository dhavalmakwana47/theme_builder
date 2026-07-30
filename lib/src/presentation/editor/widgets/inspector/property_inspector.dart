import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../providers/editor_notifier.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/layer_model.dart';
import '../../../../domain/models/layer_style.dart';
import '../../../../domain/models/enums.dart';
import '../../../../domain/models/canvas_spec.dart';
import '../../../../core/constants/canvas_presets.dart';

class PropertyInspector extends ConsumerWidget {
  const PropertyInspector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);
    final selectedLayer = state.primarySelectedLayer;

    if (selectedLayer == null) {
      return _buildEmptyState(context, state.template.canvasSpec, notifier);
    }

    return Container(
      color: AppColors.panelBackground,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Header title & Layer Name Edit
          Row(
            children: [
              Icon(_getLayerIcon(selectedLayer.type), size: 16, color: AppColors.accentPrimary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedLayer.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  selectedLayer.isLocked ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: selectedLayer.isLocked ? Colors.amber : AppColors.textMuted,
                ),
                onPressed: () => notifier.toggleLayerLock(selectedLayer.id),
                tooltip: 'Lock Layer',
              ),
              IconButton(
                icon: Icon(
                  selectedLayer.isVisible ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: selectedLayer.isVisible ? Colors.white : AppColors.textMuted,
                ),
                onPressed: () => notifier.toggleLayerVisibility(selectedLayer.id),
                tooltip: 'Hide Layer',
              ),
            ],
          ),

          const Divider(color: AppColors.borderDark, height: 20),

          // --- 1. TRANSFORMS ACCORDION ---
          _buildSectionHeader('Transform & Alignment'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNumberInput('X', selectedLayer.x, (val) => notifier.updateLayerTransform(layerId: selectedLayer.id, x: val))),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberInput('Y', selectedLayer.y, (val) => notifier.updateLayerTransform(layerId: selectedLayer.id, y: val))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNumberInput('Width', selectedLayer.width, (val) => notifier.updateLayerTransform(layerId: selectedLayer.id, width: val))),
              const SizedBox(width: 8),
              Expanded(child: _buildNumberInput('Height', selectedLayer.height, (val) => notifier.updateLayerTransform(layerId: selectedLayer.id, height: val))),
            ],
          ),
          const SizedBox(height: 8),
          _buildNumberInput('Rotation (°)', selectedLayer.rotation, (val) => notifier.updateLayerTransform(layerId: selectedLayer.id, rotation: val)),

          const SizedBox(height: 8),
          // Alignment Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAlignBtn(Icons.align_horizontal_left, 'Left', () => notifier.alignSelectedLayers('left')),
                _buildAlignBtn(Icons.align_horizontal_center, 'Center', () => notifier.alignSelectedLayers('center_x')),
                _buildAlignBtn(Icons.align_horizontal_right, 'Right', () => notifier.alignSelectedLayers('right')),
                _buildAlignBtn(Icons.align_vertical_top, 'Top', () => notifier.alignSelectedLayers('top')),
                _buildAlignBtn(Icons.align_vertical_center, 'Middle', () => notifier.alignSelectedLayers('middle_y')),
                _buildAlignBtn(Icons.align_vertical_bottom, 'Bottom', () => notifier.alignSelectedLayers('bottom')),
              ],
            ),
          ),

          const Divider(color: AppColors.borderDark, height: 24),

          // --- 2. TEXT SPECIFIC INSPECTOR ---
          if (selectedLayer.type == LayerType.text) ...[
            _buildSectionHeader('Text & Typography'),
            const SizedBox(height: 8),
            _buildTextInput('Text Content', selectedLayer.text, (val) {
              notifier.updateLayer(selectedLayer.copyWith(text: val));
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    'Font Size',
                    selectedLayer.style.fontSize,
                    (val) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(fontSize: val)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildColorPickerBtn(
                    context,
                    'Color',
                    Color(selectedLayer.style.textColorHex),
                    (color) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(textColorHex: color.value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildFontFamilyDropdown(selectedLayer, notifier),
            const SizedBox(height: 8),
            _buildDynamicVariableBinder(selectedLayer, notifier),
            const Divider(color: AppColors.borderDark, height: 24),
          ],

          // --- 3. SHAPE SPECIFIC INSPECTOR ---
          if (selectedLayer.type == LayerType.shape) ...[
            _buildSectionHeader('Shape Geometry'),
            const SizedBox(height: 8),
            _buildShapeTypeDropdown(selectedLayer, notifier),
            const SizedBox(height: 8),
            _buildDynamicVariableBinder(selectedLayer, notifier),
            const Divider(color: AppColors.borderDark, height: 24),
          ],

          // --- 4. IMAGE SPECIFIC INSPECTOR ---
          if (selectedLayer.type == LayerType.image) ...[
            _buildSectionHeader('Image Settings'),
            const SizedBox(height: 8),
            _buildTextInput('Asset URL / Path', selectedLayer.assetUrl, (val) {
              notifier.updateLayer(selectedLayer.copyWith(assetUrl: val));
            }),
            const SizedBox(height: 8),
            _buildDynamicVariableBinder(selectedLayer, notifier),
            const Divider(color: AppColors.borderDark, height: 24),
          ],

          // --- 5. SVG VECTOR INSPECTOR ---
          if (selectedLayer.type == LayerType.svg) ...[
            _buildSectionHeader('SVG Vector Settings'),
            const SizedBox(height: 8),
            _buildTextInput('SVG Code / Data', selectedLayer.svgData, (val) {
              notifier.updateLayer(selectedLayer.copyWith(svgData: val));
            }),
            const SizedBox(height: 8),
            _buildDynamicVariableBinder(selectedLayer, notifier),
            const Divider(color: AppColors.borderDark, height: 24),
          ],

          // --- 6. QR & BARCODE INSPECTOR ---
          if (selectedLayer.type == LayerType.qr || selectedLayer.type == LayerType.barcode) ...[
            _buildSectionHeader(selectedLayer.type == LayerType.qr ? 'QR Code Settings' : 'Barcode Settings'),
            const SizedBox(height: 8),
            _buildTextInput(
              'Payload Data',
              selectedLayer.type == LayerType.qr ? selectedLayer.qrData : selectedLayer.barcodeData,
              (val) {
                if (selectedLayer.type == LayerType.qr) {
                  notifier.updateLayer(selectedLayer.copyWith(qrData: val));
                } else {
                  notifier.updateLayer(selectedLayer.copyWith(barcodeData: val));
                }
              },
            ),
            const SizedBox(height: 8),
            _buildDynamicVariableBinder(selectedLayer, notifier),
            const Divider(color: AppColors.borderDark, height: 24),
          ],

          // --- 4. APPEARANCE & STYLING ---
          _buildSectionHeader('Fill & Appearance'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildColorPickerBtn(
                  context,
                  'Fill Color',
                  Color(selectedLayer.style.fillColorHex),
                  (color) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(fillColorHex: color.value)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Opacity', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    Slider(
                      value: selectedLayer.style.opacity,
                      min: 0.0,
                      max: 1.0,
                      activeColor: AppColors.accentPrimary,
                      onChanged: (val) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(opacity: val)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Border Radius & Width
          Row(
            children: [
              Expanded(
                child: _buildNumberInput(
                  'Corner Radius',
                  selectedLayer.style.borderRadius,
                  (val) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(borderRadius: val)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildNumberInput(
                  'Border Width',
                  selectedLayer.style.borderWidth,
                  (val) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(borderWidth: val)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildColorPickerBtn(
            context,
            'Border Color',
            Color(selectedLayer.style.borderColorHex),
            (color) => notifier.updateLayerStyle(selectedLayer.id, selectedLayer.style.copyWith(borderColorHex: color.value)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CanvasSpec spec, EditorNotifier notifier) {
    return Container(
      color: AppColors.panelBackground,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Canvas Resolution & Settings'),
            const SizedBox(height: 12),

            // Canvas Preset Selector
            const Text('Preset Resolution', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: AppColors.panelHeader, borderRadius: BorderRadius.circular(4)),
              child: DropdownButton<String>(
                value: CanvasPresets.presets.any((p) => p.name == spec.presetName)
                    ? spec.presetName
                    : CanvasPresets.presets.first.name,
                dropdownColor: AppColors.panelHeader,
                isExpanded: true,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                underline: const SizedBox.shrink(),
                items: CanvasPresets.presets.map((p) {
                  return DropdownMenuItem(
                    value: p.name,
                    child: Text('${p.name} (${p.width.toInt()}x${p.height.toInt()})'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  final found = CanvasPresets.presets.firstWhere((p) => p.name == val);
                  notifier.updateCanvasSpec(found.toSpec().copyWith(
                    backgroundColorHex: spec.backgroundColorHex,
                    showGrid: spec.showGrid,
                    snapToGrid: spec.snapToGrid,
                  ));
                },
              ),
            ),

            const SizedBox(height: 12),

            // Custom Width & Height Number Inputs
            Row(
              children: [
                Expanded(
                  child: InspectorNumberField(
                    key: ValueKey('canvas_width_${spec.width}'),
                    label: 'Width (px)',
                    value: spec.width,
                    onChanged: (val) => notifier.updateCanvasSpec(spec.copyWith(width: val.clamp(100.0, 5000.0))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InspectorNumberField(
                    key: ValueKey('canvas_height_${spec.height}'),
                    label: 'Height (px)',
                    value: spec.height,
                    onChanged: (val) => notifier.updateCanvasSpec(spec.copyWith(height: val.clamp(100.0, 5000.0))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Background Color Picker
            _buildColorPickerBtn(
              context,
              'Background Color',
              Color(spec.backgroundColorHex),
              (color) => notifier.updateCanvasSpec(spec.copyWith(backgroundColorHex: color.value)),
            ),

            const SizedBox(height: 12),

            // Background Image URL Section
            _buildSectionHeader('Canvas Background Image'),
            const SizedBox(height: 8),
            InspectorTextField(
              key: ValueKey('canvas_bg_url_${spec.backgroundImageUrl}'),
              label: 'Background Image URL / Path',
              value: spec.backgroundImageUrl,
              onChanged: (val) {
                notifier.updateCanvasSpec(spec.copyWith(backgroundImageUrl: val));
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppColors.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon: const Icon(Icons.wallpaper, size: 14, color: AppColors.accentSecondary),
                    label: const Text('Sample Trophy BG', style: TextStyle(fontSize: 10)),
                    onPressed: () {
                      notifier.updateCanvasSpec(spec.copyWith(
                        backgroundImageUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1080',
                      ));
                    },
                  ),
                ),
                if (spec.backgroundImageUrl.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                    tooltip: 'Clear Background Image',
                    onPressed: () {
                      notifier.updateCanvasSpec(spec.copyWith(backgroundImageUrl: ''));
                    },
                  ),
                ],
              ],
            ),

            const Divider(color: AppColors.borderDark, height: 24),

            // Grid & Snap Toggles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show Alignment Grid', style: TextStyle(color: Colors.white, fontSize: 12)),
                Switch(
                  value: spec.showGrid,
                  activeColor: AppColors.accentPrimary,
                  onChanged: (val) => notifier.updateCanvasSpec(spec.copyWith(showGrid: val)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Snap to Grid', style: TextStyle(color: Colors.white, fontSize: 12)),
                Switch(
                  value: spec.snapToGrid,
                  activeColor: AppColors.accentPrimary,
                  onChanged: (val) => notifier.updateCanvasSpec(spec.copyWith(snapToGrid: val)),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Center(
              child: Text(
                'Select any layer to edit layer properties',
                style: TextStyle(color: AppColors.textMuted.withOpacity(0.6), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
    );
  }

  Widget _buildNumberInput(String label, double value, Function(double) onChanged) {
    return InspectorNumberField(
      key: ValueKey(label),
      label: label,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTextInput(String label, String value, Function(String) onChanged) {
    return InspectorTextField(
      key: ValueKey(label),
      label: label,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildColorPickerBtn(BuildContext context, String label, Color currentColor, Function(Color) onColorPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final Color newColor = await showColorPickerDialog(
              context,
              currentColor,
              backgroundColor: AppColors.panelHeader,
              title: Text('Select $label', style: const TextStyle(color: Colors.white)),
            );
            onColorPicked(newColor);
          },
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: currentColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilyDropdown(LayerModel layer, EditorNotifier notifier) {
    const fonts = ['Inter', 'Roboto', 'Montserrat', 'Outfit', 'Poppins', 'Oswald'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Family', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppColors.panelHeader, borderRadius: BorderRadius.circular(4)),
          child: DropdownButton<String>(
            value: fonts.contains(layer.style.fontFamily) ? layer.style.fontFamily : 'Inter',
            dropdownColor: AppColors.panelHeader,
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: const SizedBox.shrink(),
            items: fonts.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) {
              if (val != null) {
                notifier.updateLayerStyle(layer.id, layer.style.copyWith(fontFamily: val));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicVariableBinder(LayerModel layer, EditorNotifier notifier) {
    const variables = [
      'None',
      '{{team_name}}',
      '{{player_name}}',
      '{{rank}}',
      '{{kills}}',
      '{{points}}',
      '{{slot}}',
      '{{match}}',
      '{{date}}',
      '{{prize}}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bind Dynamic Variable', style: TextStyle(color: AppColors.accentSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.panelHeader,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.accentSecondary.withOpacity(0.5)),
          ),
          child: DropdownButton<String>(
            value: variables.contains(layer.variableKey) ? layer.variableKey : 'None',
            dropdownColor: AppColors.panelHeader,
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: const SizedBox.shrink(),
            items: variables.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (val) {
              notifier.updateLayer(layer.copyWith(variableKey: val == 'None' ? null : val));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShapeTypeDropdown(LayerModel layer, EditorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shape Type', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(color: AppColors.panelHeader, borderRadius: BorderRadius.circular(4)),
          child: DropdownButton<ShapeType>(
            value: layer.shapeType,
            dropdownColor: AppColors.panelHeader,
            isExpanded: true,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: const SizedBox.shrink(),
            items: ShapeType.values.map((shape) {
              return DropdownMenuItem(
                value: shape,
                child: Text(shape.displayName),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                notifier.updateLayer(layer.copyWith(shapeType: val));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAlignBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 16),
      color: AppColors.textSecondary,
      tooltip: 'Align $tooltip',
      onPressed: onTap,
    );
  }

  IconData _getLayerIcon(LayerType type) {
    switch (type) {
      case LayerType.text:
        return Icons.text_fields;
      case LayerType.image:
        return Icons.image;
      case LayerType.shape:
        return Icons.shape_line;
      case LayerType.qr:
        return Icons.qr_code;
      default:
        return Icons.layers;
    }
  }
}

class InspectorNumberField extends StatefulWidget {
  final String label;
  final double value;
  final Function(double) onChanged;

  const InspectorNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<InspectorNumberField> createState() => _InspectorNumberFieldState();
}

class _InspectorNumberFieldState extends State<InspectorNumberField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(0));
  }

  @override
  void didUpdateWidget(covariant InspectorNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: true,
            fillColor: AppColors.panelHeader,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          ),
          onChanged: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null) {
              widget.onChanged(parsed);
            }
          },
          onSubmitted: (val) {
            final parsed = double.tryParse(val);
            if (parsed != null) {
              widget.onChanged(parsed);
            } else {
              _controller.text = widget.value.toStringAsFixed(0);
            }
          },
        ),
      ],
    );
  }
}

class InspectorTextField extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;

  const InspectorTextField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<InspectorTextField> createState() => _InspectorTextFieldState();
}

class _InspectorTextFieldState extends State<InspectorTextField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InspectorTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: true,
            fillColor: AppColors.panelHeader,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
          ),
          onChanged: widget.onChanged,
        ),
      ],
    );
  }
}
