import '../../domain/models/canvas_spec.dart';

class CanvasPresetItem {
  final String name;
  final double width;
  final double height;
  final String description;

  const CanvasPresetItem({
    required this.name,
    required this.width,
    required this.height,
    required this.description,
  });

  CanvasSpec toSpec() {
    return CanvasSpec(
      width: width,
      height: height,
      presetName: name,
    );
  }
}

abstract class CanvasPresets {
  static const List<CanvasPresetItem> presets = [
    CanvasPresetItem(
      name: 'Story (9:16)',
      width: 1080,
      height: 1920,
      description: '1080 x 1920 - Mobile Portrait / Instagram Story / Reels',
    ),
    CanvasPresetItem(
      name: 'Square (1:1)',
      width: 1080,
      height: 1080,
      description: '1080 x 1080 - Instagram Post / Tournament Announcement',
    ),
    CanvasPresetItem(
      name: 'Stream Overlay (16:9)',
      width: 1920,
      height: 1080,
      description: '1920 x 1080 - Full HD Stream / OBS / YouTube Overlay',
    ),
    CanvasPresetItem(
      name: 'Header Banner (3:1)',
      width: 1920,
      height: 640,
      description: '1920 x 640 - Twitter / Web Header',
    ),
    CanvasPresetItem(
      name: 'A4 Document',
      width: 1240,
      height: 1754,
      description: '1240 x 1754 - Print Rulebook / Bracket',
    ),
    CanvasPresetItem(
      name: 'A3 Poster',
      width: 1754,
      height: 2480,
      description: '1754 x 2480 - HD Tournament Wall Poster',
    ),
  ];
}
