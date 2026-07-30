import 'package:flutter/material.dart';
import 'enums.dart';

/// Styling attributes applied to a layer.
class LayerStyle {
  final int fillColorHex;
  final bool isGradientFill;
  final List<int> gradientColorsHex;
  final List<double> gradientStops;
  final double gradientAngle; // In degrees
  final int borderColorHex;
  final double borderWidth;
  final double borderRadius;
  final int shadowColorHex;
  final double shadowDx;
  final double shadowDy;
  final double shadowBlurRadius;
  final double shadowSpreadRadius;
  final double opacity; // 0.0 to 1.0
  final BlendMode blendMode;
  final double padding;
  final double margin;

  // Text specific styles
  final String fontFamily;
  final double fontSize;
  final int fontWeightValue; // 100 to 900
  final bool isItalic;
  final bool isUnderline;
  final int textColorHex;
  final double letterSpacing;
  final double wordSpacing;
  final double lineHeight;
  final double textStrokeWidth;
  final int textStrokeColorHex;
  final TextAlign textAlign;
  final TextTransformMode textTransform;

  const LayerStyle({
    this.fillColorHex = 0xFF3B82F6,
    this.isGradientFill = false,
    this.gradientColorsHex = const [0xFF3B82F6, 0xFF8B5CF6],
    this.gradientStops = const [0.0, 1.0],
    this.gradientAngle = 45.0,
    this.borderColorHex = 0x00000000,
    this.borderWidth = 0.0,
    this.borderRadius = 0.0,
    this.shadowColorHex = 0x40000000,
    this.shadowDx = 0.0,
    this.shadowDy = 4.0,
    this.shadowBlurRadius = 10.0,
    this.shadowSpreadRadius = 0.0,
    this.opacity = 1.0,
    this.blendMode = BlendMode.srcOver,
    this.padding = 0.0,
    this.margin = 0.0,
    this.fontFamily = 'Inter',
    this.fontSize = 24.0,
    this.fontWeightValue = 600,
    this.isItalic = false,
    this.isUnderline = false,
    this.textColorHex = 0xFFFFFFFF,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,
    this.lineHeight = 1.2,
    this.textStrokeWidth = 0.0,
    this.textStrokeColorHex = 0xFF000000,
    this.textAlign = TextAlign.left,
    this.textTransform = TextTransformMode.none,
  });

  LayerStyle copyWith({
    int? fillColorHex,
    bool? isGradientFill,
    List<int>? gradientColorsHex,
    List<double>? gradientStops,
    double? gradientAngle,
    int? borderColorHex,
    double? borderWidth,
    double? borderRadius,
    int? shadowColorHex,
    double? shadowDx,
    double? shadowDy,
    double? shadowBlurRadius,
    double? shadowSpreadRadius,
    double? opacity,
    BlendMode? blendMode,
    double? padding,
    double? margin,
    String? fontFamily,
    double? fontSize,
    int? fontWeightValue,
    bool? isItalic,
    bool? isUnderline,
    int? textColorHex,
    double? letterSpacing,
    double? wordSpacing,
    double? lineHeight,
    double? textStrokeWidth,
    int? textStrokeColorHex,
    TextAlign? textAlign,
    TextTransformMode? textTransform,
  }) {
    return LayerStyle(
      fillColorHex: fillColorHex ?? this.fillColorHex,
      isGradientFill: isGradientFill ?? this.isGradientFill,
      gradientColorsHex: gradientColorsHex ?? this.gradientColorsHex,
      gradientStops: gradientStops ?? this.gradientStops,
      gradientAngle: gradientAngle ?? this.gradientAngle,
      borderColorHex: borderColorHex ?? this.borderColorHex,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      shadowColorHex: shadowColorHex ?? this.shadowColorHex,
      shadowDx: shadowDx ?? this.shadowDx,
      shadowDy: shadowDy ?? this.shadowDy,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowSpreadRadius: shadowSpreadRadius ?? this.shadowSpreadRadius,
      opacity: opacity ?? this.opacity,
      blendMode: blendMode ?? this.blendMode,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeightValue: fontWeightValue ?? this.fontWeightValue,
      isItalic: isItalic ?? this.isItalic,
      isUnderline: isUnderline ?? this.isUnderline,
      textColorHex: textColorHex ?? this.textColorHex,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      textStrokeWidth: textStrokeWidth ?? this.textStrokeWidth,
      textStrokeColorHex: textStrokeColorHex ?? this.textStrokeColorHex,
      textAlign: textAlign ?? this.textAlign,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fillColorHex': fillColorHex,
      'isGradientFill': isGradientFill,
      'gradientColorsHex': gradientColorsHex,
      'gradientStops': gradientStops,
      'gradientAngle': gradientAngle,
      'borderColorHex': borderColorHex,
      'borderWidth': borderWidth,
      'borderRadius': borderRadius,
      'shadowColorHex': shadowColorHex,
      'shadowDx': shadowDx,
      'shadowDy': shadowDy,
      'shadowBlurRadius': shadowBlurRadius,
      'shadowSpreadRadius': shadowSpreadRadius,
      'opacity': opacity,
      'blendMode': blendMode.index,
      'padding': padding,
      'margin': margin,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeightValue': fontWeightValue,
      'isItalic': isItalic,
      'isUnderline': isUnderline,
      'textColorHex': textColorHex,
      'letterSpacing': letterSpacing,
      'wordSpacing': wordSpacing,
      'lineHeight': lineHeight,
      'textStrokeWidth': textStrokeWidth,
      'textStrokeColorHex': textStrokeColorHex,
      'textAlign': textAlign.index,
      'textTransform': textTransform.index,
    };
  }

  static int _parseHex(dynamic val, int defaultVal) {
    if (val == null) return defaultVal;
    final num n = val as num;
    return n.toInt().toUnsigned(32);
  }

  factory LayerStyle.fromJson(Map<dynamic, dynamic> rawJson) {
    final json = Map<String, dynamic>.from(rawJson);

    List<int> colors = const [0xFF3B82F6, 0xFF8B5CF6];
    if (json['gradientColorsHex'] is List) {
      colors = (json['gradientColorsHex'] as List)
          .map((e) => (e as num).toInt().toUnsigned(32))
          .toList();
    }

    List<double> stops = const [0.0, 1.0];
    if (json['gradientStops'] is List) {
      stops = (json['gradientStops'] as List)
          .map((e) => (e as num).toDouble())
          .toList();
    }

    final blendIndex = (json['blendMode'] as num?)?.toInt() ?? 0;
    final alignIndex = (json['textAlign'] as num?)?.toInt() ?? 0;
    final transformIndex = (json['textTransform'] as num?)?.toInt() ?? 0;

    return LayerStyle(
      fillColorHex: _parseHex(json['fillColorHex'], 0xFF3B82F6),
      isGradientFill: json['isGradientFill'] as bool? ?? false,
      gradientColorsHex: colors,
      gradientStops: stops,
      gradientAngle: (json['gradientAngle'] as num?)?.toDouble() ?? 45.0,
      borderColorHex: _parseHex(json['borderColorHex'], 0x00000000),
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 0.0,
      shadowColorHex: _parseHex(json['shadowColorHex'], 0x40000000),
      shadowDx: (json['shadowDx'] as num?)?.toDouble() ?? 0.0,
      shadowDy: (json['shadowDy'] as num?)?.toDouble() ?? 4.0,
      shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 10.0,
      shadowSpreadRadius: (json['shadowSpreadRadius'] as num?)?.toDouble() ?? 0.0,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 1.0,
      blendMode: blendIndex < BlendMode.values.length ? BlendMode.values[blendIndex] : BlendMode.srcOver,
      padding: (json['padding'] as num?)?.toDouble() ?? 0.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 0.0,
      fontFamily: json['fontFamily']?.toString() ?? 'Inter',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      fontWeightValue: (json['fontWeightValue'] as num?)?.toInt() ?? 600,
      isItalic: json['isItalic'] as bool? ?? false,
      isUnderline: json['isUnderline'] as bool? ?? false,
      textColorHex: _parseHex(json['textColorHex'], 0xFFFFFFFF),
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
      wordSpacing: (json['wordSpacing'] as num?)?.toDouble() ?? 0.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.2,
      textStrokeWidth: (json['textStrokeWidth'] as num?)?.toDouble() ?? 0.0,
      textStrokeColorHex: _parseHex(json['textStrokeColorHex'], 0xFF000000),
      textAlign: alignIndex < TextAlign.values.length ? TextAlign.values[alignIndex] : TextAlign.left,
      textTransform: transformIndex < TextTransformMode.values.length ? TextTransformMode.values[transformIndex] : TextTransformMode.none,
    );
  }
}
