import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/default_event_factories.dart';
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
part 'inspector_event_part.dart';
part 'inspector_picker_part.dart';

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
              defaultMoveEvent(_firstCharacterObjectId(ready)),
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
