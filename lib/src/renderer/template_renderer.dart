import 'package:flutter/material.dart';
import '../domain/models/template_model.dart';
import '../domain/models/layer_model.dart';
import '../domain/models/enums.dart';
import 'widgets/render_text_layer.dart';
import 'widgets/render_image_layer.dart';
import 'widgets/render_svg_layer.dart';
import 'widgets/render_shape_layer.dart';
import 'widgets/render_qr_layer.dart';
import 'widgets/render_barcode_layer.dart';
import 'widgets/render_component_layer.dart';

/// Standalone dynamic Flutter renderer engine for TournaX JSON templates.
class TemplateRenderer extends StatelessWidget {
  final TemplateModel template;
  final Map<String, String>? overrideVariables;
  final Size? customSize;

  const TemplateRenderer({
    super.key,
    required this.template,
    this.overrideVariables,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final spec = template.canvasSpec;
    final double targetWidth = customSize?.width ?? spec.width;
    final double targetHeight = customSize?.height ?? spec.height;
    final double scaleX = customSize != null ? targetWidth / spec.width : 1.0;
    final double scaleY = customSize != null ? targetHeight / spec.height : 1.0;

    final Map<String, String> activeVars = {
      ...template.globalVariables,
      ...?overrideVariables,
    };

    // Sort layers by Z-index ascending
    final sortedLayers = List<LayerModel>.from(template.layers)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    return Container(
      width: targetWidth,
      height: targetHeight,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color.fromARGB(
          ((spec.backgroundColorHex >> 24) & 0xFF) == 0 ? 255 : ((spec.backgroundColorHex >> 24) & 0xFF),
          (spec.backgroundColorHex >> 16) & 0xFF,
          (spec.backgroundColorHex >> 8) & 0xFF,
          spec.backgroundColorHex & 0xFF,
        ),
      ),
      child: Transform.scale(
        scaleX: scaleX,
        scaleY: scaleY,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: spec.width,
          height: spec.height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Scaled Canvas Background Image Layer
              if (spec.backgroundImageUrl.isNotEmpty)
                Positioned.fill(
                  child: _buildBackgroundImageWidget(spec.backgroundImageUrl),
                ),

              // 2. Scaled Template Layers Stack
              ...sortedLayers.map((layer) {
                if (!layer.isVisible) return const SizedBox.shrink();
                return Positioned(
                  left: layer.x,
                  top: layer.y,
                  child: _buildLayerTransformWrapper(layer, activeVars),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayerTransformWrapper(LayerModel layer, Map<String, String> variables) {
    Widget content = _buildLayerBody(layer, variables);

    // Apply rotation & flip transforms
    if (layer.rotation != 0.0 || layer.flipX || layer.flipY || layer.scaleX != 1.0 || layer.scaleY != 1.0) {
      final double rad = layer.rotation * (3.14159265358979323846 / 180);
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..rotateZ(rad)
          ..scale(layer.flipX ? -layer.scaleX : layer.scaleX, layer.flipY ? -layer.scaleY : layer.scaleY),
        child: content,
      );
    }

    return content;
  }

  Widget _buildLayerBody(LayerModel layer, Map<String, String> variables) {
    switch (layer.type) {
      case LayerType.text:
        return RenderTextLayer(layer: layer, variables: variables);
      case LayerType.image:
      case LayerType.playerAvatar:
      case LayerType.teamLogo:
        return RenderImageLayer(layer: layer, variables: variables);
      case LayerType.svg:
        return RenderSvgLayer(layer: layer, variables: variables);
      case LayerType.shape:
      case LayerType.container:
        return RenderShapeLayer(layer: layer);
      case LayerType.qr:
        return RenderQrLayer(layer: layer, variables: variables);
      case LayerType.barcode:
        return RenderBarcodeLayer(layer: layer, variables: variables);
      case LayerType.rankBadge:
      case LayerType.prizeBadge:
      case LayerType.slotRow:
      case LayerType.playerCard:
      case LayerType.winnerBanner:
      case LayerType.tournamentHeader:
      case LayerType.customComponent:
        return RenderComponentLayer(layer: layer, variables: variables);
      default:
        return RenderShapeLayer(layer: layer);
    }
  }

  Widget _buildBackgroundImageWidget(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Automatic host IP fallback if 10.151.118.115 vs 127.0.0.1 differs
          if (url.contains('10.151.118.115:8000')) {
            final fallbackUrl = url.replaceAll('10.151.118.115:8000', '127.0.0.1:8000');
            return Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            );
          } else if (url.contains('127.0.0.1:8000')) {
            final fallbackUrl = url.replaceAll('127.0.0.1:8000', '10.151.118.115:8000');
            return Image.network(
              fallbackUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            );
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
  }
}
