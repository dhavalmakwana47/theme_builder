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
    int perPage = 10,
    String? search,
    String? categoryType,
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
  TemplateModel create12TeamLeaderboardTemplate();
  TemplateModel create16TeamStandingsTemplate();
  TemplateModel create15TeamYellowStandingsTemplate();
  TemplateModel create12TeamGoldStandingsTemplate();
}

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateApiService apiService;

  TemplateRepositoryImpl({TemplateApiService? apiService})
      : apiService = apiService ?? TemplateApiService();

  @override
  Future<PaginatedTemplatesResponse> getTemplates({
    int page = 1,
    int perPage = 10,
    String? search,
    String? categoryType = 'slot_list',
  }) async {
    try {
      return await apiService.fetchTemplates(
        page: page,
        perPage: perPage,
        search: search,
        categoryType: categoryType,
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
          variableKey: '{{team_name}}',
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
          variableKey: '{{team_name}}',
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
      categoryType: 'slot_list',
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

  @override
  TemplateModel create12TeamLeaderboardTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();
    final List<LayerModel> layers = [];
    int zIndex = 0;

    // 1. Organiser Name
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Organiser Name Header',
        type: LayerType.text,
        text: 'Organiser Name',
        variableKey: '{{organizer_name}}',
        x: 340,
        y: 40,
        width: 400,
        height: 30,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 16,
          fontFamily: 'Montserrat',
          fontWeightValue: 700,
          textColorHex: 0xFF5C5261,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 2. Event Name Title
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Event Name Title',
        type: LayerType.text,
        text: 'Event Name',
        variableKey: '{{tournament_name}}',
        x: 240,
        y: 75,
        width: 600,
        height: 75,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 64,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFF140F19,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 3. Subtitle (Week 00 Day 00)
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Week Day Subtitle',
        type: LayerType.text,
        text: 'Week 00 Day 00',
        variableKey: '{{group_name}}',
        x: 340,
        y: 155,
        width: 400,
        height: 35,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 22,
          fontFamily: 'Montserrat',
          fontWeightValue: 800,
          textColorHex: 0xFF2A2030,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // 4. Column Headers
    final headers = [
      {'name': 'Header RANK', 'text': 'RANK', 'x': 80.0, 'w': 90.0, 'align': TextAlign.center},
      {'name': 'Header TEAM', 'text': 'TEAM', 'x': 310.0, 'w': 100.0, 'align': TextAlign.left},
      {'name': 'Header WIN', 'text': 'WIN', 'x': 540.0, 'w': 60.0, 'align': TextAlign.center},
      {'name': 'Header POINT', 'text': 'POINT', 'x': 635.0, 'w': 70.0, 'align': TextAlign.center},
      {'name': 'Header KILLS', 'text': 'KILLS', 'x': 735.0, 'w': 70.0, 'align': TextAlign.center},
      {'name': 'Header TOTAL', 'text': 'TOTAL', 'x': 835.0, 'w': 80.0, 'align': TextAlign.center},
    ];

    for (final h in headers) {
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: h['name'] as String,
          type: LayerType.text,
          text: h['text'] as String,
          x: h['x'] as double,
          y: 205,
          width: h['w'] as double,
          height: 25,
          zIndex: zIndex++,
          style: LayerStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFF140F19,
            textAlign: h['align'] as TextAlign,
          ),
        ),
      );
    }

    // 5. 12 Leaderboard Team Rows
    final teamsData = [
      {'rank': '01', 'name': 'Godl'},
      {'rank': '02', 'name': 'Soul'},
      {'rank': '03', 'name': 'TX'},
      {'rank': '04', 'name': 'FastX'},
      {'rank': '05', 'name': 'RNTX'},
      {'rank': '06', 'name': 'AX'},
      {'rank': '07', 'name': 'Apex'},
      {'rank': '08', 'name': 'RRQ'},
      {'rank': '09', 'name': 'DRX'},
      {'rank': '10', 'name': 'HORRA'},
      {'rank': '11', 'name': '4TR'},
      {'rank': '12', 'name': 'Global eSports'},
    ];

    for (int i = 0; i < teamsData.length; i++) {
      final double rowY = 232.0 + (i * 58.0);
      final t = teamsData[i];
      final rNum = t['rank']!;

      // Dark Container Background
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Row Bg #$rNum',
          type: LayerType.shape,
          shapeType: ShapeType.roundedRectangle,
          x: 60,
          y: rowY,
          width: 960,
          height: 48,
          zIndex: zIndex++,
          style: const LayerStyle(
            fillColorHex: 0xFF432A32,
            borderRadius: 4,
          ),
        ),
      );

      // Gold Bronze Accent Block
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Gold Accent #$rNum',
          type: LayerType.shape,
          shapeType: ShapeType.rectangle,
          x: 175,
          y: rowY,
          width: 55,
          height: 48,
          zIndex: zIndex++,
          style: const LayerStyle(
            fillColorHex: 0xFFC59A6D,
          ),
        ),
      );

      // Rank Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Rank #$rNum',
          type: LayerType.text,
          text: rNum,
          variableKey: '{{team_rank}}',
          x: 70,
          y: rowY + 11,
          width: 95,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 18,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );

      // Team Name Text
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Team Name #$rNum',
          type: LayerType.text,
          text: t['name']!,
          variableKey: '{{team_name}}',
          x: 240,
          y: rowY + 11,
          width: 270,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 17,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.left,
          ),
        ),
      );

      // Dividers
      final divPositions = [525.0, 620.0, 720.0, 820.0];
      for (int dIdx = 0; dIdx < divPositions.length; dIdx++) {
        layers.add(
          LayerModel(
            id: uuid.v4(),
            name: 'Divider $dIdx #$rNum',
            type: LayerType.text,
            text: '|',
            x: divPositions[dIdx],
            y: rowY + 11,
            width: 10,
            height: 26,
            zIndex: zIndex++,
            style: const LayerStyle(
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeightValue: 700,
              textColorHex: 0xFFC59A6D,
              textAlign: TextAlign.center,
            ),
          ),
        );
      }

      // Stat Columns
      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Win #$rNum',
          type: LayerType.text,
          text: '00',
          variableKey: '{{team_win}}',
          x: 545,
          y: rowY + 11,
          width: 55,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 17,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );

      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Points #$rNum',
          type: LayerType.text,
          text: '00',
          variableKey: '{{team_points}}',
          x: 640,
          y: rowY + 11,
          width: 60,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 17,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );

      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Kills #$rNum',
          type: LayerType.text,
          text: '00',
          variableKey: '{{team_kills}}',
          x: 740,
          y: rowY + 11,
          width: 60,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 17,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );

      layers.add(
        LayerModel(
          id: uuid.v4(),
          name: 'Total #$rNum',
          type: LayerType.text,
          text: '00',
          variableKey: '{{team_total_points}}',
          x: 840,
          y: rowY + 11,
          width: 70,
          height: 26,
          zIndex: zIndex++,
          style: const LayerStyle(
            fontSize: 17,
            fontFamily: 'Montserrat',
            fontWeightValue: 800,
            textColorHex: 0xFFFFFFFF,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 6. Footer
    layers.add(
      LayerModel(
        id: uuid.v4(),
        name: 'Footer Branding',
        type: LayerType.text,
        text: 'by\nPointcalc',
        x: 25,
        y: 990,
        width: 160,
        height: 50,
        zIndex: zIndex++,
        style: const LayerStyle(
          fontSize: 15,
          fontFamily: 'Montserrat',
          fontWeightValue: 900,
          textColorHex: 0xFF140F19,
          textAlign: TextAlign.left,
          lineHeight: 1.1,
        ),
      ),
    );

    return TemplateModel(
      id: '',
      name: '12-Team Pro Esports Leaderboard Graphic',
      description: 'Official 12-Team Professional Esports Leaderboard Graphic template.',
      category: 'Leaderboard',
      categoryType: 'leaderboard',
      version: 1,
      createdAt: now,
      updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080,
        height: 1080,
        presetName: 'Square (1:1)',
        backgroundColorHex: 0xFFECE8EC,
      ),
      layers: layers,
      globalVariables: const {
        '{{organizer_name}}': 'Organiser Name',
        '{{tournament_name}}': 'Event Name',
        '{{group_name}}': 'Week 00 Day 00',
        '{{team_name}}': 'Team Name',
        '{{team_rank}}': '01',
        '{{rank}}': '01',
        '{{team_win}}': '00',
        '{{team_matches}}': '00',
        '{{team_points}}': '00',
        '{{team_kills}}': '00',
        '{{team_total_points}}': '00',
      },
    );
  }

  @override
  TemplateModel create16TeamStandingsTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();
    final List<LayerModel> layers = [];
    int zIndex = 0;

    // 1. Light background
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Background Base', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 0, y: 0, width: 1080, height: 1080,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFFEEEDEE),
    ));

    // 2. Green bottom bar
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Green Bottom Bar', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 0, y: 1050, width: 1080, height: 30,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFF22CC22),
    ));

    // 3. Organiser Name (center top)
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Organiser Name', type: LayerType.text,
      text: 'Organiser Name', variableKey: '{{organizer_name}}',
      x: 240, y: 30, width: 600, height: 32, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 22, fontFamily: 'Montserrat', fontWeightValue: 500,
          textColorHex: 0xFF111111, textAlign: TextAlign.center),
    ));

    // 4. Week/Day label (top right)
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Week Day Label', type: LayerType.text,
      text: 'Week 00 Day 00', variableKey: '{{group_name}}',
      x: 820, y: 30, width: 240, height: 28, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeightValue: 600,
          textColorHex: 0xFF222222, textAlign: TextAlign.right),
    ));

    // 5. "OVERALL" large italic green
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Overall Title Line 1', type: LayerType.text,
      text: 'OVERALL', x: 30, y: 80, width: 700, height: 130, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 110, fontFamily: 'Montserrat', fontWeightValue: 900,
          isItalic: true, textColorHex: 0xFF22BB22, textAlign: TextAlign.left,
          textStrokeWidth: 2.5, textStrokeColorHex: 0xFF005500),
    ));

    // 6. "STANDINGS" large italic green
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Overall Title Line 2', type: LayerType.text,
      text: 'STANDINGS', x: 130, y: 200, width: 850, height: 130, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 110, fontFamily: 'Montserrat', fontWeightValue: 900,
          isItalic: true, textColorHex: 0xFF22BB22, textAlign: TextAlign.left,
          textStrokeWidth: 2.5, textStrokeColorHex: 0xFF005500),
    ));

    // 7. Event Name
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Event Name', type: LayerType.text,
      text: 'Event Name', variableKey: '{{tournament_name}}',
      x: 20, y: 335, width: 500, height: 50, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 36, fontFamily: 'Montserrat', fontWeightValue: 800,
          textColorHex: 0xFF111111, textAlign: TextAlign.left),
    ));

    // 8. Column Headers
    final leftHeaders = [
      {'text': '#', 'x': 22.0, 'w': 45.0, 'align': TextAlign.center},
      {'text': 'TEAM NAME', 'x': 75.0, 'w': 160.0, 'align': TextAlign.left},
      {'text': 'WIN', 'x': 245.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'P.P', 'x': 308.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'K.P', 'x': 370.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'T.P', 'x': 430.0, 'w': 55.0, 'align': TextAlign.center},
    ];
    final rightHeaders = [
      {'text': '#', 'x': 555.0, 'w': 45.0, 'align': TextAlign.center},
      {'text': 'TEAM NAME', 'x': 607.0, 'w': 160.0, 'align': TextAlign.left},
      {'text': 'WIN', 'x': 778.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'P.P', 'x': 840.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'K.P', 'x': 900.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'T.P', 'x': 958.0, 'w': 55.0, 'align': TextAlign.center},
    ];
    for (final h in [...leftHeaders, ...rightHeaders]) {
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Header ${h['text']}', type: LayerType.text,
        text: h['text'] as String, x: h['x'] as double, y: 395,
        width: h['w'] as double, height: 28, isLocked: true, zIndex: zIndex++,
        style: LayerStyle(fontSize: 14, fontFamily: 'Montserrat', fontWeightValue: 800,
            isItalic: true, textColorHex: 0xFF111111, textAlign: h['align'] as TextAlign),
      ));
    }

    // 9. Team rows (left: 01-13, right: 14-26 — 13 rows each side)
    final teams = [
      {'rank': '01', 'name': 'Godl'},         {'rank': '02', 'name': 'Soul'},
      {'rank': '03', 'name': 'TX'},            {'rank': '04', 'name': 'FastX'},
      {'rank': '05', 'name': 'RNTX'},          {'rank': '06', 'name': 'AX'},
      {'rank': '07', 'name': 'Apex'},          {'rank': '08', 'name': 'RRQ'},
      {'rank': '09', 'name': 'DRX'},           {'rank': '10', 'name': 'HORRA'},
      {'rank': '11', 'name': '4TR'},           {'rank': '12', 'name': 'Global eSports'},
      {'rank': '13', 'name': 'Wild Franks'},   {'rank': '14', 'name': 'OG'},
      {'rank': '15', 'name': 'True Tippers'},  {'rank': '16', 'name': 'Team Forever'},
      {'rank': '17', 'name': 'Phantom'},       {'rank': '18', 'name': 'Blind'},
      {'rank': '19', 'name': 'XO'},            {'rank': '20', 'name': 'Velocity'},
      {'rank': '21', 'name': 'Reckoning'},     {'rank': '22', 'name': 'Synergy'},
      {'rank': '23', 'name': 'Nova'},          {'rank': '24', 'name': 'Reborn'},
      {'rank': '25', 'name': 'Rage'},          {'rank': '26', 'name': 'Blaze'},
    ];
    const rowH = 42.0;
    const startY = 430.0;

    void addRow(int idx, Map<String,String> t, bool isRight) {
      final rowY = startY + idx * rowH;
      final rNum = t['rank']!;
      final bgCol = idx % 2 == 0 ? 0xFF3A3A3A : 0xFF484848;
      final prefix = isRight ? 'R' : 'L';
      final bgX = isRight ? 550.0 : 18.0;
      final bgW = isRight ? 505.0 : 478.0;
      final offsets = isRight
          ? [555.0, 607.0, 778.0, 840.0, 900.0, 958.0]
          : [22.0, 75.0, 245.0, 308.0, 370.0, 430.0];

      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix Row Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: bgX, y: rowY, width: bgW, height: rowH - 2,
        zIndex: zIndex++,
        style: LayerStyle(fillColorHex: bgCol, opacity: 0.85),
      ));
      // Rank: no variableKey so static text shows correctly per row
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix Rank #$rNum', type: LayerType.text,
        text: rNum,
        x: offsets[0], y: rowY + 8, width: 45, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFEEEEEE, textAlign: TextAlign.left),
      ));
      // Team Name: no variableKey so each row shows its own hardcoded team name
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix Team #$rNum', type: LayerType.text,
        text: t['name']!,
        x: offsets[1], y: rowY + 8, width: 160, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 600,
            isItalic: true, textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
      ));
      // Stats: keep variableKey so tournament app replaces them dynamically
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix Win #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_win}}',
        x: offsets[2], y: rowY + 8, width: 55, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFEEEEEE, textAlign: TextAlign.center),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix PP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_points}}',
        x: offsets[3], y: rowY + 8, width: 55, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFEEEEEE, textAlign: TextAlign.center),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix KP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_kills}}',
        x: offsets[4], y: rowY + 8, width: 55, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFEEEEEE, textAlign: TextAlign.center),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: '$prefix TP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_total_points}}',
        x: offsets[5], y: rowY + 8, width: 55, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFEEEEEE, textAlign: TextAlign.center),
      ));
    }

    // Left: 01–13 (rows 0–12), Right: 14–26 (rows 0–12 — same Y positions mirror left)
    for (int i = 0; i < 13; i++) addRow(i, teams[i], false);
    for (int i = 0; i < 13; i++) addRow(i, teams[13 + i], true);


    // 10. Footer
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer BY', type: LayerType.text,
      text: 'BY', x: 22, y: 1005, width: 60, height: 20, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 14, fontFamily: 'Montserrat', fontWeightValue: 600,
          textColorHex: 0xFF222222, textAlign: TextAlign.left),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer POINTCALC', type: LayerType.text,
      text: 'POINTCALC', x: 22, y: 1022, width: 200, height: 28, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 22, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFF111111, textAlign: TextAlign.left),
    ));

    return TemplateModel(
      id: '', name: '26-Team Overall Standings Graphic',
      description: 'Official 26-Team Overall Standings two-column leaderboard template (13 per column).',
      category: 'Leaderboard', categoryType: 'leaderboard',
      version: 1, createdAt: now, updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080, height: 1080, presetName: 'Square (1:1)',
        backgroundColorHex: 0xFFEEEDEE,
      ),
      layers: layers,
      globalVariables: const {
        '{{organizer_name}}': 'Organiser Name',
        '{{tournament_name}}': 'Event Name',
        '{{group_name}}': 'Week 00 Day 00',
        '{{team_name}}': 'Team Name',
        '{{team_rank}}': '01',
        '{{team_win}}': '00',
        '{{team_points}}': '00',
        '{{team_kills}}': '00',
        '{{team_total_points}}': '00',
      },
    );
  }

  @override
  TemplateModel create15TeamYellowStandingsTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();
    final List<LayerModel> layers = [];
    int zIndex = 0;

    // 1. Dark Base Background
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Dark Base Background', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 0, y: 0, width: 1080, height: 1350,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFF0E0E10),
    ));

    // 2. OVERALL Header Text (White)
    layers.add(LayerModel(
      id: uuid.v4(), name: 'OVERALL Header Text', type: LayerType.text,
      text: 'OVERALL', x: 500, y: 45, width: 520, height: 65, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 60, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.right),
    ));

    // 3. STANDINGS Header Text (Yellow)
    layers.add(LayerModel(
      id: uuid.v4(), name: 'STANDINGS Header Text', type: LayerType.text,
      text: 'STANDINGS', x: 350, y: 100, width: 670, height: 85, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 74, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFCC00, textAlign: TextAlign.right),
    ));

    // 4. Event Name
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Event Name', type: LayerType.text,
      text: 'Event Name', variableKey: '{{tournament_name}}',
      x: 60, y: 160, width: 500, height: 65, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 52, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));

    // 5. Column Headers Border Lines
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Header Top Border Line', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 60, y: 236, width: 960, height: 3,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFFFFCC00),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Header Bottom Border Line', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 60, y: 275, width: 960, height: 3,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFFFFCC00),
    ));

    // Header Column Labels
    final headers = [
      {'text': 'RANK', 'x': 60.0, 'w': 65.0, 'align': TextAlign.center},
      {'text': 'TEAM NAME', 'x': 155.0, 'w': 310.0, 'align': TextAlign.left},
      {'text': 'WWCD', 'x': 490.0, 'w': 100.0, 'align': TextAlign.center},
      {'text': 'PLACE PTS', 'x': 610.0, 'w': 120.0, 'align': TextAlign.center},
      {'text': 'KILL PTS', 'x': 750.0, 'w': 120.0, 'align': TextAlign.center},
      {'text': 'TOTAL PTS', 'x': 890.0, 'w': 130.0, 'align': TextAlign.center},
    ];
    for (final h in headers) {
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Header ${h['text']}', type: LayerType.text,
        text: h['text'] as String, x: h['x'] as double, y: 244,
        width: h['w'] as double, height: 26, isLocked: true, zIndex: zIndex++,
        style: LayerStyle(fontSize: 15, fontFamily: 'Montserrat', fontWeightValue: 800,
            textColorHex: 0xFFFFCC00, textAlign: h['align'] as TextAlign),
      ));
    }

    // 6. 15 Team Rows
    final teams = [
      {'rank': '01', 'name': 'Godl'}, {'rank': '02', 'name': 'Soul'},
      {'rank': '03', 'name': 'TX'}, {'rank': '04', 'name': 'FastX'},
      {'rank': '05', 'name': 'RNTX'}, {'rank': '06', 'name': 'AX'},
      {'rank': '07', 'name': 'Apex'}, {'rank': '08', 'name': 'RRQ'},
      {'rank': '09', 'name': 'DRX'}, {'rank': '10', 'name': 'HORRA'},
      {'rank': '11', 'name': '4TR'}, {'rank': '12', 'name': 'Global eSports'},
      {'rank': '13', 'name': 'Wild Franks'}, {'rank': '14', 'name': 'OG'},
      {'rank': '15', 'name': 'True Tippers'},
    ];

    const rowH = 58.0;
    const startY = 290.0;

    for (int i = 0; i < teams.length; i++) {
      final t = teams[i];
      final rowY = startY + (i * rowH);
      final rNum = t['rank']!;

      // Rank Box (Yellow)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Rank Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 60, y: rowY, width: 65, height: 50,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFCC00),
      ));
      // Rank Text (Black)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Rank Text #$rNum', type: LayerType.text,
        text: rNum, x: 60, y: rowY + 10, width: 65, height: 30, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 22, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));

      // Team Box (Dark with Yellow Border)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Team Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 135, y: rowY, width: 345, height: 50,
        zIndex: zIndex++,
        style: const LayerStyle(fillColorHex: 0xFF1B1B1E, strokeColorHex: 0xFFFFCC00, strokeWidth: 2.0),
      ));
      // Team Text (White)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Team Text #$rNum', type: LayerType.text,
        text: t['name']!, x: 155, y: rowY + 11, width: 310, height: 28, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 700,
            textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
      ));

      // Stats Bg (Yellow)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Stats Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 490, y: rowY, width: 530, height: 50,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFCC00),
      ));

      // WWCD
      layers.add(LayerModel(
        id: uuid.v4(), name: 'WWCD #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_win}}',
        x: 490, y: rowY + 11, width: 100, height: 28, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));
      // Place Pts
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Place Pts #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_points}}',
        x: 610, y: rowY + 11, width: 120, height: 28, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));
      // Kill Pts
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Kill Pts #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_kills}}',
        x: 750, y: rowY + 11, width: 120, height: 28, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));
      // Total Pts
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Total Pts #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_total_points}}',
        x: 890, y: rowY + 11, width: 130, height: 28, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));
    }

    // 7. Footer
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer By Label', type: LayerType.text,
      text: 'By', x: 60, y: 1265, width: 150, height: 18, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 14, fontFamily: 'Montserrat', fontWeightValue: 500,
          textColorHex: 0xFFAAAAAA, textAlign: TextAlign.left),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer Pointcalc Label', type: LayerType.text,
      text: 'Pointcalc', x: 60, y: 1285, width: 200, height: 30, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 22, fontFamily: 'Montserrat', fontWeightValue: 800,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));

    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer PRESENTED BY', type: LayerType.text,
      text: 'PRESENTED BY', x: 380, y: 1265, width: 320, height: 18, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 13, fontFamily: 'Montserrat', fontWeightValue: 700,
          textColorHex: 0xFFFFCC00, textAlign: TextAlign.center),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer Organiser Name', type: LayerType.text,
      text: 'Organiser Name', variableKey: '{{organizer_name}}',
      x: 340, y: 1285, width: 400, height: 32, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 26, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
    ));

    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer Week Day Label', type: LayerType.text,
      text: 'Week 00 Day 00', variableKey: '{{group_name}}',
      x: 780, y: 1285, width: 240, height: 28, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeightValue: 700,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.right),
    ));

    return TemplateModel(
      id: '', name: '15-Team Yellow Pro Overall Standings Graphic',
      description: 'Official 15-Team Yellow & Dark Pro Overall Standings Leaderboard graphic.',
      category: 'Leaderboard', categoryType: 'leaderboard',
      version: 1, createdAt: now, updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080, height: 1350, presetName: 'Portrait (4:5)',
        backgroundColorHex: 0xFF0E0E10,
      ),
      layers: layers,
      globalVariables: const {
        '{{organizer_name}}': 'Organiser Name',
        '{{tournament_name}}': 'Event Name',
        '{{group_name}}': 'Week 00 Day 00',
        '{{team_name}}': 'Team Name',
        '{{team_rank}}': '01',
        '{{rank}}': '01',
        '{{team_win}}': '00',
        '{{team_matches}}': '00',
        '{{team_points}}': '00',
        '{{team_kills}}': '00',
        '{{team_total_points}}': '00',
      },
    );
  }

  @override
  TemplateModel create12TeamGoldStandingsTemplate() {
    const uuid = Uuid();
    final now = DateTime.now().toIso8601String();
    final List<LayerModel> layers = [];
    int zIndex = 0;

    // 1. Dark Amber Base Background
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Backdrop Base', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 0, y: 0, width: 1080, height: 1080,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFF140F0B),
    ));

    // 2. Top Right Week Day Label
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Week Day Label', type: LayerType.text,
      text: 'Week 00 Day 00', variableKey: '{{group_name}}',
      x: 800, y: 60, width: 230, height: 30, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 700,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.right),
    ));

    // 3. Event Name Title
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Event Name Title', type: LayerType.text,
      text: 'Event Name', variableKey: '{{tournament_name}}',
      x: 140, y: 180, width: 800, height: 80, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 72, fontFamily: 'Montserrat', fontWeightValue: 900,
          isItalic: true, textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
    ));

    // 4. Header Yellow Bar
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Header Yellow Bar', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 175, y: 285, width: 730, height: 42,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFFF5A623),
    ));

    final headers = [
      {'text': '#', 'x': 175.0, 'w': 55.0, 'align': TextAlign.center},
      {'text': 'TEAM NAME', 'x': 245.0, 'w': 275.0, 'align': TextAlign.left},
      {'text': 'MP', 'x': 525.0, 'w': 65.0, 'align': TextAlign.center},
      {'text': 'CD', 'x': 595.0, 'w': 65.0, 'align': TextAlign.center},
      {'text': 'PP', 'x': 665.0, 'w': 65.0, 'align': TextAlign.center},
      {'text': 'KP', 'x': 735.0, 'w': 65.0, 'align': TextAlign.center},
      {'text': 'TP', 'x': 805.0, 'w': 85.0, 'align': TextAlign.center},
    ];
    for (final h in headers) {
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Header ${h['text']}', type: LayerType.text,
        text: h['text'] as String, x: h['x'] as double, y: 293,
        width: h['w'] as double, height: 26, isLocked: true, zIndex: zIndex++,
        style: LayerStyle(fontSize: 16, fontFamily: 'Montserrat', fontWeightValue: 900,
            textColorHex: 0xFF000000, textAlign: h['align'] as TextAlign),
      ));
    }

    // 5. 12 Team Rows
    final teams = [
      {'rank': '01', 'name': 'Godl'}, {'rank': '02', 'name': 'Soul'},
      {'rank': '03', 'name': 'TX'}, {'rank': '04', 'name': 'FastX'},
      {'rank': '05', 'name': 'RNTX'}, {'rank': '06', 'name': 'AX'},
      {'rank': '07', 'name': 'Apex'}, {'rank': '08', 'name': 'RRQ'},
      {'rank': '09', 'name': 'DRX'}, {'rank': '10', 'name': 'HORRA'},
      {'rank': '11', 'name': '4TR'}, {'rank': '12', 'name': 'Global eSports'},
    ];

    const startY = 335.0;
    const rowH = 48.0;

    for (int i = 0; i < teams.length; i++) {
      final t = teams[i];
      final rowY = startY + (i * rowH);
      final rNum = t['rank']!;

      // Rank Box
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Rank Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 175, y: rowY, width: 55, height: 44,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFFFFF),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Rank Text #$rNum', type: LayerType.text,
        text: rNum, x: 175, y: rowY + 8, width: 55, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));

      // Team Box
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Team Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 235, y: rowY, width: 280, height: 44,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFFFFF),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Team Text #$rNum', type: LayerType.text,
        text: t['name']!, x: 250, y: rowY + 8, width: 250, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 18, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFF000000, textAlign: TextAlign.left),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Team Underline #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 235, y: rowY + 41, width: 280, height: 3,
        isLocked: true, zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFF5A623),
      ));

      // Stats Section
      layers.add(LayerModel(
        id: uuid.v4(), name: 'Stats Bg #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 520, y: rowY, width: 385, height: 44,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFF45484E),
      ));

      // MP
      layers.add(LayerModel(
        id: uuid.v4(), name: 'MP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_matches}}',
        x: 525, y: rowY + 8, width: 65, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 17, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
      ));

      // CD (White Box)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'CD Box #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 595, y: rowY + 4, width: 60, height: 36,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFFFFF),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: 'CD #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_win}}',
        x: 595, y: rowY + 8, width: 60, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 17, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));

      // PP
      layers.add(LayerModel(
        id: uuid.v4(), name: 'PP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_points}}',
        x: 665, y: rowY + 8, width: 65, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 17, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
      ));

      // KP
      layers.add(LayerModel(
        id: uuid.v4(), name: 'KP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_kills}}',
        x: 735, y: rowY + 8, width: 65, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 17, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
      ));

      // TP (White Box)
      layers.add(LayerModel(
        id: uuid.v4(), name: 'TP Box #$rNum', type: LayerType.shape,
        shapeType: ShapeType.rectangle, x: 805, y: rowY + 4, width: 80, height: 36,
        zIndex: zIndex++, style: const LayerStyle(fillColorHex: 0xFFFFFFFF),
      ));
      layers.add(LayerModel(
        id: uuid.v4(), name: 'TP #$rNum', type: LayerType.text,
        text: '00', variableKey: '{{team_total_points}}',
        x: 805, y: rowY + 8, width: 80, height: 26, zIndex: zIndex++,
        style: const LayerStyle(fontSize: 17, fontFamily: 'Montserrat', fontWeightValue: 700,
            isItalic: true, textColorHex: 0xFF000000, textAlign: TextAlign.center),
      ));
    }

    // 6. Bottom Table Gold Line
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Bottom Table Gold Line', type: LayerType.shape,
      shapeType: ShapeType.rectangle, x: 175, y: 918, width: 730, height: 5,
      isLocked: true, zIndex: zIndex++,
      style: const LayerStyle(fillColorHex: 0xFFF5A623),
    ));

    // 7. Footer
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer by Label', type: LayerType.text,
      text: 'by', x: 30, y: 955, width: 120, height: 18, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 14, fontFamily: 'Montserrat', fontWeightValue: 500,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer Pointcalc Label', type: LayerType.text,
      text: 'Pointcalc', x: 30, y: 972, width: 180, height: 28, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 20, fontFamily: 'Montserrat', fontWeightValue: 800,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));

    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer Organiser Name', type: LayerType.text,
      text: 'Organiser Name', variableKey: '{{organizer_name}}',
      x: 340, y: 970, width: 400, height: 32, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 24, fontFamily: 'Montserrat', fontWeightValue: 800,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.center),
    ));

    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer OVERALL Label', type: LayerType.text,
      text: 'OVERALL', x: 890, y: 962, width: 140, height: 18, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 13, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));
    layers.add(LayerModel(
      id: uuid.v4(), name: 'Footer STANDING Label', type: LayerType.text,
      text: 'STANDING', x: 890, y: 978, width: 140, height: 18, zIndex: zIndex++,
      style: const LayerStyle(fontSize: 13, fontFamily: 'Montserrat', fontWeightValue: 900,
          textColorHex: 0xFFFFFFFF, textAlign: TextAlign.left),
    ));

    return TemplateModel(
      id: '', name: '12-Team Gold Overall Standings Graphic',
      description: 'Official 12-Team Gold & Dark Overall Standings Leaderboard template (1080 x 1080).',
      category: 'Leaderboard', categoryType: 'leaderboard',
      version: 1, createdAt: now, updatedAt: now,
      canvasSpec: const CanvasSpec(
        width: 1080, height: 1080, presetName: 'Square (1:1)',
        backgroundColorHex: 0xFF140F0B,
      ),
      layers: layers,
      globalVariables: const {
        '{{organizer_name}}': 'Organiser Name',
        '{{tournament_name}}': 'Event Name',
        '{{group_name}}': 'Week 00 Day 00',
        '{{team_name}}': 'Team Name',
        '{{team_rank}}': '01',
        '{{rank}}': '01',
        '{{team_win}}': '00',
        '{{team_matches}}': '00',
        '{{team_points}}': '00',
        '{{team_kills}}': '00',
        '{{team_total_points}}': '00',
      },
    );
  }
}


