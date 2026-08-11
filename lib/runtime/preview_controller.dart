import 'dart:async';
import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_audio_player.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final plan = _plan ?? _planFor(editorState);
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
    if (dialogue == null || eventId == null) {
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
      final addedUnits =
          TimelinePlan.usesWordTypewriter(editorState.project, dialogue.text)
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
    if (dialogue == null || world.currentEventId == null) {
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
  }) : spans = _buildSceneSpans(scene),
       audioCues = _buildSceneAudioCues(scene),
       dialogueTypeCues = _buildSceneDialogueTypeCues(project, scene) {
    duration = spans.isEmpty ? 0 : spans.last.end;
  }

  final StudioProject project;
  final Scene scene;
  final EventChain? chain;
  final List<TimelineSpan> spans;
  final List<TimelineAudioCue> audioCues;
  final List<TimelineDialogueTypeCue> dialogueTypeCues;
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
      if (time < span.end) {
        break;
      }
      world = world.copyWith(
        clearDialogue: true,
        clearActiveMove: true,
        clearActiveVideo: true,
      );
    }
    return world.copyWith(currentTime: time, totalDuration: duration);
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
    if (nodes.length == 1) {
      return _placeObject(current, event, startX, startY, Direction.down);
    }
    for (var index = 0; index < nodes.length - 1; index += 1) {
      final target = _orthogonalTarget(startX, startY, nodes[index + 1]);
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
        return _placeObject(
          current,
          event,
          startX + dx * segmentT,
          startY + dy * segmentT,
          _directionFor(dx, dy),
          progress: (index + segmentT) / (nodes.length - 1),
        );
      }
      elapsed += segmentDuration;
      lastX = target.x;
      lastY = target.y;
      current = _placeObject(
        current,
        event,
        target.x,
        target.y,
        _directionFor(target.x - startX, target.y - startY),
        progress: (index + 1) / (nodes.length - 1),
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
      final touchedTriggerId = end.triggerId ?? _triggerAtPoint(end.x, end.y);
      final linkedTriggerId = _linkedTriggerId(touchedTriggerId);
      final destination = _triggerObjectPosition(linkedTriggerId);
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
        ).copyWith(fadeOpacity: 0);
        startX = destination.x;
        startY = destination.y;
        lastX = destination.x;
        lastY = destination.y;
        elapsed += doorTransitionDuration;
      }
      final triggered = _triggerChain(touchedTriggerId);
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
      }
    }
    return _placeObject(
      current,
      event,
      lastX,
      lastY,
      current.objects[event.characterObjectId]?.facing ?? Direction.down,
      progress: 1,
      isMoving: false,
    ).copyWith(clearActiveMove: true);
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
    final appeared = _placeObject(
      world,
      event,
      destination.x,
      destination.y,
      world.objects[event.characterObjectId]?.facing ?? Direction.down,
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
    bool isMoving = true,
  }) {
    final placed =
        _updateObject(world, event.characterObjectId, (object) {
          return object.copyWith(
            facing: facing,
            transform: object.transform.copyWith(x: x, y: y),
            isMoving: isMoving,
          );
        }).copyWith(
          currentEventId: event.id,
          activeMoveEventId: event.id,
          activeMoveProgress: progress,
        );
    return _applyFollowersFromMove(placed, event, progress);
  }

  RuntimeWorld _setMoving(RuntimeWorld world, String objectId, bool isMoving) {
    return _updateObject(world, objectId, (object) {
      return object.copyWith(isMoving: isMoving);
    });
  }

  RuntimeWorld _applyFollowersFromMove(
    RuntimeWorld world,
    CharacterMoveEvent event,
    double progress,
  ) {
    var current = world;
    for (final entry in world.followStates.entries) {
      final followerId = entry.key;
      final follow = entry.value;
      if (follow.leaderObjectId != event.characterObjectId) {
        continue;
      }
      final position = _followPositionForPath(
        event.path,
        progress,
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
        );
      });
    }
    return current;
  }

  FollowPosition? _followPositionForPath(
    MovementPath path,
    double progress,
    double distance,
  ) {
    final samples = _pathSamples(path);
    if (samples.isEmpty) {
      return null;
    }
    final total = samples.last.distance;
    final leaderDistance = (total * progress).clamp(0, total).toDouble();
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
          direction: _directionFor(
            sample.x - previous.x,
            sample.y - previous.y,
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
      final target = _orthogonalTarget(startX, startY, node);
      final dx = target.x - startX;
      final dy = target.y - startY;
      distance += math.sqrt(dx * dx + dy * dy);
      samples.add(
        PathSample(
          x: target.x,
          y: target.y,
          distance: distance,
          direction: _directionFor(dx, dy),
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

  EventChain? _triggerChain(String? triggerId) {
    if (triggerId == null) {
      return null;
    }
    for (final trigger in scene.triggers) {
      final match = trigger.map(
        area: (value) => value.id == triggerId ? value.eventChainId : null,
        object: (value) => value.id == triggerId ? value.eventChainId : null,
        auto: (value) => value.id == triggerId ? value.eventChainId : null,
        moveComplete: (value) =>
            value.id == triggerId ? value.eventChainId : null,
      );
      if (match != null) {
        for (final chain in scene.eventChains) {
          if (chain.id == match &&
              chain.triggerMode == EventChainTriggerMode.triggerPoint) {
            return chain;
          }
        }
      }
    }
    return null;
  }

  String? _linkedTriggerId(String? triggerId) {
    if (triggerId == null) {
      return null;
    }
    for (final trigger in scene.triggers) {
      final match = trigger.map(
        area: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        object: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        auto: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        moveComplete: (value) =>
            value.id == triggerId ? value.linkedTriggerId : null,
      );
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  DoorDestination? _triggerObjectPosition(String? triggerId) {
    if (triggerId == null) {
      return null;
    }
    for (final object in scene.objects) {
      final objectTriggerId = object.maybeMap(
        triggerPoint: (value) => value.triggerId,
        triggerArea: (value) => value.triggerId,
        orElse: () => null,
      );
      if (objectTriggerId == triggerId) {
        final transform = object.objectTransform;
        return DoorDestination(transform.x, transform.y);
      }
    }
    return null;
  }

  String? _triggerAtPoint(double x, double y) {
    for (final object in scene.objects) {
      final triggerId = object.maybeMap(
        triggerPoint: (value) => value.triggerId,
        triggerArea: (value) => value.triggerId,
        orElse: () => null,
      );
      if (triggerId == null) {
        continue;
      }
      final transform = object.objectTransform;
      final rect = RectLike(
        transform.x,
        transform.y,
        transform.width * transform.scale,
        transform.height * transform.scale,
      ).inflate(10);
      if (rect.contains(x, y)) {
        return triggerId;
      }
    }
    return null;
  }

  static List<TimelineSpan> _buildSpans(
    Scene scene,
    EventChain? chain,
    Set<String> stack,
  ) {
    if (chain == null || stack.contains(chain.id)) {
      return const [];
    }
    final nextStack = {...stack, chain.id};
    final spans = <TimelineSpan>[];
    var cursor = 0.0;
    for (final event in chain.events) {
      final duration = _eventDuration(scene, event, nextStack);
      spans.add(
        TimelineSpan(event: event, start: cursor, end: cursor + duration),
      );
      cursor += duration;
    }
    return spans;
  }

  static List<TimelineSpan> _buildSceneSpans(Scene scene) {
    final spans = <TimelineSpan>[];
    var cursor = 0.0;
    for (final chain in scene.eventChains) {
      if (chain.events.isEmpty ||
          chain.triggerMode != EventChainTriggerMode.always) {
        continue;
      }
      final chainSpans = _buildSpans(scene, chain, const {});
      for (final span in chainSpans) {
        spans.add(
          TimelineSpan(
            event: span.event,
            start: cursor + span.start,
            end: cursor + span.end,
          ),
        );
      }
      cursor += chainSpans.isEmpty ? 0 : chainSpans.last.end;
    }
    return spans;
  }

  static List<TimelineAudioCue> _buildSceneAudioCues(Scene scene) {
    final cues = <TimelineAudioCue>[];
    var cursor = 0.0;
    for (final chain in scene.eventChains) {
      if (chain.events.isEmpty ||
          chain.triggerMode != EventChainTriggerMode.always) {
        continue;
      }
      final chainSpans = _buildSpans(scene, chain, const {});
      cues.addAll(_audioCuesForSpans(scene, chainSpans, cursor, const {}));
      cursor += chainSpans.isEmpty ? 0 : chainSpans.last.end;
    }
    cues.sort((a, b) => a.time.compareTo(b.time));
    return cues;
  }

  static List<TimelineDialogueTypeCue> _buildSceneDialogueTypeCues(
    StudioProject project,
    Scene scene,
  ) {
    final cues = <TimelineDialogueTypeCue>[];
    var cursor = 0.0;
    for (final chain in scene.eventChains) {
      if (chain.events.isEmpty ||
          chain.triggerMode != EventChainTriggerMode.always) {
        continue;
      }
      final chainSpans = _buildSpans(scene, chain, const {});
      cues.addAll(
        _dialogueTypeCuesForSpans(project, scene, chainSpans, cursor, const {}),
      );
      cursor += chainSpans.isEmpty ? 0 : chainSpans.last.end;
    }
    cues.sort((a, b) => a.time.compareTo(b.time));
    return cues;
  }

  static List<TimelineAudioCue> _audioCuesForSpans(
    Scene scene,
    List<TimelineSpan> spans,
    double baseTime,
    Set<String> stack,
  ) {
    final cues = <TimelineAudioCue>[];
    for (final span in spans) {
      final event = span.event;
      if (event is AudioPlayBgmEvent || event is AudioPlaySoundEvent) {
        cues.add(TimelineAudioCue(event: event, time: baseTime + span.start));
      }
      if (event is CharacterMoveEvent) {
        cues.addAll(
          _audioCuesForMove(scene, event, baseTime + span.start, stack),
        );
      }
    }
    return cues;
  }

  static List<TimelineDialogueTypeCue> _dialogueTypeCuesForSpans(
    StudioProject project,
    Scene scene,
    List<TimelineSpan> spans,
    double baseTime,
    Set<String> stack,
  ) {
    final cues = <TimelineDialogueTypeCue>[];
    for (final span in spans) {
      final event = span.event;
      if (event is DialogueSayEvent) {
        final assetId = event.textSoundAssetId;
        if (assetId != null && assetId.isNotEmpty) {
          final byWord = usesWordTypewriter(project, event.text);
          final interval = byWord ? 1 / 6.0 : 1 / 32.0;
          final count = byWord
              ? _englishWordStops(event.text).length
              : event.text.length;
          for (var index = 1; index <= count; index += 1) {
            final time = baseTime + span.start + index * interval;
            if (time < baseTime + span.end) {
              cues.add(TimelineDialogueTypeCue(assetId: assetId, time: time));
            }
          }
        }
      }
      if (event is CharacterMoveEvent) {
        cues.addAll(
          _dialogueTypeCuesForMove(
            project,
            scene,
            event,
            baseTime + span.start,
            stack,
          ),
        );
      }
    }
    return cues;
  }

  static List<TimelineAudioCue> _audioCuesForMove(
    Scene scene,
    CharacterMoveEvent event,
    double baseTime,
    Set<String> stack,
  ) {
    final cues = <TimelineAudioCue>[];
    if (event.path.nodes.length < 2) {
      return cues;
    }
    var elapsed = 0.0;
    var startX = event.path.nodes.first.x;
    var startY = event.path.nodes.first.y;
    for (var index = 0; index < event.path.nodes.length - 1; index += 1) {
      final end = event.path.nodes[index + 1];
      elapsed += _segmentDuration(
        startX,
        startY,
        end.x,
        end.y,
        event.path.speed,
      );
      final target = _orthogonalTarget(startX, startY, end);
      startX = target.x;
      startY = target.y;
      elapsed += end.waitSeconds ?? 0;
      final triggerId =
          end.triggerId ?? _triggerAtPointStatic(scene, end.x, end.y);
      final linkedTriggerId = _linkedTriggerIdStatic(scene, triggerId);
      if (linkedTriggerId != null) {
        elapsed += doorTransitionDuration;
        final destination = _triggerObjectPositionStatic(
          scene,
          linkedTriggerId,
        );
        if (destination != null) {
          startX = destination.x;
          startY = destination.y;
        }
      }
      final chain = _triggerChainStatic(scene, triggerId);
      if (chain == null ||
          chain.triggerMode != EventChainTriggerMode.triggerPoint ||
          stack.contains(chain.id)) {
        continue;
      }
      final spans = _buildSpans(scene, chain, stack);
      cues.addAll(
        _audioCuesForSpans(scene, spans, baseTime + elapsed, {
          ...stack,
          chain.id,
        }),
      );
      elapsed += spans.isEmpty ? 0 : spans.last.end;
    }
    return cues;
  }

  static List<TimelineDialogueTypeCue> _dialogueTypeCuesForMove(
    StudioProject project,
    Scene scene,
    CharacterMoveEvent event,
    double baseTime,
    Set<String> stack,
  ) {
    final cues = <TimelineDialogueTypeCue>[];
    if (event.path.nodes.length < 2) {
      return cues;
    }
    var elapsed = 0.0;
    var startX = event.path.nodes.first.x;
    var startY = event.path.nodes.first.y;
    for (var index = 0; index < event.path.nodes.length - 1; index += 1) {
      final end = event.path.nodes[index + 1];
      elapsed += _segmentDuration(
        startX,
        startY,
        end.x,
        end.y,
        event.path.speed,
      );
      final target = _orthogonalTarget(startX, startY, end);
      startX = target.x;
      startY = target.y;
      elapsed += end.waitSeconds ?? 0;
      final triggerId =
          end.triggerId ?? _triggerAtPointStatic(scene, end.x, end.y);
      final linkedTriggerId = _linkedTriggerIdStatic(scene, triggerId);
      if (linkedTriggerId != null) {
        elapsed += doorTransitionDuration;
        final destination = _triggerObjectPositionStatic(
          scene,
          linkedTriggerId,
        );
        if (destination != null) {
          startX = destination.x;
          startY = destination.y;
        }
      }
      final chain = _triggerChainStatic(scene, triggerId);
      if (chain == null ||
          chain.triggerMode != EventChainTriggerMode.triggerPoint ||
          stack.contains(chain.id)) {
        continue;
      }
      final spans = _buildSpans(scene, chain, stack);
      cues.addAll(
        _dialogueTypeCuesForSpans(project, scene, spans, baseTime + elapsed, {
          ...stack,
          chain.id,
        }),
      );
      elapsed += spans.isEmpty ? 0 : spans.last.end;
    }
    return cues;
  }

  static double _chainDuration(
    Scene scene,
    EventChain chain,
    Set<String> stack,
  ) {
    if (stack.contains(chain.id)) {
      return 0;
    }
    return _buildSpans(
      scene,
      chain,
      stack,
    ).fold<double>(0, (duration, span) => math.max(duration, span.end));
  }

  static double _eventDuration(
    Scene scene,
    StudioEvent event,
    Set<String> stack,
  ) {
    return event.map(
      characterMove: (value) {
        var duration = 0.0;
        if (value.path.nodes.length < 2) {
          return 0.1;
        }
        var startX = value.path.nodes.first.x;
        var startY = value.path.nodes.first.y;
        for (var index = 0; index < value.path.nodes.length - 1; index += 1) {
          final end = value.path.nodes[index + 1];
          duration += _segmentDuration(
            startX,
            startY,
            end.x,
            end.y,
            value.path.speed,
          );
          final target = _orthogonalTarget(startX, startY, end);
          startX = target.x;
          startY = target.y;
          duration += end.waitSeconds ?? 0;
          final triggerId =
              end.triggerId ?? _triggerAtPointStatic(scene, end.x, end.y);
          if (triggerId != null) {
            for (final trigger in scene.triggers) {
              final linkedTriggerId = trigger.map(
                area: (item) =>
                    item.id == triggerId ? item.linkedTriggerId : null,
                object: (item) =>
                    item.id == triggerId ? item.linkedTriggerId : null,
                auto: (item) =>
                    item.id == triggerId ? item.linkedTriggerId : null,
                moveComplete: (item) =>
                    item.id == triggerId ? item.linkedTriggerId : null,
              );
              if (linkedTriggerId != null) {
                duration += doorTransitionDuration;
                final destination = _triggerObjectPositionStatic(
                  scene,
                  linkedTriggerId,
                );
                if (destination != null) {
                  startX = destination.x;
                  startY = destination.y;
                }
                break;
              }
            }
            for (final trigger in scene.triggers) {
              final chainId = trigger.map(
                area: (item) => item.id == triggerId ? item.eventChainId : null,
                object: (item) =>
                    item.id == triggerId ? item.eventChainId : null,
                auto: (item) => item.id == triggerId ? item.eventChainId : null,
                moveComplete: (item) =>
                    item.id == triggerId ? item.eventChainId : null,
              );
              if (chainId == null) {
                continue;
              }
              for (final chain in scene.eventChains) {
                if (chain.id == chainId &&
                    chain.triggerMode == EventChainTriggerMode.triggerPoint) {
                  duration += _chainDuration(scene, chain, stack);
                }
              }
            }
          }
        }
        return math.max(duration, 0.1);
      },
      characterWait: (value) => math.max(value.duration, 0.1),
      characterChangeExpression: (value) => math.max(value.duration, 0.1),
      characterStartFollow: (_) => 0.1,
      characterStopFollow: (_) => 0.1,
      dialogueSay: (value) => math.max(value.duration, 0.1),
      cameraFollow: (_) => 0.1,
      cameraFocus: (value) => math.max(value.duration, 0.1),
      sceneFade: (value) => math.max(value.duration, 0.1),
      sceneChange: (_) => 0.1,
      audioPlayBgm: (_) => 0.1,
      audioPlaySound: (_) => 0.1,
      videoPlay: (value) => math.max(value.duration, 0.1),
    );
  }

  static DoorDestination _orthogonalTarget(
    double startX,
    double startY,
    PathNode target,
  ) {
    final dx = target.x - startX;
    final dy = target.y - startY;
    if (dx.abs() >= dy.abs()) {
      return DoorDestination(target.x, startY);
    }
    return DoorDestination(startX, target.y);
  }

  static int _typewriterCharacters(
    StudioProject project,
    String text,
    double localTime,
  ) {
    if (usesWordTypewriter(project, text)) {
      final stops = _englishWordStops(text);
      if (stops.isEmpty) {
        return 0;
      }
      const wordsPerSecond = 6.0;
      final visibleWords = (localTime * wordsPerSecond).floor();
      if (visibleWords <= 0) {
        return 0;
      }
      return stops[math.min(visibleWords, stops.length) - 1];
    }
    const charactersPerSecond = 32.0;
    final visible = (localTime * charactersPerSecond).floor();
    return visible.clamp(0, text.length);
  }

  static bool usesWordTypewriter(StudioProject project, String text) {
    if (!project.settings.englishDialogueTypewriterByWord ||
        project.settings.language != AppLanguage.english) {
      return false;
    }
    final letters = RegExp(r'[A-Za-z]').allMatches(text).length;
    if (letters == 0) {
      return false;
    }
    final nonAsciiLetters = RegExp(r'[^\x00-\x7F]').hasMatch(text);
    return !nonAsciiLetters;
  }

  static List<int> _englishWordStops(String text) {
    final stops = <int>[];
    final matches = RegExp(r'\S+\s*').allMatches(text);
    for (final match in matches) {
      stops.add(match.end);
    }
    return stops;
  }

  static double _segmentDuration(
    double startX,
    double startY,
    double endX,
    double endY,
    double speed,
  ) {
    final target = _orthogonalTarget(
      startX,
      startY,
      PathNode(id: 'duration', x: endX, y: endY),
    );
    final dx = target.x - startX;
    final dy = target.y - startY;
    final distance = math.sqrt(dx * dx + dy * dy);
    return distance / math.max(speed, 1);
  }

  static String? _triggerAtPointStatic(Scene scene, double x, double y) {
    for (final object in scene.objects) {
      final triggerId = object.maybeMap(
        triggerPoint: (value) => value.triggerId,
        triggerArea: (value) => value.triggerId,
        orElse: () => null,
      );
      if (triggerId == null) {
        continue;
      }
      final transform = object.objectTransform;
      final rect = RectLike(
        transform.x,
        transform.y,
        transform.width * transform.scale,
        transform.height * transform.scale,
      ).inflate(10);
      if (rect.contains(x, y)) {
        return triggerId;
      }
    }
    return null;
  }

  static String? _linkedTriggerIdStatic(Scene scene, String? triggerId) {
    if (triggerId == null) {
      return null;
    }
    for (final trigger in scene.triggers) {
      final match = trigger.map(
        area: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        object: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        auto: (value) => value.id == triggerId ? value.linkedTriggerId : null,
        moveComplete: (value) =>
            value.id == triggerId ? value.linkedTriggerId : null,
      );
      if (match != null) {
        return match;
      }
    }
    return null;
  }

  static EventChain? _triggerChainStatic(Scene scene, String? triggerId) {
    if (triggerId == null) {
      return null;
    }
    for (final trigger in scene.triggers) {
      final chainId = trigger.map(
        area: (value) => value.id == triggerId ? value.eventChainId : null,
        object: (value) => value.id == triggerId ? value.eventChainId : null,
        auto: (value) => value.id == triggerId ? value.eventChainId : null,
        moveComplete: (value) =>
            value.id == triggerId ? value.eventChainId : null,
      );
      if (chainId == null || chainId.isEmpty) {
        continue;
      }
      for (final chain in scene.eventChains) {
        if (chain.id == chainId &&
            chain.triggerMode == EventChainTriggerMode.triggerPoint) {
          return chain;
        }
      }
    }
    return null;
  }

  static DoorDestination? _triggerObjectPositionStatic(
    Scene scene,
    String triggerId,
  ) {
    for (final object in scene.objects) {
      final objectTriggerId = object.maybeMap(
        triggerPoint: (value) => value.triggerId,
        triggerArea: (value) => value.triggerId,
        orElse: () => null,
      );
      if (objectTriggerId == triggerId) {
        final transform = object.objectTransform;
        return DoorDestination(transform.x, transform.y);
      }
    }
    return null;
  }

  static Direction _directionFor(double dx, double dy) {
    if (dx.abs() > dy.abs()) {
      return dx >= 0 ? Direction.right : Direction.left;
    }
    return dy >= 0 ? Direction.down : Direction.up;
  }
}

final class TimelineSpan {
  const TimelineSpan({
    required this.event,
    required this.start,
    required this.end,
  });

  final StudioEvent event;
  final double start;
  final double end;

  double get duration => math.max(0.1, end - start);
}

final class TimelineAudioCue {
  const TimelineAudioCue({required this.event, required this.time});

  final StudioEvent event;
  final double time;
}

final class TimelineDialogueTypeCue {
  const TimelineDialogueTypeCue({required this.assetId, required this.time});

  final String assetId;
  final double time;
}

final class DoorDestination {
  const DoorDestination(this.x, this.y);

  final double x;
  final double y;
}

final class PathSample {
  const PathSample({
    required this.x,
    required this.y,
    required this.distance,
    required this.direction,
  });

  final double x;
  final double y;
  final double distance;
  final Direction direction;
}

final class FollowPosition {
  const FollowPosition({
    required this.x,
    required this.y,
    required this.direction,
    required this.isMoving,
  });

  final double x;
  final double y;
  final Direction direction;
  final bool isMoving;
}

final class RectLike {
  const RectLike(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;

  RectLike inflate(double amount) {
    return RectLike(
      left - amount,
      top - amount,
      width + amount * 2,
      height + amount * 2,
    );
  }

  bool contains(double x, double y) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }
}

sealed class PreviewState {
  const PreviewState();

  const factory PreviewState.stopped() = PreviewStopped;
  const factory PreviewState.playing({
    required RuntimeWorld world,
    bool cleanPreview,
  }) = PreviewPlaying;
  const factory PreviewState.paused({
    required RuntimeWorld world,
    bool cleanPreview,
  }) = PreviewPaused;

  RuntimeWorld? get world => switch (this) {
    PreviewStopped() => null,
    PreviewPlaying(:final world) => world,
    PreviewPaused(:final world) => world,
  };

  bool get isPlaying => this is PreviewPlaying;

  bool get cleanPreview => switch (this) {
    PreviewStopped() => false,
    PreviewPlaying(:final cleanPreview) => cleanPreview,
    PreviewPaused(:final cleanPreview) => cleanPreview,
  };
}

final class PreviewStopped extends PreviewState {
  const PreviewStopped();
}

final class PreviewPlaying extends PreviewState {
  const PreviewPlaying({required this.world, this.cleanPreview = false});
  @override
  final RuntimeWorld world;
  @override
  final bool cleanPreview;
}

final class PreviewPaused extends PreviewState {
  const PreviewPaused({required this.world, this.cleanPreview = false});
  @override
  final RuntimeWorld world;
  @override
  final bool cleanPreview;
}
