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
    this.activeVideo,
    this.cameraFollowObjectId,
    this.cameraFocusTarget,
    this.followStates = const {},
    this.teleportedFollowerIds = const {},
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
  final VideoPlaybackState? activeVideo;
  final String? cameraFollowObjectId;
  final FocusTarget? cameraFocusTarget;
  final Map<String, CharacterFollowState> followStates;
  final Set<String> teleportedFollowerIds;

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
    VideoPlaybackState? activeVideo,
    String? cameraFollowObjectId,
    FocusTarget? cameraFocusTarget,
    Map<String, CharacterFollowState>? followStates,
    Set<String>? teleportedFollowerIds,
    bool clearEvent = false,
    bool clearDialogue = false,
    bool clearActiveMove = false,
    bool clearAudioEvents = false,
    bool clearActiveVideo = false,
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
      activeVideo: clearActiveVideo ? null : activeVideo ?? this.activeVideo,
      cameraFollowObjectId: cameraFollowObjectId ?? this.cameraFollowObjectId,
      cameraFocusTarget: clearCameraFocus
          ? null
          : cameraFocusTarget ?? this.cameraFocusTarget,
      followStates: followStates ?? this.followStates,
      teleportedFollowerIds:
          teleportedFollowerIds ?? this.teleportedFollowerIds,
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

final class CharacterFollowState {
  const CharacterFollowState({
    required this.leaderObjectId,
    required this.distance,
  });

  final String leaderObjectId;
  final double distance;
}

final class VideoPlaybackState {
  const VideoPlaybackState({
    required this.assetId,
    required this.fit,
    required this.localTime,
    required this.duration,
  });

  final String assetId;
  final VideoFitMode fit;
  final double localTime;
  final double duration;
}

final class DialogueBoxState {
  const DialogueBoxState({
    required this.text,
    required this.style,
    this.portraitAssetId,
    this.textSoundAssetId,
    this.visibleCharacters,
  });
  final String text;
  final DialogueStyle style;
  final String? portraitAssetId;
  final String? textSoundAssetId;
  final int? visibleCharacters;
}

final class RuntimeObject {
  const RuntimeObject({
    required this.source,
    required this.transform,
    required this.facing,
    this.expressionId,
    this.isMoving = false,
  });

  final SceneObject source;
  final Transform2D transform;
  final Direction facing;
  final String? expressionId;
  final bool isMoving;

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
    bool? isMoving,
  }) {
    return RuntimeObject(
      source: source,
      transform: transform ?? this.transform,
      facing: facing ?? this.facing,
      expressionId: expressionId ?? this.expressionId,
      isMoving: isMoving ?? this.isMoving,
    );
  }
}
