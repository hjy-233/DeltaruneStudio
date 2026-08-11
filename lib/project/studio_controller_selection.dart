part of 'project_controller.dart';

extension StudioControllerSelectionActions on StudioController {
  void select(EditorSelection? selection) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _controllerState = current.copyWith(selection: selection);
  }

  void selectScene(String sceneId) {
    final current = _controllerState.asReady;
    if (current == null || current.project.currentSceneId == sceneId) {
      return;
    }
    _controllerState = current.copyWith(
      selection: null,
      project: current.project.copyWith(currentSceneId: sceneId),
    );
  }

  void selectObject(String? objectId) {
    select(objectId == null ? null : EditorSelection.object(objectId));
  }

  void selectObjects(List<String> objectIds) {
    final unique = objectIds.toSet().toList(growable: false);
    if (unique.isEmpty) {
      select(null);
      return;
    }
    select(
      unique.length == 1
          ? EditorSelection.object(unique.single)
          : EditorSelection.objects(unique),
    );
  }

  void toggleObjectSelection(String objectId) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final ids = [...current.selection.objectIds];
    if (ids.contains(objectId)) {
      ids.remove(objectId);
    } else {
      ids.add(objectId);
    }
    selectObjects(ids);
  }

  void selectChain(String? chainId) {
    select(chainId == null ? null : EditorSelection.eventChain(chainId));
  }

  void selectEvent(String chainId, String eventId) {
    select(EditorSelection.event(chainId, eventId));
  }

  void selectPathNode(String chainId, String eventId, String nodeId) {
    select(EditorSelection.pathNode(chainId, eventId, nodeId));
  }

  void selectAsset(String assetId) {
    select(EditorSelection.asset(assetId));
  }

  void selectCharacter(String characterId) {
    select(EditorSelection.character(characterId));
  }

  void undo() {
    final current = _controllerState.asReady;
    if (current == null || _undoStack.isEmpty) {
      return;
    }
    final previous = _undoStack.removeLast();
    _redoStack.add(
      _HistoryEntry(
        project: current.project,
        selection: current.selection,
        clipboardObjects: current.clipboardObjects,
      ),
    );
    _restoringHistory = true;
    _controllerState = current.copyWith(
      project: previous.project,
      selection: previous.selection,
      clipboardObjects: previous.clipboardObjects,
      isDirty: true,
      statusMessage: 'Undo.',
    );
    _restoringHistory = false;
  }

  void redo() {
    final current = _controllerState.asReady;
    if (current == null || _redoStack.isEmpty) {
      return;
    }
    final next = _redoStack.removeLast();
    _undoStack.add(
      _HistoryEntry(
        project: current.project,
        selection: current.selection,
        clipboardObjects: current.clipboardObjects,
      ),
    );
    _restoringHistory = true;
    _controllerState = current.copyWith(
      project: next.project,
      selection: next.selection,
      clipboardObjects: next.clipboardObjects,
      isDirty: true,
      statusMessage: 'Redo.',
    );
    _restoringHistory = false;
  }

  void moveSelectedObject(double dx, double dy) {
    final current = _controllerState.asReady;
    final objectIds = current?.selection.objectIds ?? const [];
    if (current == null || objectIds.isEmpty) {
      return;
    }
    moveObjectsById(objectIds, dx, dy);
  }

  void moveObjectById(String objectId, double dx, double dy) {
    moveObjectsById([objectId], dx, dy);
  }

  void moveObjectsById(List<String> objectIds, double dx, double dy) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final ids = objectIds.where((id) {
      final object = current.objectById(id);
      return object != null && !_isObjectLocked(object);
    }).toSet();
    if (ids.isEmpty) {
      return;
    }
    final scene = current.currentScene.copyWith(
      objects: current.currentScene.objects.map((object) {
        if (!ids.contains(object.objectId)) {
          return object;
        }
        final transform = object.objectTransform;
        return _withObjectTransform(
          object,
          transform.copyWith(x: transform.x + dx, y: transform.y + dy),
        );
      }).toList(),
    );
    _replaceCurrentScene(scene);
    if (current.currentScene.objects.any(
      (object) => ids.contains(object.objectId) && isTriggerSceneObject(object),
    )) {
      _syncAllPathNodeTriggerLinks();
    }
  }

  void moveSelectedPathNode(double dx, double dy) {
    final current = _controllerState.asReady;
    final selection = current?.selection;
    if (current == null || selection is! PathNodeSelection) {
      return;
    }
    updatePathNode(selection.chainId, selection.eventId, selection.nodeId, (
      node,
    ) {
      return node.copyWith(x: node.x + dx, y: node.y + dy);
    });
    linkPathNodeToNearbyTrigger(
      selection.chainId,
      selection.eventId,
      selection.nodeId,
    );
  }

  void movePathNodeById(
    String chainId,
    String eventId,
    String nodeId,
    double dx,
    double dy,
  ) {
    updatePathNode(chainId, eventId, nodeId, (node) {
      return node.copyWith(x: node.x + dx, y: node.y + dy);
    });
    linkPathNodeToNearbyTrigger(chainId, eventId, nodeId);
  }

  void linkPathNodeToNearbyTrigger(
    String chainId,
    String eventId,
    String nodeId,
  ) {
    final current = _controllerState.asReady;
    final node = current?.pathNodeById(chainId, eventId, nodeId);
    if (current == null || node == null) {
      return;
    }
    final nearestTriggerId = nearestTriggerIdForPathNode(
      current.currentScene,
      node,
    );
    if (nearestTriggerId == node.triggerId) {
      return;
    }
    updatePathNode(chainId, eventId, nodeId, (value) {
      return value.copyWith(triggerId: nearestTriggerId);
    });
    final trigger = current.triggerById(nearestTriggerId);
    _controllerState =
        _controllerState.asReady?.copyWith(
          statusMessage: nearestTriggerId == null
              ? 'Path node trigger link removed.'
              : trigger == null
              ? 'Path node linked to trigger.'
              : 'Path node linked to ${current.triggerName(trigger)}.',
        ) ??
        _controllerState;
  }

  void updateSelectedTransform(Transform2D transform) {
    final current = _controllerState.asReady;
    final objectId = current?.selection.objectId;
    if (current == null || objectId == null) {
      return;
    }
    updateObjectTransformById(objectId, (_) => transform);
  }

  void updateObjectTransformById(
    String objectId,
    Transform2D Function(Transform2D transform) update,
  ) {
    final current = _controllerState.asReady;
    final object = current?.objectById(objectId);
    if (object == null || _isObjectLocked(object)) {
      return;
    }
    final isTriggerObject = object.maybeMap(
      triggerPoint: (_) => true,
      triggerArea: (_) => true,
      orElse: () => false,
    );
    _replaceCurrentSceneObject((object) {
      if (object.objectId != objectId) {
        return object;
      }
      return _withObjectTransform(object, update(object.objectTransform));
    });
    if (isTriggerObject) {
      _syncAllPathNodeTriggerLinks();
    }
  }

  void updateObject(SceneObject object) {
    _replaceCurrentSceneObject((candidate) {
      return candidate.objectId == object.objectId ? object : candidate;
    });
    if (isTriggerSceneObject(object)) {
      _syncAllPathNodeTriggerLinks();
    }
  }

  void setObjectsLocked(List<String> objectIds, bool locked) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final ids = objectIds.toSet();
    final scene = current.currentScene.copyWith(
      objects: current.currentScene.objects.map((object) {
        if (!ids.contains(object.objectId)) {
          return object;
        }
        return _withObjectLocked(object, locked);
      }).toList(),
    );
    _replaceCurrentScene(scene);
  }

  void copySelection() {
    final current = _controllerState.asReady;
    final ids = current?.selection.objectIds ?? const [];
    if (current == null || ids.isEmpty) {
      return;
    }
    final objects = current.currentScene.objects
        .where((object) => ids.contains(object.objectId))
        .toList(growable: false);
    _controllerState = current.copyWith(
      clipboardObjects: objects,
      statusMessage: 'Copied ${objects.length} object(s).',
    );
  }

  void pasteSelection() {
    final current = _controllerState.asReady;
    final clipboard = current?.clipboardObjects ?? const [];
    if (current == null || clipboard.isEmpty) {
      return;
    }
    final newObjects = <SceneObject>[];
    final newTriggers = <Trigger>[];
    final newChains = <EventChain>[];
    for (final source in clipboard) {
      final nextObjectId = StudioIds.object();
      final copied = _copyObjectForPaste(source, nextObjectId);
      newObjects.add(copied.object);
      if (copied.trigger != null) {
        newTriggers.add(copied.trigger!);
      }
      if (copied.chain != null) {
        newChains.add(copied.chain!);
      }
    }
    final scene = current.currentScene.copyWith(
      objects: [...current.currentScene.objects, ...newObjects],
      triggers: [...current.currentScene.triggers, ...newTriggers],
      eventChains: [...current.currentScene.eventChains, ...newChains],
    );
    _replaceCurrentScene(
      scene,
      selection: newObjects.length == 1
          ? EditorSelection.object(newObjects.single.objectId)
          : EditorSelection.objects(
              newObjects.map((object) => object.objectId).toList(),
            ),
    );
  }
}
