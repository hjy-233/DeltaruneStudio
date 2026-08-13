part of 'event_chain_panel.dart';

class _TimelineEventBlock extends StatelessWidget {
  const _TimelineEventBlock({
    required this.span,
    required this.project,
    required this.scene,
    required this.left,
    required this.width,
    required this.height,
    required this.selected,
    required this.scheduled,
    required this.pixelsPerSecond,
    required this.trackOffset,
    required this.onScheduleChanged,
    required this.onTap,
    required this.onRemove,
    this.onAddPathNode,
  });

  final TimelineSpan span;
  final StudioProject project;
  final Scene scene;
  final double left;
  final double width;
  final double height;
  final bool selected;
  final bool scheduled;
  final double pixelsPerSecond;
  final double trackOffset;
  final ValueChanged<double> onScheduleChanged;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback? onAddPathNode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _eventColor(span.event);
    final block = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: selected ? Colors.white : color,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: span.event is CharacterMoveEvent ? 22 : 0,
                  right: selected ? 18 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _eventTitle(project, l10n, span.event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _eventDetails(project, l10n, span),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (span.event is CharacterMoveEvent)
                _MovePathMarkers(
                  event: span.event as CharacterMoveEvent,
                  duration: span.duration,
                  width: width - 4,
                  scene: scene,
                  color: Colors.white70,
                ),
              if (onAddPathNode != null)
                Positioned(
                  right: selected ? 18 : 3,
                  bottom: 2,
                  child: InkWell(
                    onTap: onAddPathNode,
                    child: const Icon(
                      Icons.add_location_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (selected)
                Positioned(
                  right: 2,
                  top: 2,
                  child: InkWell(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    return Positioned(
      left: left + 2,
      top: 7,
      width: width - 4,
      height: height,
      child: scheduled
          ? _ScheduledEventDrag(
              pixelsPerSecond: pixelsPerSecond,
              startTime: span.start - trackOffset,
              onChanged: onScheduleChanged,
              child: block,
            )
          : block,
    );
  }
}

class _MovePathMarkers extends StatelessWidget {
  const _MovePathMarkers({
    required this.event,
    required this.duration,
    required this.width,
    required this.scene,
    required this.color,
  });

  final CharacterMoveEvent event;
  final double duration;
  final double width;
  final Scene scene;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final positions = _moveNodeTimeRatios(event, scene, duration);
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            for (var index = 0; index < positions.length; index += 1)
              Positioned(
                left: positions[index] * width,
                top: 2,
                child: Transform.translate(
                  offset: const Offset(-3, 0),
                  child: Tooltip(
                    message: 'Node ${index + 1}',
                    child: Icon(Icons.circle, size: 6, color: color),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

List<double> _moveNodeTimeRatios(
  CharacterMoveEvent event,
  Scene scene,
  double duration,
) {
  final nodes = event.path.nodes;
  if (nodes.isEmpty) return const [];
  final ratios = <double>[0];
  var elapsed = 0.0;
  var x = nodes.first.x;
  var y = nodes.first.y;
  for (var index = 1; index < nodes.length; index += 1) {
    final node = nodes[index];
    final target = movementTarget(x, y, node, event.path.mode);
    final targetX = target.x;
    final targetY = target.y;
    elapsed +=
        math.sqrt(math.pow(targetX - x, 2) + math.pow(targetY - y, 2)) /
        math.max(event.path.speed, 1);
    ratios.add((elapsed / math.max(duration, 0.1)).clamp(0.0, 1.0));
    x = targetX;
    y = targetY;
    elapsed += node.waitSeconds ?? 0;
    final triggerId = node.triggerId ?? triggerAtPoint(scene, targetX, targetY);
    if (triggerId != null) {
      final linkedId = linkedTriggerId(scene, triggerId);
      if (linkedId != null) {
        elapsed += TimelinePlan.doorTransitionDuration;
        final destination = triggerObjectPosition(scene, linkedId);
        if (destination != null) {
          x = destination.x;
          y = destination.y;
        }
      }
      final chain = triggerChain(scene, triggerId);
      if (chain != null) {
        elapsed += _timelineChainDuration(chain, scene, <String>{});
      }
      continue;
    }
  }
  return ratios;
}

double _timelineChainDuration(
  EventChain chain,
  Scene scene,
  Set<String> stack,
) {
  if (!stack.add(chain.id)) return 0;
  var total = 0.0;
  for (final event in chain.events) {
    total += _timelineEventDuration(event, scene, stack);
  }
  stack.remove(chain.id);
  return total;
}

double _timelineEventDuration(
  StudioEvent event,
  Scene scene,
  Set<String> stack,
) {
  return event.map(
    characterMove: (value) {
      var total = 0.0;
      var x = value.path.nodes.isEmpty ? 0.0 : value.path.nodes.first.x;
      var y = value.path.nodes.isEmpty ? 0.0 : value.path.nodes.first.y;
      for (var index = 1; index < value.path.nodes.length; index += 1) {
        final node = value.path.nodes[index];
        final target = movementTarget(x, y, node, value.path.mode);
        final targetX = target.x;
        final targetY = target.y;
        total +=
            math.sqrt(math.pow(targetX - x, 2) + math.pow(targetY - y, 2)) /
            math.max(value.path.speed, 1);
        total += node.waitSeconds ?? 0;
        final triggerId =
            node.triggerId ?? triggerAtPoint(scene, targetX, targetY);
        if (triggerId != null) {
          final linkedId = linkedTriggerId(scene, triggerId);
          if (linkedId != null) total += TimelinePlan.doorTransitionDuration;
          final nested = triggerChain(scene, triggerId);
          if (nested != null) {
            total += _timelineChainDuration(nested, scene, stack);
          }
        }
        x = targetX;
        y = targetY;
      }
      return math.max(total, 0.1);
    },
    characterWait: (value) => value.duration,
    characterChangeExpression: (value) => value.duration,
    characterStartFollow: (_) => 0.1,
    characterStopFollow: (_) => 0.1,
    dialogueSay: (value) => value.duration,
    cameraFollow: (_) => 0.1,
    cameraFocus: (value) => value.duration,
    sceneFade: (value) => value.duration,
    sceneChange: (_) => 0.1,
    audioPlayBgm: (_) => 0.1,
    audioPlaySound: (_) => 0.1,
    videoPlay: (value) => value.duration,
  );
}

String _eventTitle(
  StudioProject project,
  AppLocalizations l10n,
  StudioEvent event,
) {
  return event.map(
    characterMove: (value) =>
        '${_characterName(project, value.characterObjectId)} ${l10n.characterMove}',
    characterStartFollow: (value) =>
        '${_characterName(project, value.followerObjectId)} ${l10n.startFollow}',
    characterStopFollow: (value) =>
        '${_characterName(project, value.followerObjectId)} ${l10n.stopFollow}',
    characterWait: (_) => l10n.wait,
    characterChangeExpression: (value) =>
        '${_characterName(project, value.characterObjectId)} ${l10n.changeExpression}',
    dialogueSay: (value) => _dialoguePreview(value.text),
    cameraFollow: (value) =>
        '${l10n.cameraFollow}: ${_objectName(project, value.targetObjectId)}',
    cameraFocus: (_) => l10n.cameraFocus,
    sceneFade: (value) => '${l10n.fade}: ${value.mode.name}',
    sceneChange: (value) =>
        '${l10n.canvasJump}: ${_sceneName(project, value.sceneId)}',
    audioPlayBgm: (value) =>
        '${l10n.playBgm}: ${_assetName(project, value.assetId)}',
    audioPlaySound: (value) =>
        '${l10n.playSound}: ${_assetName(project, value.assetId)}',
    videoPlay: (value) =>
        '${l10n.playVideo}: ${_assetName(project, value.assetId)}',
  );
}

String _eventDetails(
  StudioProject project,
  AppLocalizations l10n,
  TimelineSpan span,
) {
  final event = span.event;
  final interval =
      '${span.start.toStringAsFixed(2)}-${span.displayEndValue.toStringAsFixed(2)}s';
  final details = event.map(
    characterMove: (value) =>
        '${value.path.nodes.length} nodes  ${value.path.speed.round()} px/s  shake ${value.path.shake.round()}',
    characterStartFollow: (value) => 'distance ${value.distance.round()} px',
    characterStopFollow: (_) => l10n.stop,
    characterWait: (value) => '${value.duration.toStringAsFixed(2)}s',
    characterChangeExpression: (value) =>
        '${value.expressionId}  ${value.duration.toStringAsFixed(2)}s',
    dialogueSay: (value) =>
        '${value.style.name}  ${value.duration.toStringAsFixed(2)}s',
    cameraFollow: (_) => l10n.cameraFollow,
    cameraFocus: (value) => '${value.duration.toStringAsFixed(2)}s',
    sceneFade: (value) =>
        '${value.mode.name}  ${value.duration.toStringAsFixed(2)}s',
    sceneChange: (value) => _sceneName(project, value.sceneId),
    audioPlayBgm: (value) => _assetName(project, value.assetId),
    audioPlaySound: (value) => _assetName(project, value.assetId),
    videoPlay: (value) => _assetName(project, value.assetId),
  );
  return '$details  $interval';
}

String _dialoguePreview(String text) {
  final oneLine = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (oneLine.isEmpty) return '...';
  return oneLine.length > 24 ? '${oneLine.substring(0, 24)}...' : oneLine;
}

String _characterName(StudioProject project, String objectId) {
  final object = _findObject(project, objectId);
  if (object is CharacterInstanceObject) return object.name;
  return objectId.isEmpty ? '?' : objectId;
}

String _objectName(StudioProject project, String objectId) {
  final object = _findObject(project, objectId);
  return object?.map(
        characterInstance: (value) => value.name,
        prop: (value) => value.name,
        background: (value) => value.name,
        triggerPoint: (value) => value.name,
        triggerArea: (value) => value.name,
      ) ??
      (objectId.isEmpty ? '?' : objectId);
}

String _sceneName(StudioProject project, String sceneId) {
  for (final scene in project.scenes) {
    if (scene.id == sceneId) return scene.name;
  }
  return sceneId;
}

String _assetName(StudioProject project, String assetId) {
  for (final asset in project.assets) {
    if (asset.id == assetId) return asset.originalName;
  }
  return assetId.isEmpty ? '?' : assetId;
}

SceneObject? _findObject(StudioProject project, String objectId) {
  for (final scene in project.scenes) {
    for (final object in scene.objects) {
      if (object.objectId == objectId) return object;
    }
  }
  return null;
}

Color _eventColor(StudioEvent event) {
  return event.map(
    characterMove: (_) => Colors.blue.shade700,
    characterStartFollow: (_) => Colors.indigo.shade600,
    characterStopFollow: (_) => Colors.indigo.shade400,
    characterWait: (_) => Colors.blueGrey.shade600,
    characterChangeExpression: (_) => Colors.teal.shade600,
    dialogueSay: (_) => Colors.green.shade700,
    cameraFollow: (_) => Colors.orange.shade700,
    cameraFocus: (_) => Colors.deepOrange.shade600,
    sceneFade: (_) => Colors.purple.shade600,
    sceneChange: (_) => Colors.purple.shade800,
    audioPlayBgm: (_) => Colors.pink.shade600,
    audioPlaySound: (_) => Colors.pink.shade400,
    videoPlay: (_) => Colors.red.shade700,
  );
}

class _AddEventMenu extends StatelessWidget {
  const _AddEventMenu({
    required this.enabled,
    required this.sampleCharacterId,
    required this.onSelected,
    this.compact = false,
  });

  final bool enabled;
  final String? sampleCharacterId;
  final ValueChanged<StudioEvent> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<StudioEvent>(
      enabled: enabled,
      tooltip: l10n.addEvent,
      onSelected: onSelected,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: defaultMoveEvent(sampleCharacterId),
          child: Text(l10n.characterMove),
        ),
        PopupMenuItem(
          value: StudioEvent.characterStartFollow(
            id: StudioIds.event(),
            followerObjectId: sampleCharacterId ?? '',
            leaderObjectId: sampleCharacterId ?? '',
          ),
          child: Text(l10n.startFollow),
        ),
        PopupMenuItem(
          value: StudioEvent.characterStopFollow(
            id: StudioIds.event(),
            followerObjectId: sampleCharacterId ?? '',
          ),
          child: Text(l10n.stopFollow),
        ),
        PopupMenuItem(
          value: StudioEvent.characterWait(id: StudioIds.event(), duration: 1),
          child: Text(l10n.wait),
        ),
        PopupMenuItem(
          value: StudioEvent.characterChangeExpression(
            id: StudioIds.event(),
            characterObjectId: sampleCharacterId ?? '',
            expressionId: 'idle',
            duration: 1,
          ),
          child: Text(l10n.changeExpression),
        ),
        PopupMenuItem(
          value: StudioEvent.dialogueSay(
            id: StudioIds.event(),
            text: '...',
            style: DialogueStyle.regular,
            duration: 2,
          ),
          child: Text(l10n.dialogue),
        ),
        PopupMenuItem(
          value: StudioEvent.sceneFade(
            id: StudioIds.event(),
            mode: FadeMode.out,
            duration: 0.8,
          ),
          child: Text(l10n.fadeOut),
        ),
        PopupMenuItem(
          value: StudioEvent.cameraFollow(
            id: StudioIds.event(),
            targetObjectId: sampleCharacterId ?? '',
          ),
          child: Text(l10n.cameraFollow),
        ),
        PopupMenuItem(
          value: StudioEvent.cameraFocus(
            id: StudioIds.event(),
            target: const FocusTarget.point(x: 240, y: 135),
          ),
          child: Text(l10n.cameraFocus),
        ),
        PopupMenuItem(
          value: StudioEvent.audioPlaySound(id: StudioIds.event(), assetId: ''),
          child: Text(l10n.playSound),
        ),
        PopupMenuItem(
          value: StudioEvent.audioPlayBgm(id: StudioIds.event(), assetId: ''),
          child: Text(l10n.playBgm),
        ),
        PopupMenuItem(
          value: StudioEvent.videoPlay(id: StudioIds.event(), assetId: ''),
          child: Text(l10n.playVideo),
        ),
      ],
      child: compact
          ? const Icon(Icons.add, size: 24)
          : DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                ),
                borderRadius: BorderRadius.circular(20),
                color: enabled
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).disabledColor.withValues(alpha: 0.12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 18,
                      color: enabled
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).disabledColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.addEvent,
                      style: TextStyle(
                        color: enabled
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
