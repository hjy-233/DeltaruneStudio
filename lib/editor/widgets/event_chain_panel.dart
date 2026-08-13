import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/editor/default_event_factories.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:deltarune_studio/runtime/movement_path_geometry.dart';
import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

part 'event_chain_timeline_blocks.dart';

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
  final ScrollController _timelineVerticalController = ScrollController();
  final ScrollController _timelineLabelsController = ScrollController();
  bool _syncingTimelineScroll = false;
  double _pixelsPerSecond = 100;
  double _trackHeight = 66;

  @override
  void dispose() {
    _timelineVerticalController.dispose();
    _timelineLabelsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _readLayout(widget.ready.project.editorLayout);
    _timelineVerticalController.addListener(_syncTimelineLabels);
  }

  void _syncTimelineLabels() {
    if (_syncingTimelineScroll ||
        !_timelineLabelsController.hasClients ||
        !_timelineVerticalController.hasClients) {
      return;
    }
    _syncingTimelineScroll = true;
    final target = _timelineVerticalController.offset.clamp(
      0.0,
      _timelineLabelsController.position.maxScrollExtent,
    );
    if ((_timelineLabelsController.offset - target).abs() > 0.1) {
      _timelineLabelsController.jumpTo(target);
    }
    _syncingTimelineScroll = false;
  }

  @override
  void didUpdateWidget(covariant EventChainPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ready.project.id != widget.ready.project.id) {
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
                    Text(
                      l10n.eventChains,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    IconButton(
                      tooltip: l10n.addEventChain,
                      onPressed: controller.addEventChain,
                      icon: const Icon(Icons.add),
                    ),
                    const Spacer(),
                    _TimelineViewControls(
                      pixelsPerSecond: _pixelsPerSecond,
                      trackHeight: _trackHeight,
                      onZoom: _setZoom,
                      onTrackHeight: _setTrackHeight,
                      onFit: () => _setZoom(
                        ((constraints.maxWidth - 190) / math.max(duration, 1))
                            .clamp(20, 240)
                            .toDouble(),
                      ),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: _TimelineFixedLabels(
                                    controller: _timelineLabelsController,
                                    tracks: tracks,
                                    selectedChainId: selectedChainId,
                                    trackHeight: _trackHeight,
                                    sampleCharacterId: widget.sampleCharacterId,
                                    onAddEvent:
                                        controller.addEventToSelectedChain,
                                    onSelectChain: controller.selectChain,
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SizedBox(
                                      width: timelineWidth,
                                      child: SingleChildScrollView(
                                        controller: _timelineVerticalController,
                                        child: Column(
                                          children: [
                                            _TimelineRuler(
                                              width: timelineWidth,
                                              pixelsPerSecond: _pixelsPerSecond,
                                              showLabel: false,
                                            ),
                                            for (final track in tracks)
                                              _TimelineTrackRow(
                                                track: track,
                                                width: timelineWidth,
                                                pixelsPerSecond:
                                                    _pixelsPerSecond,
                                                currentTime: currentTime,
                                                height: _trackHeight,
                                                project: widget.ready.project,
                                                scene:
                                                    widget.ready.currentScene,
                                                selectedChain:
                                                    selectedChainId ==
                                                    track.chain.id,
                                                selectedEventId:
                                                    selectedEventId,
                                                onSelectChain: () =>
                                                    controller.selectChain(
                                                      track.chain.id,
                                                    ),
                                                onSelectEvent: (eventId) =>
                                                    controller.selectEvent(
                                                      track.chain.id,
                                                      eventId,
                                                    ),
                                                onRemoveEvent:
                                                    controller.removeEvent,
                                                onAddPathNode:
                                                    controller.addPathNode,
                                                onMoveScheduledEvent: controller
                                                    .moveScheduledEvent,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
  const _TimelineRuler({
    required this.width,
    required this.pixelsPerSecond,
    this.showLabel = true,
  });

  final double width;
  final double pixelsPerSecond;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final seconds = math.max(1, (width / pixelsPerSecond).ceil());
    return SizedBox(
      height: 26,
      child: Row(
        children: [
          if (showLabel)
            SizedBox(
              width: 150,
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  '0s',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
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
    return Padding(
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
    required this.selectedChain,
    required this.selectedEventId,
    required this.onSelectChain,
    required this.onSelectEvent,
    required this.onRemoveEvent,
    required this.onAddPathNode,
    required this.onMoveScheduledEvent,
  });

  final TimelineChainTrack track;
  final double width;
  final double pixelsPerSecond;
  final double currentTime;
  final double height;
  final StudioProject project;
  final Scene scene;
  final bool selectedChain;
  final String? selectedEventId;
  final VoidCallback onSelectChain;
  final ValueChanged<String> onSelectEvent;
  final ValueChanged<String> onRemoveEvent;
  final void Function(String chainId, String eventId) onAddPathNode;
  final void Function(String chainId, String eventId, double startTime)
  onMoveScheduledEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Row(
        children: [
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
                      scheduled:
                          track.chain.triggerMode ==
                          EventChainTriggerMode.scheduled,
                      pixelsPerSecond: pixelsPerSecond,
                      trackOffset: track.offset,
                      onScheduleChanged: (time) => onMoveScheduledEvent(
                        track.chain.id,
                        span.event.eventId,
                        time,
                      ),
                      onTap: () => onSelectEvent(span.event.eventId),
                      onRemove: () => onRemoveEvent(span.event.eventId),
                      onAddPathNode: span.event is CharacterMoveEvent
                          ? () => onAddPathNode(
                              track.chain.id,
                              span.event.eventId,
                            )
                          : null,
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

class _ScheduledEventDrag extends StatefulWidget {
  const _ScheduledEventDrag({
    required this.pixelsPerSecond,
    required this.startTime,
    required this.onChanged,
    required this.child,
  });

  final double pixelsPerSecond;
  final double startTime;
  final ValueChanged<double> onChanged;
  final Widget child;

  @override
  State<_ScheduledEventDrag> createState() => _ScheduledEventDragState();
}

class _ScheduledEventDragState extends State<_ScheduledEventDrag> {
  double _dragSeconds = 0;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        setState(() {
          _dragging = true;
          _dragSeconds = 0;
        });
      },
      onHorizontalDragUpdate: (details) {
        final delta = details.primaryDelta ?? 0;
        if (delta == 0) {
          return;
        }
        setState(() {
          _dragSeconds += delta / widget.pixelsPerSecond;
        });
      },
      onHorizontalDragEnd: (_) => _commitDrag(),
      onHorizontalDragCancel: _cancelDrag,
      child: Transform.translate(
        offset: _dragging
            ? Offset(_dragSeconds * widget.pixelsPerSecond, 0)
            : Offset.zero,
        child: widget.child,
      ),
    );
  }

  void _commitDrag() {
    if (!_dragging) {
      return;
    }
    widget.onChanged(math.max(0, widget.startTime + _dragSeconds));
    _cancelDrag();
  }

  void _cancelDrag() {
    if (!mounted) {
      return;
    }
    setState(() {
      _dragging = false;
      _dragSeconds = 0;
    });
  }
}

class _TimelineFixedLabels extends StatelessWidget {
  const _TimelineFixedLabels({
    required this.controller,
    required this.tracks,
    required this.selectedChainId,
    required this.onSelectChain,
    required this.trackHeight,
    required this.sampleCharacterId,
    required this.onAddEvent,
  });

  final ScrollController controller;
  final List<TimelineChainTrack> tracks;
  final String? selectedChainId;
  final ValueChanged<String> onSelectChain;
  final double trackHeight;
  final String? sampleCharacterId;
  final ValueChanged<StudioEvent> onAddEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 26),
          for (final track in tracks)
            SizedBox(
              height: trackHeight,
              child: InkWell(
                onTap: () => onSelectChain(track.chain.id),
                child: Container(
                  padding: const EdgeInsets.only(left: 4, right: 12),
                  decoration: BoxDecoration(
                    color: selectedChainId == track.chain.id
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surfaceContainerHighest,
                    border: Border(
                      top: BorderSide(color: theme.dividerColor),
                      bottom: BorderSide(color: theme.dividerColor),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 0),
                      _AddEventMenu(
                        enabled: true,
                        sampleCharacterId: sampleCharacterId,
                        compact: true,
                        onSelected: (event) {
                          onSelectChain(track.chain.id);
                          onAddEvent(event);
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.chain.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(switch (track.chain.triggerMode) {
                              EventChainTriggerMode.always =>
                                l10n.timelineTriggerAlways,
                              EventChainTriggerMode.triggerPoint =>
                                l10n.timelineTriggerPoint,
                              EventChainTriggerMode.scheduled =>
                                l10n.timelineTriggerScheduled,
                            }, style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
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
