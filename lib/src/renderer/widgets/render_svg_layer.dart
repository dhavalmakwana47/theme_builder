import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/models/layer_model.dart';

class RenderSvgLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderSvgLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    final style = layer.style;
    final svgSource = layer.svgData.isNotEmpty ? layer.svgData : layer.assetUrl;

    Widget svgWidget;
    if (svgSource.startsWith('<svg')) {
      svgWidget = SvgPicture.string(
        svgSource,
        width: layer.width,
        height: layer.height,
        fit: BoxFit.contain,
      );
    } else if (svgSource.startsWith('http://') || svgSource.startsWith('https://')) {
      svgWidget = SvgPicture.network(
        svgSource,
        width: layer.width,
        height: layer.height,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    } else if (svgSource.isNotEmpty) {
      svgWidget = SvgPicture.asset(
        svgSource,
        width: layer.width,
        height: layer.height,
        fit: BoxFit.contain,
      );
    } else {
      svgWidget = Container(
        color: const Color(0xFF27272A),
        child: const Center(
          child: Icon(Icons.code, color: Colors.white54, size: 28),
        ),
      );
    }

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Opacity(
        opacity: style.opacity,
        child: svgWidget,
      ),
    );
  }
}
