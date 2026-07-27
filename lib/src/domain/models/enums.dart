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
}

/// Text transform rules.
enum TextTransformMode {
  none,
  uppercase,
  lowercase,
  capitalize;
}

/// Image fit modes.
enum ImageFitMode {
  contain,
  cover,
  fill,
  fitWidth,
  fitHeight,
  none;
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
