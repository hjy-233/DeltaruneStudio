import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/editor/default_event_factories.dart';
import 'package:deltarune_studio/l10n/event_labels.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventChainPanel extends ConsumerWidget {
  const EventChainPanel({
    required this.ready,
    required this.sampleCharacterId,
    super.key,
  });

  final StudioReady ready;
  final String? sampleCharacterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(previewControllerProvider);
    final controller = ref.read(studioControllerProvider.notifier);
    final previewController = ref.read(previewControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final world = preview.world;
    final plan = TimelinePlan(
      project: ready.project,
      scene: ready.currentScene,
      chain: ready.activeChain,
    );
    final currentTime = world?.currentTime ?? 0;
    final duration = world?.totalDuration ?? plan.duration;
    final tracks = plan.tracks;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pixelsPerSecond = 100.0;
          final timelineWidth = math
              .max(
                constraints.maxWidth - 170,
                math.max(760, duration * pixelsPerSecond + 120),
              )
              .toDouble();
          final selectedEventId = ready.selection is EventSelection
              ? (ready.selection! as EventSelection).eventId
              : null;
          return Column(
            children: [
              _TimelineControls(
                preview: preview,
                currentTime: currentTime,
                duration: duration,
                currentEventId: world?.currentEventId,
                onPlay: preview.isPlaying
                    ? previewController.pause
                    : () => previewController.play(ready),
                onStop: previewController.stop,
                onSeek: (time) => previewController.seek(ready, time),
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
                      enabled: ready.activeChain != null,
                      sampleCharacterId: sampleCharacterId,
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
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _TimelineRuler(
                                width: timelineWidth,
                                pixelsPerSecond: pixelsPerSecond,
                              ),
                              for (final track in tracks)
                                _TimelineTrackRow(
                                  track: track,
                                  width: timelineWidth,
                                  pixelsPerSecond: pixelsPerSecond,
                                  currentTime: currentTime,
                                  selectedEventId: selectedEventId,
                                  onSelectChain: () =>
                                      controller.selectChain(track.chain.id),
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

class _TimelineTrackRow extends StatelessWidget {
  const _TimelineTrackRow({
    required this.track,
    required this.width,
    required this.pixelsPerSecond,
    required this.currentTime,
    required this.selectedEventId,
    required this.onSelectChain,
    required this.onSelectEvent,
    required this.onRemoveEvent,
  });

  final TimelineChainTrack track;
  final double width;
  final double pixelsPerSecond;
  final double currentTime;
  final String? selectedEventId;
  final VoidCallback onSelectChain;
  final ValueChanged<String> onSelectEvent;
  final ValueChanged<String> onRemoveEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          InkWell(
            onTap: onSelectChain,
            child: Container(
              width: 150,
              height: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: track.chain.triggerMode == EventChainTriggerMode.always
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.28)
                    : theme.colorScheme.surfaceContainerHigh,
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  track.chain.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
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
                      left: span.start * pixelsPerSecond,
                      width: math.max(
                        76,
                        span.displayDuration * pixelsPerSecond,
                      ),
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
    required this.left,
    required this.width,
    required this.selected,
    required this.onTap,
    required this.onRemove,
  });

  final TimelineSpan span;
  final double left;
  final double width;
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
      height: 44,
      child: Tooltip(
        message:
            '${eventLabel(l10n, span.event)}\n'
            '${span.start.toStringAsFixed(2)}s - '
            '${span.displayEndValue.toStringAsFixed(2)}s',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: selected ? Colors.white : color,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      eventLabel(l10n, span.event),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    InkWell(
                      onTap: onRemove,
                      child: const Icon(
                        Icons.close,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
