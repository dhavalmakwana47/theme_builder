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

  factory CanvasSpec.fromJson(Map<String, dynamic> json) {
    return CanvasSpec(
      width: (json['width'] as num?)?.toDouble() ?? 1080.0,
      height: (json['height'] as num?)?.toDouble() ?? 1920.0,
      backgroundColorHex: json['backgroundColorHex'] as int? ?? 0xFF18181B,
      backgroundImageUrl: json['backgroundImageUrl'] as String? ?? '',
      showGrid: json['showGrid'] as bool? ?? true,
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 20.0,
      snapToGrid: json['snapToGrid'] as bool? ?? true,
      snapToObjects: json['snapToObjects'] as bool? ?? true,
      showRulers: json['showRulers'] as bool? ?? true,
      presetName: json['presetName'] as String? ?? 'Story 1080x1920',
    );
  }
}
