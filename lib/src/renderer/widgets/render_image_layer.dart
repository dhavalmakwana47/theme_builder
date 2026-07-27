import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/enums.dart';

class RenderImageLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderImageLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  String _resolveImageUrl() {
    if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
      final value = variables[layer.variableKey];
      if (value != null && value.isNotEmpty) return value;
    }
    return layer.assetUrl;
  }

  BoxFit _mapFit(ImageFitMode fit) {
    switch (fit) {
      case ImageFitMode.contain:
        return BoxFit.contain;
      case ImageFitMode.cover:
        return BoxFit.cover;
      case ImageFitMode.fill:
        return BoxFit.fill;
      case ImageFitMode.fitWidth:
        return BoxFit.fitWidth;
      case ImageFitMode.fitHeight:
        return BoxFit.fitHeight;
      case ImageFitMode.none:
        return BoxFit.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolveImageUrl();
    final style = layer.style;
    final fit = _mapFit(layer.imageFit);

    Widget imageWidget;
    if (url.startsWith('http://') || url.startsWith('https://')) {
      imageWidget = CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (context, _) => Container(
          color: const Color(0xFF27272A),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, _, __) => Container(
          color: const Color(0xFF3F3F46),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.white54, size: 28),
              SizedBox(height: 4),
              Text('Image Error', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ),
      );
    } else if (url.isNotEmpty) {
      imageWidget = Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, _, __) => _buildPlaceholder(),
      );
    } else {
      imageWidget = _buildPlaceholder();
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(style.borderRadius),
          boxShadow: style.shadowColorHex != 0x00000000 && style.shadowBlurRadius > 0
              ? [
                  BoxShadow(
                    color: Color(style.shadowColorHex),
                    offset: Offset(style.shadowDx, style.shadowDy),
                    blurRadius: style.shadowBlurRadius,
                    spreadRadius: style.shadowSpreadRadius,
                  )
                ]
              : null,
          border: style.borderWidth > 0
              ? Border.all(
                  color: Color(style.borderColorHex),
                  width: style.borderWidth,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(style.borderRadius),
          child: Opacity(
            opacity: style.opacity,
            child: imageWidget,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Color(layer.style.fillColorHex),
        gradient: layer.style.isGradientFill && layer.style.gradientColorsHex.length >= 2
            ? LinearGradient(
                colors: layer.style.gradientColorsHex.map((c) => Color(c)).toList(),
              )
            : null,
      ),
      child: const Center(
        child: Icon(Icons.image, color: Colors.white70, size: 36),
      ),
    );
  }
}
