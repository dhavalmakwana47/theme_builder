import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

abstract class ImageExportService {
  static Future<Uint8List?> capturePng({
    required GlobalKey repaintBoundaryKey,
    double pixelRatio = 2.0,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveImageToFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      // Pick save path
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Rendered Image',
        fileName: fileName,
        type: FileType.image,
      );

      if (outputFile == null) {
        final dir = await getApplicationDocumentsDirectory();
        outputFile = '${dir.path}/$fileName';
      }

      final file = File(outputFile);
      await file.writeAsBytes(bytes);
      return outputFile;
    } catch (_) {
      return null;
    }
  }
}
