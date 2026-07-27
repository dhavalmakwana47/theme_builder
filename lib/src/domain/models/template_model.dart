import 'canvas_spec.dart';
import 'layer_model.dart';

/// Top-level root template model for TournaX Visual Builder.
class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final int version;
  final String createdAt;
  final String updatedAt;
  final CanvasSpec canvasSpec;
  final List<LayerModel> layers;
  final Map<String, String> globalVariables;
  final Map<String, dynamic> metadata;

  const TemplateModel({
    required this.id,
    required this.name,
    this.description = 'TournaX Dynamic Tournament Template',
    this.category = 'Tournament Overlay',
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
    this.canvasSpec = const CanvasSpec(),
    this.layers = const [],
    this.globalVariables = const {
      '{{team_name}}': 'ALPHA ESPORTS',
      '{{player_name}}': 'CYPHER_07',
      '{{rank}}': '#1',
      '{{kills}}': '18',
      '{{points}}': '45',
      '{{slot}}': 'SLOT 04',
      '{{match}}': 'FINALS - MATCH 03',
      '{{date}}': '28 JUL 2026',
      '{{prize}}': '\$5,000 USD',
      '{{country}}': 'INDIA',
    },
    this.metadata = const {},
  });

  TemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? version,
    String? createdAt,
    String? updatedAt,
    CanvasSpec? canvasSpec,
    List<LayerModel>? layers,
    Map<String, String>? globalVariables,
    Map<String, dynamic>? metadata,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canvasSpec: canvasSpec ?? this.canvasSpec,
      layers: layers ?? this.layers,
      globalVariables: globalVariables ?? this.globalVariables,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'version': version,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'canvasSpec': canvasSpec.toJson(),
      'layers': layers.map((e) => e.toJson()).toList(),
      'globalVariables': globalVariables,
      'metadata': metadata,
    };
  }

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'TournaX Dynamic Tournament Template',
      category: json['category'] as String? ?? 'Tournament Overlay',
      version: json['version'] as int? ?? 1,
      createdAt: json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      canvasSpec: json['canvasSpec'] != null
          ? CanvasSpec.fromJson(json['canvasSpec'] as Map<String, dynamic>)
          : const CanvasSpec(),
      layers: (json['layers'] as List<dynamic>?)
              ?.map((e) => LayerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      globalVariables: (json['globalVariables'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}
