import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/models/layer_model.dart';

class RenderQrLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderQrLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  String _resolveQrData() {
    if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
      final val = variables[layer.variableKey];
      if (val != null && val.isNotEmpty) return val;
    }
    return layer.qrData.isNotEmpty ? layer.qrData : 'https://tournax.com';
  }

  @override
  Widget build(BuildContext context) {
    final data = _resolveQrData();
    final style = layer.style;

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: EdgeInsets.all(style.padding > 0 ? style.padding : 8.0),
        decoration: BoxDecoration(
          color: Color(style.fillColorHex == 0x00000000 ? 0xFFFFFFFF : style.fillColorHex),
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: style.borderWidth > 0
              ? Border.all(color: Color(style.borderColorHex), width: style.borderWidth)
              : null,
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(style.textColorHex == 0xFFFFFFFF ? 0xFF000000 : style.textColorHex),
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(style.textColorHex == 0xFFFFFFFF ? 0xFF000000 : style.textColorHex),
          ),
        ),
      ),
    );
  }
}
