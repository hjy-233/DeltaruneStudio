import 'dart:async';
import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/domain/overlay_models.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_audio_player.dart';
import 'package:deltarune_studio/runtime/movement_path_geometry.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'timeline_plan_builders.dart';
part 'timeline_trigger_tools.dart';
part 'preview_runtime_types.dart';

final previewControllerProvider =
    StateNotifierProvider<PreviewController, PreviewState>((ref) {
      return PreviewController(ref);
    });

final class PreviewController extends StateNotifier<PreviewState> {
  PreviewController(this._ref) : super(const PreviewState.stopped());

  final Ref _ref;
  Timer? _timer;
  TimelinePlan? _plan;
  final PreviewAudioPlayer _audioPlayer = PreviewAudioPlayer();
  final Set<String> _playedAudioEvents = {};
  int _lastDialogueVisibleCharacters = 0;
  String? _lastDialogueEventId;

  void play(
    StudioReady editorState, {
    bool fromStart = false,
    bool cleanPreview = false,
  }) {
    final plan = _planFor(editorState);
    final startTime = fromStart ? 0.0 : state.world?.currentTime ?? 0;
    _plan = plan;
    _timer?.cancel();
    _resetAudioEventTracking(plan, startTime);
    if (fromStart) {
      unawaited(_audioPlayer.stopAll());
    }
    final startWorld = plan.evaluate(startTime);
    _primeDialogueTypeSound(startWorld);
    state = PreviewState.playing(world: startWorld, cleanPreview: cleanPreview);
    _playAudioForWorld(editorState, startWorld);
    final playbackClock = Stopwatch()..start();
    var lastElapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final world = state.world;
      if (world == null) {
        return;
      }
      final elapsed = playbackClock.elapsed;
      final delta = elapsed - lastElapsed;
      lastElapsed = elapsed;
      final nextTime = (world.currentTime + delta.inMicroseconds / 1000000)
          .clamp(0, plan.duration)
          .toDouble();
      _playAudioBetween(editorState, plan, world.currentTime, nextTime);
      final nextWorld = plan.evaluate(nextTime);
      _syncDialogueTypeSound(editorState, world, nextWorld);
      _playAudioForWorld(editorState, nextWorld);
      if (cleanPreview && nextWorld.activeVideo != null) {
        _timer?.cancel();
        state = PreviewState.playing(
          world: nextWorld,
          cleanPreview: cleanPreview,
        );
        return;
      }
      if (nextTime >= plan.duration) {
        _timer?.cancel();
        unawaited(_audioPlayer.stopAll());
        _playedAudioEvents.clear();
        state = const PreviewState.stopped();
      } else {
        state = PreviewState.playing(
          world: nextWorld,
          cleanPreview: cleanPreview,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    unawaited(_audioPlayer.stopAll());
    final world = state.world;
    if (world != null) {
      state = PreviewState.paused(
        world: world,
        cleanPreview: state.cleanPreview,
      );
    }
  }

  void seek(StudioReady editorState, double time) {
    final plan = _planFor(editorState);
    _plan = plan;
    _timer?.cancel();
    unawaited(_audioPlayer.stopAll());
    _resetAudioEventTracking(plan, time);
    state = PreviewState.paused(
      world: plan.evaluate(time.clamp(0, plan.duration).toDouble()),
      cleanPreview: false,
    );
  }

  void stop() {
    _timer?.cancel();
    unawaited(_audioPlayer.stopAll());
    _playedAudioEvents.clear();
    state = const PreviewState.stopped();
  }

  void previewAudioAsset(
    StudioReady editorState,
    String assetId, {
    bool bgm = false,
  }) {
    if (assetId.isEmpty) {
      return;
    }
    final event = bgm
        ? StudioEvent.audioPlayBgm(id: 'preview_audio', assetId: assetId)
        : StudioEvent.audioPlaySound(id: 'preview_audio', assetId: assetId);
    unawaited(_audioPlayer.playEvent(editorState, event));
  }

  void previewAudioAssetId(StudioReady editorState, String assetId) {
    final builtIns = _ref.read(builtInAssetLibraryProvider).valueOrNull;
    unawaited(_audioPlayer.playAssetId(editorState, builtIns, assetId));
  }

  void completeActiveVideo(StudioReady editorState) {
    final world = state.world;
    final plan = _plan ?? _planFor(editorState);
    if (world?.activeVideo == null || world?.currentEventId == null) {
      return;
    }
    final span = plan.spanForEventAt(world!.currentEventId!, world.currentTime);
    if (span == null) {
      stop();
      return;
    }
    final resumeTime = (span.end + 0.001).clamp(0, plan.duration).toDouble();
    if (resumeTime >= plan.duration) {
      stop();
      return;
    }
    state = PreviewState.playing(
      world: plan.evaluate(resumeTime),
      cleanPreview: state.cleanPreview,
    );
    play(editorState, cleanPreview: state.cleanPreview);
  }

  TimelinePlan _planFor(StudioReady editorState) {
    return TimelinePlan(
      project: editorState.project,
      scene: editorState.currentScene,
      chain: editorState.activeChain,
    );
  }

  void _resetAudioEventTracking(TimelinePlan plan, double startTime) {
    _playedAudioEvents
      ..clear()
      ..addAll(
        plan.audioCues
            .where((cue) => cue.time < startTime)
            .map((cue) => cue.event.eventId),
      );
    _lastDialogueVisibleCharacters = 0;
    _lastDialogueEventId = null;
  }

  void _syncDialogueTypeSound(
    StudioReady editorState,
    RuntimeWorld? previous,
    RuntimeWorld current,
  ) {
    final dialogue = current.dialogue;
    final eventId = current.currentEventId;
    if (dialogue == null ||
        eventId == null ||
        (dialogue.expiresAt != null &&
            current.currentTime >= dialogue.expiresAt!)) {
      _lastDialogueVisibleCharacters = 0;
      _lastDialogueEventId = null;
      return;
    }
    final soundAssetId = dialogue.textSoundAssetId;
    if (soundAssetId == null || soundAssetId.isEmpty) {
      _lastDialogueVisibleCharacters = dialogue.visibleCharacters ?? 0;
      _lastDialogueEventId = eventId;
      return;
    }
    final previousCount = _lastDialogueEventId == eventId
        ? _lastDialogueVisibleCharacters
        : previous?.dialogue?.visibleCharacters ?? 0;
    final currentCount = dialogue.visibleCharacters ?? 0;
    if (currentCount > previousCount) {
      final builtIns = _ref.read(builtInAssetLibraryProvider).valueOrNull;
      final addedUnits = usesWordTypewriter(editorState.project, dialogue.text)
          ? 1
          : currentCount - previousCount;
      for (var index = 0; index < addedUnits; index += 1) {
        unawaited(
          _audioPlayer.playAssetId(editorState, builtIns, soundAssetId),
        );
      }
    }
    _lastDialogueVisibleCharacters = currentCount;
    _lastDialogueEventId = eventId;
  }

  void _primeDialogueTypeSound(RuntimeWorld world) {
    final dialogue = world.dialogue;
    if (dialogue == null ||
        world.currentEventId == null ||
        (dialogue.expiresAt != null &&
            world.currentTime >= dialogue.expiresAt!)) {
      _lastDialogueVisibleCharacters = 0;
      _lastDialogueEventId = null;
      return;
    }
    _lastDialogueVisibleCharacters = dialogue.visibleCharacters ?? 0;
    _lastDialogueEventId = world.currentEventId;
  }

  void _playAudioBetween(
    StudioReady editorState,
    TimelinePlan plan,
    double from,
    double to,
  ) {
    for (final cue in plan.audioCues) {
      if (cue.time > from && cue.time <= to) {
        _playAudioEvent(editorState, cue.event);
      }
    }
  }

  void _playAudioForWorld(StudioReady editorState, RuntimeWorld world) {
    for (final eventId in world.audioEventIds) {
      final event = _eventById(world.scene, eventId);
      if (event != null) {
        _playAudioEvent(editorState, event);
      }
    }
    final eventId = world.currentEventId;
    if (eventId == null) {
      return;
    }
    final event = _eventById(world.scene, eventId);
    if (event != null) {
      _playAudioEvent(editorState, event);
    }
  }

  StudioEvent? _eventById(Scene scene, String eventId) {
    for (final chain in scene.eventChains) {
      for (final event in chain.events) {
        if (event.eventId == eventId) {
          return event;
        }
      }
    }
    return null;
  }

  void _playAudioEvent(StudioReady editorState, StudioEvent event) {
    if (event is! AudioPlayBgmEvent && event is! AudioPlaySoundEvent) {
      return;
    }
    if (!_playedAudioEvents.add(event.eventId)) {
      return;
    }
    unawaited(_audioPlayer.playEvent(editorState, event));
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }
}

final class TimelinePlan {
  static const doorTransitionDuration = 0.3;

  TimelinePlan({
    required this.project,
    required this.scene,
    required this.chain,
  }) {
    tracks = _buildSceneTracks(scene);
    spans = _buildRuntimeSpans(tracks);
    audioCues = _buildSceneAudioCues(scene);
    dialogueTypeCues = _buildSceneDialogueTypeCues(project, scene);
    duration = spans.fold<double>(
      0,
      (value, span) => math.max(value, span.end),
    );
  }

  final StudioProject project;
  final Scene scene;
  final EventChain? chain;
  late final List<TimelineSpan> spans;
  late final List<TimelineChainTrack> tracks;
  late final List<TimelineAudioCue> audioCues;
  late final List<TimelineDialogueTypeCue> dialogueTypeCues;
  late final double duration;

  TimelineSpan? spanForEventAt(String eventId, double time) {
    for (final span in spans) {
      if (span.event.eventId == eventId &&
          time >= span.start &&
          time <= span.end) {
        return span;
      }
    }
    return null;
  }

  RuntimeWorld evaluate(double time) {
    var world = _initialWorld().copyWith(
      currentTime: time,
      totalDuration: duration,
      clearDialogue: true,
      clearEvent: true,
      clearActiveMove: true,
      clearAudioEvents: true,
      clearActiveVideo: true,
      clearOverlays: true,
      teleportedFollowerIds: const {},
    );
    if (spans.isEmpty) {
      return world;
    }
    for (final span in spans) {
      if (time < span.start) {
        break;
      }
      if (time >= span.end && span.event is CharacterChangeExpressionEvent) {
        continue;
      }
      final localTime = (time - span.start).clamp(0, span.duration).toDouble();
      world = _applyEvent(
        world,
        span.event,
        localTime,
        span.duration,
        const {},
      );
      if (time >= span.end) {
        world = _clearFinishedSpan(world, span);
      }
    }
    return world.copyWith(currentTime: time, totalDuration: duration);
  }

  RuntimeWorld _clearFinishedSpan(RuntimeWorld world, TimelineSpan span) {
    final event = span.event;
    if (event is DialogueSayEvent) {
      return world.copyWith(clearDialogue: true);
    }
    if (event is VideoPlayEvent) {
      return world.copyWith(clearActiveVideo: true);
    }
    if (event is OverlayShowEvent) {
      final overlays = {...world.overlays}..remove(event.id);
      return world.copyWith(overlays: overlays);
    }
    if (event is CharacterMoveEvent && world.activeMoveEventId == event.id) {
      return _setMoving(
        world.copyWith(clearActiveMove: true),
        event.characterObjectId,
        false,
      );
    }
    return world;
  }

  RuntimeWorld _initialWorld() {
    var world = RuntimeWorld.fromScene(project, scene);
    for (final span in spans) {
      final event = span.event;
      if (event is CharacterMoveEvent && event.path.nodes.isNotEmpty) {
        final first = event.path.nodes.first;
        world = _updateObject(world, event.characterObjectId, (object) {
          return object.copyWith(
            transform: object.transform.copyWith(x: first.x, y: first.y),
          );
        });
        break;
      }
    }
    return world;
  }

  RuntimeWorld _applyEvent(
    RuntimeWorld world,
    StudioEvent event,
    double localTime,
    double eventDuration,
    Set<String> stack,
  ) {
    return event.map(
      characterMove: (value) => _applyMove(world, value, localTime, stack),
      characterWait: (_) => world.copyWith(currentEventId: event.eventId),
      characterChangeExpression: (value) {
        return _updateObject(world, value.characterObjectId, (object) {
          return object.copyWith(
            expressionId: value.expressionId,
            expressionOverrideActive: true,
            isMoving: false,
          );
        }).copyWith(currentEventId: value.id);
      },
      characterStartFollow: (value) => world.copyWith(
        currentEventId: value.id,
        followStates: {
          ...world.followStates,
          value.followerObjectId: CharacterFollowState(
            leaderObjectId: value.leaderObjectId,
            distance: value.distance,
          ),
        },
      ),
      characterStopFollow: (value) {
        final states = {...world.followStates}..remove(value.followerObjectId);
        return world.copyWith(currentEventId: value.id, followStates: states);
      },
      dialogueSay: (value) => world.copyWith(
        currentEventId: value.id,
        dialogue: DialogueBoxState(
          text: value.text,
          style: value.style,
          portraitAssetId: value.portraitAssetId,
          textSoundAssetId: value.textSoundAssetId,
          visibleCharacters: _typewriterCharacters(
            project,
            value.text,
            localTime,
          ),
          expiresAt: world.currentTime + math.max(0, eventDuration - localTime),
        ),
      ),
      videoPlay: (value) => world.copyWith(
        currentEventId: value.id,
        activeVideo: VideoPlaybackState(
          assetId: value.assetId,
          fit: value.fit,
          localTime: localTime,
          duration: eventDuration,
        ),
      ),
      overlayShow: (value) {
        final fadeInProgress = value.fadeIn <= 0
            ? 1.0
            : (localTime / value.fadeIn).clamp(0.0, 1.0);
        final remaining = eventDuration - localTime;
        final fadeOutProgress = value.fadeOut <= 0
            ? 1.0
            : (remaining / value.fadeOut).clamp(0.0, 1.0);
        final transform = _overlayTransform(world, value);
        return world.copyWith(
          currentEventId: value.id,
          overlays: {
            ...world.overlays,
            value.id: RuntimeOverlay(
              event: value,
              localTime: localTime,
              duration: eventDuration,
              opacity: value.opacity * fadeInProgress * fadeOutProgress,
              transform: transform,
            ),
          },
        );
      },
      cameraFollow: (value) => world.copyWith(
        currentEventId: value.id,
        cameraFollowObjectId: value.targetObjectId,
        clearCameraFocus: true,
      ),
      cameraFocus: (value) => world.copyWith(
        currentEventId: value.id,
        cameraFocusTarget: value.target,
      ),
      sceneFade: (value) {
        final progress = eventDuration <= 0 ? 1.0 : localTime / eventDuration;
        return world.copyWith(
          currentEventId: value.id,
          fadeOpacity: value.mode == FadeMode.out ? progress : 1 - progress,
        );
      },
      sceneChange: (value) => world.copyWith(currentEventId: value.id),
      audioPlayBgm: (value) => world.copyWith(
        currentEventId: value.id,
        audioEventIds: [...world.audioEventIds, value.id],
      ),
      audioPlaySound: (value) => world.copyWith(
        currentEventId: value.id,
        audioEventIds: [...world.audioEventIds, value.id],
      ),
    );
  }

  Transform2D _overlayTransform(RuntimeWorld world, OverlayShowEvent event) {
    if (event.boundObjectId == null || event.space != OverlaySpace.world) {
      return event.transform;
    }
    final bound = world.objects[event.boundObjectId!];
    if (bound == null) {
      return event.transform;
    }
    return event.transform.copyWith(
      x: bound.transform.x + event.transform.x,
      y: bound.transform.y + event.transform.y,
    );
  }

  RuntimeWorld _applyMove(
    RuntimeWorld world,
    CharacterMoveEvent event,
    double localTime,
    Set<String> stack,
  ) {
    final nodes = event.path.nodes;
    if (nodes.isEmpty) {
      return world.copyWith(currentEventId: event.id);
    }
    var elapsed = 0.0;
    var current = world;
    var startX = nodes.first.x;
    var startY = nodes.first.y;
    var lastX = startX;
    var lastY = startY;
    var pathDistance = 0.0;
    var followerPath = event.path;
    DoorDestination? finalDoorDestination;
    if (nodes.length == 1) {
      return _placeObject(current, event, startX, startY, Direction.down);
    }
    for (var index = 0; index < nodes.length - 1; index += 1) {
      final target = movementTarget(
        startX,
        startY,
        nodes[index + 1],
        event.path.mode,
      );
      final segmentDuration = _segmentDuration(
        startX,
        startY,
        target.x,
        target.y,
        event.path.speed,
      );
      if (localTime <= elapsed + segmentDuration) {
        final segmentT = segmentDuration <= 0
            ? 1.0
            : (localTime - elapsed) / segmentDuration;
        final dx = target.x - startX;
        final dy = target.y - startY;
        final segmentDistance = math.sqrt(dx * dx + dy * dy);
        return _placeObject(
          current,
          event,
          startX + dx * segmentT,
          startY + dy * segmentT,
          movementDirection(dx, dy, event.path.mode, index),
          progress: (index + segmentT) / (nodes.length - 1),
          pathDistance: pathDistance + segmentDistance * segmentT,
          followerPath: followerPath,
          followerProgress: followerPath == event.path
              ? (index + segmentT) / (nodes.length - 1)
              : segmentT,
        );
      }
      elapsed += segmentDuration;
      pathDistance += _distance(startX, startY, target.x, target.y);
      lastX = target.x;
      lastY = target.y;
      current = _placeObject(
        current,
        event,
        target.x,
        target.y,
        movementDirection(
          target.x - startX,
          target.y - startY,
          event.path.mode,
          index,
        ),
        progress: (index + 1) / (nodes.length - 1),
        pathDistance: pathDistance,
        followerPath: followerPath,
        followerProgress: followerPath == event.path
            ? (index + 1) / (nodes.length - 1)
            : 1,
      );
      startX = target.x;
      startY = target.y;
      final end = nodes[index + 1];
      final wait = end.waitSeconds ?? 0;
      if (localTime <= elapsed + wait) {
        return _setMoving(
          current,
          event.characterObjectId,
          false,
        ).copyWith(currentEventId: event.id);
      }
      elapsed += wait;
      final touchedTriggerId =
          end.triggerId ?? triggerAtPoint(scene, target.x, target.y);
      final linkedId = linkedTriggerId(scene, touchedTriggerId);
      final destination = triggerObjectPosition(scene, linkedId);
      if (destination != null) {
        if (localTime <= elapsed + doorTransitionDuration) {
          return _applyDoorTransition(
            current,
            event,
            destination,
            localTime - elapsed,
          );
        }
        current = _placeObject(
          current,
          event,
          destination.x,
          destination.y,
          current.objects[event.characterObjectId]?.facing ?? Direction.down,
          progress: (index + 1) / (nodes.length - 1),
          pathDistance: pathDistance,
        ).copyWith(fadeOpacity: 0);
        current = _teleportFollowers(
          current,
          event.characterObjectId,
          destination,
        );
        if (index == nodes.length - 2) {
          finalDoorDestination = destination;
        }
        startX = destination.x;
        startY = destination.y;
        lastX = destination.x;
        lastY = destination.y;
        elapsed += doorTransitionDuration;
        pathDistance = 0;
        followerPath = MovementPath(
          nodes: [
            PathNode(
              id: '${event.id}_teleport_$index',
              x: destination.x,
              y: destination.y,
            ),
            ...nodes.skip(index + 2),
          ],
          speed: event.path.speed,
          shake: event.path.shake,
        );
        current = current.copyWith(teleportedFollowerIds: const {});
      }
      final triggered = triggerChain(scene, touchedTriggerId);
      if (triggered != null && !stack.contains(triggered.id)) {
        current = _setMoving(current, event.characterObjectId, false);
        final nestedDuration = _chainDuration(scene, triggered, stack);
        if (localTime <= elapsed + nestedDuration) {
          return _evaluateNested(
            current,
            triggered,
            localTime - elapsed,
            stack,
          );
        }
        current = _evaluateNested(current, triggered, nestedDuration, stack);
        elapsed += nestedDuration;
        final object = current.objects[event.characterObjectId];
        if (object != null) {
          lastX = object.transform.x;
          lastY = object.transform.y;
          startX = lastX;
          startY = lastY;
        }
      }
    }
    final currentObject = current.objects[event.characterObjectId];
    if (currentObject != null) {
      lastX = currentObject.transform.x;
      lastY = currentObject.transform.y;
    }
    var finished = _placeObject(
      current,
      event,
      lastX,
      lastY,
      current.objects[event.characterObjectId]?.facing ?? Direction.down,
      progress: 1,
      pathDistance: pathDistance,
      followerPath: followerPath,
      followerProgress: followerPath == event.path ? 1 : 1,
      isMoving: false,
    ).copyWith(clearActiveMove: true);
    if (finalDoorDestination != null) {
      finished = _teleportFollowers(
        finished,
        event.characterObjectId,
        finalDoorDestination,
      );
    }
    return finished;
  }

  RuntimeWorld _applyDoorTransition(
    RuntimeWorld world,
    CharacterMoveEvent event,
    DoorDestination destination,
    double localTime,
  ) {
    final half = doorTransitionDuration / 2;
    final progress = (localTime / doorTransitionDuration)
        .clamp(0, 1)
        .toDouble();
    if (localTime < half) {
      return world.copyWith(
        currentEventId: event.id,
        fadeOpacity: progress * 2,
        activeMoveEventId: event.id,
      );
    }
    var appeared = _placeObject(
      world,
      event,
      destination.x,
      destination.y,
      world.objects[event.characterObjectId]?.facing ?? Direction.down,
    );
    appeared = _teleportFollowers(
      appeared,
      event.characterObjectId,
      destination,
    );
    return appeared.copyWith(
      currentEventId: event.id,
      fadeOpacity: (1 - ((localTime - half) / half)).clamp(0, 1).toDouble(),
      activeMoveEventId: event.id,
    );
  }

  RuntimeWorld _evaluateNested(
    RuntimeWorld base,
    EventChain chain,
    double time,
    Set<String> stack,
  ) {
    var world = base;
    final activeStack = {...stack, chain.id};
    final spans = _buildSpans(scene, chain, stack);
    for (final span in spans) {
      if (time < span.start) {
        break;
      }
      if (time >= span.end && span.event is CharacterChangeExpressionEvent) {
        continue;
      }
      world = _applyEvent(
        world,
        span.event,
        (time - span.start).clamp(0, span.duration),
        span.duration,
        activeStack,
      );
      if (time >= span.end) {
        world = _clearFinishedSpan(world, span);
      }
      if (time <= span.end) {
        break;
      }
    }
    return world;
  }

  RuntimeWorld _placeObject(
    RuntimeWorld world,
    CharacterMoveEvent event,
    double x,
    double y,
    Direction facing, {
    double progress = 0,
    double? pathDistance,
    MovementPath? followerPath,
    double? followerProgress,
    bool isMoving = true,
  }) {
    final placed =
        _updateObject(world, event.characterObjectId, (object) {
          return object.copyWith(
            facing: facing,
            transform: object.transform.copyWith(x: x, y: y),
            isMoving: isMoving,
            movementPoseAssetId: _movementPoseAssetId(
              object,
              facing,
              isMoving,
              world.currentTime,
            ),
          );
        }).copyWith(
          currentEventId: event.id,
          activeMoveEventId: event.id,
          activeMoveProgress: progress,
        );
    return _applyFollowersFromMove(
      placed,
      event,
      followerPath ?? event.path,
      followerProgress ?? progress,
      pathDistance,
    );
  }

  RuntimeWorld _setMoving(RuntimeWorld world, String objectId, bool isMoving) {
    return _updateObject(world, objectId, (object) {
      return object.copyWith(
        isMoving: isMoving,
        movementPoseAssetId: isMoving
            ? object.movementPoseAssetId
            : _movementPoseAssetId(
                object,
                object.facing,
                false,
                world.currentTime,
              ),
      );
    });
  }

  RuntimeWorld _teleportFollowers(
    RuntimeWorld world,
    String leaderObjectId,
    DoorDestination destination,
  ) {
    var current = world;
    for (final entry in world.followStates.entries) {
      if (entry.value.leaderObjectId != leaderObjectId) {
        continue;
      }
      current = _updateObject(current, entry.key, (object) {
        return object.copyWith(
          transform: object.transform.copyWith(
            x: destination.x,
            y: destination.y,
          ),
          isMoving: false,
        );
      });
      current = current.copyWith(
        teleportedFollowerIds: {...current.teleportedFollowerIds, entry.key},
      );
    }
    return current;
  }

  RuntimeWorld _applyFollowersFromMove(
    RuntimeWorld world,
    CharacterMoveEvent event,
    MovementPath path,
    double progress,
    double? pathDistance,
  ) {
    var current = world;
    for (final entry in world.followStates.entries) {
      final followerId = entry.key;
      final follow = entry.value;
      if (follow.leaderObjectId != event.characterObjectId) {
        continue;
      }
      if (current.teleportedFollowerIds.contains(followerId)) {
        continue;
      }
      final position = _followPositionForPath(
        path,
        progress,
        pathDistance,
        follow.distance,
      );
      if (position == null) {
        continue;
      }
      current = _updateObject(current, followerId, (object) {
        return object.copyWith(
          transform: object.transform.copyWith(x: position.x, y: position.y),
          facing: position.direction,
          isMoving: position.isMoving,
          movementPoseAssetId: _movementPoseAssetId(
            object,
            position.direction,
            position.isMoving,
            world.currentTime,
          ),
        );
      });
    }
    return current;
  }

  String? _movementPoseAssetId(
    RuntimeObject object,
    Direction facing,
    bool isMoving,
    double currentTime,
  ) {
    final character = _characterForRuntimeObject(object);
    if (character == null) {
      return object.movementPoseAssetId;
    }
    if (!isMoving) {
      return standingMovementAssetIdForCharacter(
            character: character,
            facing: facing,
          ) ??
          object.movementPoseAssetId;
    }
    return movementAssetIdForCharacter(
          character: character,
          facing: facing,
          isMoving: isMoving,
          currentTime: currentTime,
        ) ??
        object.movementPoseAssetId;
  }

  Character? _characterForRuntimeObject(RuntimeObject object) {
    final characterId = object.source.maybeMap(
      characterInstance: (value) => value.characterId,
      orElse: () => null,
    );
    if (characterId == null) {
      return null;
    }
    for (final character in project.characters) {
      if (character.id == characterId) {
        return character;
      }
    }
    return null;
  }

  FollowPosition? _followPositionForPath(
    MovementPath path,
    double progress,
    double? pathDistance,
    double distance,
  ) {
    final samples = _pathSamples(path);
    if (samples.isEmpty) {
      return null;
    }
    final total = samples.last.distance;
    final leaderDistance = (pathDistance ?? total * progress)
        .clamp(0, total)
        .toDouble();
    final followerDistance = math.max(
      0,
      leaderDistance - math.max(distance, 0),
    );
    var previous = samples.first;
    for (final sample in samples.skip(1)) {
      if (followerDistance <= sample.distance) {
        final segmentDistance = sample.distance - previous.distance;
        final t = segmentDistance <= 0
            ? 1.0
            : (followerDistance - previous.distance) / segmentDistance;
        return FollowPosition(
          x: previous.x + (sample.x - previous.x) * t,
          y: previous.y + (sample.y - previous.y) * t,
          direction: movementDirection(
            sample.x - previous.x,
            sample.y - previous.y,
            path.mode,
            samples.indexOf(sample),
          ),
          isMoving: leaderDistance > distance && progress < 1,
        );
      }
      previous = sample;
    }
    return FollowPosition(
      x: samples.last.x,
      y: samples.last.y,
      direction: samples.last.direction,
      isMoving: false,
    );
  }

  double _distance(double startX, double startY, double endX, double endY) {
    final dx = endX - startX;
    final dy = endY - startY;
    return math.sqrt(dx * dx + dy * dy);
  }

  List<PathSample> _pathSamples(MovementPath path) {
    if (path.nodes.isEmpty) {
      return const [];
    }
    final samples = <PathSample>[
      PathSample(
        x: path.nodes.first.x,
        y: path.nodes.first.y,
        distance: 0,
        direction: Direction.down,
      ),
    ];
    var startX = path.nodes.first.x;
    var startY = path.nodes.first.y;
    var distance = 0.0;
    for (final node in path.nodes.skip(1)) {
      final target = movementTarget(startX, startY, node, path.mode);
      final dx = target.x - startX;
      final dy = target.y - startY;
      distance += math.sqrt(dx * dx + dy * dy);
      samples.add(
        PathSample(
          x: target.x,
          y: target.y,
          distance: distance,
          direction: movementDirection(dx, dy, path.mode, samples.length - 1),
        ),
      );
      startX = target.x;
      startY = target.y;
    }
    return samples;
  }

  RuntimeWorld _updateObject(
    RuntimeWorld world,
    String objectId,
    RuntimeObject Function(RuntimeObject object) update,
  ) {
    final object = world.objects[objectId];
    if (object == null) {
      return world;
    }
    return world.copyWith(
      objects: {...world.objects, objectId: update(object)},
    );
  }
}
