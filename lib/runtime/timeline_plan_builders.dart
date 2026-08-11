part of 'preview_controller.dart';

List<TimelineSpan> _buildSpans(
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

List<TimelineChainTrack> _buildSceneTracks(Scene scene) {
  final tracks = [
    for (final chain in scene.eventChains) _buildChainTrack(scene, chain),
  ];
  final timelineEnd = tracks
      .where((track) => track.chain.triggerMode == EventChainTriggerMode.always)
      .fold<double>(0, (value, track) => math.max(value, track.duration));
  return [
    for (final track in tracks) _extendPersistentEventSpans(track, timelineEnd),
  ];
}

TimelineChainTrack _extendPersistentEventSpans(
  TimelineChainTrack track,
  double timelineEnd,
) {
  if (track.chain.triggerMode != EventChainTriggerMode.always) {
    return track;
  }
  return TimelineChainTrack(
    chain: track.chain,
    offset: track.offset,
    spans: [
      for (final span in track.spans)
        _extendPersistentEventSpan(track.spans, span, timelineEnd),
    ],
  );
}

TimelineSpan _extendPersistentEventSpan(
  List<TimelineSpan> spans,
  TimelineSpan span,
  double timelineEnd,
) {
  final event = span.event;
  if (event is! CharacterStartFollowEvent) {
    return span;
  }
  TimelineSpan? stop;
  for (final candidate in spans) {
    if (candidate.start < span.start ||
        candidate.event is! CharacterStopFollowEvent ||
        (candidate.event as CharacterStopFollowEvent).followerObjectId !=
            event.followerObjectId) {
      continue;
    }
    stop = candidate;
    break;
  }
  return TimelineSpan(
    event: span.event,
    start: span.start,
    end: span.end,
    displayEnd: stop?.start ?? math.max(timelineEnd, span.end),
  );
}

List<TimelineSpan> _buildRuntimeSpans(List<TimelineChainTrack> tracks) {
  final spans = <TimelineSpan>[];
  for (final track in tracks) {
    if (track.chain.triggerMode != EventChainTriggerMode.always) {
      continue;
    }
    spans.addAll(track.spans);
  }
  spans.sort(_compareSpans);
  return spans;
}

TimelineChainTrack _buildChainTrack(Scene scene, EventChain chain) {
  final localSpans = _buildSpans(scene, chain, const {});
  final offset = chain.triggerMode == EventChainTriggerMode.always
      ? 0.0
      : _findTriggerChainOffset(scene, chain.id) ?? 0.0;
  return TimelineChainTrack(
    chain: chain,
    offset: offset,
    spans: [
      for (final span in localSpans)
        TimelineSpan(
          event: span.event,
          start: span.start + offset,
          end: span.end + offset,
        ),
    ],
  );
}

double? _findTriggerChainOffset(Scene scene, String targetChainId) {
  for (final chain in scene.eventChains) {
    if (chain.triggerMode != EventChainTriggerMode.always) {
      continue;
    }
    final offset = _findChainOffsetInChain(scene, chain, targetChainId, 0, {
      chain.id,
    });
    if (offset != null) {
      return offset;
    }
  }
  return null;
}

double? _findChainOffsetInChain(
  Scene scene,
  EventChain chain,
  String targetChainId,
  double baseOffset,
  Set<String> stack,
) {
  var elapsed = 0.0;
  for (final event in chain.events) {
    if (event is CharacterMoveEvent) {
      final offset = _findChainOffsetInMove(
        scene,
        event,
        targetChainId,
        baseOffset + elapsed,
        stack,
      );
      if (offset != null) {
        return offset;
      }
    }
    elapsed += _eventDuration(scene, event, stack);
  }
  return null;
}

double? _findChainOffsetInMove(
  Scene scene,
  CharacterMoveEvent event,
  String targetChainId,
  double baseOffset,
  Set<String> stack,
) {
  if (event.path.nodes.length < 2) {
    return null;
  }
  var elapsed = 0.0;
  var startX = event.path.nodes.first.x;
  var startY = event.path.nodes.first.y;
  for (var index = 0; index < event.path.nodes.length - 1; index += 1) {
    final end = event.path.nodes[index + 1];
    final target = _orthogonalTarget(startX, startY, end);
    elapsed += _segmentDuration(
      startX,
      startY,
      target.x,
      target.y,
      event.path.speed,
    );
    elapsed += end.waitSeconds ?? 0;
    final triggerId = end.triggerId ?? triggerAtPoint(scene, end.x, end.y);
    final linkedId = linkedTriggerId(scene, triggerId);
    if (linkedId != null) {
      elapsed += TimelinePlan.doorTransitionDuration;
    }
    final triggered = triggerChain(scene, triggerId);
    if (triggered != null && !stack.contains(triggered.id)) {
      if (triggered.id == targetChainId) {
        return baseOffset + elapsed;
      }
      final nestedOffset = _findChainOffsetInChain(
        scene,
        triggered,
        targetChainId,
        baseOffset + elapsed,
        {...stack, triggered.id},
      );
      if (nestedOffset != null) {
        return nestedOffset;
      }
      elapsed += _chainDuration(scene, triggered, stack);
    }
    if (linkedId != null) {
      final destination = triggerObjectPosition(scene, linkedId);
      if (destination != null) {
        startX = destination.x;
        startY = destination.y;
        continue;
      }
    }
    startX = target.x;
    startY = target.y;
  }
  return null;
}

List<TimelineAudioCue> _buildSceneAudioCues(Scene scene) {
  final cues = <TimelineAudioCue>[];
  for (final chain in scene.eventChains) {
    if (chain.events.isEmpty ||
        chain.triggerMode != EventChainTriggerMode.always) {
      continue;
    }
    final chainSpans = _buildSpans(scene, chain, const {});
    cues.addAll(_audioCuesForSpans(scene, chainSpans, 0, const {}));
  }
  cues.sort((a, b) => a.time.compareTo(b.time));
  return cues;
}

List<TimelineDialogueTypeCue> _buildSceneDialogueTypeCues(
  StudioProject project,
  Scene scene,
) {
  final cues = <TimelineDialogueTypeCue>[];
  for (final chain in scene.eventChains) {
    if (chain.events.isEmpty ||
        chain.triggerMode != EventChainTriggerMode.always) {
      continue;
    }
    final chainSpans = _buildSpans(scene, chain, const {});
    cues.addAll(
      _dialogueTypeCuesForSpans(project, scene, chainSpans, 0, const {}),
    );
  }
  cues.sort((a, b) => a.time.compareTo(b.time));
  return cues;
}

int _compareSpans(TimelineSpan a, TimelineSpan b) {
  final byStart = a.start.compareTo(b.start);
  if (byStart != 0) {
    return byStart;
  }
  return _eventPriority(a.event).compareTo(_eventPriority(b.event));
}

int _eventPriority(StudioEvent event) {
  return event.map(
    characterStartFollow: (_) => 0,
    cameraFollow: (_) => 1,
    cameraFocus: (_) => 1,
    characterChangeExpression: (_) => 2,
    characterMove: (_) => 3,
    characterWait: (_) => 4,
    characterStopFollow: (_) => 5,
    dialogueSay: (_) => 6,
    sceneFade: (_) => 7,
    sceneChange: (_) => 8,
    audioPlayBgm: (_) => 9,
    audioPlaySound: (_) => 9,
    videoPlay: (_) => 10,
  );
}

List<TimelineAudioCue> _audioCuesForSpans(
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

List<TimelineDialogueTypeCue> _dialogueTypeCuesForSpans(
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

List<TimelineAudioCue> _audioCuesForMove(
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
    elapsed += _segmentDuration(startX, startY, end.x, end.y, event.path.speed);
    final target = _orthogonalTarget(startX, startY, end);
    startX = target.x;
    startY = target.y;
    elapsed += end.waitSeconds ?? 0;
    final triggerId = end.triggerId ?? triggerAtPoint(scene, end.x, end.y);
    final linkedId = linkedTriggerId(scene, triggerId);
    if (linkedId != null) {
      elapsed += TimelinePlan.doorTransitionDuration;
      final destination = triggerObjectPosition(scene, linkedId);
      if (destination != null) {
        startX = destination.x;
        startY = destination.y;
      }
    }
    final chain = triggerChain(scene, triggerId);
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

List<TimelineDialogueTypeCue> _dialogueTypeCuesForMove(
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
    elapsed += _segmentDuration(startX, startY, end.x, end.y, event.path.speed);
    final target = _orthogonalTarget(startX, startY, end);
    startX = target.x;
    startY = target.y;
    elapsed += end.waitSeconds ?? 0;
    final triggerId = end.triggerId ?? triggerAtPoint(scene, end.x, end.y);
    final linkedId = linkedTriggerId(scene, triggerId);
    if (linkedId != null) {
      elapsed += TimelinePlan.doorTransitionDuration;
      final destination = triggerObjectPosition(scene, linkedId);
      if (destination != null) {
        startX = destination.x;
        startY = destination.y;
      }
    }
    final chain = triggerChain(scene, triggerId);
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

double _chainDuration(Scene scene, EventChain chain, Set<String> stack) {
  if (stack.contains(chain.id)) {
    return 0;
  }
  return _buildSpans(
    scene,
    chain,
    stack,
  ).fold<double>(0, (duration, span) => math.max(duration, span.end));
}

double _eventDuration(Scene scene, StudioEvent event, Set<String> stack) {
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
        final triggerId = end.triggerId ?? triggerAtPoint(scene, end.x, end.y);
        if (triggerId != null) {
          final linkedId = linkedTriggerId(scene, triggerId);
          if (linkedId != null) {
            duration += TimelinePlan.doorTransitionDuration;
            final destination = triggerObjectPosition(scene, linkedId);
            if (destination != null) {
              startX = destination.x;
              startY = destination.y;
            }
          }
          final chain = triggerChain(scene, triggerId);
          if (chain != null) {
            duration += _chainDuration(scene, chain, stack);
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

DoorDestination _orthogonalTarget(
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

int _typewriterCharacters(
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

bool usesWordTypewriter(StudioProject project, String text) {
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

List<int> _englishWordStops(String text) {
  final stops = <int>[];
  final matches = RegExp(r'\S+\s*').allMatches(text);
  for (final match in matches) {
    stops.add(match.end);
  }
  return stops;
}

double _segmentDuration(
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

Direction _directionFor(double dx, double dy) {
  if (dx.abs() > dy.abs()) {
    return dx >= 0 ? Direction.right : Direction.left;
  }
  return dy >= 0 ? Direction.down : Direction.up;
}
