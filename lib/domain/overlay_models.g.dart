// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overlay_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OverlayTextStyle _$OverlayTextStyleFromJson(Map<String, dynamic> json) =>
    _OverlayTextStyle(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24,
      color: json['color'] as String? ?? '#FFFFFFFF',
      alignment:
          $enumDecodeNullable(
            _$OverlayTextAlignmentEnumMap,
            json['alignment'],
          ) ??
          OverlayTextAlignment.left,
    );

Map<String, dynamic> _$OverlayTextStyleToJson(_OverlayTextStyle instance) =>
    <String, dynamic>{
      'fontSize': instance.fontSize,
      'color': instance.color,
      'alignment': _$OverlayTextAlignmentEnumMap[instance.alignment]!,
    };

const _$OverlayTextAlignmentEnumMap = {
  OverlayTextAlignment.left: 'left',
  OverlayTextAlignment.center: 'center',
  OverlayTextAlignment.right: 'right',
};
