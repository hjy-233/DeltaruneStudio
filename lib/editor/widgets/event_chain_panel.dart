import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/editor/studio_workspace.dart';
import 'package:deltarune_studio/l10n/event_labels.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _triggerModeLabel(AppLocalizations l10n, EventChainTriggerMode mode) {
  return switch (mode) {
    EventChainTriggerMode.triggerPoint => l10n.triggerModeTriggerPoint,
    EventChainTriggerMode.always => l10n.triggerModeAlways,
  };
}

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
    final chain = ready.activeChain;
    final preview = ref.watch(previewControllerProvider);
    final controller = ref.read(studioControllerProvider.notifier);
    final previewController = ref.read(previewControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final world = preview.world;
    final fallbackDuration = TimelinePlan(
      project: ready.project,
      scene: ready.currentScene,
      chain: chain,
    ).duration;
    final currentTime = world?.currentTime ?? 0;
    final duration = world?.totalDuration ?? fallbackDuration;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showChainList = constraints.maxWidth >= 320;
          return Row(
            children: [
              if (showChainList)
                SizedBox(
                  width: 150,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      Row(
                        children: [
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
                        ],
                      ),
                      for (final candidate in ready.currentScene.eventChains)
                        ListTile(
                          dense: true,
                          selected: candidate.id == chain?.id,
                          leading: const Icon(Icons.account_tree),
                          title: Text(
                            candidate.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_triggerModeLabel(l10n, candidate.triggerMode)} · '
                            '${l10n.eventsCount(candidate.events.length)}',
                          ),
                          onTap: () => controller.selectChain(candidate.id),
                        ),
                    ],
                  ),
                ),
              if (showChainList) const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 62,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 520,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              IconButton(
                                tooltip: preview.isPlaying
                                    ? l10n.pause
                                    : l10n.play,
                                onPressed: preview.isPlaying
                                    ? previewController.pause
                                    : () => previewController.play(ready),
                                icon: Icon(
                                  preview.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                              IconButton(
                                tooltip: l10n.stop,
                                onPressed: previewController.stop,
                                icon: const Icon(Icons.stop),
                              ),
                              SizedBox(
                                width: 92,
                                child: Text(
                                  '${currentTime.toStringAsFixed(1)} / ${duration.toStringAsFixed(1)}s',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: duration <= 0
                                      ? 0
                                      : currentTime.clamp(0, duration),
                                  min: 0,
                                  max: duration <= 0 ? 1 : duration,
                                  onChanged: (time) =>
                                      previewController.seek(ready, time),
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: Text(
                                  world?.currentEventId ?? l10n.noEvent,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SizedBox(
                      height: 44,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 360,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  chain?.name ?? 'No Chain',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _AddEventMenu(
                                enabled: chain != null,
                                sampleCharacterId: sampleCharacterId,
                                onSelected: controller.addEventToSelectedChain,
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: chain == null
                          ? Center(child: Text(l10n.createOrSelectChain))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(12),
                              itemCount: chain.events.length,
                              itemBuilder: (context, index) {
                                final event = chain.events[index];
                                final selected =
                                    ready.selection is EventSelection &&
                                    (ready.selection as EventSelection)
                                            .eventId ==
                                        event.eventId;
                                return _EventCard(
                                  index: index,
                                  event: event,
                                  selected: selected,
                                  chainId: chain.id,
                                  onTap: () => controller.selectEvent(
                                    chain.id,
                                    event.eventId,
                                  ),
                                  onRemove: () =>
                                      controller.removeEvent(event.eventId),
                                );
                              },
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

class _EventCard extends ConsumerWidget {
  const _EventCard({
    required this.index,
    required this.event,
    required this.selected,
    required this.chainId,
    required this.onTap,
    required this.onRemove,
  });

  final int index;
  final StudioEvent event;
  final bool selected;
  final String chainId;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 12, child: Text('${index + 1}')),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _title(l10n, event),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.deleteEvent,
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _description(l10n, event),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (event is CharacterMoveEvent) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => ref
                      .read(studioControllerProvider.notifier)
                      .addPathNode(chainId, event.eventId),
                  icon: const Icon(Icons.add_location_alt, size: 16),
                  label: Text(l10n.addNode),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n, StudioEvent event) {
    return eventLabel(l10n, event);
  }

  String _description(AppLocalizations l10n, StudioEvent event) {
    return event.map(
      characterMove: (value) => l10n.moveDescription(
        value.path.nodes.length,
        value.path.speed,
        value.path.shake,
      ),
      characterStartFollow: (value) =>
          '${value.followerObjectId} -> ${value.leaderObjectId}, ${value.distance}px',
      characterStopFollow: (value) => value.followerObjectId,
      characterWait: (value) => '${value.duration}s',
      characterChangeExpression: (value) =>
          '${value.expressionId}, ${value.duration}s',
      dialogueSay: (value) => '${value.text} (${value.style.name})',
      cameraFollow: (value) => value.targetObjectId,
      cameraFocus: (value) => value.target.toString(),
      sceneFade: (value) => '${value.mode.name}, ${value.duration}s',
      sceneChange: (value) => value.entryPointId ?? value.sceneId,
      audioPlayBgm: (value) =>
          value.assetId.isEmpty ? l10n.noAssetSelected : value.assetId,
      audioPlaySound: (value) =>
          value.assetId.isEmpty ? l10n.noAssetSelected : value.assetId,
      videoPlay: (value) =>
          value.assetId.isEmpty ? l10n.noAssetSelected : value.assetId,
    );
  }
}
