import 'dart:io' as io;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';

abstract class ImageExportService {
  static Future<Uint8List?> capturePng({
    required GlobalKey repaintBoundaryKey,
    double pixelRatio = 2.0,
  }) async {
    final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      throw Exception('Canvas render boundary not found. Ensure canvas is loaded on screen.');
    }

    if (boundary.debugNeedsPaint) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to generate PNG bytes from canvas image');
    }
    return byteData.buffer.asUint8List();
  }

  static Future<String?> saveImageToFile({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (kIsWeb) {
      downloadBytesOnWeb(bytes, fileName);
      return fileName;
    }

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Rendered Image',
      fileName: fileName,
      type: FileType.image,
    );

    if (outputFile == null) {
      final dir = await getApplicationDocumentsDirectory();
      outputFile = '${dir.path}/$fileName';
    }

    final file = io.File(outputFile);
    await file.writeAsBytes(bytes);
    return outputFile;
  }
}
