import 'package:freezed_annotation/freezed_annotation.dart';
import 'overlay_models.dart';

part 'studio_models.freezed.dart';
part 'studio_models.g.dart';

enum AssetKind { background, character, audio, prop, dialoguePortrait, video }

enum Direction { up, down, left, right }

enum MovementMode { fourWay, eightWay, free }

enum FadeMode { in_, out }

enum DialogueStyle { regular, darkWorld }

enum VideoFitMode { contain }

enum AppLanguage { system, english, chinese }

enum CharacterLibraryScope { global, project }

enum EventChainTriggerMode { triggerPoint, always, scheduled }

@freezed
abstract class StudioProject with _$StudioProject {
  const factory StudioProject({
    @Default(4) int schemaVersion,
    required String id,
    required String name,
    required String currentSceneId,
    required List<Scene> scenes,
    required List<Character> characters,
    required List<AssetRef> assets,
    @Default(EditorLayout()) EditorLayout editorLayout,
    @Default(EditorSettings()) EditorSettings settings,
  }) = _StudioProject;

  factory StudioProject.fromJson(Map<String, dynamic> json) =>
      _$StudioProjectFromJson(json);
}

@freezed
abstract class EditorLayout with _$EditorLayout {
  const factory EditorLayout({
    @Default(220) double leftSidebarWidth,
    @Default(280) double rightSidebarWidth,
    @Default(300) double bottomPanelHeight,
    @Default(100) double timelinePixelsPerSecond,
    @Default(66) double timelineTrackHeight,
  }) = _EditorLayout;

  factory EditorLayout.fromJson(Map<String, dynamic> json) =>
      _$EditorLayoutFromJson(json);
}

@freezed
abstract class EditorSettings with _$EditorSettings {
  const factory EditorSettings({
    @Default(AppLanguage.system) AppLanguage language,
    @Default(true) bool englishDialogueTypewriterByWord,
    @Default(CharacterLibraryScope.global)
    CharacterLibraryScope characterLibraryScope,
  }) = _EditorSettings;

  factory EditorSettings.fromJson(Map<String, dynamic> json) =>
      _$EditorSettingsFromJson(json);
}

@freezed
abstract class AssetRef with _$AssetRef {
  const factory AssetRef({
    required String id,
    @JsonKey(unknownEnumValue: AssetKind.prop) required AssetKind kind,
    required String relativePath,
    required String originalName,
    String? dataUri,
  }) = _AssetRef;

  factory AssetRef.fromJson(Map<String, dynamic> json) =>
      _$AssetRefFromJson(json);
}

@freezed
abstract class Scene with _$Scene {
  const factory Scene({
    required String id,
    required String name,
    String? backgroundAssetId,
    required List<SceneObject> objects,
    required List<Trigger> triggers,
    required List<EventChain> eventChains,
    required List<InterestPoint> interestPoints,
    required CameraPolicy cameraPolicy,
  }) = _Scene;

  factory Scene.fromJson(Map<String, dynamic> json) => _$SceneFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
sealed class SceneObject with _$SceneObject {
  const SceneObject._();

  @FreezedUnionValue('characterInstance')
  const factory SceneObject.characterInstance({
    required String id,
    required String name,
    required String characterId,
    required Transform2D transform,
    required Direction facing,
    String? initialExpression,
    ActivityProfile? activity,
    @Default(false) bool locked,
  }) = CharacterInstanceObject;

  @FreezedUnionValue('prop')
  const factory SceneObject.prop({
    required String id,
    required String name,
    required String assetId,
    required Transform2D transform,
    @Default(false) bool interactable,
    @Default(false) bool locked,
  }) = PropSceneObject;

  @FreezedUnionValue('background')
  const factory SceneObject.background({
    required String id,
    required String name,
    required String assetId,
    required Transform2D transform,
    @Default(false) bool locked,
  }) = BackgroundObject;

  @FreezedUnionValue('triggerPoint')
  const factory SceneObject.triggerPoint({
    required String id,
    required String name,
    required String triggerId,
    required Transform2D transform,
    @Default(false) bool locked,
  }) = TriggerPointObject;

  @FreezedUnionValue('triggerArea')
  const factory SceneObject.triggerArea({
    required String id,
    required String name,
    required String triggerId,
    required Transform2D transform,
    @Default(false) bool locked,
  }) = TriggerAreaObject;

  String get objectId => map(
    characterInstance: (value) => value.id,
    prop: (value) => value.id,
    background: (value) => value.id,
    triggerPoint: (value) => value.id,
    triggerArea: (value) => value.id,
  );

  Transform2D get objectTransform => map(
    characterInstance: (value) => value.transform,
    prop: (value) => value.transform,
    background: (value) => value.transform,
    triggerPoint: (value) => value.transform,
    triggerArea: (value) => value.transform,
  );

  factory SceneObject.fromJson(Map<String, dynamic> json) =>
      _$SceneObjectFromJson(json);
}

@freezed
abstract class Transform2D with _$Transform2D {
  const factory Transform2D({
    required double x,
    required double y,
    @Default(48) double width,
    @Default(64) double height,
    @Default(1) double scale,
    @Default(0) double rotation,
  }) = _Transform2D;

  factory Transform2D.fromJson(Map<String, dynamic> json) =>
      _$Transform2DFromJson(json);
}

@freezed
abstract class Character with _$Character {
  const factory Character({
    required String id,
    required String name,
    required List<AnimationClip> animations,
    required List<CharacterExpression> expressions,
    required CharacterMovementProfile movement,
    @Default(Transform2D(x: 180, y: 180)) Transform2D defaultTransform,
    @Default(Direction.down) Direction defaultFacing,
    String? defaultExpressionId,
  }) = _Character;

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);
}

@freezed
abstract class AnimationClip with _$AnimationClip {
  const factory AnimationClip({
    required String id,
    required String name,
    required String assetId,
    Direction? direction,
    @Default(8) double framesPerSecond,
  }) = _AnimationClip;

  factory AnimationClip.fromJson(Map<String, dynamic> json) =>
      _$AnimationClipFromJson(json);
}

@freezed
abstract class CharacterExpression with _$CharacterExpression {
  const factory CharacterExpression({
    required String id,
    required String name,
    String? assetId,
    Direction? direction,
    @Default([]) List<String> assetIds,
    @Default(6) double framesPerSecond,
    @Default(true) bool loop,
  }) = _CharacterExpression;

  factory CharacterExpression.fromJson(Map<String, dynamic> json) =>
      _$CharacterExpressionFromJson(json);
}

@freezed
abstract class CharacterMovementProfile with _$CharacterMovementProfile {
  const factory CharacterMovementProfile({
    @Default(320) double defaultSpeed,
    @Default(16) double defaultShake,
  }) = _CharacterMovementProfile;

  factory CharacterMovementProfile.fromJson(Map<String, dynamic> json) =>
      _$CharacterMovementProfileFromJson(json);
}

@freezed
abstract class MovementPath with _$MovementPath {
  const factory MovementPath({
    required List<PathNode> nodes,
    @Default(320) double speed,
    @Default(0) double shake,
    @Default(MovementMode.fourWay) MovementMode mode,
  }) = _MovementPath;

  factory MovementPath.fromJson(Map<String, dynamic> json) =>
      _$MovementPathFromJson(json);
}

@freezed
abstract class PathNode with _$PathNode {
  const factory PathNode({
    required String id,
    @Default('Node') String name,
    required double x,
    required double y,
    double? waitSeconds,
    String? triggerId,
  }) = _PathNode;

  factory PathNode.fromJson(Map<String, dynamic> json) =>
      _$PathNodeFromJson(json);
}

@freezed
abstract class ActivityProfile with _$ActivityProfile {
  const factory ActivityProfile({
    required String zoneId,
    @Default(50) int level,
    @Default(0.5) double idleBias,
    @Default(0.5) double interestBias,
  }) = _ActivityProfile;

  factory ActivityProfile.fromJson(Map<String, dynamic> json) =>
      _$ActivityProfileFromJson(json);
}

@freezed
abstract class InterestPoint with _$InterestPoint {
  const factory InterestPoint({
    required String id,
    required String name,
    required String kind,
    required double x,
    required double y,
  }) = _InterestPoint;

  factory InterestPoint.fromJson(Map<String, dynamic> json) =>
      _$InterestPointFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
sealed class Trigger with _$Trigger {
  @FreezedUnionValue('area')
  const factory Trigger.area({
    required String id,
    required String name,
    required String eventChainId,
    String? linkedTriggerId,
  }) = AreaTrigger;

  @FreezedUnionValue('object')
  const factory Trigger.object({
    required String id,
    required String name,
    required String objectId,
    required String eventChainId,
    String? linkedTriggerId,
  }) = ObjectTrigger;

  @FreezedUnionValue('auto')
  const factory Trigger.auto({
    required String id,
    required String name,
    required String eventChainId,
    String? linkedTriggerId,
  }) = AutoTrigger;

  @FreezedUnionValue('moveComplete')
  const factory Trigger.moveComplete({
    required String id,
    required String name,
    required String targetObjectId,
    required String eventChainId,
    String? linkedTriggerId,
  }) = MoveCompleteTrigger;

  factory Trigger.fromJson(Map<String, dynamic> json) =>
      _$TriggerFromJson(json);
}

@freezed
abstract class EventChain with _$EventChain {
  const factory EventChain({
    required String id,
    required String name,
    @Default(EventChainTriggerMode.always) EventChainTriggerMode triggerMode,
    @Default(0) double startTime,
    required List<StudioEvent> events,
  }) = _EventChain;

  factory EventChain.fromJson(Map<String, dynamic> json) =>
      _$EventChainFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
sealed class StudioEvent with _$StudioEvent {
  const StudioEvent._();

  @FreezedUnionValue('character.move')
  const factory StudioEvent.characterMove({
    required String id,
    required String characterObjectId,
    required MovementPath path,
    @Default(0) double scheduleStart,
  }) = CharacterMoveEvent;

  @FreezedUnionValue('character.wait')
  const factory StudioEvent.characterWait({
    required String id,
    @Default(1) double duration,
    @Default(0) double scheduleStart,
  }) = CharacterWaitEvent;

  @FreezedUnionValue('character.changeExpression')
  const factory StudioEvent.characterChangeExpression({
    required String id,
    required String characterObjectId,
    required String expressionId,
    @Default(1) double duration,
    @Default(0) double scheduleStart,
  }) = CharacterChangeExpressionEvent;

  @FreezedUnionValue('character.startFollow')
  const factory StudioEvent.characterStartFollow({
    required String id,
    required String followerObjectId,
    required String leaderObjectId,
    @Default(48) double distance,
    @Default(0) double scheduleStart,
  }) = CharacterStartFollowEvent;

  @FreezedUnionValue('character.stopFollow')
  const factory StudioEvent.characterStopFollow({
    required String id,
    required String followerObjectId,
    @Default(0) double scheduleStart,
  }) = CharacterStopFollowEvent;

  @FreezedUnionValue('dialogue.say')
  const factory StudioEvent.dialogueSay({
    required String id,
    required String text,
    String? portraitAssetId,
    String? textSoundAssetId,
    @Default(DialogueStyle.regular) DialogueStyle style,
    @Default(2) double duration,
    @Default(0) double scheduleStart,
  }) = DialogueSayEvent;

  @FreezedUnionValue('camera.follow')
  const factory StudioEvent.cameraFollow({
    required String id,
    required String targetObjectId,
    @Default(0) double scheduleStart,
  }) = CameraFollowEvent;

  @FreezedUnionValue('camera.focus')
  const factory StudioEvent.cameraFocus({
    required String id,
    required FocusTarget target,
    @Default(0.5) double duration,
    @Default(0) double scheduleStart,
  }) = CameraFocusEvent;

  @FreezedUnionValue('scene.fade')
  const factory StudioEvent.sceneFade({
    required String id,
    required FadeMode mode,
    @Default(0.8) double duration,
    @Default(0) double scheduleStart,
  }) = SceneFadeEvent;

  @FreezedUnionValue('scene.change')
  const factory StudioEvent.sceneChange({
    required String id,
    required String sceneId,
    String? entryPointId,
    @Default(0) double scheduleStart,
  }) = SceneChangeEvent;

  @FreezedUnionValue('audio.playBgm')
  const factory StudioEvent.audioPlayBgm({
    required String id,
    required String assetId,
    @Default(0) double scheduleStart,
  }) = AudioPlayBgmEvent;

  @FreezedUnionValue('audio.playSound')
  const factory StudioEvent.audioPlaySound({
    required String id,
    required String assetId,
    @Default(0) double scheduleStart,
  }) = AudioPlaySoundEvent;

  @FreezedUnionValue('video.play')
  const factory StudioEvent.videoPlay({
    required String id,
    required String assetId,
    @Default(3) double duration,
    @Default(VideoFitMode.contain) VideoFitMode fit,
    @Default(0) double scheduleStart,
  }) = VideoPlayEvent;

  @FreezedUnionValue('overlay.show')
  const factory StudioEvent.overlayShow({
    required String id,
    @Default(OverlaySpace.camera) OverlaySpace space,
    @Default(OverlayContentKind.image) OverlayContentKind contentKind,
    String? assetId,
    String? text,
    @Default('#FFFFFFFF') String color,
    @Default(OverlayTextStyle()) OverlayTextStyle textStyle,
    @Default(OverlayAnchor.center) OverlayAnchor anchor,
    @Default(Transform2D(x: 0, y: 0, width: 160, height: 90))
    Transform2D transform,
    @Default(1) double opacity,
    @Default(0) double rotation,
    @Default(0) int zIndex,
    String? boundObjectId,
    @Default(0) double fadeIn,
    @Default(0) double fadeOut,
    @Default(2) double duration,
    @Default(3) double videoFallbackDuration,
    @Default(0) double scheduleStart,
  }) = OverlayShowEvent;

  String get eventId => map(
    characterMove: (value) => value.id,
    characterWait: (value) => value.id,
    characterChangeExpression: (value) => value.id,
    characterStartFollow: (value) => value.id,
    characterStopFollow: (value) => value.id,
    dialogueSay: (value) => value.id,
    cameraFollow: (value) => value.id,
    cameraFocus: (value) => value.id,
    sceneFade: (value) => value.id,
    sceneChange: (value) => value.id,
    audioPlayBgm: (value) => value.id,
    audioPlaySound: (value) => value.id,
    videoPlay: (value) => value.id,
    overlayShow: (value) => value.id,
  );

  double get eventScheduleStart => map(
    characterMove: (value) => value.scheduleStart,
    characterWait: (value) => value.scheduleStart,
    characterChangeExpression: (value) => value.scheduleStart,
    characterStartFollow: (value) => value.scheduleStart,
    characterStopFollow: (value) => value.scheduleStart,
    dialogueSay: (value) => value.scheduleStart,
    cameraFollow: (value) => value.scheduleStart,
    cameraFocus: (value) => value.scheduleStart,
    sceneFade: (value) => value.scheduleStart,
    sceneChange: (value) => value.scheduleStart,
    audioPlayBgm: (value) => value.scheduleStart,
    audioPlaySound: (value) => value.scheduleStart,
    videoPlay: (value) => value.scheduleStart,
    overlayShow: (value) => value.scheduleStart,
  );

  StudioEvent withScheduleStart(double startTime) => map(
    characterMove: (value) => value.copyWith(scheduleStart: startTime),
    characterWait: (value) => value.copyWith(scheduleStart: startTime),
    characterChangeExpression: (value) =>
        value.copyWith(scheduleStart: startTime),
    characterStartFollow: (value) => value.copyWith(scheduleStart: startTime),
    characterStopFollow: (value) => value.copyWith(scheduleStart: startTime),
    dialogueSay: (value) => value.copyWith(scheduleStart: startTime),
    cameraFollow: (value) => value.copyWith(scheduleStart: startTime),
    cameraFocus: (value) => value.copyWith(scheduleStart: startTime),
    sceneFade: (value) => value.copyWith(scheduleStart: startTime),
    sceneChange: (value) => value.copyWith(scheduleStart: startTime),
    audioPlayBgm: (value) => value.copyWith(scheduleStart: startTime),
    audioPlaySound: (value) => value.copyWith(scheduleStart: startTime),
    videoPlay: (value) => value.copyWith(scheduleStart: startTime),
    overlayShow: (value) => value.copyWith(scheduleStart: startTime),
  );

  factory StudioEvent.fromJson(Map<String, dynamic> json) =>
      _$StudioEventFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
sealed class CameraPolicy with _$CameraPolicy {
  @FreezedUnionValue('followPlayer')
  const factory CameraPolicy.followPlayer({required String playerObjectId}) =
      FollowPlayerCameraPolicy;

  @FreezedUnionValue('focus')
  const factory CameraPolicy.focus({required FocusTarget target}) =
      FocusCameraPolicy;

  factory CameraPolicy.fromJson(Map<String, dynamic> json) =>
      _$CameraPolicyFromJson(json);
}

@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.none)
sealed class FocusTarget with _$FocusTarget {
  @FreezedUnionValue('object')
  const factory FocusTarget.object({required String objectId}) =
      ObjectFocusTarget;

  @FreezedUnionValue('point')
  const factory FocusTarget.point({required double x, required double y}) =
      PointFocusTarget;

  factory FocusTarget.fromJson(Map<String, dynamic> json) =>
      _$FocusTargetFromJson(json);
}
