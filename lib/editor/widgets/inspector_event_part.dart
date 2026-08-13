part of 'inspector_panel.dart';

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
    final chain = ready.currentScene.eventChains
        .where((candidate) => candidate.id == chainId)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InspectorSectionTitle(eventLabel(l10n, value)),
        if (chain?.triggerMode == EventChainTriggerMode.scheduled)
          InspectorNumberField(
            label: l10n.startTime,
            value: value.eventScheduleStart,
            onChanged: (time) => controller.updateEvent(
              chainId,
              value.withScheduleStart(time.clamp(0, 99999).toDouble()),
            ),
          ),
        value.map(
          characterMove: (move) => _buildMoveEvent(controller, l10n, move),
          characterStartFollow: (follow) =>
              _buildStartFollowEvent(controller, follow),
          characterStopFollow: (follow) =>
              _buildStopFollowEvent(controller, follow),
          characterWait: (wait) => _buildWaitEvent(controller, l10n, wait),
          characterChangeExpression: (expression) =>
              _buildExpressionEvent(controller, l10n, expression),
          dialogueSay: (dialogue) =>
              _buildDialogueEvent(controller, l10n, dialogue),
          cameraFollow: (camera) =>
              _buildCameraFollowEvent(controller, l10n, camera),
          cameraFocus: (camera) => _FocusEditor(
            focus: camera,
            onChanged: (next) => controller.updateEvent(chainId, next),
          ),
          sceneFade: (fade) => _buildFadeEvent(controller, l10n, fade),
          sceneChange: (scene) =>
              _buildSceneChangeEvent(controller, l10n, scene),
          audioPlayBgm: (audio) => _buildAudioEvent(controller, audio, true),
          audioPlaySound: (audio) => _buildAudioEvent(controller, audio, false),
          videoPlay: (video) => _buildVideoEvent(controller, video),
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

  Widget _buildMoveEvent(
    StudioController controller,
    AppLocalizations l10n,
    CharacterMoveEvent move,
  ) {
    return Column(
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
        _DropdownField<MovementMode>(
          label: l10n.movementMode,
          value: move.path.mode,
          values: MovementMode.values,
          labelFor: (mode) => switch (mode) {
            MovementMode.fourWay => l10n.movementModeFourWay,
            MovementMode.eightWay => l10n.movementModeEightWay,
            MovementMode.free => l10n.movementModeFree,
          },
          onChanged: (mode) => controller.updateEvent(
            chainId,
            move.copyWith(
              path: move.path.copyWith(
                mode: mode,
                nodes: normalizeMovementPathNodes(move.path.nodes, mode),
              ),
            ),
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
            onTap: () => controller.selectPathNode(chainId, move.id, node.id),
          ),
      ],
    );
  }

  Widget _buildStartFollowEvent(
    StudioController controller,
    CharacterStartFollowEvent follow,
  ) {
    return Column(
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
    );
  }

  Widget _buildStopFollowEvent(
    StudioController controller,
    CharacterStopFollowEvent follow,
  ) {
    return _ObjectPicker(
      ready: ready,
      label: '跟随者',
      value: follow.followerObjectId,
      characterOnly: true,
      onChanged: (id) => controller.updateEvent(
        chainId,
        follow.copyWith(followerObjectId: id),
      ),
    );
  }

  Widget _buildWaitEvent(
    StudioController controller,
    AppLocalizations l10n,
    CharacterWaitEvent wait,
  ) {
    return InspectorNumberField(
      label: l10n.duration,
      value: wait.duration,
      onChanged: (duration) =>
          controller.updateEvent(chainId, wait.copyWith(duration: duration)),
    );
  }

  Widget _buildExpressionEvent(
    StudioController controller,
    AppLocalizations l10n,
    CharacterChangeExpressionEvent expression,
  ) {
    return Column(
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
    );
  }

  Widget _buildDialogueEvent(
    StudioController controller,
    AppLocalizations l10n,
    DialogueSayEvent dialogue,
  ) {
    return Column(
      children: [
        InspectorStringField(
          label: l10n.text,
          value: dialogue.text,
          maxLines: 4,
          onChanged: (text) =>
              controller.updateEvent(chainId, dialogue.copyWith(text: text)),
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
          onChanged: (style) =>
              controller.updateEvent(chainId, dialogue.copyWith(style: style)),
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
    );
  }

  Widget _buildCameraFollowEvent(
    StudioController controller,
    AppLocalizations l10n,
    CameraFollowEvent camera,
  ) {
    return _ObjectPicker(
      ready: ready,
      label: l10n.target,
      value: camera.targetObjectId,
      onChanged: (id) =>
          controller.updateEvent(chainId, camera.copyWith(targetObjectId: id)),
    );
  }

  Widget _buildFadeEvent(
    StudioController controller,
    AppLocalizations l10n,
    SceneFadeEvent fade,
  ) {
    return Column(
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
    );
  }

  Widget _buildSceneChangeEvent(
    StudioController controller,
    AppLocalizations l10n,
    SceneChangeEvent scene,
  ) {
    return InspectorStringField(
      label: l10n.canvasMarker,
      value: scene.entryPointId ?? scene.sceneId,
      onChanged: (marker) =>
          controller.updateEvent(chainId, scene.copyWith(entryPointId: marker)),
    );
  }

  Widget _buildAudioEvent(
    StudioController controller,
    StudioEvent audio,
    bool isBgm,
  ) {
    final assetId = audio.mapOrNull(
      audioPlayBgm: (value) => value.assetId,
      audioPlaySound: (value) => value.assetId,
    );
    return _AudioEventEditor(
      ready: ready,
      assetId: assetId ?? '',
      isBgm: isBgm,
      onChanged: (assetId) => controller.updateEvent(
        chainId,
        audio.map(
          audioPlayBgm: (value) => value.copyWith(assetId: assetId),
          audioPlaySound: (value) => value.copyWith(assetId: assetId),
          characterMove: (_) => audio,
          characterWait: (_) => audio,
          characterChangeExpression: (_) => audio,
          characterStartFollow: (_) => audio,
          characterStopFollow: (_) => audio,
          dialogueSay: (_) => audio,
          cameraFollow: (_) => audio,
          cameraFocus: (_) => audio,
          sceneFade: (_) => audio,
          sceneChange: (_) => audio,
          videoPlay: (_) => audio,
        ),
      ),
    );
  }

  Widget _buildVideoEvent(StudioController controller, VideoPlayEvent video) {
    return Column(
      children: [
        _AssetPicker(
          ready: ready,
          kind: AssetKind.video,
          value: video.assetId,
          onChanged: (assetId) =>
              controller.updateEvent(chainId, video.copyWith(assetId: assetId)),
        ),
        InspectorInfo(label: 'Fit', value: video.fit.name),
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
