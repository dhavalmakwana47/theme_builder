/// Configuration spec for the canvas viewport.
class CanvasSpec {
  final double width;
  final double height;
  final int backgroundColorHex;
  final String backgroundImageUrl;
  final bool showGrid;
  final double gridSize;
  final bool snapToGrid;
  final bool snapToObjects;
  final bool showRulers;
  final String presetName;

  const CanvasSpec({
    this.width = 1080.0,
    this.height = 1920.0,
    this.backgroundColorHex = 0xFF18181B, // Dark sleek background
    this.backgroundImageUrl = '',
    this.showGrid = true,
    this.gridSize = 20.0,
    this.snapToGrid = true,
    this.snapToObjects = true,
    this.showRulers = true,
    this.presetName = 'Story 1080x1920',
  });

  CanvasSpec copyWith({
    double? width,
    double? height,
    int? backgroundColorHex,
    String? backgroundImageUrl,
    bool? showGrid,
    double? gridSize,
    bool? snapToGrid,
    bool? snapToObjects,
    bool? showRulers,
    String? presetName,
  }) {
    return CanvasSpec(
      width: width ?? this.width,
      height: height ?? this.height,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      showGrid: showGrid ?? this.showGrid,
      gridSize: gridSize ?? this.gridSize,
      snapToGrid: snapToGrid ?? this.snapToGrid,
      snapToObjects: snapToObjects ?? this.snapToObjects,
      showRulers: showRulers ?? this.showRulers,
      presetName: presetName ?? this.presetName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'backgroundColorHex': backgroundColorHex,
      'backgroundImageUrl': backgroundImageUrl,
      'showGrid': showGrid,
      'gridSize': gridSize,
      'snapToGrid': snapToGrid,
      'snapToObjects': snapToObjects,
      'showRulers': showRulers,
      'presetName': presetName,
    };
  }

  factory CanvasSpec.fromJson(Map<dynamic, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);

    int parseColorVal(dynamic val) {
      if (val == null) return 0xFF18181B;
      if (val is int) return val.toUnsigned(32);
      if (val is num) return val.toInt().toUnsigned(32);
      final str = val.toString().trim();
      final parsedInt = int.tryParse(str);
      if (parsedInt != null) return parsedInt.toUnsigned(32);

      var cleanHex = str.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '').trim();
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      if (cleanHex.length == 8) {
        final parsed = int.tryParse(cleanHex, radix: 16);
        if (parsed != null) return parsed.toUnsigned(32);
      }
      return 0xFF18181B;
    }

    final bgVal = json['backgroundColorHex'] ?? json['background_color_hex'] ?? json['backgroundColor'] ?? json['background_color'];
    final bgImgVal = json['backgroundImageUrl'] ?? json['background_image_url'] ?? json['backgroundImage'] ?? json['background_image'];

    return CanvasSpec(
      width: (json['width'] as num?)?.toDouble() ?? 1080.0,
      height: (json['height'] as num?)?.toDouble() ?? 1920.0,
      backgroundColorHex: parseColorVal(bgVal),
      backgroundImageUrl: bgImgVal?.toString() ?? '',
      showGrid: (json['showGrid'] ?? json['show_grid']) as bool? ?? true,
      gridSize: ((json['gridSize'] ?? json['grid_size']) as num?)?.toDouble() ?? 20.0,
      snapToGrid: (json['snapToGrid'] ?? json['snap_to_grid']) as bool? ?? true,
      snapToObjects: (json['snapToObjects'] ?? json['snap_to_objects']) as bool? ?? true,
      showRulers: (json['showRulers'] ?? json['show_rulers']) as bool? ?? true,
      presetName: (json['presetName'] ?? json['preset_name'])?.toString() ?? 'Story 1080x1920',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasSpec &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          backgroundColorHex == other.backgroundColorHex &&
          backgroundImageUrl == other.backgroundImageUrl &&
          showGrid == other.showGrid &&
          gridSize == other.gridSize &&
          snapToGrid == other.snapToGrid &&
          snapToObjects == other.snapToObjects &&
          showRulers == other.showRulers &&
          presetName == other.presetName;

  @override
  int get hashCode =>
      Object.hash(width, height, backgroundColorHex, backgroundImageUrl, showGrid, gridSize, snapToGrid, snapToObjects, showRulers, presetName);
}
