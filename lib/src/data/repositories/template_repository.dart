import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/layer_style.dart';
import '../../domain/models/canvas_spec.dart';
import '../../domain/models/enums.dart';

abstract class TemplateRepository {
  Future<List<TemplateModel>> getTemplates();
  Future<TemplateModel?> getTemplateById(String id);
  Future<void> saveTemplate(TemplateModel template);
  Future<void> deleteTemplate(String id);
  String exportToJson(TemplateModel template);
  TemplateModel importFromJson(String jsonStr);
  TemplateModel createSampleTemplate();
}

class TemplateRepositoryImpl implements TemplateRepository {
  final Dio dio;
  static const String _storageKey = 'tournax_saved_templates';

  TemplateRepositoryImpl({Dio? dioClient}) : dio = dioClient ?? Dio(BaseOptions(baseUrl: 'https://api.tournax.com/v1'));

  @override
  Future<List<TemplateModel>> getTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null && data.isNotEmpty) {
        final List<dynamic> list = jsonDecode(data);
        return list.map((e) => TemplateModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}

    // Fallback to sample template if none saved
    return [createSampleTemplate()];
  }

  @override
  Future<TemplateModel?> getTemplateById(String id) async {
    final templates = await getTemplates();
    return templates.firstWhere((t) => t.id == id, orElse: () => createSampleTemplate());
  }

  @override
  Future<void> saveTemplate(TemplateModel template) async {
    final templates = await getTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template.copyWith(updatedAt: DateTime.now().toIso8601String());
    } else {
      templates.add(template);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));

    // Async Laravel sync attempt (swallow network errors gracefully)
    try {
      await dio.post('/templates', data: template.toJson());
    } catch (_) {}
  }

  @override
  Future<void> deleteTemplate(String id) async {
    final templates = await getTemplates();
    templates.removeWhere((t) => t.id == id);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = templates.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));

    try {
      await dio.delete('/templates/$id');
    } catch (_) {}
  }

  @override
  String exportToJson(TemplateModel template) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(template.toJson());
  }

  @override
  TemplateModel importFromJson(String jsonStr) {
    final Map<String, dynamic> map = jsonDecode(jsonStr);
    return TemplateModel.fromJson(map);
  }

  @override
  TemplateModel createSampleTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();

    final backgroundLayer = LayerModel(
      id: uuid.v4(),
      name: 'Background Fill',
      type: LayerType.shape,
      shapeType: ShapeType.rectangle,
      x: 0,
      y: 0,
      width: 1080,
      height: 1920,
      isLocked: true,
      zIndex: 0,
      style: const LayerStyle(
        fillColorHex: 0xFF121214,
        isGradientFill: true,
        gradientColorsHex: [0xFF09090B, 0xFF18181B, 0xFF0F172A],
        gradientAngle: 135,
      ),
    );

    final headerLayer = LayerModel(
      id: uuid.v4(),
      name: 'Tournament Header',
      type: LayerType.tournamentHeader,
      x: 40,
      y: 80,
      width: 1000,
      height: 100,
      zIndex: 1,
    );

    final winnerBannerLayer = LayerModel(
      id: uuid.v4(),
      name: 'Winner Banner',
      type: LayerType.winnerBanner,
      x: 40,
      y: 220,
      width: 1000,
      height: 160,
      zIndex: 2,
    );

    final titleText = LayerModel(
      id: uuid.v4(),
      name: 'Title - GRAND FINALS',
      type: LayerType.text,
      text: 'GRAND FINALS 2026',
      x: 40,
      y: 420,
      width: 1000,
      height: 80,
      zIndex: 3,
      style: const LayerStyle(
        fontSize: 48,
        fontFamily: 'Montserrat',
        fontWeightValue: 900,
        textColorHex: 0xFFF59E0B,
        letterSpacing: 3,
        textAlign: TextAlign.center,
        isGradientFill: true,
        gradientColorsHex: [0xFFFBBF24, 0xFFF59E0B],
      ),
    );

    final slot1 = LayerModel(
      id: uuid.v4(),
      name: 'Slot Row #1',
      type: LayerType.slotRow,
      x: 40,
      y: 520,
      width: 1000,
      height: 70,
      zIndex: 4,
      variableKey: '{{team_name}}',
    );

    final slot2 = LayerModel(
      id: uuid.v4(),
      name: 'Slot Row #2',
      type: LayerType.slotRow,
      x: 40,
      y: 610,
      width: 1000,
      height: 70,
      zIndex: 5,
    );

    final slot3 = LayerModel(
      id: uuid.v4(),
      name: 'Slot Row #3',
      type: LayerType.slotRow,
      x: 40,
      y: 700,
      width: 1000,
      height: 70,
      zIndex: 6,
    );

    final prizeBadge = LayerModel(
      id: uuid.v4(),
      name: 'Prize Pool Badge',
      type: LayerType.prizeBadge,
      x: 340,
      y: 800,
      width: 400,
      height: 60,
      zIndex: 7,
    );

    final qrCodeLayer = LayerModel(
      id: uuid.v4(),
      name: 'Scan Stream QR',
      type: LayerType.qr,
      qrData: 'https://tournax.com/live/finals-2026',
      x: 415,
      y: 1650,
      width: 250,
      height: 200,
      zIndex: 8,
      style: const LayerStyle(
        fillColorHex: 0xFFFFFFFF,
        textColorHex: 0xFF09090B,
        borderRadius: 16,
      ),
    );

    return TemplateModel(
      id: uuid.v4(),
      name: 'Esports Championship Poster',
      description: 'Official TournaX 9:16 mobile story graphic template.',
      category: 'Tournament Overlay',
      version: 1,
      createdAt: now,
      updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080,
        height: 1920,
        presetName: 'Story (9:16)',
        backgroundColorHex: 0xFF09090B,
      ),
      layers: [
        backgroundLayer,
        headerLayer,
        winnerBannerLayer,
        titleText,
        slot1,
        slot2,
        slot3,
        prizeBadge,
        qrCodeLayer,
      ],
    );
  }
}
