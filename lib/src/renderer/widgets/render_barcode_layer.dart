import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../domain/models/layer_model.dart';

class RenderBarcodeLayer extends StatelessWidget {
  final LayerModel layer;
  final Map<String, String> variables;

  const RenderBarcodeLayer({
    super.key,
    required this.layer,
    required this.variables,
  });

  String _resolveData() {
    if (layer.variableKey != null && layer.variableKey!.isNotEmpty) {
      final val = variables[layer.variableKey];
      if (val != null && val.isNotEmpty) return val;
    }
    return layer.barcodeData.isNotEmpty ? layer.barcodeData : '1234567890';
  }

  @override
  Widget build(BuildContext context) {
    final data = _resolveData();
    final style = layer.style;

    return SizedBox(
      width: layer.width,
      height: layer.height,
      child: Container(
        padding: EdgeInsets.all(style.padding > 0 ? style.padding : 6.0),
        decoration: BoxDecoration(
          color: Color(style.fillColorHex == 0x00000000 ? 0xFFFFFFFF : style.fillColorHex),
          borderRadius: BorderRadius.circular(style.borderRadius),
        ),
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: data,
          color: Color(style.textColorHex == 0xFFFFFFFF ? 0xFF000000 : style.textColorHex),
          drawText: true,
          style: TextStyle(
            fontSize: 10,
            color: Color(style.textColorHex == 0xFFFFFFFF ? 0xFF000000 : style.textColorHex),
          ),
        ),
      ),
    );
  }
}
