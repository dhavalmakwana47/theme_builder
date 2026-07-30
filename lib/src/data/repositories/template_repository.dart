import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/template_model.dart';
import '../../domain/models/layer_model.dart';
import '../../domain/models/layer_style.dart';
import '../../domain/models/canvas_spec.dart';
import '../../domain/models/enums.dart';
import '../services/template_api_service.dart';

abstract class TemplateRepository {
  Future<PaginatedTemplatesResponse> getTemplates({
    int page = 1,
    int perPage = 20,
    String? search,
  });
  Future<TemplateModel?> getTemplateById(String id);
  Future<TemplateModel> saveTemplate(TemplateModel template, {String? thumbnailBase64});
  Future<void> deleteTemplate(String id);
  Future<TemplateModel> duplicateTemplate(String id);
  Future<TemplateModel> renameTemplate(String id, String newName);
  String exportToJson(TemplateModel template);
  TemplateModel importFromJson(String jsonStr);
  TemplateModel createSampleTemplate();
  TemplateModel create12SlotListTemplate();
}

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateApiService apiService;

  TemplateRepositoryImpl({TemplateApiService? apiService})
      : apiService = apiService ?? TemplateApiService();

  @override
  Future<PaginatedTemplatesResponse> getTemplates({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    try {
      return await apiService.fetchTemplates(
        page: page,
        perPage: perPage,
        search: search,
      );
    } catch (e) {
      final sampleList = [create12SlotListTemplate(), createSampleTemplate()];
      return PaginatedTemplatesResponse(
        templates: sampleList,
        currentPage: 1,
        perPage: perPage,
        total: sampleList.length,
        lastPage: 1,
      );
    }
  }

  @override
  Future<TemplateModel?> getTemplateById(String id) async {
    try {
      return await apiService.getTemplateById(id);
    } catch (_) {
      if (id == 'slot_list_12_preset') {
        return create12SlotListTemplate();
      }
      return createSampleTemplate();
    }
  }

  @override
  Future<TemplateModel> saveTemplate(TemplateModel template, {String? thumbnailBase64}) async {
    final bool isExisting = template.id.isNotEmpty &&
        !template.id.contains('-') &&
        int.tryParse(template.id) != null;

    if (isExisting) {
      return await apiService.updateTemplate(
        template.id,
        template,
        thumbnailBase64: thumbnailBase64,
      );
    } else {
      return await apiService.createTemplate(
        template,
        thumbnailBase64: thumbnailBase64,
      );
    }
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await apiService.deleteTemplate(id);
  }

  @override
  Future<TemplateModel> duplicateTemplate(String id) async {
    return await apiService.duplicateTemplate(id);
  }

  @override
  Future<TemplateModel> renameTemplate(String id, String newName) async {
    return await apiService.renameTemplate(id, newName);
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

    final titleText = LayerModel(
      id: uuid.v4(),
      name: 'Title - GRAND FINALS',
      type: LayerType.text,
      text: 'GRAND FINALS 2026',
      x: 40,
      y: 420,
      width: 1000,
      height: 80,
      zIndex: 1,
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

    return TemplateModel(
      id: '',
      name: 'New Custom Template',
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
        titleText,
      ],
    );
  }

  @override
  TemplateModel create12SlotListTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();

    final List<LayerModel> layers = [];
    int zIndex = 0;

    // 1. Transparent Backdrop Overlay
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Backdrop Overlay',
        type: LayerType.shape,
        shapeType: ShapeType.rectangle,
        x: 0,
        y: 0,
        width: 1080,
        height: 1350,
        isLocked: true,
        zIndex: zIndex++,
        style: const LayerStyle(
          fillColorHex: 0x00000000,
        ),
      ),
    );

    // 2. Week 00 Subtitle (Top Left White)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Week Subtitle',
        type: LayerType.text,
        text: 'Week 00',
        x: 60,
        y: 50,
        width: 160,
        height: 35,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 24,
          fontFamily: 'Montserrat',
          fontWeightValue: 700,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.left,
        ),
      ),
    );

    // 3. Organiser Name Title (Top Center White)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Organiser Name Title',
        type: LayerType.text,
        text: 'Organiser Name',
        x: 0,
        y: 80,
        width: 1080,
        height: 40,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 32,
          fontFamily: 'Montserrat',
          fontWeightValue: 800,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 4. Event Name Title (Fiery Orange)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Event Name Title',
        type: LayerType.text,
        text: 'Event Name',
        x: 0,
        y: 130,
        width: 1080,
        height: 55,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 44,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFFFF6B00,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 5. SCRIMS Title (Large White Sci-Fi Stencil)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'SCRIMS Title',
        type: LayerType.text,
        text: 'SCRIMS',
        x: 0,
        y: 185,
        width: 1080,
        height: 80,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 84,
          fontFamily: 'Cinzel',
          fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 6. SLOT LIST Sunset Orange Gradient Ribbon Shape
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'SLOT LIST Ribbon Shape',
        type: LayerType.shape,
        shapeType: ShapeType.roundedRectangle,
        x: 390,
        y: 280,
        width: 300,
        height: 44,
        zIndex: zIndex++,
        style: const LayerStyle(
          fillColorHex: 0xFFFFCC00,
          isGradientFill: true,
          gradientColorsHex: [0xFFFFCC00, 0xFFFF4500],
          borderRadius: 6,
        ),
      ),
    );

    // 7. SLOT LIST Ribbon Text (Dark Charcoal)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'SLOT LIST Ribbon Text',
        type: LayerType.text,
        text: 'SLOT LIST',
        x: 390,
        y: 290,
        width: 300,
        height: 30,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 18,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFF121214,
          textAlign: TextAlign.center,
          letterSpacing: 1.5,
        ),
      ),
    );

    // 8. Vertical Watermarks (Left & Right Rotated)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Left Vertical Watermark',
        type: LayerType.text,
        text: 'B A T T L E   B E G I N S',
        x: 40,
        y: 550,
        width: 300,
        height: 40,
        rotation: 270.0,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeightValue: 800,
          textColorHex: 0xFFA0A0A0,
          textAlign: TextAlign.center,
        ),
      ),
    );

    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Right Vertical Watermark',
        type: LayerType.text,
        text: 'B A T T L E   B E G I N S',
        x: 740,
        y: 550,
        width: 300,
        height: 40,
        rotation: 90.0,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeightValue: 800,
          textColorHex: 0xFFA0A0A0,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 9. 24 Glassmorphic Slot Rows (12 Rows x 2 Columns)
    final Map<String, String> globalVars = {};

    for (int row = 0; row < 12; row++) {
      final double rowY = 345.0 + (row * 46.0);

      // Full Row Metallic Glassmorphic Container
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Glass Row #${row + 1}',
          type: LayerType.shape,
          shapeType: ShapeType.roundedRectangle,
          x: 140,
          y: rowY,
          width: 800,
          height: 42,
          zIndex: zIndex++,
          style: const LayerStyle(
            fillColorHex: 0x33121214,
            borderColorHex: 0xFFFF8C00,
            borderWidth: 1.0,
            borderRadius: 6,
          ),
        ),
      );

      // --- Left Column Slot ---
      final int leftNum = row + 1;
      final String leftNumStr = leftNum < 10 ? '0$leftNum' : '$leftNum';
      globalVars['{{team_name_$leftNum}}'] = 'Team $leftNumStr';

      // Left Slot Number Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Left Slot Text #$leftNumStr',
          type: LayerType.text,
          text: leftNumStr,
          x: 155,
          y: rowY + 9,
          width: 40,
          height: 28,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeightValue: 900,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Left Vertical Divider Line |
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Left Divider #$leftNumStr',
          type: LayerType.text,
          text: '|',
          x: 205,
          y: rowY + 9,
          width: 10,
          height: 28,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            fontWeightValue: 700,
            textColorHex: 0xFFFF8C00,
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Left Team Name Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Left Team Name #$leftNumStr',
          type: LayerType.text,
          text: 'Team $leftNumStr',
          x: 225,
          y: rowY + 9,
          width: 250,
          height: 28,
          zIndex: zIndex++,
          variableKey: '{{team_name_$leftNum}}',
          style: const LayerStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.left,
          ),
        ),
      );

      // --- Center Divider Star ✶ ---
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Center Star #$leftNumStr',
          type: LayerType.text,
          text: '✶',
          x: 530,
          y: rowY + 9,
          width: 20,
          height: 28,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            fontWeightValue: 900,
            textColorHex: 0xFFFF8C00,
            textAlign: TextAlign.center,
          ),
        ),
      );

      // --- Right Column Slot ---
      final int rightNum = row + 13;
      final String rightNumStr = '$rightNum';
      globalVars['{{team_name_$rightNum}}'] = 'Team $rightNumStr';

      // Right Team Name Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Right Team Name #$rightNumStr',
          type: LayerType.text,
          text: 'Team $rightNumStr',
          x: 615,
          y: rowY + 9,
          width: 220,
          height: 28,
          zIndex: zIndex++,
          variableKey: '{{team_name_$rightNum}}',
          style: const LayerStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.right,
          ),
        ),
      );

      // Right Vertical Divider Line |
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Right Divider #$rightNumStr',
          type: LayerType.text,
          text: '|',
          x: 845,
          y: rowY + 9,
          width: 10,
          height: 28,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            fontWeightValue: 700,
            textColorHex: 0xFFFF8C00,
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Right Slot Number Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Right Slot Text #$rightNumStr',
          type: LayerType.text,
          text: rightNumStr,
          x: 865,
          y: rowY + 9,
          width: 40,
          height: 28,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
            fontWeightValue: 900,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 10. Footer Watermarks & Publisher Logos
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Footer Publisher Logos',
        type: LayerType.text,
        text: 'BATTLEGROUNDS MOBILE INDIA   KRAFTON',
        x: 80,
        y: 1250,
        width: 320,
        height: 40,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 15,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.left,
        ),
      ),
    );

    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'FOLLOW US Title',
        type: LayerType.text,
        text: 'FOLLOW US ON\nSOCIAL MEDIA',
        x: 440,
        y: 1250,
        width: 240,
        height: 40,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFFFF6B00,
          textAlign: TextAlign.center,
        ),
      ),
    );

    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Footer Divider Line',
        type: LayerType.text,
        text: '|',
        x: 685,
        y: 1250,
        width: 10,
        height: 40,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 24,
          fontFamily: 'Montserrat',
          fontWeightValue: 700,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.center,
        ),
      ),
    );

    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Footer Social Handles',
        type: LayerType.text,
        text: 'huw\nhje',
        x: 705,
        y: 1250,
        width: 180,
        height: 40,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 15,
          fontFamily: 'Montserrat',
          fontWeightValue: 800,
          textColorHex: 0xFFFFFFFF,
          textAlign: TextAlign.left,
        ),
      ),
    );

    return TemplateModel(
      id: '',
      name: '24-Slot Dark Sci-Fi Ember Inferno Graphic',
      description: 'Official 24-Slot Dark Sci-Fi Ember Inferno Tournament Graphic template.',
      category: 'Slot List',
      version: 1,
      createdAt: now,
      updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080,
        height: 1350,
        presetName: 'Poster (4:5)',
        backgroundColorHex: 0xFF0A0E17,
        backgroundImageUrl: 'http://10.151.118.115:8000/api/v1/template_assets/slot_list_background/dark_inferno_bg.png',
      ),
      layers: layers,
      globalVariables: globalVars,
    );
  }
}
