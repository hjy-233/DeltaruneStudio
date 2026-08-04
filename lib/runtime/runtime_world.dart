import 'package:deltarune_studio/domain/studio_models.dart';

final class RuntimeWorld {
  const RuntimeWorld({
    required this.project,
    required this.scene,
    required this.objects,
    this.currentEventId,
    this.dialogue,
    this.fadeOpacity = 0,
    this.currentTime = 0,
    this.totalDuration = 0,
    this.activeMoveEventId,
    this.activeMoveProgress = 0,
    this.audioEventIds = const [],
    this.cameraFollowObjectId,
    this.cameraFocusTarget,
  });

  final StudioProject project;
  final Scene scene;
  final Map<String, RuntimeObject> objects;
  final String? currentEventId;
  final DialogueBoxState? dialogue;
  final double fadeOpacity;
  final double currentTime;
  final double totalDuration;
  final String? activeMoveEventId;
  final double activeMoveProgress;
  final List<String> audioEventIds;
  final String? cameraFollowObjectId;
  final FocusTarget? cameraFocusTarget;

  RuntimeWorld copyWith({
    StudioProject? project,
    Scene? scene,
    Map<String, RuntimeObject>? objects,
    String? currentEventId,
    DialogueBoxState? dialogue,
    double? fadeOpacity,
    double? currentTime,
    double? totalDuration,
    String? activeMoveEventId,
    double? activeMoveProgress,
    List<String>? audioEventIds,
    String? cameraFollowObjectId,
    FocusTarget? cameraFocusTarget,
    bool clearEvent = false,
    bool clearDialogue = false,
    bool clearActiveMove = false,
    bool clearAudioEvents = false,
    bool clearCameraFocus = false,
  }) {
    return RuntimeWorld(
      project: project ?? this.project,
      scene: scene ?? this.scene,
      objects: objects ?? this.objects,
      currentEventId: clearEvent ? null : currentEventId ?? this.currentEventId,
      dialogue: clearDialogue ? null : dialogue ?? this.dialogue,
      fadeOpacity: fadeOpacity ?? this.fadeOpacity,
      currentTime: currentTime ?? this.currentTime,
      totalDuration: totalDuration ?? this.totalDuration,
      activeMoveEventId: clearActiveMove
          ? null
          : activeMoveEventId ?? this.activeMoveEventId,
      activeMoveProgress: activeMoveProgress ?? this.activeMoveProgress,
      audioEventIds: clearAudioEvents
          ? const []
          : audioEventIds ?? this.audioEventIds,
      cameraFollowObjectId: cameraFollowObjectId ?? this.cameraFollowObjectId,
      cameraFocusTarget: clearCameraFocus
          ? null
          : cameraFocusTarget ?? this.cameraFocusTarget,
    );
  }

  static RuntimeWorld fromScene(StudioProject project, Scene scene) {
    final followObjectId = scene.cameraPolicy.maybeMap(
      followPlayer: (value) => value.playerObjectId,
      orElse: () => null,
    );
    final focusTarget = scene.cameraPolicy.maybeMap(
      focus: (value) => value.target,
      orElse: () => null,
    );
    return RuntimeWorld(
      project: project,
      scene: scene,
      cameraFollowObjectId: followObjectId,
      cameraFocusTarget: focusTarget,
      objects: {
        for (final object in scene.objects)
          object.objectId: RuntimeObject.fromSceneObject(object),
      },
    );
  }
}

final class DialogueBoxState {
  const DialogueBoxState({
    required this.speaker,
    required this.text,
    required this.style,
    this.portraitAssetId,
  });

  final String speaker;
  final String text;
  final DialogueStyle style;
  final String? portraitAssetId;
}

final class RuntimeObject {
  const RuntimeObject({
    required this.source,
    required this.transform,
    required this.facing,
    this.expressionId,
  });

  final SceneObject source;
  final Transform2D transform;
  final Direction facing;
  final String? expressionId;

  factory RuntimeObject.fromSceneObject(SceneObject source) {
    return RuntimeObject(
      source: source,
      transform: source.objectTransform,
      facing: source.maybeMap(
        characterInstance: (value) => value.facing,
        orElse: () => Direction.down,
      ),
      expressionId: source.maybeMap(
        characterInstance: (value) => value.initialExpression,
        orElse: () => null,
      ),
    );
  }

  RuntimeObject copyWith({
    Transform2D? transform,
    Direction? facing,
    String? expressionId,
  }) {
    return RuntimeObject(
      source: source,
      transform: transform ?? this.transform,
      facing: facing ?? this.facing,
      expressionId: expressionId ?? this.expressionId,
    );
  }
}
