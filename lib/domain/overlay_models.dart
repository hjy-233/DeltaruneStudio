import 'package:freezed_annotation/freezed_annotation.dart';

part 'overlay_models.freezed.dart';
part 'overlay_models.g.dart';

enum OverlaySpace { camera, world, fullscreen }

enum OverlayContentKind { image, video, text, color }

enum OverlayAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

enum OverlayTextAlignment { left, center, right }

@freezed
abstract class OverlayTextStyle with _$OverlayTextStyle {
  const factory OverlayTextStyle({
    @Default(24) double fontSize,
    @Default('#FFFFFFFF') String color,
    @Default(OverlayTextAlignment.left) OverlayTextAlignment alignment,
  }) = _OverlayTextStyle;

  factory OverlayTextStyle.fromJson(Map<String, dynamic> json) =>
      _$OverlayTextStyleFromJson(json);
}
