import 'enums.dart';
import 'layer_style.dart';

/// Single visual layer model within the template.
class LayerModel {
  final String id;
  final String name;
  final LayerType type;
  final String? parentId;
  final List<String> childrenIds;
  final bool isLocked;
  final bool isVisible;
  final int zIndex;

  // Transforms
  final double x;
  final double y;
  final double width;
  final double height;
  final double rotation; // In degrees
  final double scaleX;
  final double scaleY;
  final bool flipX;
  final bool flipY;

  // Style
  final LayerStyle style;

  // Specific Layer Payloads
  final String text;
  final String assetUrl;
  final String svgData;
  final String qrData;
  final String barcodeData;
  final ShapeType shapeType;
  final ImageFitMode imageFit;
  final String? variableKey;
  final Map<String, dynamic> metadata;

  const LayerModel({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.childrenIds = const [],
    this.isLocked = false,
    this.isVisible = true,
    this.zIndex = 0,
    this.x = 0.0,
    this.y = 0.0,
    this.width = 200.0,
    this.height = 100.0,
    this.rotation = 0.0,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
    this.flipX = false,
    this.flipY = false,
    this.style = const LayerStyle(),
    this.text = 'Sample Text',
    this.assetUrl = '',
    this.svgData = '',
    this.qrData = 'https://tournax.com',
    this.barcodeData = '123456789012',
    this.shapeType = ShapeType.rectangle,
    this.imageFit = ImageFitMode.cover,
    this.variableKey,
    this.metadata = const {},
  });

  LayerModel copyWith({
    String? id,
    String? name,
    LayerType? type,
    String? parentId,
    List<String>? childrenIds,
    bool? isLocked,
    bool? isVisible,
    int? zIndex,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    double? scaleX,
    double? scaleY,
    bool? flipX,
    bool? flipY,
    LayerStyle? style,
    String? text,
    String? assetUrl,
    String? svgData,
    String? qrData,
    String? barcodeData,
    ShapeType? shapeType,
    ImageFitMode? imageFit,
    String? variableKey,
    Map<String, dynamic>? metadata,
  }) {
    return LayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      parentId: parentId ?? this.parentId,
      childrenIds: childrenIds ?? this.childrenIds,
      isLocked: isLocked ?? this.isLocked,
      isVisible: isVisible ?? this.isVisible,
      zIndex: zIndex ?? this.zIndex,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      flipX: flipX ?? this.flipX,
      flipY: flipY ?? this.flipY,
      style: style ?? this.style,
      text: text ?? this.text,
      assetUrl: assetUrl ?? this.assetUrl,
      svgData: svgData ?? this.svgData,
      qrData: qrData ?? this.qrData,
      barcodeData: barcodeData ?? this.barcodeData,
      shapeType: shapeType ?? this.shapeType,
      imageFit: imageFit ?? this.imageFit,
      variableKey: variableKey ?? this.variableKey,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'parentId': parentId,
      'childrenIds': childrenIds,
      'isLocked': isLocked,
      'isVisible': isVisible,
      'zIndex': zIndex,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'scaleX': scaleX,
      'scaleY': scaleY,
      'flipX': flipX,
      'flipY': flipY,
      'style': style.toJson(),
      'text': text,
      'assetUrl': assetUrl,
      'svgData': svgData,
      'qrData': qrData,
      'barcodeData': barcodeData,
      'shapeType': shapeType.index,
      'imageFit': imageFit.index,
      'variableKey': variableKey,
      'metadata': metadata,
    };
  }

  factory LayerModel.fromJson(Map<String, dynamic> json) {
    return LayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: LayerType.values[json['type'] as int? ?? 0],
      parentId: json['parentId'] as String?,
      childrenIds: (json['childrenIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isLocked: json['isLocked'] as bool? ?? false,
      isVisible: json['isVisible'] as bool? ?? true,
      zIndex: json['zIndex'] as int? ?? 0,
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
      width: (json['width'] as num?)?.toDouble() ?? 200.0,
      height: (json['height'] as num?)?.toDouble() ?? 100.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      scaleX: (json['scaleX'] as num?)?.toDouble() ?? 1.0,
      scaleY: (json['scaleY'] as num?)?.toDouble() ?? 1.0,
      flipX: json['flipX'] as bool? ?? false,
      flipY: json['flipY'] as bool? ?? false,
      style: json['style'] != null
          ? LayerStyle.fromJson(json['style'] as Map<String, dynamic>)
          : const LayerStyle(),
      text: json['text'] as String? ?? 'Sample Text',
      assetUrl: json['assetUrl'] as String? ?? '',
      svgData: json['svgData'] as String? ?? '',
      qrData: json['qrData'] as String? ?? 'https://tournax.com',
      barcodeData: json['barcodeData'] as String? ?? '123456789012',
      shapeType: ShapeType.values[json['shapeType'] as int? ?? 0],
      imageFit: ImageFitMode.values[json['imageFit'] as int? ?? 0],
      variableKey: json['variableKey'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}
