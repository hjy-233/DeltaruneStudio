import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/editor/default_event_factories.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

class EventChainPanel extends ConsumerStatefulWidget {
  const EventChainPanel({
    required this.ready,
    required this.sampleCharacterId,
    super.key,
  });

  final StudioReady ready;
  final String? sampleCharacterId;

  @override
  ConsumerState<EventChainPanel> createState() => _EventChainPanelState();
}

class _EventChainPanelState extends ConsumerState<EventChainPanel> {
  final Set<String> _collapsedChains = <String>{};
  double _pixelsPerSecond = 100;
  double _trackHeight = 66;

  @override
  void initState() {
    super.initState();
    _readLayout(widget.ready.project.editorLayout);
  }

  @override
  void didUpdateWidget(covariant EventChainPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ready.project.id != widget.ready.project.id) {
      _collapsedChains.clear();
      _readLayout(widget.ready.project.editorLayout);
    }
  }

  void _readLayout(EditorLayout layout) {
    _pixelsPerSecond = layout.timelinePixelsPerSecond.clamp(20, 240);
    _trackHeight = layout.timelineTrackHeight.clamp(42, 120);
  }

  void _updateLayout({double? pixelsPerSecond, double? trackHeight}) {
    final ready = widget.ready;
    final controller = ref.read(studioControllerProvider.notifier);
    final layout = ready.project.editorLayout.copyWith(
      timelinePixelsPerSecond: pixelsPerSecond ?? _pixelsPerSecond,
      timelineTrackHeight: trackHeight ?? _trackHeight,
    );
    controller.updateEditorLayout(layout);
  }

  void _setZoom(double value) {
    final next = value.clamp(20, 240).toDouble();
    if ((next - _pixelsPerSecond).abs() < 0.01) return;
    setState(() => _pixelsPerSecond = next);
    _updateLayout(pixelsPerSecond: next);
  }

  void _setTrackHeight(double value) {
    final next = value.clamp(42, 120).toDouble();
    if ((next - _trackHeight).abs() < 0.01) return;
    setState(() => _trackHeight = next);
    _updateLayout(trackHeight: next);
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final preview = ref.watch(previewControllerProvider);
    final controller = ref.read(studioControllerProvider.notifier);
    final previewController = ref.read(previewControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final world = preview.world;
    final plan = TimelinePlan(
      project: widget.ready.project,
      scene: widget.ready.currentScene,
      chain: widget.ready.activeChain,
    );
    final currentTime = world?.currentTime ?? 0;
    final duration = world?.totalDuration ?? plan.duration;
    final tracks = plan.tracks;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final timelineWidth = math
              .max(
                constraints.maxWidth - 170,
                math.max(760, duration * _pixelsPerSecond + 120),
              )
              .toDouble();
          final selectedEventId = widget.ready.selection is EventSelection
              ? (widget.ready.selection! as EventSelection).eventId
              : null;
          final selectedChainId = widget.ready.selection?.chainId;
          return Column(
            children: [
              _TimelineControls(
                preview: preview,
                currentTime: currentTime,
                duration: duration,
                currentEventId: world?.currentEventId,
                onPlay: preview.isPlaying
                    ? previewController.pause
                    : () => previewController.play(widget.ready),
                onStop: previewController.stop,
                onSeek: (time) => previewController.seek(widget.ready, time),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 44,
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.eventChains,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.addEventChain,
                      onPressed: controller.addEventChain,
                      icon: const Icon(Icons.add),
                    ),
                    _AddEventMenu(
                      enabled: widget.ready.activeChain != null,
                      sampleCharacterId: widget.sampleCharacterId,
                      onSelected: controller.addEventToSelectedChain,
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: tracks.isEmpty
                    ? Center(child: Text(l10n.createOrSelectChain))
                    : Stack(
                        children: [
                          Listener(
                            onPointerSignal: (event) {
                              if (event is! PointerScrollEvent ||
                                  !HardwareKeyboard.instance.logicalKeysPressed
                                      .any(
                                        (key) =>
                                            key ==
                                                LogicalKeyboardKey.metaLeft ||
                                            key ==
                                                LogicalKeyboardKey.metaRight ||
                                            key ==
                                                LogicalKeyboardKey
                                                    .controlLeft ||
                                            key ==
                                                LogicalKeyboardKey.controlRight,
                                      )) {
                                return;
                              }
                              _setZoom(
                                _pixelsPerSecond - event.scrollDelta.dy * 0.12,
                              );
                            },
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    _TimelineRuler(
                                      width: timelineWidth,
                                      pixelsPerSecond: _pixelsPerSecond,
                                    ),
                                    for (final track in tracks)
                                      _TimelineTrackRow(
                                        track: track,
                                        width: timelineWidth,
                                        pixelsPerSecond: _pixelsPerSecond,
                                        currentTime: currentTime,
                                        height: _trackHeight,
                                        project: widget.ready.project,
                                        scene: widget.ready.currentScene,
                                        collapsed: _collapsedChains.contains(
                                          track.chain.id,
                                        ),
                                        selectedChain:
                                            selectedChainId == track.chain.id,
                                        selectedEventId: selectedEventId,
                                        onToggleCollapsed: () => setState(() {
                                          if (!_collapsedChains.add(
                                            track.chain.id,
                                          )) {
                                            _collapsedChains.remove(
                                              track.chain.id,
                                            );
                                          }
                                        }),
                                        onSelectChain: () => controller
                                            .selectChain(track.chain.id),
                                        onSelectEvent: (eventId) {
                                          controller.selectEvent(
                                            track.chain.id,
                                            eventId,
                                          );
                                        },
                                        onRemoveEvent: controller.removeEvent,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: _TimelineViewControls(
                              pixelsPerSecond: _pixelsPerSecond,
                              trackHeight: _trackHeight,
                              onZoom: _setZoom,
                              onTrackHeight: _setTrackHeight,
                              onFit: () => _setZoom(
                                ((constraints.maxWidth - 190) /
                                        math.max(duration, 1))
                                    .clamp(20, 240)
                                    .toDouble(),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimelineControls extends StatelessWidget {
  const _TimelineControls({
    required this.preview,
    required this.currentTime,
    required this.duration,
    required this.currentEventId,
    required this.onPlay,
    required this.onStop,
    required this.onSeek,
  });

  final PreviewState preview;
  final double currentTime;
  final double duration;
  final String? currentEventId;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final max = duration <= 0 ? 1.0 : duration;
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            tooltip: preview.isPlaying ? l10n.pause : l10n.play,
            onPressed: onPlay,
            icon: Icon(preview.isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            tooltip: l10n.stop,
            onPressed: onStop,
            icon: const Icon(Icons.stop),
          ),
          SizedBox(
            width: 94,
            child: Text(
              '${currentTime.toStringAsFixed(1)} / ${duration.toStringAsFixed(1)}s',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Slider(
              value: currentTime.clamp(0, max),
              min: 0,
              max: max,
              onChanged: onSeek,
            ),
          ),
          SizedBox(
            width: 130,
            child: Text(
              currentEventId ?? l10n.noEvent,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _TimelineRuler extends StatelessWidget {
  const _TimelineRuler({required this.width, required this.pixelsPerSecond});

  final double width;
  final double pixelsPerSecond;

  @override
  Widget build(BuildContext context) {
    final seconds = math.max(1, (width / pixelsPerSecond).ceil());
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('0s', style: Theme.of(context).textTheme.labelSmall),
            ),
          ),
          SizedBox(
            width: width,
            child: Stack(
              children: [
                for (var second = 0; second <= seconds; second += 1)
                  Positioned(
                    left: second * pixelsPerSecond,
                    top: 0,
                    child: Text(
                      '${second}s',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineViewControls extends StatelessWidget {
  const _TimelineViewControls({
    required this.pixelsPerSecond,
    required this.trackHeight,
    required this.onZoom,
    required this.onTrackHeight,
    required this.onFit,
  });

  final double pixelsPerSecond;
  final double trackHeight;
  final ValueChanged<double> onZoom;
  final ValueChanged<double> onTrackHeight;
  final VoidCallback onFit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: l10n.timelineZoom,
              onPressed: () => onZoom(pixelsPerSecond - 10),
              icon: const Icon(Icons.remove, size: 17),
            ),
            Text(
              '${pixelsPerSecond.round()}%',
              style: const TextStyle(fontSize: 11),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: l10n.timelineZoom,
              onPressed: () => onZoom(pixelsPerSecond + 10),
              icon: const Icon(Icons.add, size: 17),
            ),
            const VerticalDivider(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: l10n.timelineFit,
              onPressed: onFit,
              icon: const Icon(Icons.fit_screen, size: 17),
            ),
            PopupMenuButton<double>(
              tooltip: l10n.timelineTrackHeight,
              initialValue: trackHeight,
              onSelected: onTrackHeight,
              itemBuilder: (context) => [
                for (final height in [42.0, 56.0, 66.0, 82.0, 100.0, 120.0])
                  PopupMenuItem(
                    value: height,
                    child: Text('${height.round()} px'),
                  ),
              ],
              icon: const Icon(Icons.height, size: 17),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineTrackRow extends StatelessWidget {
  const _TimelineTrackRow({
    required this.track,
    required this.width,
    required this.pixelsPerSecond,
    required this.currentTime,
    required this.height,
    required this.project,
    required this.scene,
    required this.collapsed,
    required this.selectedChain,
    required this.onToggleCollapsed,
    required this.selectedEventId,
    required this.onSelectChain,
    required this.onSelectEvent,
    required this.onRemoveEvent,
  });

  final TimelineChainTrack track;
  final double width;
  final double pixelsPerSecond;
  final double currentTime;
  final double height;
  final StudioProject project;
  final Scene scene;
  final bool collapsed;
  final bool selectedChain;
  final String? selectedEventId;
  final VoidCallback onToggleCollapsed;
  final VoidCallback onSelectChain;
  final ValueChanged<String> onSelectEvent;
  final ValueChanged<String> onRemoveEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: collapsed ? 44 : height,
      child: Row(
        children: [
          InkWell(
            onTap: onSelectChain,
            child: Container(
              width: 150,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: selectedChain
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    onPressed: onToggleCollapsed,
                    icon: Icon(
                      collapsed ? Icons.chevron_right : Icons.expand_more,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.chain.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (!collapsed)
                          Text(
                            track.chain.triggerMode ==
                                    EventChainTriggerMode.always
                                ? AppLocalizations.of(
                                    context,
                                  )!.timelineTriggerAlways
                                : AppLocalizations.of(
                                    context,
                                  )!.timelineTriggerPoint,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!collapsed)
            SizedBox(
              width: width,
              height: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelectChain,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _TimelineGridPainter(
                          pixelsPerSecond: pixelsPerSecond,
                          color: theme.dividerColor,
                        ),
                      ),
                    ),
                    for (final span in track.spans)
                      _TimelineEventBlock(
                        span: span,
                        project: project,
                        scene: scene,
                        left: span.start * pixelsPerSecond,
                        width: math.max(
                          76,
                          span.displayDuration * pixelsPerSecond,
                        ),
                        height: height - 8,
                        selected: selectedEventId == span.event.eventId,
                        onTap: () => onSelectEvent(span.event.eventId),
                        onRemove: () => onRemoveEvent(span.event.eventId),
                      ),
                    Positioned(
                      left: currentTime * pixelsPerSecond,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: Container(
                          width: 2,
                          color: theme.colorScheme.error.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineGridPainter extends CustomPainter {
  const _TimelineGridPainter({
    required this.pixelsPerSecond,
    required this.color,
  });

  final double pixelsPerSecond;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    for (var x = 0.0; x <= size.width; x += pixelsPerSecond) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _TimelineGridPainter oldDelegate) {
    return oldDelegate.pixelsPerSecond != pixelsPerSecond ||
        oldDelegate.color != color;
  }
}

class _TimelineEventBlock extends StatelessWidget {
  const _TimelineEventBlock({
    required this.span,
    required this.project,
    required this.scene,
    required this.left,
    required this.width,
    required this.height,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final TimelineSpan span;
  final StudioProject project;
  final Scene scene;
  final double left;
  final double width;
  final double height;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _eventColor(span.event);
    return Positioned(
      left: left + 2,
      top: 7,
      width: width - 4,
      height: height,
      child: Material(
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
      ),
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
    final dx = node.x - x;
    final dy = node.y - y;
    final targetX = dx.abs() >= dy.abs() ? node.x : x;
    final targetY = dx.abs() >= dy.abs() ? y : node.y;
    elapsed +=
        math.sqrt(math.pow(targetX - x, 2) + math.pow(targetY - y, 2)) /
        math.max(event.path.speed, 1);
    ratios.add((elapsed / math.max(duration, 0.1)).clamp(0.0, 1.0));
    x = targetX;
    y = targetY;
    elapsed += node.waitSeconds ?? 0;
    final triggerId = node.triggerId ?? triggerAtPoint(scene, node.x, node.y);
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
      var x = value.path.nodes.isEmpty ? 0 : value.path.nodes.first.x;
      var y = value.path.nodes.isEmpty ? 0 : value.path.nodes.first.y;
      for (var index = 1; index < value.path.nodes.length; index += 1) {
        final node = value.path.nodes[index];
        final dx = node.x - x;
        final dy = node.y - y;
        final targetX = dx.abs() >= dy.abs() ? node.x : x;
        final targetY = dx.abs() >= dy.abs() ? y : node.y;
        total +=
            math.sqrt(math.pow(targetX - x, 2) + math.pow(targetY - y, 2)) /
            math.max(value.path.speed, 1);
        total += node.waitSeconds ?? 0;
        final triggerId =
            node.triggerId ?? triggerAtPoint(scene, node.x, node.y);
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
  });

  final bool enabled;
  final String? sampleCharacterId;
  final ValueChanged<StudioEvent> onSelected;

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
      child: DecoratedBox(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
