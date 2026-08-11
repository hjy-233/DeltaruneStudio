part of 'project_controller.dart';

extension StudioControllerEditingActions on StudioController {
  void addCharacterInstance() {
    final current = _controllerState.asReady;
    if (current == null || current.project.characters.isEmpty) {
      return;
    }
    final selectedCharacterId = current.selection is CharacterSelection
        ? (current.selection as CharacterSelection).characterId
        : null;
    final character = selectedCharacterId == null
        ? current.project.characters.first
        : current.characterById(selectedCharacterId) ??
              current.project.characters.first;
    final object = SceneObject.characterInstance(
      id: StudioIds.object(),
      name: character.name,
      characterId: character.id,
      transform: character.defaultTransform,
      facing: character.defaultFacing,
      initialExpression:
          character.defaultExpressionId ??
          character.expressions.firstOrNull?.id,
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  void addCharacterDefinition() {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final character = Character(
      id: StudioIds.character(),
      name: 'Character ${current.project.characters.length + 1}',
      animations: const [],
      expressions: const [CharacterExpression(id: 'idle', name: 'Idle')],
      movement: const CharacterMovementProfile(),
      defaultTransform: const Transform2D(x: 180, y: 180),
      defaultFacing: Direction.down,
      defaultExpressionId: 'idle',
    );
    final project = current.project.copyWith(
      characters: [...current.project.characters, character],
    );
    _controllerState = current.copyWith(
      project: project,
      selection: EditorSelection.character(character.id),
      isDirty: true,
      statusMessage: 'Added ${character.name}.',
    );
    unawaited(_saveGlobalCharactersIfNeeded(project));
  }

  void addTriggerArea() => addTriggerPoint();

  void addTriggerPoint() {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final chain = EventChain(
      id: StudioIds.chain(),
      name: 'Trigger Action',
      triggerMode: EventChainTriggerMode.triggerPoint,
      events: const [],
    );
    final trigger = Trigger.area(
      id: StudioIds.trigger(),
      name: 'Trigger Point',
      eventChainId: chain.id,
    );
    final object = SceneObject.triggerPoint(
      id: StudioIds.object(),
      name: 'Trigger Point',
      triggerId: trigger.id,
      transform: const Transform2D(x: 240, y: 140, width: 22, height: 22),
    );
    final scene = current.currentScene.copyWith(
      objects: [...current.currentScene.objects, object],
      triggers: [...current.currentScene.triggers, trigger],
      eventChains: [...current.currentScene.eventChains, chain],
    );
    _replaceCurrentScene(
      scene,
      selection: EditorSelection.object(object.objectId),
    );
  }

  void addEventChain() {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final chain = EventChain(
      id: StudioIds.chain(),
      name: 'Event Chain',
      events: const [],
    );
    _replaceCurrentScene(
      current.currentScene.copyWith(
        eventChains: [...current.currentScene.eventChains, chain],
      ),
      selection: EditorSelection.eventChain(chain.id),
    );
  }

  void updateTrigger(Trigger trigger) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _replaceCurrentScene(
      current.currentScene.copyWith(
        triggers: current.currentScene.triggers
            .map(
              (candidate) => triggerIdOf(candidate) == triggerIdOf(trigger)
                  ? trigger
                  : candidate,
            )
            .toList(),
      ),
    );
  }

  void updateEventChain(EventChain chain) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _replaceCurrentScene(
      current.currentScene.copyWith(
        eventChains: current.currentScene.eventChains
            .map((candidate) => candidate.id == chain.id ? chain : candidate)
            .toList(),
      ),
    );
  }

  void deleteEventChain(String chainId) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final scene = current.currentScene.copyWith(
      eventChains: current.currentScene.eventChains
          .where((chain) => chain.id != chainId)
          .toList(),
      triggers: current.currentScene.triggers.map((trigger) {
        return trigger.map(
          area: (value) => value.eventChainId == chainId
              ? value.copyWith(eventChainId: '')
              : value,
          object: (value) => value.eventChainId == chainId
              ? value.copyWith(eventChainId: '')
              : value,
          auto: (value) => value.eventChainId == chainId
              ? value.copyWith(eventChainId: '')
              : value,
          moveComplete: (value) => value.eventChainId == chainId
              ? value.copyWith(eventChainId: '')
              : value,
        );
      }).toList(),
    );
    _replaceCurrentScene(scene, selection: null);
  }

  void addEventToSelectedChain(StudioEvent event) {
    final current = _controllerState.asReady;
    final chainId = current?.activeChain?.id;
    if (current == null || chainId == null) {
      return;
    }
    final scene = current.currentScene.copyWith(
      eventChains: current.currentScene.eventChains.map((chain) {
        if (chain.id != chainId) {
          return chain;
        }
        return chain.copyWith(events: [...chain.events, event]);
      }).toList(),
    );
    _replaceCurrentScene(
      scene,
      selection: EditorSelection.event(chainId, event.eventId),
    );
  }

  void updateEvent(String chainId, StudioEvent event) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _replaceCurrentScene(
      current.currentScene.copyWith(
        eventChains: current.currentScene.eventChains.map((chain) {
          if (chain.id != chainId) {
            return chain;
          }
          return chain.copyWith(
            events: chain.events
                .map(
                  (candidate) =>
                      candidate.eventId == event.eventId ? event : candidate,
                )
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  void removeEvent(String eventId) {
    final current = _controllerState.asReady;
    final chainId = current?.activeChain?.id;
    if (current == null || chainId == null) {
      return;
    }
    final scene = current.currentScene.copyWith(
      eventChains: current.currentScene.eventChains.map((chain) {
        if (chain.id != chainId) {
          return chain;
        }
        return chain.copyWith(
          events: chain.events
              .where((event) => event.eventId != eventId)
              .toList(),
        );
      }).toList(),
    );
    _replaceCurrentScene(scene, selection: EditorSelection.eventChain(chainId));
  }

  void addPathNode(String chainId, String eventId) {
    final current = _controllerState.asReady;
    final event = current?.eventById(chainId, eventId);
    if (current == null || event is! CharacterMoveEvent) {
      return;
    }
    final last = event.path.nodes.isEmpty
        ? const PathNode(id: 'seed', x: 120, y: 120)
        : event.path.nodes.last;
    final node = PathNode(
      id: StudioIds.event(),
      name: 'Node ${event.path.nodes.length + 1}',
      x: last.x + 48,
      y: last.y,
    );
    updateEvent(
      chainId,
      event.copyWith(
        path: event.path.copyWith(nodes: [...event.path.nodes, node]),
      ),
    );
    selectPathNode(chainId, eventId, node.id);
    linkPathNodeToNearbyTrigger(chainId, eventId, node.id);
  }

  void updatePathNode(
    String chainId,
    String eventId,
    String nodeId,
    PathNode Function(PathNode node) update,
  ) {
    final current = _controllerState.asReady;
    final event = current?.eventById(chainId, eventId);
    if (current == null || event is! CharacterMoveEvent) {
      return;
    }
    updateEvent(
      chainId,
      event.copyWith(
        path: event.path.copyWith(
          nodes: normalizeOrthogonalPathNodes(
            event.path.nodes.map((node) {
              return node.id == nodeId ? update(node) : node;
            }).toList(),
            nodeId,
          ),
        ),
      ),
    );
  }

  void removePathNode(String chainId, String eventId, String nodeId) {
    final current = _controllerState.asReady;
    final event = current?.eventById(chainId, eventId);
    if (current == null || event is! CharacterMoveEvent) {
      return;
    }
    updateEvent(
      chainId,
      event.copyWith(
        path: event.path.copyWith(
          nodes: event.path.nodes.where((node) => node.id != nodeId).toList(),
        ),
      ),
    );
    select(EditorSelection.event(chainId, eventId));
  }

  void updateAsset(AssetRef asset) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    _controllerState = current.copyWith(
      project: current.project.copyWith(
        assets: current.project.assets
            .map((candidate) => candidate.id == asset.id ? asset : candidate)
            .toList(),
      ),
      isDirty: true,
    );
  }

  void deleteUnusedAsset(String assetId) {
    final current = _controllerState.asReady;
    if (current == null || current.assetIsUsed(assetId)) {
      return;
    }
    _recordHistory(current);
    _controllerState = current.copyWith(
      project: current.project.copyWith(
        assets: current.project.assets
            .where((asset) => asset.id != assetId)
            .toList(),
      ),
      selection: null,
      isDirty: true,
    );
  }

  void updateCharacter(Character character) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    final project = current.project.copyWith(
      characters: current.project.characters
          .map(
            (candidate) => candidate.id == character.id ? character : candidate,
          )
          .toList(),
    );
    _controllerState = current.copyWith(project: project, isDirty: true);
    unawaited(_saveGlobalCharactersIfNeeded(project));
  }

  void addCharacterAnimationFrame({
    required String characterId,
    required String assetId,
    required Direction? direction,
  }) {
    final current = _controllerState.asReady;
    final character = current?.characterById(characterId);
    final asset = current?.assetById(assetId);
    if (current == null || character == null || asset == null) {
      return;
    }
    final animation = AnimationClip(
      id: 'anim_${StudioIds.event()}',
      name: p.basenameWithoutExtension(asset.originalName),
      assetId: asset.id,
      direction: direction,
    );
    updateCharacter(
      character.copyWith(animations: [...character.animations, animation]),
    );
    _controllerState =
        _controllerState.asReady?.copyWith(
          statusMessage:
              'Added ${asset.originalName} to ${direction?.name ?? 'fallback'} sprites.',
        ) ??
        _controllerState;
  }

  void removeCharacterAnimationFrame({
    required String characterId,
    required String animationId,
  }) {
    final current = _controllerState.asReady;
    final character = current?.characterById(characterId);
    if (current == null || character == null) {
      return;
    }
    updateCharacter(
      character.copyWith(
        animations: character.animations
            .where((animation) => animation.id != animationId)
            .toList(),
      ),
    );
  }

  void deleteSelectedObject() {
    final current = _controllerState.asReady;
    final objectIds = current?.selection.objectIds ?? const [];
    if (current == null || objectIds.isEmpty) {
      return;
    }
    final objectIdSet = objectIds.toSet();
    final triggerIds = current.currentScene.objects
        .where((object) => objectIdSet.contains(object.objectId))
        .map(
          (object) => object.maybeMap(
            triggerPoint: (value) => value.triggerId,
            triggerArea: (value) => value.triggerId,
            orElse: () => null,
          ),
        )
        .whereType<String>()
        .toSet();
    var scene = current.currentScene.copyWith(
      objects: current.currentScene.objects
          .where((candidate) => !objectIdSet.contains(candidate.objectId))
          .toList(),
    );
    if (triggerIds.isNotEmpty) {
      scene = scene.copyWith(
        triggers: scene.triggers
            .where((trigger) => !triggerIds.contains(triggerIdOf(trigger)))
            .toList(),
        eventChains: scene.eventChains.map((chain) {
          return chain.copyWith(
            events: chain.events.map((event) {
              return event.maybeMap(
                characterMove: (move) => move.copyWith(
                  path: move.path.copyWith(
                    nodes: move.path.nodes.map((node) {
                      return triggerIds.contains(node.triggerId)
                          ? node.copyWith(triggerId: null)
                          : node;
                    }).toList(),
                  ),
                ),
                orElse: () => event,
              );
            }).toList(),
          );
        }).toList(),
      );
    }
    _replaceCurrentScene(scene, selection: null);
  }

  void moveSelectedLayer(int delta) {
    final current = _controllerState.asReady;
    final objectId = current?.selection.objectId;
    if (current == null || objectId == null) {
      return;
    }
    final objects = [...current.currentScene.objects];
    final index = objects.indexWhere((object) => object.objectId == objectId);
    if (index < 0) {
      return;
    }
    final nextIndex = (index + delta).clamp(0, objects.length - 1);
    if (nextIndex == index) {
      return;
    }
    final object = objects.removeAt(index);
    objects.insert(nextIndex, object);
    _replaceCurrentScene(current.currentScene.copyWith(objects: objects));
  }

  void moveSelectedToFront() => moveSelectedLayer(9999);
  void moveSelectedToBack() => moveSelectedLayer(-9999);

  void _appendObject(SceneObject object, {EditorSelection? selection}) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _replaceCurrentScene(
      current.currentScene.copyWith(
        objects: [...current.currentScene.objects, object],
      ),
      selection: selection,
    );
  }

  void _replaceCurrentSceneObject(SceneObject Function(SceneObject) update) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final scene = current.currentScene.copyWith(
      objects: current.currentScene.objects.map(update).toList(),
    );
    _replaceCurrentScene(scene);
  }

  void _syncAllPathNodeTriggerLinks() {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    final scene = syncPathNodeTriggerLinks(current.currentScene);
    if (scene != current.currentScene) {
      _replaceCurrentScene(scene);
    }
  }

  void _replaceCurrentScene(Scene scene, {EditorSelection? selection}) {
    final current = _controllerState.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    _controllerState = current.copyWith(
      selection: selection ?? current.selection,
      project: current.project.copyWith(
        scenes: current.project.scenes
            .map((candidate) => candidate.id == scene.id ? scene : candidate)
            .toList(),
      ),
      isDirty: true,
    );
  }

  void _recordHistory(StudioReady current) {
    if (_restoringHistory) {
      return;
    }
    _undoStack.add(
      _HistoryEntry(
        project: current.project,
        selection: current.selection,
        clipboardObjects: current.clipboardObjects,
      ),
    );
    if (_undoStack.length > 120) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void _clearHistory() {
    _undoStack.clear();
    _redoStack.clear();
  }

  SceneObject _withObjectTransform(SceneObject object, Transform2D transform) {
    return object.map(
      characterInstance: (value) => value.copyWith(transform: transform),
      prop: (value) => value.copyWith(transform: transform),
      background: (value) => value.copyWith(transform: transform),
      triggerPoint: (value) => value.copyWith(transform: transform),
      triggerArea: (value) => value.copyWith(transform: transform),
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

  bool _isObjectLocked(SceneObject object) {
    return object.map(
      characterInstance: (value) => value.locked,
      prop: (value) => value.locked,
      background: (value) => value.locked,
      triggerPoint: (value) => value.locked,
      triggerArea: (value) => value.locked,
    );
  }

  _PastedObject _copyObjectForPaste(SceneObject source, String objectId) {
    final transform = source.objectTransform.copyWith(
      x: source.objectTransform.x + 16,
      y: source.objectTransform.y + 16,
    );
    return source.map(
      characterInstance: (value) => _PastedObject(
        object: value.copyWith(id: objectId, transform: transform),
      ),
      prop: (value) => _PastedObject(
        object: value.copyWith(id: objectId, transform: transform),
      ),
      background: (value) => _PastedObject(
        object: value.copyWith(id: objectId, transform: transform),
      ),
      triggerPoint: (value) {
        final triggerId = StudioIds.trigger();
        final chainId = StudioIds.chain();
        final trigger = Trigger.area(
          id: triggerId,
          name: '${value.name} Copy',
          eventChainId: chainId,
        );
        return _PastedObject(
          object: value.copyWith(
            id: objectId,
            name: '${value.name} Copy',
            triggerId: triggerId,
            transform: transform,
          ),
          trigger: trigger,
          chain: EventChain(
            id: chainId,
            name: '${value.name} Trigger',
            triggerMode: EventChainTriggerMode.triggerPoint,
            events: const [],
          ),
        );
      },
      triggerArea: (value) {
        final triggerId = StudioIds.trigger();
        final chainId = StudioIds.chain();
        final trigger = Trigger.area(
          id: triggerId,
          name: '${value.name} Copy',
          eventChainId: chainId,
        );
        return _PastedObject(
          object: SceneObject.triggerPoint(
            id: objectId,
            name: '${value.name} Copy',
            triggerId: triggerId,
            transform: transform.copyWith(width: 22, height: 22, scale: 1),
            locked: value.locked,
          ),
          trigger: trigger,
          chain: EventChain(
            id: chainId,
            name: '${value.name} Trigger',
            triggerMode: EventChainTriggerMode.triggerPoint,
            events: const [],
          ),
        );
      },
    );
  }
}
