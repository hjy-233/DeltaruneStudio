part of 'project_controller.dart';

extension StudioControllerAssetActions on StudioController {
  Future<void> importBackground() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.background);
    if (asset == null) {
      return;
    }
    if (_applyAssetToSelection(asset, targetSelection: targetSelection)) {
      return;
    }
    final object = SceneObject.background(
      id: StudioIds.object(),
      name: asset.originalName,
      assetId: asset.id,
      transform: _atEditorCenter(
        const Transform2D(x: 0, y: 0, width: 320, height: 180),
      ),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  void addRoomBackground() {
    final object = SceneObject.background(
      id: StudioIds.object(),
      name: 'Room',
      assetId: '',
      transform: _atEditorCenter(
        const Transform2D(x: 0, y: 0, width: 360, height: 220),
      ),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  Future<void> importProp() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.prop);
    if (asset == null) {
      return;
    }
    if (_applyAssetToSelection(asset, targetSelection: targetSelection)) {
      return;
    }
    final object = SceneObject.prop(
      id: StudioIds.object(),
      name: asset.originalName,
      assetId: asset.id,
      transform: _atEditorCenter(
        const Transform2D(x: 0, y: 0, width: 64, height: 64),
      ),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  Future<void> importCharacterAsset() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.character);
    if (asset == null) {
      return;
    }
    _attachCharacterAsset(asset, targetSelection: targetSelection);
  }

  Future<void> importAudio() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.audio);
    if (asset == null) {
      return;
    }
    _applyAssetToSelection(asset, targetSelection: targetSelection);
  }

  Future<void> importVideo() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.video);
    if (asset == null) {
      return;
    }
    if (!_applyAssetToSelection(asset, targetSelection: targetSelection)) {
      selectAsset(asset.id);
    }
  }

  Future<void> importDialoguePortrait() async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _importAsset(AssetKind.dialoguePortrait);
    if (asset == null) {
      return;
    }
    _applyAssetToSelection(asset, targetSelection: targetSelection);
  }

  Future<void> addBuiltInAsset(BuiltInAsset builtIn) async {
    final targetSelection = _controllerState.asReady?.selection;
    final asset = await _copyBuiltInAsset(builtIn);
    if (asset == null) {
      return;
    }
    if (_applyAssetToSelection(asset, targetSelection: targetSelection)) {
      return;
    }
    switch (builtIn.kind) {
      case AssetKind.background:
        final object = SceneObject.background(
          id: StudioIds.object(),
          name: builtIn.name,
          assetId: asset.id,
          transform: const Transform2D(x: 40, y: 40, width: 320, height: 180),
        );
        _appendObject(
          object,
          selection: EditorSelection.object(object.objectId),
        );
      case AssetKind.prop:
        final object = SceneObject.prop(
          id: StudioIds.object(),
          name: builtIn.name,
          assetId: asset.id,
          transform: const Transform2D(x: 120, y: 120, width: 64, height: 64),
        );
        _appendObject(
          object,
          selection: EditorSelection.object(object.objectId),
        );
      case AssetKind.character:
        _attachCharacterAsset(asset, targetSelection: targetSelection);
      case AssetKind.audio:
        selectAsset(asset.id);
      case AssetKind.dialoguePortrait:
        if (!_applyAssetToSelection(asset, targetSelection: targetSelection)) {
          selectAsset(asset.id);
        }
      case AssetKind.video:
        if (!_applyAssetToSelection(asset, targetSelection: targetSelection)) {
          selectAsset(asset.id);
        }
    }
  }

  Future<AssetRef?> _copyBuiltInAsset(BuiltInAsset builtIn) async {
    final current = _controllerState.asReady;
    if (current == null) {
      return null;
    }
    try {
      final data = await _readBuiltInAssetBytes(builtIn);
      final directory = kIsWeb
          ? current.projectDirectory
          : current.projectDirectory ?? await _defaultProjectDir();
      final asset = kIsWeb
          ? AssetRef(
              id: StudioIds.asset(),
              kind: builtIn.kind,
              originalName: p.basename(builtIn.sourcePath),
              relativePath: '',
              dataUri:
                  'data:${_mimeForName(builtIn.sourcePath)};base64,${base64Encode(data)}',
            )
          : await _repository.importAssetBytes(
              projectDirectory: directory!,
              bytes: data,
              kind: builtIn.kind,
              originalName: p.basename(builtIn.sourcePath),
            );
      final latest = _controllerState.asReady ?? current;
      _recordHistory(latest);
      _controllerState = latest.copyWith(
        projectDirectory: directory,
        project: latest.project.copyWith(
          assets: [...latest.project.assets, asset],
        ),
        selection: EditorSelection.asset(asset.id),
        isDirty: true,
        statusMessage: 'Added built-in ${asset.originalName}.',
      );
      return asset;
    } on Object catch (error) {
      _controllerState = current.copyWith(
        statusMessage: 'Built-in import failed: $error',
      );
      return null;
    }
  }

  Future<Uint8List> _readBuiltInAssetBytes(BuiltInAsset builtIn) async {
    if (!kIsWeb) {
      final file = File(builtIn.resolvedPath);
      if (await file.exists()) {
        return file.readAsBytes();
      }
    }
    return (await rootBundle.load(builtIn.assetPath)).buffer.asUint8List();
  }

  void _attachCharacterAsset(
    AssetRef asset, {
    EditorSelection? targetSelection,
  }) {
    _attachCharacterAssetToSelection(asset, targetSelection: targetSelection);
  }

  void applyExistingAsset(String assetId) {
    final current = _controllerState.asReady;
    final asset = current?.assetById(assetId);
    if (current == null || asset == null) {
      return;
    }
    if (!_applyAssetToSelection(asset)) {
      selectAsset(asset.id);
    }
  }

  bool _applyAssetToSelection(
    AssetRef asset, {
    EditorSelection? targetSelection,
  }) {
    final current = _controllerState.asReady;
    if (current == null) {
      return false;
    }
    final selection = targetSelection ?? current.selection;
    if (selection is EventSelection) {
      final event = current.eventById(selection.chainId, selection.eventId);
      if (asset.kind == AssetKind.audio && event is AudioPlayBgmEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            _controllerState;
        return true;
      }
      if (asset.kind == AssetKind.audio && event is AudioPlaySoundEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            _controllerState;
        return true;
      }
      if (asset.kind == AssetKind.audio && event is DialogueSayEvent) {
        updateEvent(
          selection.chainId,
          event.copyWith(textSoundAssetId: asset.id),
        );
        select(EditorSelection.event(selection.chainId, selection.eventId));
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)} text sound.',
            ) ??
            _controllerState;
        return true;
      }
      if (asset.kind == AssetKind.dialoguePortrait &&
          event is DialogueSayEvent) {
        updateEvent(
          selection.chainId,
          event.copyWith(portraitAssetId: asset.id),
        );
        select(EditorSelection.event(selection.chainId, selection.eventId));
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)} portrait.',
            ) ??
            _controllerState;
        return true;
      }
      if (asset.kind == AssetKind.video && event is VideoPlayEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            _controllerState;
        return true;
      }
      if (asset.kind == AssetKind.audio ||
          asset.kind == AssetKind.dialoguePortrait ||
          asset.kind == AssetKind.video) {
        return false;
      }
    }
    if (asset.kind == AssetKind.audio ||
        asset.kind == AssetKind.dialoguePortrait ||
        asset.kind == AssetKind.video) {
      return false;
    }
    if (selection is CharacterSelection || selection is ObjectSelection) {
      final object = selection is ObjectSelection
          ? current.objectById(selection.objectId)
          : null;
      if (object is BackgroundObject) {
        updateObject(object.copyWith(assetId: asset.id));
        selectObject(object.id);
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Replaced ${object.name} with ${asset.originalName}.',
            ) ??
            _controllerState;
        return true;
      }
      if (object is PropSceneObject) {
        updateObject(object.copyWith(assetId: asset.id));
        selectObject(object.id);
        _controllerState =
            _controllerState.asReady?.copyWith(
              statusMessage:
                  'Replaced ${object.name} with ${asset.originalName}.',
            ) ??
            _controllerState;
        return true;
      }
      if (selection is CharacterSelection ||
          object is CharacterInstanceObject) {
        _attachCharacterAssetToSelection(asset, targetSelection: selection);
        return true;
      }
    }
    return false;
  }

  String _eventTypeKey(StudioEvent event) {
    return event.map(
      characterMove: (_) => 'character.move',
      characterStartFollow: (_) => 'character.startFollow',
      characterStopFollow: (_) => 'character.stopFollow',
      characterWait: (_) => 'character.wait',
      characterChangeExpression: (_) => 'character.changeExpression',
      dialogueSay: (_) => 'dialogue.say',
      cameraFollow: (_) => 'camera.follow',
      cameraFocus: (_) => 'camera.focus',
      sceneFade: (_) => 'scene.fade',
      sceneChange: (_) => 'scene.change',
      audioPlayBgm: (_) => 'audio.playBgm',
      audioPlaySound: (_) => 'audio.playSound',
      videoPlay: (_) => 'video.play',
    );
  }

  void _attachCharacterAssetToSelection(
    AssetRef asset, {
    EditorSelection? targetSelection,
  }) {
    final current = _controllerState.asReady;
    if (current == null || current.project.characters.isEmpty) {
      return;
    }
    final selection = targetSelection ?? current.selection;
    final selectedObject = selection is ObjectSelection
        ? current.objectById(selection.objectId)
        : null;
    final targetCharacterId = selectedObject is CharacterInstanceObject
        ? selectedObject.characterId
        : selection is CharacterSelection
        ? selection.characterId
        : null;
    final direction = selectedObject is CharacterInstanceObject
        ? selectedObject.facing
        : null;
    final selectedCharacter =
        current.characterById(targetCharacterId) ??
        current.project.characters.first;
    final animation = AnimationClip(
      id: 'anim_${StudioIds.event()}',
      name: p.basenameWithoutExtension(asset.originalName),
      assetId: asset.id,
      direction: direction,
    );
    updateCharacter(
      selectedCharacter.copyWith(
        animations: [...selectedCharacter.animations, animation],
      ),
    );
    if (selectedObject is CharacterInstanceObject) {
      selectObject(selectedObject.id);
    } else {
      selectCharacter(selectedCharacter.id);
    }
    _controllerState =
        _controllerState.asReady?.copyWith(
          statusMessage:
              'Replaced ${selectedCharacter.name} sprite with ${asset.originalName}.',
        ) ??
        _controllerState;
  }

  Future<AssetRef?> _importAsset(AssetKind kind) async {
    final current = _controllerState.asReady;
    if (current == null) {
      return null;
    }
    try {
      final file = await openFile(
        acceptedTypeGroups: [_typeGroupForKind(kind)],
      );
      if (file == null) {
        _controllerState = current.copyWith(statusMessage: 'Import cancelled.');
        return null;
      }
      final bytes = await file.readAsBytes();
      final directory = kIsWeb
          ? current.projectDirectory
          : current.projectDirectory ?? await _defaultProjectDir();
      final asset = kIsWeb
          ? AssetRef(
              id: StudioIds.asset(),
              kind: kind,
              originalName: file.name,
              relativePath: '',
              dataUri:
                  'data:${_mimeForName(file.name)};base64,${base64Encode(bytes)}',
            )
          : await _repository.importAssetBytes(
              projectDirectory: directory!,
              bytes: bytes,
              kind: kind,
              originalName: file.name,
            );
      _recordHistory(current);
      _controllerState = current.copyWith(
        projectDirectory: kIsWeb ? current.projectDirectory : directory,
        project: current.project.copyWith(
          assets: [...current.project.assets, asset],
        ),
        selection: EditorSelection.asset(asset.id),
        isDirty: true,
        statusMessage: 'Imported ${asset.originalName}.',
      );
      return asset;
    } on Object catch (error) {
      _controllerState = current.copyWith(
        statusMessage: 'Import failed: $error',
      );
      return null;
    }
  }

  XTypeGroup _typeGroupForKind(AssetKind kind) {
    return switch (kind) {
      AssetKind.background ||
      AssetKind.prop ||
      AssetKind.character ||
      AssetKind.dialoguePortrait => const XTypeGroup(
        label: 'Images',
        extensions: ['png', 'jpg', 'jpeg', 'webp'],
      ),
      AssetKind.audio => const XTypeGroup(
        label: 'Audio',
        extensions: ['mp3', 'wav', 'ogg', 'flac', 'm4a'],
      ),
      AssetKind.video => const XTypeGroup(
        label: 'Video',
        extensions: ['mp4', 'mov', 'webm', 'm4v'],
      ),
    };
  }

  String _mimeForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    if (lower.endsWith('.mp3')) {
      return 'audio/mpeg';
    }
    if (lower.endsWith('.ogg')) {
      return 'audio/ogg';
    }
    if (lower.endsWith('.wav')) {
      return 'audio/wav';
    }
    if (lower.endsWith('.mp4') || lower.endsWith('.m4v')) {
      return 'video/mp4';
    }
    if (lower.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (lower.endsWith('.webm')) {
      return 'video/webm';
    }
    return 'image/png';
  }
}
