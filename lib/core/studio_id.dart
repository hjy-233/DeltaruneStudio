import 'package:uuid/uuid.dart';

final class StudioIds {
  StudioIds._();

  static const _uuid = Uuid();

  static String asset() => 'asset_${_uuid.v4()}';
  static String character() => 'char_${_uuid.v4()}';
  static String chain() => 'chain_${_uuid.v4()}';
  static String event() => 'event_${_uuid.v4()}';
  static String object() => 'obj_${_uuid.v4()}';
  static String scene() => 'scene_${_uuid.v4()}';
  static String trigger() => 'trigger_${_uuid.v4()}';
}
