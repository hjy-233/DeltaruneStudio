import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';

sealed class StudioState {
  const StudioState();

  const factory StudioState.loading() = StudioLoading;
  const factory StudioState.ready({
    required StudioProject project,
    Directory? projectDirectory,
    EditorSelection? selection,
    bool isDirty,
    String? statusMessage,
  }) = StudioReady;

  StudioReady? get asReady => switch (this) {
    final StudioReady ready => ready,
    StudioLoading() => null,
  };
}

final class StudioLoading extends StudioState {
  const StudioLoading();
}

final class StudioReady extends StudioState {
  const StudioReady({
    required this.project,
    this.projectDirectory,
    this.selection,
    this.clipboardObjects = const [],
    this.isDirty = false,
    this.statusMessage,
  });

  final StudioProject project;
  final Directory? projectDirectory;
  final EditorSelection? selection;
  final List<SceneObject> clipboardObjects;
  final bool isDirty;
  final String? statusMessage;

  String? get selectedObjectId => selection.objectId;

  Scene get currentScene => project.scenes.firstWhere(
    (scene) => scene.id == project.currentSceneId,
    orElse: () => project.scenes.first,
  );

  SceneObject? get selectedObject => objectById(selection.objectId);

  EventChain? get activeChain {
    if (currentScene.eventChains.isEmpty) {
      return null;
    }
    final chainId = selection.chainId;
    if (chainId == null) {
      return currentScene.eventChains.first;
    }
    return chainById(chainId) ?? currentScene.eventChains.first;
  }

  SceneObject? objectById(String? id) {
    if (id == null) {
      return null;
    }
    for (final object in currentScene.objects) {
      if (object.objectId == id) {
        return object;
      }
    }
    return null;
  }

  Trigger? triggerById(String? id) {
    if (id == null) {
      return null;
    }
    for (final trigger in currentScene.triggers) {
      if (triggerId(trigger) == id) {
        return trigger;
      }
    }
    return null;
  }

  EventChain? chainById(String? id) {
    if (id == null) {
      return null;
    }
    for (final chain in currentScene.eventChains) {
      if (chain.id == id) {
        return chain;
      }
    }
    return null;
  }

  StudioEvent? eventById(String chainId, String eventId) {
    final chain = chainById(chainId);
    if (chain == null) {
      return null;
    }
    for (final event in chain.events) {
      if (event.eventId == eventId) {
        return event;
      }
    }
    return null;
  }

  PathNode? pathNodeById(String chainId, String eventId, String nodeId) {
    final event = eventById(chainId, eventId);
    if (event is! CharacterMoveEvent) {
      return null;
    }
    for (final node in event.path.nodes) {
      if (node.id == nodeId) {
        return node;
      }
    }
    return null;
  }

  AssetRef? assetById(String? id) {
    if (id == null) {
      return null;
    }
    for (final asset in project.assets) {
      if (asset.id == id) {
        return asset;
      }
    }
    return null;
  }

  Character? characterById(String? id) {
    if (id == null) {
      return null;
    }
    for (final character in project.characters) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }

  bool assetIsUsed(String assetId) {
    for (final object in currentScene.objects) {
      final used = object.maybeMap(
        prop: (value) => value.assetId == assetId,
        background: (value) => value.assetId == assetId,
        orElse: () => false,
      );
      if (used) {
        return true;
      }
    }
    for (final character in project.characters) {
      for (final animation in character.animations) {
        if (animation.assetId == assetId) {
          return true;
        }
      }
    }
    return false;
  }

  String triggerId(Trigger trigger) {
    return trigger.map(
      area: (value) => value.id,
      object: (value) => value.id,
      auto: (value) => value.id,
      moveComplete: (value) => value.id,
    );
  }

  String triggerName(Trigger trigger) {
    return trigger.map(
      area: (value) => value.name,
      object: (value) => value.name,
      auto: (value) => value.name,
      moveComplete: (value) => value.name,
    );
  }

  String? triggerChainId(Trigger trigger) {
    return trigger.map(
      area: (value) => value.eventChainId,
      object: (value) => value.eventChainId,
      auto: (value) => value.eventChainId,
      moveComplete: (value) => value.eventChainId,
    );
  }

  String? triggerLinkedTriggerId(Trigger trigger) {
    return trigger.map(
      area: (value) => value.linkedTriggerId,
      object: (value) => value.linkedTriggerId,
      auto: (value) => value.linkedTriggerId,
      moveComplete: (value) => value.linkedTriggerId,
    );
  }

  StudioReady copyWith({
    StudioProject? project,
    Directory? projectDirectory,
    Object? selection = _unchanged,
    List<SceneObject>? clipboardObjects,
    bool? isDirty,
    Object? statusMessage = _unchanged,
  }) {
    return StudioReady(
      project: project ?? this.project,
      projectDirectory: projectDirectory ?? this.projectDirectory,
      selection: selection == _unchanged
          ? this.selection
          : selection as EditorSelection?,
      clipboardObjects: clipboardObjects ?? this.clipboardObjects,
      isDirty: isDirty ?? this.isDirty,
      statusMessage: statusMessage == _unchanged
          ? this.statusMessage
          : statusMessage as String?,
    );
  }
}

const _unchanged = Object();
