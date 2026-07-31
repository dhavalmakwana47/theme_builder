/// Enumerations for TournaX Visual Template Builder.
library;

/// Types of layers supported by the editor & renderer.
enum LayerType {
  text,
  image,
  svg,
  shape,
  container,
  row,
  column,
  stack,
  icon,
  qr,
  barcode,
  group,
  playerAvatar,
  teamLogo,
  rankBadge,
  prizeBadge,
  slotRow,
  playerCard,
  winnerBanner,
  tournamentHeader,
  customComponent;

  String get displayName {
    switch (this) {
      case LayerType.text:
        return 'Text';
      case LayerType.image:
        return 'Image';
      case LayerType.svg:
        return 'SVG Vector';
      case LayerType.shape:
        return 'Shape';
      case LayerType.container:
        return 'Container';
      case LayerType.row:
        return 'Row Layout';
      case LayerType.column:
        return 'Column Layout';
      case LayerType.stack:
        return 'Stack Layout';
      case LayerType.icon:
        return 'Icon';
      case LayerType.qr:
        return 'QR Code';
      case LayerType.barcode:
        return 'Barcode';
      case LayerType.group:
        return 'Group';
      case LayerType.playerAvatar:
        return 'Player Avatar';
      case LayerType.teamLogo:
        return 'Team Logo';
      case LayerType.rankBadge:
        return 'Rank Badge';
      case LayerType.prizeBadge:
        return 'Prize Badge';
      case LayerType.slotRow:
        return 'Slot Row';
      case LayerType.playerCard:
        return 'Player Card';
      case LayerType.winnerBanner:
        return 'Winner Banner';
      case LayerType.tournamentHeader:
        return 'Tournament Header';
      case LayerType.customComponent:
        return 'Custom Component';
    }
  }

  static LayerType fromDynamic(dynamic val, [LayerType defaultType = LayerType.text]) {
    if (val == null) return defaultType;
    if (val is int) {
      return val >= 0 && val < LayerType.values.length ? LayerType.values[val] : defaultType;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < LayerType.values.length ? LayerType.values[i] : defaultType;
    }
    final str = val.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < LayerType.values.length ? LayerType.values[parsedInt] : defaultType;
    }
    final normalized = str.replaceAll('_', '').replaceAll(' ', '').toLowerCase();
    for (final type in LayerType.values) {
      if (type.name.toLowerCase() == normalized ||
          type.name.replaceAll('_', '').toLowerCase() == normalized ||
          type.displayName.replaceAll(' ', '').toLowerCase() == normalized) {
        return type;
      }
    }
    return defaultType;
  }
}

/// Supported vector shape types.
enum ShapeType {
  rectangle,
  circle,
  roundedRectangle,
  triangle,
  polygon,
  line,
  divider;

  String get displayName {
    switch (this) {
      case ShapeType.rectangle:
        return 'Rectangle';
      case ShapeType.circle:
        return 'Circle';
      case ShapeType.roundedRectangle:
        return 'Rounded Rectangle';
      case ShapeType.triangle:
        return 'Triangle';
      case ShapeType.polygon:
        return 'Polygon';
      case ShapeType.line:
        return 'Line';
      case ShapeType.divider:
        return 'Divider';
    }
  }

  static ShapeType fromDynamic(dynamic val, [ShapeType defaultShape = ShapeType.rectangle]) {
    if (val == null) return defaultShape;
    if (val is int) {
      return val >= 0 && val < ShapeType.values.length ? ShapeType.values[val] : defaultShape;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < ShapeType.values.length ? ShapeType.values[i] : defaultShape;
    }
    final str = val.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < ShapeType.values.length ? ShapeType.values[parsedInt] : defaultShape;
    }
    final normalized = str.replaceAll('_', '').replaceAll(' ', '').toLowerCase();
    for (final shape in ShapeType.values) {
      if (shape.name.toLowerCase() == normalized ||
          shape.name.replaceAll('_', '').toLowerCase() == normalized ||
          shape.displayName.replaceAll(' ', '').toLowerCase() == normalized) {
        return shape;
      }
    }
    return defaultShape;
  }
}

/// Text transform rules.
enum TextTransformMode {
  none,
  uppercase,
  lowercase,
  capitalize;

  static TextTransformMode fromDynamic(dynamic val, [TextTransformMode defaultMode = TextTransformMode.none]) {
    if (val == null) return defaultMode;
    if (val is int) {
      return val >= 0 && val < TextTransformMode.values.length ? TextTransformMode.values[val] : defaultMode;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < TextTransformMode.values.length ? TextTransformMode.values[i] : defaultMode;
    }
    final str = val.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < TextTransformMode.values.length ? TextTransformMode.values[parsedInt] : defaultMode;
    }
    final normalized = str.toLowerCase();
    for (final mode in TextTransformMode.values) {
      if (mode.name.toLowerCase() == normalized) return mode;
    }
    return defaultMode;
  }
}

/// Image fit modes.
enum ImageFitMode {
  contain,
  cover,
  fill,
  fitWidth,
  fitHeight,
  none;

  static ImageFitMode fromDynamic(dynamic val, [ImageFitMode defaultMode = ImageFitMode.cover]) {
    if (val == null) return defaultMode;
    if (val is int) {
      return val >= 0 && val < ImageFitMode.values.length ? ImageFitMode.values[val] : defaultMode;
    }
    if (val is num) {
      final i = val.toInt();
      return i >= 0 && i < ImageFitMode.values.length ? ImageFitMode.values[i] : defaultMode;
    }
    final str = val.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return parsedInt >= 0 && parsedInt < ImageFitMode.values.length ? ImageFitMode.values[parsedInt] : defaultMode;
    }
    final normalized = str.replaceAll('_', '').toLowerCase();
    for (final mode in ImageFitMode.values) {
      if (mode.name.toLowerCase() == normalized || mode.name.replaceAll('_', '').toLowerCase() == normalized) {
        return mode;
      }
    }
    return defaultMode;
  }
}

/// Active tool in the editor.
enum EditorTool {
  select,
  hand,
  text,
  image,
  rectangle,
  circle,
  shape,
  qr,
  barcode,
  badge,
  eyedropper,
  zoom;
}

/// Template Category Types.
enum TemplateCategoryType {
  slotList,
  leaderboard;

  String get value {
    switch (this) {
      case TemplateCategoryType.slotList:
        return 'slot_list';
      case TemplateCategoryType.leaderboard:
        return 'leaderboard';
    }
  }

  String get displayName {
    switch (this) {
      case TemplateCategoryType.slotList:
        return 'Slot List';
      case TemplateCategoryType.leaderboard:
        return 'Leaderboard';
    }
  }

  static TemplateCategoryType fromDynamic(dynamic val, [TemplateCategoryType defaultType = TemplateCategoryType.slotList]) {
    if (val == null) return defaultType;
    final str = val.toString().trim().toLowerCase();
    if (str == 'leaderboard' || str == 'lederbaord') return TemplateCategoryType.leaderboard;
    if (str == 'slot_list' || str == 'slotlist' || str == 'slot list') return TemplateCategoryType.slotList;
    return defaultType;
  }
}
