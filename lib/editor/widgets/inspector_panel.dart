import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/editor/widgets/inspector_form_fields.dart';
import 'package:deltarune_studio/l10n/event_labels.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class InspectorPanel extends ConsumerWidget {
  const InspectorPanel({required this.ready, super.key});

  final StudioReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ready.selection;
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.inspector, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          switch (selection) {
            ObjectSelection(:final objectId) => _ObjectInspector(
              ready: ready,
              object: ready.objectById(objectId),
            ),
            ObjectMultiSelection(:final objectIds) => _MultiObjectInspector(
              ready: ready,
              objectIds: objectIds,
            ),
            TriggerSelection(:final triggerId) => _TriggerInspector(
              ready: ready,
              trigger: ready.triggerById(triggerId),
            ),
            EventChainSelection(:final chainId) => _ChainInspector(
              ready: ready,
              chain: ready.chainById(chainId),
            ),
            EventSelection(:final chainId, :final eventId) => _EventInspector(
              ready: ready,
              chainId: chainId,
              event: ready.eventById(chainId, eventId),
            ),
            PathNodeSelection(:final chainId, :final eventId, :final nodeId) =>
              _PathNodeInspector(
                ready: ready,
                chainId: chainId,
                eventId: eventId,
                node: ready.pathNodeById(chainId, eventId, nodeId),
              ),
            AssetSelection(:final assetId) => _AssetInspector(
              ready: ready,
              asset: ready.assetById(assetId),
            ),
            CharacterSelection(:final characterId) => _CharacterInspector(
              ready: ready,
              character: ready.characterById(characterId),
            ),
            null => _NoSelectionActions(ready: ready),
          },
        ],
      ),
    );
  }
}

class _NoSelectionActions extends ConsumerWidget {
  const _NoSelectionActions({required this.ready});

  final StudioReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final activeChain = ready.activeChain;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: controller.addRoomBackground,
          icon: const Icon(Icons.meeting_room),
          label: Text(l10n.addRoom),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: controller.addCharacterInstance,
          icon: const Icon(Icons.person_add),
          label: Text(l10n.addActor),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: controller.addTriggerPoint,
          icon: const Icon(Icons.radio_button_checked),
          label: Text(l10n.addDoorTrigger),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: controller.importBackground,
          icon: const Icon(Icons.wallpaper),
          label: Text(l10n.importBackground),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: controller.importProp,
          icon: const Icon(Icons.category),
          label: Text(l10n.importProp),
        ),
        const SizedBox(height: 16),
        if (activeChain == null)
          FilledButton.icon(
            onPressed: controller.addEventChain,
            icon: const Icon(Icons.account_tree),
            label: Text(l10n.createEventChain),
          )
        else
          FilledButton.icon(
            onPressed: () => controller.addEventToSelectedChain(
              _defaultMoveEvent(_firstCharacterObjectId(ready)),
            ),
            icon: const Icon(Icons.route),
            label: Text(l10n.addMoveEvent),
          ),
      ],
    );
  }

  String? _firstCharacterObjectId(StudioReady ready) {
    for (final object in ready.currentScene.objects) {
      if (object is CharacterInstanceObject) {
        return object.id;
      }
    }
    return ready.currentScene.objects.isEmpty
        ? null
        : ready.currentScene.objects.first.objectId;
  }

  StudioEvent _defaultMoveEvent(String? objectId) {
    return StudioEvent.characterMove(
      id: StudioIds.event(),
      characterObjectId: objectId ?? '',
      path: MovementPath(
        nodes: [
          const PathNode(id: 'path_a', name: 'Start', x: 120, y: 180),
          const PathNode(id: 'path_b', name: 'Node 2', x: 240, y: 180),
          const PathNode(id: 'path_c', name: 'Node 3', x: 240, y: 120),
        ],
        speed: 320,
        shake: 12,
      ),
    );
  }
}

class _ObjectInspector extends ConsumerWidget {
  const _ObjectInspector({required this.ready, required this.object});

  final StudioReady ready;
  final SceneObject? object;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = object;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingObject);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final transform = value.objectTransform;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(_kindName(l10n, value)),
        InspectorStringField(
          label: l10n.name,
          value: _objectName(value),
          onChanged: (name) =>
              controller.updateObject(_renameObject(value, name)),
        ),
        const SizedBox(height: 12),
        value.map(
          characterInstance: (character) => Column(
            children: [
              _DropdownField<String>(
                label: l10n.character,
                value: character.characterId,
                values: ready.project.characters
                    .map((item) => item.id)
                    .toList(),
                labelFor: (id) => ready.characterById(id)?.name ?? id,
                onChanged: (id) => controller.updateObject(
                  character.copyWith(characterId: id),
                ),
              ),
            ],
          ),
          background: (background) => Column(
            children: [
              if (background.assetId.isEmpty)
                InspectorInfo(label: l10n.visual, value: l10n.builtInRoom),
              _AssetPicker(
                ready: ready,
                kind: AssetKind.background,
                value: background.assetId,
                onChanged: (assetId) => controller.updateObject(
                  background.copyWith(assetId: assetId),
                ),
              ),
            ],
          ),
          prop: (prop) => Column(
            children: [
              _AssetPicker(
                ready: ready,
                kind: AssetKind.prop,
                value: prop.assetId,
                onChanged: (assetId) =>
                    controller.updateObject(prop.copyWith(assetId: assetId)),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.interactable),
                value: prop.interactable,
                onChanged: (interactable) => controller.updateObject(
                  prop.copyWith(interactable: interactable),
                ),
              ),
            ],
          ),
          triggerPoint: (triggerPoint) => _TriggerReferenceEditor(
            ready: ready,
            triggerId: triggerPoint.triggerId,
          ),
          triggerArea: (triggerArea) => _TriggerReferenceEditor(
            ready: ready,
            triggerId: triggerArea.triggerId,
          ),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.locked),
          value: _objectLocked(value),
          onChanged: (locked) =>
              controller.updateObject(_withObjectLocked(value, locked)),
        ),
        const SizedBox(height: 12),
        _TransformEditor(
          transform: transform,
          onChanged: controller.updateSelectedTransform,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.moveSelectedLayer(-1),
              icon: const Icon(Icons.keyboard_arrow_down),
              label: Text(l10n.back),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.moveSelectedLayer(1),
              icon: const Icon(Icons.keyboard_arrow_up),
              label: Text(l10n.front),
            ),
            OutlinedButton.icon(
              onPressed: controller.moveSelectedToBack,
              icon: const Icon(Icons.vertical_align_bottom),
              label: Text(l10n.bottom),
            ),
            OutlinedButton.icon(
              onPressed: controller.moveSelectedToFront,
              icon: const Icon(Icons.vertical_align_top),
              label: Text(l10n.top),
            ),
            FilledButton.tonalIcon(
              onPressed: controller.deleteSelectedObject,
              icon: const Icon(Icons.delete),
              label: Text(l10n.delete),
            ),
          ],
        ),
      ],
    );
  }

  String _kindName(AppLocalizations l10n, SceneObject object) {
    return object.map(
      characterInstance: (_) => l10n.characterInstance,
      prop: (_) => l10n.propObject,
      background: (_) => l10n.backgroundObject,
      triggerPoint: (_) => l10n.triggerPoint,
      triggerArea: (_) => l10n.triggerPoint,
    );
  }

  String _objectName(SceneObject object) {
    return object.map(
      characterInstance: (value) => value.name,
      prop: (value) => value.name,
      background: (value) => value.name,
      triggerPoint: (value) => value.name,
      triggerArea: (value) => value.name,
    );
  }

  SceneObject _renameObject(SceneObject object, String name) {
    return object.map(
      characterInstance: (value) => value.copyWith(name: name),
      prop: (value) => value.copyWith(name: name),
      background: (value) => value.copyWith(name: name),
      triggerPoint: (value) => value.copyWith(name: name),
      triggerArea: (value) => value.copyWith(name: name),
    );
  }

  bool _objectLocked(SceneObject object) {
    return object.map(
      characterInstance: (value) => value.locked,
      prop: (value) => value.locked,
      background: (value) => value.locked,
      triggerPoint: (value) => value.locked,
      triggerArea: (value) => value.locked,
    );
  }

  SceneObject _withObjectLocked(SceneObject object, bool locked) {
    return object.map(
      characterInstance: (value) => value.copyWith(locked: locked),
      prop: (value) => value.copyWith(locked: locked),
      background: (value) => value.copyWith(locked: locked),
      triggerPoint: (value) => value.copyWith(locked: locked),
      triggerArea: (value) => value.copyWith(locked: locked),
    );
  }
}

class _MultiObjectInspector extends ConsumerWidget {
  const _MultiObjectInspector({required this.ready, required this.objectIds});

  final StudioReady ready;
  final List<String> objectIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final objects = objectIds
        .map(ready.objectById)
        .whereType<SceneObject>()
        .toList(growable: false);
    if (objects.isEmpty) {
      return Text(AppLocalizations.of(context)!.missingObject);
    }
    final l10n = AppLocalizations.of(context)!;
    final allLocked = objects.every(_objectLocked);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle('多选对象'),
        InspectorInfo(label: '数量', value: '${objects.length}'),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.locked),
          value: allLocked,
          onChanged: (locked) => controller.setObjectsLocked(
            objects.map((object) => object.objectId).toList(),
            locked,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => controller.moveObjectsById(objectIds, -1, 0),
              icon: const Icon(Icons.keyboard_arrow_left),
              label: const Text('X -1'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.moveObjectsById(objectIds, 1, 0),
              icon: const Icon(Icons.keyboard_arrow_right),
              label: const Text('X +1'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.moveObjectsById(objectIds, 0, -1),
              icon: const Icon(Icons.keyboard_arrow_up),
              label: const Text('Y -1'),
            ),
            OutlinedButton.icon(
              onPressed: () => controller.moveObjectsById(objectIds, 0, 1),
              icon: const Icon(Icons.keyboard_arrow_down),
              label: const Text('Y +1'),
            ),
            FilledButton.tonalIcon(
              onPressed: controller.deleteSelectedObject,
              icon: const Icon(Icons.delete),
              label: Text(l10n.delete),
            ),
          ],
        ),
      ],
    );
  }

  bool _objectLocked(SceneObject object) {
    return object.map(
      characterInstance: (value) => value.locked,
      prop: (value) => value.locked,
      background: (value) => value.locked,
      triggerPoint: (value) => value.locked,
      triggerArea: (value) => value.locked,
    );
  }
}

class _TriggerReferenceEditor extends ConsumerWidget {
  const _TriggerReferenceEditor({required this.ready, required this.triggerId});

  final StudioReady ready;
  final String triggerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trigger = ready.triggerById(triggerId);
    if (trigger == null) {
      return Text(AppLocalizations.of(context)!.missingTrigger);
    }
    return _TriggerInspector(ready: ready, trigger: trigger);
  }
}

class _TriggerInspector extends ConsumerWidget {
  const _TriggerInspector({required this.ready, required this.trigger});

  final StudioReady ready;
  final Trigger? trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = trigger;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingTrigger);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(l10n.triggerPoint),
        InspectorStringField(
          label: l10n.name,
          value: ready.triggerName(value),
          onChanged: (name) => controller.updateTrigger(_rename(value, name)),
        ),
        _DropdownField<String>(
          label: l10n.eventChain,
          value: ready.triggerChainId(value) ?? '',
          values: ready.currentScene.eventChains
              .map((chain) => chain.id)
              .toList(),
          labelFor: (id) => ready.chainById(id)?.name ?? id,
          onChanged: (chainId) => controller.updateTrigger(
            value.map(
              area: (item) => item.copyWith(eventChainId: chainId),
              object: (item) => item.copyWith(eventChainId: chainId),
              auto: (item) => item.copyWith(eventChainId: chainId),
              moveComplete: (item) => item.copyWith(eventChainId: chainId),
            ),
          ),
        ),
        _DropdownField<String?>(
          label: l10n.linkedDoor,
          value: ready.triggerLinkedTriggerId(value),
          values: [
            null,
            ...ready.currentScene.triggers
                .where(
                  (trigger) =>
                      ready.triggerId(trigger) != ready.triggerId(value),
                )
                .map(ready.triggerId),
          ],
          labelFor: (id) => id == null
              ? l10n.none
              : ready.triggerName(ready.triggerById(id)!),
          onChanged: (linkedTriggerId) => controller.updateTrigger(
            value.map(
              area: (item) => item.copyWith(linkedTriggerId: linkedTriggerId),
              object: (item) => item.copyWith(linkedTriggerId: linkedTriggerId),
              auto: (item) => item.copyWith(linkedTriggerId: linkedTriggerId),
              moveComplete: (item) =>
                  item.copyWith(linkedTriggerId: linkedTriggerId),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.triggerPointHelp,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Trigger _rename(Trigger trigger, String name) {
    return trigger.map(
      area: (value) => value.copyWith(name: name),
      object: (value) => value.copyWith(name: name),
      auto: (value) => value.copyWith(name: name),
      moveComplete: (value) => value.copyWith(name: name),
    );
  }
}

class _ChainInspector extends ConsumerWidget {
  const _ChainInspector({required this.ready, required this.chain});

  final StudioReady ready;
  final EventChain? chain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = chain;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingEventChain);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(l10n.eventChain),
        InspectorStringField(
          label: l10n.name,
          value: value.name,
          onChanged: (name) =>
              controller.updateEventChain(value.copyWith(name: name)),
        ),
        _DropdownField<EventChainTriggerMode>(
          label: l10n.triggerMode,
          value: value.triggerMode,
          values: EventChainTriggerMode.values,
          labelFor: (mode) => switch (mode) {
            EventChainTriggerMode.triggerPoint => l10n.triggerModeTriggerPoint,
            EventChainTriggerMode.always => l10n.triggerModeAlways,
          },
          onChanged: (mode) =>
              controller.updateEventChain(value.copyWith(triggerMode: mode)),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.eventsCount(value.events.length),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => controller.deleteEventChain(value.id),
          icon: const Icon(Icons.delete),
          label: Text(l10n.delete),
        ),
      ],
    );
  }
}

class _EventInspector extends ConsumerWidget {
  const _EventInspector({
    required this.ready,
    required this.chainId,
    required this.event,
  });

  final StudioReady ready;
  final String chainId;
  final StudioEvent? event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = event;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingEvent);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(eventLabel(l10n, value)),
        value.map(
          characterMove: (move) => Column(
            children: [
              _ObjectPicker(
                ready: ready,
                label: l10n.character,
                value: move.characterObjectId,
                characterOnly: true,
                onChanged: (id) => controller.updateEvent(
                  chainId,
                  move.copyWith(characterObjectId: id),
                ),
              ),
              InspectorNumberField(
                label: l10n.speed,
                value: move.path.speed,
                onChanged: (speed) => controller.updateEvent(
                  chainId,
                  move.copyWith(path: move.path.copyWith(speed: speed)),
                ),
              ),
              InspectorNumberField(
                label: l10n.shake,
                value: move.path.shake,
                onChanged: (shake) => controller.updateEvent(
                  chainId,
                  move.copyWith(path: move.path.copyWith(shake: shake)),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => controller.addPathNode(chainId, move.id),
                icon: const Icon(Icons.add_location_alt),
                label: Text(l10n.addPathNode),
              ),
              const SizedBox(height: 8),
              for (final node in move.path.nodes)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.route),
                  title: Text(node.name),
                  subtitle: Text(
                    l10n.nodeCoordinates(
                      node.x.toStringAsFixed(1),
                      node.y.toStringAsFixed(1),
                    ),
                  ),
                  onTap: () =>
                      controller.selectPathNode(chainId, move.id, node.id),
                ),
            ],
          ),
          characterStartFollow: (follow) => Column(
            children: [
              _ObjectPicker(
                ready: ready,
                label: '跟随者',
                value: follow.followerObjectId,
                characterOnly: true,
                onChanged: (id) => controller.updateEvent(
                  chainId,
                  follow.copyWith(followerObjectId: id),
                ),
              ),
              _ObjectPicker(
                ready: ready,
                label: '目标角色',
                value: follow.leaderObjectId,
                characterOnly: true,
                onChanged: (id) => controller.updateEvent(
                  chainId,
                  follow.copyWith(leaderObjectId: id),
                ),
              ),
              InspectorNumberField(
                label: '跟随距离',
                value: follow.distance,
                onChanged: (distance) => controller.updateEvent(
                  chainId,
                  follow.copyWith(distance: distance.clamp(0, 9999)),
                ),
              ),
            ],
          ),
          characterStopFollow: (follow) => _ObjectPicker(
            ready: ready,
            label: '跟随者',
            value: follow.followerObjectId,
            characterOnly: true,
            onChanged: (id) => controller.updateEvent(
              chainId,
              follow.copyWith(followerObjectId: id),
            ),
          ),
          characterWait: (wait) => InspectorNumberField(
            label: l10n.duration,
            value: wait.duration,
            onChanged: (duration) => controller.updateEvent(
              chainId,
              wait.copyWith(duration: duration),
            ),
          ),
          characterChangeExpression: (expression) => Column(
            children: [
              _ObjectPicker(
                ready: ready,
                label: l10n.character,
                value: expression.characterObjectId,
                characterOnly: true,
                onChanged: (id) => controller.updateEvent(
                  chainId,
                  expression.copyWith(characterObjectId: id),
                ),
              ),
              _ExpressionPicker(
                ready: ready,
                characterObjectId: expression.characterObjectId,
                label: l10n.expression,
                value: expression.expressionId,
                onChanged: (id) => controller.updateEvent(
                  chainId,
                  expression.copyWith(expressionId: id),
                ),
              ),
              InspectorNumberField(
                label: l10n.duration,
                value: expression.duration,
                onChanged: (duration) => controller.updateEvent(
                  chainId,
                  expression.copyWith(duration: duration),
                ),
              ),
            ],
          ),
          dialogueSay: (dialogue) => Column(
            children: [
              InspectorStringField(
                label: l10n.text,
                value: dialogue.text,
                maxLines: 4,
                onChanged: (text) => controller.updateEvent(
                  chainId,
                  dialogue.copyWith(text: text),
                ),
              ),
              _DialoguePortraitPicker(
                ready: ready,
                value: dialogue.portraitAssetId ?? '',
                onChanged: (assetId) => controller.updateEvent(
                  chainId,
                  dialogue.copyWith(
                    portraitAssetId: assetId.isEmpty ? null : assetId,
                  ),
                ),
              ),
              _DialogueSoundPicker(
                ready: ready,
                value: dialogue.textSoundAssetId ?? '',
                onChanged: (assetId) => controller.updateEvent(
                  chainId,
                  dialogue.copyWith(
                    textSoundAssetId: assetId.isEmpty ? null : assetId,
                  ),
                ),
              ),
              _DropdownField<DialogueStyle>(
                label: l10n.dialogueStyle,
                value: dialogue.style,
                values: DialogueStyle.values,
                labelFor: (style) => switch (style) {
                  DialogueStyle.regular => l10n.dialogueStyleRegular,
                  DialogueStyle.darkWorld => l10n.dialogueStyleDarkWorld,
                },
                onChanged: (style) => controller.updateEvent(
                  chainId,
                  dialogue.copyWith(style: style),
                ),
              ),
              InspectorNumberField(
                label: l10n.duration,
                value: dialogue.duration,
                onChanged: (duration) => controller.updateEvent(
                  chainId,
                  dialogue.copyWith(duration: duration),
                ),
              ),
            ],
          ),
          cameraFollow: (camera) => _ObjectPicker(
            ready: ready,
            label: l10n.target,
            value: camera.targetObjectId,
            onChanged: (id) => controller.updateEvent(
              chainId,
              camera.copyWith(targetObjectId: id),
            ),
          ),
          cameraFocus: (camera) => _FocusEditor(
            focus: camera,
            onChanged: (next) => controller.updateEvent(chainId, next),
          ),
          sceneFade: (fade) => Column(
            children: [
              _DropdownField<FadeMode>(
                label: l10n.mode,
                value: fade.mode,
                values: FadeMode.values,
                labelFor: (mode) => mode == FadeMode.in_ ? 'in' : 'out',
                onChanged: (mode) =>
                    controller.updateEvent(chainId, fade.copyWith(mode: mode)),
              ),
              InspectorNumberField(
                label: l10n.duration,
                value: fade.duration,
                onChanged: (duration) => controller.updateEvent(
                  chainId,
                  fade.copyWith(duration: duration),
                ),
              ),
            ],
          ),
          sceneChange: (scene) => InspectorStringField(
            label: l10n.canvasMarker,
            value: scene.entryPointId ?? scene.sceneId,
            onChanged: (marker) => controller.updateEvent(
              chainId,
              scene.copyWith(entryPointId: marker),
            ),
          ),
          audioPlayBgm: (audio) => _AudioEventEditor(
            ready: ready,
            assetId: audio.assetId,
            isBgm: true,
            onChanged: (assetId) => controller.updateEvent(
              chainId,
              audio.copyWith(assetId: assetId),
            ),
          ),
          audioPlaySound: (audio) => _AudioEventEditor(
            ready: ready,
            assetId: audio.assetId,
            isBgm: false,
            onChanged: (assetId) => controller.updateEvent(
              chainId,
              audio.copyWith(assetId: assetId),
            ),
          ),
          videoPlay: (video) => Column(
            children: [
              _AssetPicker(
                ready: ready,
                kind: AssetKind.video,
                value: video.assetId,
                onChanged: (assetId) => controller.updateEvent(
                  chainId,
                  video.copyWith(assetId: assetId),
                ),
              ),
              InspectorInfo(label: 'Fit', value: video.fit.name),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => controller.removeEvent(value.eventId),
          icon: const Icon(Icons.delete),
          label: Text(l10n.deleteEvent),
        ),
      ],
    );
  }
}

class _PathNodeInspector extends ConsumerWidget {
  const _PathNodeInspector({
    required this.ready,
    required this.chainId,
    required this.eventId,
    required this.node,
  });

  final StudioReady ready;
  final String chainId;
  final String eventId;
  final PathNode? node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = node;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingPathNode);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    void update(PathNode next) {
      controller.updatePathNode(chainId, eventId, value.id, (_) => next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(l10n.pathNode),
        InspectorStringField(
          label: l10n.name,
          value: value.name,
          onChanged: (name) => update(value.copyWith(name: name)),
        ),
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: 'X',
                value: value.x,
                onChanged: (x) => update(value.copyWith(x: x)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InspectorNumberField(
                label: 'Y',
                value: value.y,
                onChanged: (y) => update(value.copyWith(y: y)),
              ),
            ),
          ],
        ),
        InspectorNumberField(
          label: l10n.waitSeconds,
          value: value.waitSeconds ?? 0,
          onChanged: (seconds) => update(
            value.copyWith(waitSeconds: seconds <= 0 ? null : seconds),
          ),
        ),
        _DropdownField<String?>(
          label: l10n.linkedTrigger,
          value: value.triggerId,
          values: [null, ...ready.currentScene.triggers.map(ready.triggerId)],
          labelFor: (id) => id == null
              ? l10n.none
              : ready.triggerName(ready.triggerById(id)!),
          onChanged: (triggerId) =>
              update(value.copyWith(triggerId: triggerId)),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () =>
              controller.removePathNode(chainId, eventId, value.id),
          icon: const Icon(Icons.delete),
          label: Text(l10n.deleteNode),
        ),
      ],
    );
  }
}

class _AssetInspector extends ConsumerWidget {
  const _AssetInspector({required this.ready, required this.asset});

  final StudioReady ready;
  final AssetRef? asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = asset;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingAsset);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final file = ready.projectDirectory == null
        ? null
        : File(p.join(ready.projectDirectory!.path, value.relativePath));
    final missing = file != null && !file.existsSync();
    final used = ready.assetIsUsed(value.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(l10n.asset),
        if (missing)
          Text(l10n.missingFile, style: const TextStyle(color: Colors.orange)),
        InspectorStringField(
          label: l10n.name,
          value: value.originalName,
          onChanged: (name) =>
              controller.updateAsset(value.copyWith(originalName: name)),
        ),
        InspectorInfo(label: l10n.kind, value: value.kind.name),
        InspectorInfo(label: l10n.path, value: value.relativePath),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: used ? null : () => controller.deleteUnusedAsset(value.id),
          icon: const Icon(Icons.delete),
          label: Text(used ? l10n.assetInUse : l10n.deleteAsset),
        ),
      ],
    );
  }
}

class _CharacterInspector extends ConsumerWidget {
  const _CharacterInspector({required this.ready, required this.character});

  final StudioReady ready;
  final Character? character;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = character;
    if (value == null) {
      return Text(AppLocalizations.of(context)!.missingCharacter);
    }
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(l10n.characterDefinition),
        InspectorStringField(
          label: l10n.name,
          value: value.name,
          onChanged: (name) =>
              controller.updateCharacter(value.copyWith(name: name)),
        ),
        InspectorNumberField(
          label: l10n.defaultSpeed,
          value: value.movement.defaultSpeed,
          onChanged: (speed) => controller.updateCharacter(
            value.copyWith(
              movement: value.movement.copyWith(defaultSpeed: speed),
            ),
          ),
        ),
        InspectorNumberField(
          label: l10n.defaultShake,
          value: value.movement.defaultShake,
          onChanged: (shake) => controller.updateCharacter(
            value.copyWith(
              movement: value.movement.copyWith(defaultShake: shake),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('默认大小', style: Theme.of(context).textTheme.titleSmall),
        InspectorNumberField(
          label: 'Width',
          value: value.defaultTransform.width * value.defaultTransform.scale,
          onChanged: (width) => controller.updateCharacter(
            value.copyWith(
              defaultTransform: value.defaultTransform.copyWith(
                width: width,
                scale: 1,
              ),
            ),
          ),
        ),
        InspectorNumberField(
          label: 'Height',
          value: value.defaultTransform.height * value.defaultTransform.scale,
          onChanged: (height) => controller.updateCharacter(
            value.copyWith(
              defaultTransform: value.defaultTransform.copyWith(
                height: height,
                scale: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Directional sprites',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        _DirectionalSpriteSlots(ready: ready, characterId: value.id),
        const SizedBox(height: 12),
        Text(l10n.expressions, style: Theme.of(context).textTheme.titleSmall),
        for (final expression in value.expressions)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                InspectorStringField(
                  label: expression.id,
                  value: expression.name,
                  onChanged: (name) => controller.updateCharacter(
                    value.copyWith(
                      expressions: value.expressions
                          .map(
                            (item) => item.id == expression.id
                                ? item.copyWith(name: name)
                                : item,
                          )
                          .toList(),
                    ),
                  ),
                ),
                _ExpressionSpriteSlot(
                  ready: ready,
                  character: value,
                  expression: expression,
                ),
              ],
            ),
          ),
        FilledButton.tonalIcon(
          onPressed: () {
            final expression = CharacterExpression(
              id: 'expr_${StudioIds.event()}',
              name: 'Expression ${value.expressions.length + 1}',
            );
            controller.updateCharacter(
              value.copyWith(expressions: [...value.expressions, expression]),
            );
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.addExpression),
        ),
      ],
    );
  }
}

class _DirectionalSpriteSlots extends ConsumerWidget {
  const _DirectionalSpriteSlots({
    required this.ready,
    required this.characterId,
  });

  final StudioReady ready;
  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ready.characterById(characterId);
    if (character == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final direction in Direction.values)
          _SpriteSlot(ready: ready, character: character, direction: direction),
        _SpriteSlot(ready: ready, character: character, direction: null),
      ],
    );
  }
}

class _ExpressionSpriteSlot extends ConsumerWidget {
  const _ExpressionSpriteSlot({
    required this.ready,
    required this.character,
    required this.expression,
  });

  final StudioReady ready;
  final Character character;
  final CharacterExpression expression;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final frames = [
      ...expression.assetIds,
      if ((expression.assetId ?? '').isNotEmpty) expression.assetId!,
    ];
    final imageAssets = ready.project.assets
        .where(
          (asset) =>
              asset.kind != AssetKind.audio && asset.kind != AssetKind.video,
        )
        .toList();

    void update(CharacterExpression next) {
      controller.updateCharacter(
        character.copyWith(
          expressions: character.expressions
              .map((item) => item.id == expression.id ? next : item)
              .toList(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var index = 0; index < frames.length; index += 1)
              InputChip(
                label: Text(_assetName(frames[index])),
                onDeleted: () {
                  final nextFrames = [...frames]..removeAt(index);
                  update(
                    expression.copyWith(assetId: null, assetIds: nextFrames),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          isExpanded: true,
          decoration: const InputDecoration(
            isDense: true,
            border: OutlineInputBorder(),
            labelText: 'Add expression frame',
          ),
          initialValue: null,
          items: [
            for (final asset in imageAssets)
              DropdownMenuItem(
                value: asset.id,
                child: Text(
                  asset.originalName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (assetId) {
            if (assetId == null) {
              return;
            }
            update(
              expression.copyWith(
                assetId: null,
                assetIds: [...frames, assetId],
              ),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: 'FPS',
                value: expression.framesPerSecond,
                onChanged: (fps) => update(
                  expression.copyWith(framesPerSecond: fps.clamp(0.1, 60)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Loop'),
                value: expression.loop,
                onChanged: (loop) => update(expression.copyWith(loop: loop)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _assetName(String assetId) {
    return ready.assetById(assetId)?.originalName ?? assetId;
  }
}

class _SpriteSlot extends ConsumerWidget {
  const _SpriteSlot({
    required this.ready,
    required this.character,
    required this.direction,
  });

  final StudioReady ready;
  final Character character;
  final Direction? direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final frames = character.animations
        .where((animation) => animation.direction == direction)
        .toList();
    final imageAssets = ready.project.assets
        .where(
          (asset) =>
              asset.kind != AssetKind.audio && asset.kind != AssetKind.video,
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            direction?.name ?? 'fallback',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final frame in frames)
                InputChip(
                  label: Text(_assetName(frame.assetId)),
                  onDeleted: () => controller.removeCharacterAnimationFrame(
                    characterId: character.id,
                    animationId: frame.id,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              labelText: 'Add sprite frame',
            ),
            initialValue: null,
            items: [
              for (final asset in imageAssets)
                DropdownMenuItem(
                  value: asset.id,
                  child: Text(
                    asset.originalName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (assetId) {
              if (assetId == null) {
                return;
              }
              controller.addCharacterAnimationFrame(
                characterId: character.id,
                assetId: assetId,
                direction: direction,
              );
            },
          ),
        ],
      ),
    );
  }

  String _assetName(String assetId) {
    return ready.assetById(assetId)?.originalName ?? assetId;
  }
}

class _FocusEditor extends StatelessWidget {
  const _FocusEditor({required this.focus, required this.onChanged});

  final CameraFocusEvent focus;
  final ValueChanged<CameraFocusEvent> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        InspectorNumberField(
          label: l10n.duration,
          value: focus.duration,
          onChanged: (duration) =>
              onChanged(focus.copyWith(duration: duration)),
        ),
        InspectorNumberField(
          label: l10n.pointX,
          value: focus.target.maybeMap(
            point: (point) => point.x,
            orElse: () => 0,
          ),
          onChanged: (x) => onChanged(
            focus.copyWith(
              target: FocusTarget.point(
                x: x,
                y: focus.target.maybeMap(
                  point: (point) => point.y,
                  orElse: () => 0,
                ),
              ),
            ),
          ),
        ),
        InspectorNumberField(
          label: l10n.pointY,
          value: focus.target.maybeMap(
            point: (point) => point.y,
            orElse: () => 0,
          ),
          onChanged: (y) => onChanged(
            focus.copyWith(
              target: FocusTarget.point(
                x: focus.target.maybeMap(
                  point: (point) => point.x,
                  orElse: () => 0,
                ),
                y: y,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpressionPicker extends StatelessWidget {
  const _ExpressionPicker({
    required this.ready,
    required this.characterObjectId,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String characterObjectId;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final object = ready.objectById(characterObjectId);
    final characterId = object is CharacterInstanceObject
        ? object.characterId
        : null;
    final character = ready.characterById(characterId);
    final expressions = character?.expressions ?? const <CharacterExpression>[];
    return _DropdownField<String>(
      label: label,
      value: value,
      values: expressions.map((expression) => expression.id).toList(),
      labelFor: (id) =>
          expressions
              .where((expression) => expression.id == id)
              .firstOrNull
              ?.name ??
          id,
      onChanged: onChanged,
    );
  }
}

class _TransformEditor extends StatelessWidget {
  const _TransformEditor({required this.transform, required this.onChanged});

  final Transform2D transform;
  final ValueChanged<Transform2D> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(l10n.advancedPosition),
      children: [
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: 'X',
                value: transform.x,
                onChanged: (x) => onChanged(transform.copyWith(x: x)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InspectorNumberField(
                label: 'Y',
                value: transform.y,
                onChanged: (y) => onChanged(transform.copyWith(y: y)),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: InspectorNumberField(
                label: l10n.width,
                value: transform.width,
                onChanged: (width) =>
                    onChanged(transform.copyWith(width: width)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InspectorNumberField(
                label: l10n.height,
                value: transform.height,
                onChanged: (height) =>
                    onChanged(transform.copyWith(height: height)),
              ),
            ),
          ],
        ),
        InspectorNumberField(
          label: l10n.scale,
          value: transform.scale,
          onChanged: (scale) => onChanged(transform.copyWith(scale: scale)),
        ),
      ],
    );
  }
}

class _ObjectPicker extends StatelessWidget {
  const _ObjectPicker({
    required this.ready,
    required this.label,
    required this.value,
    required this.onChanged,
    this.characterOnly = false,
  });

  final StudioReady ready;
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool characterOnly;

  @override
  Widget build(BuildContext context) {
    final objects = ready.currentScene.objects.where((object) {
      return !characterOnly || object is CharacterInstanceObject;
    }).toList();
    return _DropdownField<String>(
      label: label,
      value: value,
      values: objects.map((object) => object.objectId).toList(),
      labelFor: (id) =>
          ready
              .objectById(id)
              ?.map(
                characterInstance: (value) => value.name,
                prop: (value) => value.name,
                background: (value) => value.name,
                triggerPoint: (value) => value.name,
                triggerArea: (value) => value.name,
              ) ??
          id,
      onChanged: onChanged,
    );
  }
}

class _AudioEventEditor extends ConsumerWidget {
  const _AudioEventEditor({
    required this.ready,
    required this.assetId,
    required this.isBgm,
    required this.onChanged,
  });

  final StudioReady ready;
  final String assetId;
  final bool isBgm;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AssetPicker(
          ready: ready,
          kind: AssetKind.audio,
          value: assetId,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: assetId.isEmpty
              ? null
              : () => ref
                    .read(previewControllerProvider.notifier)
                    .previewAudioAsset(ready, assetId, bgm: isBgm),
          icon: const Icon(Icons.volume_up),
          label: Text(l10n.play),
        ),
      ],
    );
  }
}

class _AssetPicker extends StatelessWidget {
  const _AssetPicker({
    required this.ready,
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final AssetKind kind;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assets = ready.project.assets
        .where((asset) => asset.kind == kind)
        .map((asset) => asset.id)
        .toList();
    if (value.isEmpty) {
      assets.insert(0, '');
    }
    if (!assets.contains(value) && value.isNotEmpty) {
      assets.add(value);
    }
    return _DropdownField<String>(
      label: l10n.asset,
      value: value,
      values: assets,
      labelFor: (id) => id.isEmpty
          ? l10n.builtIn
          : ready.assetById(id)?.originalName ?? l10n.missingAsset,
      onChanged: onChanged,
    );
  }
}

class _DialoguePortraitPicker extends ConsumerStatefulWidget {
  const _DialoguePortraitPicker({
    required this.ready,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_DialoguePortraitPicker> createState() =>
      _DialoguePortraitPickerState();
}

class _DialoguePortraitPickerState
    extends ConsumerState<_DialoguePortraitPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = _query.trim().toLowerCase();
    final importedPortraits = widget.ready.project.assets
        .where((asset) => asset.kind == AssetKind.dialoguePortrait)
        .where((asset) {
          if (normalized.isEmpty) {
            return true;
          }
          return asset.originalName.toLowerCase().contains(normalized) ||
              asset.relativePath.toLowerCase().contains(normalized);
        })
        .toList();
    final selected = widget.ready.assetById(widget.value);
    final builtInLibrary = ref.watch(builtInAssetLibraryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.portrait,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: ref
                  .read(studioControllerProvider.notifier)
                  .importDialoguePortrait,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('导入头像'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search, size: 18),
            labelText: '搜索对话头像',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        if (selected != null && widget.value.isNotEmpty)
          InputChip(
            avatar: _AssetTinyPreview(ready: widget.ready, asset: selected),
            label: Text(selected.originalName, overflow: TextOverflow.ellipsis),
            onDeleted: () => widget.onChanged(''),
          )
        else
          Text(l10n.none, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SizedBox(
          height: 300,
          child: ListView(
            children: [
              _PortraitGridHeader(
                label: '用户导入',
                count: importedPortraits.length,
              ),
              if (importedPortraits.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '还没有导入头像',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                )
              else
                _ImportedPortraitGrid(
                  ready: widget.ready,
                  portraits: importedPortraits,
                  selectedAssetId: widget.value,
                  onChanged: widget.onChanged,
                ),
              const SizedBox(height: 12),
              builtInLibrary.when(
                data: (library) {
                  final builtIns = _filterBuiltInPortraits(
                    library.assets,
                    normalized,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PortraitGridHeader(
                        label: '内置头像库',
                        count: builtIns.length,
                      ),
                      if (builtIns.isEmpty)
                        Text(
                          '没有匹配的内置头像',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      else
                        _BuiltInPortraitGrid(
                          portraits: builtIns.take(240).toList(),
                          onSelected: ref
                              .read(studioControllerProvider.notifier)
                              .addBuiltInAsset,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                  '$error',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<BuiltInAsset> _filterBuiltInPortraits(
    List<BuiltInAsset> assets,
    String normalized,
  ) {
    return assets.where((asset) {
      if (asset.kind != AssetKind.dialoguePortrait ||
          !asset.assetPath.startsWith('assets/dialogue/portraits/')) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      return asset.name.toLowerCase().contains(normalized) ||
          asset.sourcePath.toLowerCase().contains(normalized);
    }).toList();
  }
}

class _PortraitGridHeader extends StatelessWidget {
  const _PortraitGridHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label ($count)',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _ImportedPortraitGrid extends StatelessWidget {
  const _ImportedPortraitGrid({
    required this.ready,
    required this.portraits,
    required this.selectedAssetId,
    required this.onChanged,
  });

  final StudioReady ready;
  final List<AssetRef> portraits;
  final String selectedAssetId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: portraits.length,
      itemBuilder: (context, index) {
        final asset = portraits[index];
        return _PortraitTile(
          active: asset.id == selectedAssetId,
          title: asset.originalName,
          image: _AssetPreviewImage(ready: ready, asset: asset),
          onTap: () => onChanged(asset.id),
        );
      },
    );
  }
}

class _BuiltInPortraitGrid extends StatelessWidget {
  const _BuiltInPortraitGrid({
    required this.portraits,
    required this.onSelected,
  });

  final List<BuiltInAsset> portraits;
  final ValueChanged<BuiltInAsset> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
      ),
      itemCount: portraits.length,
      itemBuilder: (context, index) {
        final asset = portraits[index];
        return _PortraitTile(
          active: false,
          title: asset.name,
          image: _BuiltInPortraitPreview(asset: asset),
          onTap: () => onSelected(asset),
        );
      },
    );
  }
}

class _PortraitTile extends StatelessWidget {
  const _PortraitTile({
    required this.active,
    required this.title,
    required this.image,
    required this.onTap,
  });

  final bool active;
  final String title;
  final Widget image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Expanded(child: image),
              const SizedBox(height: 4),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuiltInPortraitPreview extends StatelessWidget {
  const _BuiltInPortraitPreview({required this.asset});

  final BuiltInAsset asset;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.asset(
        asset.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
      );
    }
    return Image.file(
      File(asset.resolvedPath),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
    );
  }
}

class _DialogueSoundPicker extends ConsumerStatefulWidget {
  const _DialogueSoundPicker({
    required this.ready,
    required this.value,
    required this.onChanged,
  });

  final StudioReady ready;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  ConsumerState<_DialogueSoundPicker> createState() =>
      _DialogueSoundPickerState();
}

class _DialogueSoundPickerState extends ConsumerState<_DialogueSoundPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final normalized = _query.trim().toLowerCase();
    final importedSounds = widget.ready.project.assets
        .where((asset) => asset.kind == AssetKind.audio)
        .where((asset) {
          if (normalized.isEmpty) {
            return true;
          }
          return asset.originalName.toLowerCase().contains(normalized) ||
              asset.relativePath.toLowerCase().contains(normalized);
        })
        .toList();
    final selected = widget.ready.assetById(widget.value);
    final builtInLibrary = ref.watch(builtInAssetLibraryProvider);
    final controller = ref.read(studioControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                '打字音效',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton.icon(
              onPressed: controller.importAudio,
              icon: const Icon(Icons.library_music),
              label: const Text('导入音效'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: const InputDecoration(
            isDense: true,
            prefixIcon: Icon(Icons.search, size: 18),
            labelText: '搜索对话音效',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        if (widget.value.isNotEmpty)
          InputChip(
            avatar: const Icon(Icons.volume_up, size: 18),
            label: Text(
              selected?.originalName ?? _builtInSoundName(widget.value),
              overflow: TextOverflow.ellipsis,
            ),
            onDeleted: () => widget.onChanged(''),
          )
        else
          Text(
            AppLocalizations.of(context)!.none,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView(
            children: [
              _SoundListHeader(label: '用户导入', count: importedSounds.length),
              for (final asset in importedSounds)
                _SoundTile(
                  title: asset.originalName,
                  subtitle: asset.relativePath,
                  active: asset.id == widget.value,
                  onTap: () => widget.onChanged(asset.id),
                  onPreview: () => ref
                      .read(previewControllerProvider.notifier)
                      .previewAudioAsset(widget.ready, asset.id),
                ),
              if (importedSounds.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '还没有导入音效',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              builtInLibrary.when(
                data: (library) {
                  final sounds = _filterDialogueSounds(
                    library.assets,
                    normalized,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SoundListHeader(label: '内置音效库', count: sounds.length),
                      for (final sound in sounds.take(160))
                        _SoundTile(
                          title: sound.name,
                          subtitle: sound.sourcePath,
                          active: sound.id == widget.value,
                          onTap: () => controller.addBuiltInAsset(sound),
                          onPreview: () => ref
                              .read(previewControllerProvider.notifier)
                              .previewAudioAssetId(widget.ready, sound.id),
                        ),
                      if (sounds.isEmpty)
                        Text(
                          '没有匹配的内置音效',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                  '$error',
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _builtInSoundName(String assetId) {
    final library = ref.read(builtInAssetLibraryProvider).valueOrNull;
    return library?.assets
            .where((asset) => asset.id == assetId)
            .firstOrNull
            ?.name ??
        assetId;
  }

  List<BuiltInAsset> _filterDialogueSounds(
    List<BuiltInAsset> assets,
    String normalized,
  ) {
    return assets.where((asset) {
      if (asset.kind != AssetKind.audio ||
          !asset.assetPath.startsWith('assets/dialogue/sound/')) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      return asset.name.toLowerCase().contains(normalized) ||
          asset.sourcePath.toLowerCase().contains(normalized);
    }).toList();
  }
}

class _SoundListHeader extends StatelessWidget {
  const _SoundListHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        '$label ($count)',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

class _SoundTile extends StatelessWidget {
  const _SoundTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
    required this.onPreview,
  });

  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      selected: active,
      leading: IconButton(
        tooltip: '试听',
        icon: const Icon(Icons.play_arrow),
        onPressed: onPreview,
      ),
      title: Text(title, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis),
      onTap: onTap,
    );
  }
}

class _AssetTinyPreview extends StatelessWidget {
  const _AssetTinyPreview({required this.ready, required this.asset});

  final StudioReady ready;
  final AssetRef asset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: _AssetPreviewImage(ready: ready, asset: asset),
    );
  }
}

class _AssetPreviewImage extends StatelessWidget {
  const _AssetPreviewImage({required this.ready, required this.asset});

  final StudioReady ready;
  final AssetRef asset;

  @override
  Widget build(BuildContext context) {
    final dataUri = asset.dataUri;
    if (dataUri != null && dataUri.isNotEmpty) {
      return Image.memory(
        _bytesFromDataUri(dataUri),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
        errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
      );
    }
    final directory = ready.projectDirectory;
    if (directory == null) {
      return const Icon(Icons.image);
    }
    final file = File(p.join(directory.path, asset.relativePath));
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image);
    }
    return Image.file(
      file,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      isAntiAlias: false,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
    );
  }
}

Uint8List _bytesFromDataUri(String dataUri) {
  final comma = dataUri.indexOf(',');
  if (comma < 0) {
    return Uint8List(0);
  }
  return base64Decode(dataUri.substring(comma + 1));
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return InspectorInfo(
        label: label,
        value: AppLocalizations.of(context)!.none,
      );
    }
    final actualValue = values.contains(value) ? value : values.first;
    return DropdownButtonFormField<T>(
      initialValue: actualValue,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final item in values)
          DropdownMenuItem<T>(value: item, child: Text(labelFor(item))),
      ],
      onChanged: (next) {
        if (next != null || null is T) {
          onChanged(next as T);
        }
      },
    );
  }
}
