import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';

import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/project/studio_state.dart';
import 'package:deltarune_studio/project/web_project_download_stub.dart'
    if (dart.library.html) 'package:deltarune_studio/project/web_project_download_web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

export 'package:deltarune_studio/project/studio_state.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final studioControllerProvider =
    StateNotifierProvider<StudioController, StudioState>((ref) {
      return StudioController(ref.watch(projectRepositoryProvider));
    });

final class StudioController extends StateNotifier<StudioState> {
  StudioController(this._repository) : super(const StudioState.loading()) {
    openLastProjectOrCreateScratch();
  }

  final ProjectRepository _repository;
  final List<_HistoryEntry> _undoStack = [];
  final List<_HistoryEntry> _redoStack = [];
  bool _restoringHistory = false;

  static const _settingsFileName = 'settings.json';
  static const _lastProjectPathKey = 'lastProjectPath';

  Future<void> openLastProjectOrCreateScratch() async {
    if (kIsWeb) {
      await createScratchProject();
      return;
    }
    final lastProjectPath = await _readLastProjectPath();
    if (lastProjectPath != null) {
      final directory = Directory(lastProjectPath);
      try {
        final project = await _repository.openProject(directory);
        _clearHistory();
        state = StudioState.ready(
          project: project,
          projectDirectory: directory,
          statusMessage: 'Opened last project ${directory.path}.',
        );
        return;
      } on Object {
        await _clearLastProjectPath();
      }
    }
    await createScratchProject();
  }

  Future<void> createScratchProject() async {
    final project = await _repository.createDefaultProject('Deltarune Studio');
    _clearHistory();
    state = StudioState.ready(project: project);
  }

  Future<void> newProject() => createScratchProject();

  Future<void> saveProject() async {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (kIsWeb) {
      const encoder = JsonEncoder.withIndent('  ');
      await downloadProjectJson(
        '${current.project.name}.drs.json',
        encoder.convert(current.project.toJson()),
      );
      state = current.copyWith(
        isDirty: false,
        statusMessage: 'Downloaded ${current.project.name}.drs.json.',
      );
      return;
    }
    final directory = current.projectDirectory ?? await _defaultProjectDir();
    await _repository.saveProject(
      directory: directory,
      project: current.project,
    );
    final latest = state.asReady ?? current;
    if (latest.project != current.project) {
      await _repository.saveProject(
        directory: directory,
        project: latest.project,
      );
    }
    state = latest.copyWith(
      projectDirectory: directory,
      isDirty: false,
      statusMessage: 'Saved to ${directory.path}.',
    );
    await _writeLastProjectPath(directory);
  }

  Future<void> saveProjectAs() async {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (kIsWeb) {
      await saveProject();
      return;
    }
    final path = await getSaveLocation(
      suggestedName: '${current.project.name}.drs',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Deltarune Studio Project', extensions: ['drs']),
      ],
    );
    if (path == null) {
      return;
    }
    final directoryPath = path.path.endsWith('.drs')
        ? path.path
        : '${path.path}.drs';
    final directory = Directory(directoryPath);
    await _repository.saveProject(
      directory: directory,
      project: current.project,
    );
    final latest = state.asReady ?? current;
    if (latest.project != current.project) {
      await _repository.saveProject(
        directory: directory,
        project: latest.project,
      );
    }
    state = latest.copyWith(
      projectDirectory: directory,
      isDirty: false,
      statusMessage: 'Saved to ${directory.path}.',
    );
    await _writeLastProjectPath(directory);
  }

  void updateEditorLayout(EditorLayout layout) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (current.project.editorLayout == layout) {
      return;
    }
    state = current.copyWith(
      project: current.project.copyWith(editorLayout: layout),
      isDirty: true,
    );
  }

  void updateEditorSettings(EditorSettings settings) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (current.project.settings == settings) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
      project: current.project.copyWith(settings: settings),
      isDirty: true,
      statusMessage: 'Updated editor settings.',
    );
  }

  Future<void> openProject() async {
    if (kIsWeb) {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Deltarune Studio Project',
            extensions: ['json', 'drs'],
          ),
        ],
      );
      if (file == null) {
        return;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) {
        return;
      }
      state = StudioState.ready(
        project: _repository.migrateProjectForOpen(
          StudioProject.fromJson(json),
        ),
        statusMessage: 'Opened ${file.name}.',
      );
      _clearHistory();
      return;
    }
    final path = await getDirectoryPath(confirmButtonText: 'Open Project');
    if (path == null) {
      return;
    }
    final directory = Directory(path);
    final project = await _repository.openProject(directory);
    _clearHistory();
    state = StudioState.ready(project: project, projectDirectory: directory);
    await _writeLastProjectPath(directory);
  }

  Future<void> importBackground() async {
    final targetSelection = state.asReady?.selection;
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
      transform: const Transform2D(x: 40, y: 40, width: 320, height: 180),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  void addRoomBackground() {
    final object = SceneObject.background(
      id: StudioIds.object(),
      name: 'Room',
      assetId: '',
      transform: const Transform2D(x: 40, y: 40, width: 360, height: 220),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  Future<void> importProp() async {
    final targetSelection = state.asReady?.selection;
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
      transform: const Transform2D(x: 120, y: 120, width: 64, height: 64),
    );
    _appendObject(object, selection: EditorSelection.object(object.objectId));
  }

  Future<void> importCharacterAsset() async {
    final targetSelection = state.asReady?.selection;
    final asset = await _importAsset(AssetKind.character);
    if (asset == null) {
      return;
    }
    _attachCharacterAsset(asset, targetSelection: targetSelection);
  }

  Future<void> importAudio() async {
    final targetSelection = state.asReady?.selection;
    final asset = await _importAsset(AssetKind.audio);
    if (asset == null) {
      return;
    }
    _applyAssetToSelection(asset, targetSelection: targetSelection);
  }

  Future<void> importVideo() async {
    final targetSelection = state.asReady?.selection;
    final asset = await _importAsset(AssetKind.video);
    if (asset == null) {
      return;
    }
    if (!_applyAssetToSelection(asset, targetSelection: targetSelection)) {
      selectAsset(asset.id);
    }
  }

  Future<void> importDialoguePortrait() async {
    final targetSelection = state.asReady?.selection;
    final asset = await _importAsset(AssetKind.dialoguePortrait);
    if (asset == null) {
      return;
    }
    _applyAssetToSelection(asset, targetSelection: targetSelection);
  }

  Future<void> addBuiltInAsset(BuiltInAsset builtIn) async {
    final targetSelection = state.asReady?.selection;
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
    final current = state.asReady;
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
      final latest = state.asReady ?? current;
      _recordHistory(latest);
      state = latest.copyWith(
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
      state = current.copyWith(statusMessage: 'Built-in import failed: $error');
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
    final current = state.asReady;
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
    final current = state.asReady;
    if (current == null) {
      return false;
    }
    final selection = targetSelection ?? current.selection;
    if (selection is EventSelection) {
      final event = current.eventById(selection.chainId, selection.eventId);
      if (asset.kind == AssetKind.audio && event is AudioPlayBgmEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            state;
        return true;
      }
      if (asset.kind == AssetKind.audio && event is AudioPlaySoundEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            state;
        return true;
      }
      if (asset.kind == AssetKind.audio && event is DialogueSayEvent) {
        updateEvent(
          selection.chainId,
          event.copyWith(textSoundAssetId: asset.id),
        );
        select(EditorSelection.event(selection.chainId, selection.eventId));
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)} text sound.',
            ) ??
            state;
        return true;
      }
      if (asset.kind == AssetKind.dialoguePortrait &&
          event is DialogueSayEvent) {
        updateEvent(
          selection.chainId,
          event.copyWith(portraitAssetId: asset.id),
        );
        select(EditorSelection.event(selection.chainId, selection.eventId));
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)} portrait.',
            ) ??
            state;
        return true;
      }
      if (asset.kind == AssetKind.video && event is VideoPlayEvent) {
        updateEvent(selection.chainId, event.copyWith(assetId: asset.id));
        select(EditorSelection.event(selection.chainId, selection.eventId));
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Assigned ${asset.originalName} to ${_eventTypeKey(event)}.',
            ) ??
            state;
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
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Replaced ${object.name} with ${asset.originalName}.',
            ) ??
            state;
        return true;
      }
      if (object is PropSceneObject) {
        updateObject(object.copyWith(assetId: asset.id));
        selectObject(object.id);
        state =
            state.asReady?.copyWith(
              statusMessage:
                  'Replaced ${object.name} with ${asset.originalName}.',
            ) ??
            state;
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
    final current = state.asReady;
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
    state =
        state.asReady?.copyWith(
          statusMessage:
              'Replaced ${selectedCharacter.name} sprite with ${asset.originalName}.',
        ) ??
        state;
  }

  Future<AssetRef?> _importAsset(AssetKind kind) async {
    final current = state.asReady;
    if (current == null) {
      return null;
    }
    try {
      final file = await openFile(
        acceptedTypeGroups: [_typeGroupForKind(kind)],
      );
      if (file == null) {
        state = current.copyWith(statusMessage: 'Import cancelled.');
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
      state = current.copyWith(
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
      state = current.copyWith(statusMessage: 'Import failed: $error');
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

  void select(EditorSelection? selection) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    state = current.copyWith(selection: selection);
  }

  void selectScene(String sceneId) {
    final current = state.asReady;
    if (current == null || current.project.currentSceneId == sceneId) {
      return;
    }
    state = current.copyWith(
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    state = current.copyWith(
      project: previous.project,
      selection: previous.selection,
      clipboardObjects: previous.clipboardObjects,
      isDirty: true,
      statusMessage: 'Undo.',
    );
    _restoringHistory = false;
  }

  void redo() {
    final current = state.asReady;
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
    state = current.copyWith(
      project: next.project,
      selection: next.selection,
      clipboardObjects: next.clipboardObjects,
      isDirty: true,
      statusMessage: 'Redo.',
    );
    _restoringHistory = false;
  }

  void moveSelectedObject(double dx, double dy) {
    final current = state.asReady;
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
    final current = state.asReady;
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
      (object) =>
          ids.contains(object.objectId) && _objectIsTriggerObject(object),
    )) {
      _syncAllPathNodeTriggerLinks();
    }
  }

  void moveSelectedPathNode(double dx, double dy) {
    final current = state.asReady;
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
    final current = state.asReady;
    final node = current?.pathNodeById(chainId, eventId, nodeId);
    if (current == null || node == null) {
      return;
    }
    final nearestTriggerId = _nearestTriggerIdForNode(
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
    state =
        state.asReady?.copyWith(
          statusMessage: nearestTriggerId == null
              ? 'Path node trigger link removed.'
              : trigger == null
              ? 'Path node linked to trigger.'
              : 'Path node linked to ${current.triggerName(trigger)}.',
        ) ??
        state;
  }

  void updateSelectedTransform(Transform2D transform) {
    final current = state.asReady;
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
    final current = state.asReady;
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
    if (_objectIsTriggerObject(object)) {
      _syncAllPathNodeTriggerLinks();
    }
  }

  void setObjectsLocked(List<String> objectIds, bool locked) {
    final current = state.asReady;
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
    final current = state.asReady;
    final ids = current?.selection.objectIds ?? const [];
    if (current == null || ids.isEmpty) {
      return;
    }
    final objects = current.currentScene.objects
        .where((object) => ids.contains(object.objectId))
        .toList(growable: false);
    state = current.copyWith(
      clipboardObjects: objects,
      statusMessage: 'Copied ${objects.length} object(s).',
    );
  }

  void pasteSelection() {
    final current = state.asReady;
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

  void addCharacterInstance() {
    final current = state.asReady;
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
    final current = state.asReady;
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
    state = current.copyWith(
      project: current.project.copyWith(
        characters: [...current.project.characters, character],
      ),
      selection: EditorSelection.character(character.id),
      isDirty: true,
      statusMessage: 'Added ${character.name}.',
    );
  }

  void addTriggerArea() => addTriggerPoint();

  void addTriggerPoint() {
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
    if (current == null) {
      return;
    }
    _replaceCurrentScene(
      current.currentScene.copyWith(
        triggers: current.currentScene.triggers
            .map(
              (candidate) => _triggerId(candidate) == _triggerId(trigger)
                  ? trigger
                  : candidate,
            )
            .toList(),
      ),
    );
  }

  void updateEventChain(EventChain chain) {
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
    final event = current?.eventById(chainId, eventId);
    if (current == null || event is! CharacterMoveEvent) {
      return;
    }
    updateEvent(
      chainId,
      event.copyWith(
        path: event.path.copyWith(
          nodes: _normalizePathNodes(
            event.path.nodes.map((node) {
              return node.id == nodeId ? update(node) : node;
            }).toList(),
            nodeId,
          ),
        ),
      ),
    );
  }

  List<PathNode> _normalizePathNodes(List<PathNode> nodes, String changedId) {
    if (nodes.length < 2) {
      return nodes;
    }
    final normalized = [...nodes];
    final index = normalized.indexWhere((node) => node.id == changedId);
    if (index < 0) {
      return normalized;
    }
    if (index > 0) {
      normalized[index] = _snapNodeToOrthogonal(
        anchor: normalized[index - 1],
        node: normalized[index],
      );
    } else {
      normalized[index] = _snapNodeToOrthogonal(
        anchor: normalized[1],
        node: normalized[index],
      );
    }
    if (index + 1 < normalized.length) {
      normalized[index + 1] = _snapNodeToOrthogonal(
        anchor: normalized[index],
        node: normalized[index + 1],
      );
    }
    return normalized;
  }

  PathNode _snapNodeToOrthogonal({
    required PathNode anchor,
    required PathNode node,
  }) {
    final dx = node.x - anchor.x;
    final dy = node.y - anchor.y;
    if (dx.abs() >= dy.abs()) {
      return node.copyWith(y: anchor.y);
    }
    return node.copyWith(x: anchor.x);
  }

  void removePathNode(String chainId, String eventId, String nodeId) {
    final current = state.asReady;
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
    final current = state.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
      project: current.project.copyWith(
        assets: current.project.assets
            .map((candidate) => candidate.id == asset.id ? asset : candidate)
            .toList(),
      ),
      isDirty: true,
    );
  }

  void deleteUnusedAsset(String assetId) {
    final current = state.asReady;
    if (current == null || current.assetIsUsed(assetId)) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
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
    final current = state.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
      project: current.project.copyWith(
        characters: current.project.characters
            .map(
              (candidate) =>
                  candidate.id == character.id ? character : candidate,
            )
            .toList(),
      ),
      isDirty: true,
    );
  }

  void addCharacterAnimationFrame({
    required String characterId,
    required String assetId,
    required Direction? direction,
  }) {
    final current = state.asReady;
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
    state =
        state.asReady?.copyWith(
          statusMessage:
              'Added ${asset.originalName} to ${direction?.name ?? 'fallback'} sprites.',
        ) ??
        state;
  }

  void removeCharacterAnimationFrame({
    required String characterId,
    required String animationId,
  }) {
    final current = state.asReady;
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
    final current = state.asReady;
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
            .where((trigger) => !triggerIds.contains(_triggerId(trigger)))
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
    final current = state.asReady;
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
    final current = state.asReady;
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
    final current = state.asReady;
    if (current == null) {
      return;
    }
    final scene = current.currentScene.copyWith(
      objects: current.currentScene.objects.map(update).toList(),
    );
    _replaceCurrentScene(scene);
  }

  void _syncAllPathNodeTriggerLinks() {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    var changed = false;
    final scene = current.currentScene.copyWith(
      eventChains: current.currentScene.eventChains.map((chain) {
        return chain.copyWith(
          events: chain.events.map((event) {
            if (event is! CharacterMoveEvent) {
              return event;
            }
            final nodes = event.path.nodes.map((node) {
              final triggerId = _nearestTriggerIdForNode(
                current.currentScene,
                node,
              );
              if (triggerId == node.triggerId) {
                return node;
              }
              changed = true;
              return node.copyWith(triggerId: triggerId);
            }).toList();
            return event.copyWith(path: event.path.copyWith(nodes: nodes));
          }).toList(),
        );
      }).toList(),
    );
    if (changed) {
      _replaceCurrentScene(scene);
    }
  }

  String? _nearestTriggerIdForNode(Scene scene, PathNode node) {
    String? nearestTriggerId;
    var nearestDistance = double.infinity;
    for (final object in scene.objects) {
      final triggerId = object.maybeMap(
        triggerPoint: (value) => value.triggerId,
        triggerArea: (value) => value.triggerId,
        orElse: () => null,
      );
      if (triggerId == null) {
        continue;
      }
      final transform = object.objectTransform;
      const triggerPadding = 10.0;
      final left = transform.x - triggerPadding;
      final top = transform.y - triggerPadding;
      final right =
          transform.x + transform.width * transform.scale + triggerPadding;
      final bottom =
          transform.y + transform.height * transform.scale + triggerPadding;
      final inside =
          node.x >= left &&
          node.x <= right &&
          node.y >= top &&
          node.y <= bottom;
      final center = Offset2D((left + right) / 2, (top + bottom) / 2);
      final distance = center.distanceTo(node.x, node.y);
      if (inside && distance < nearestDistance) {
        nearestTriggerId = triggerId;
        nearestDistance = distance;
      }
    }
    return nearestTriggerId;
  }

  bool _objectIsTriggerObject(SceneObject object) {
    return object.maybeMap(
      triggerPoint: (_) => true,
      triggerArea: (_) => true,
      orElse: () => false,
    );
  }

  void _replaceCurrentScene(Scene scene, {EditorSelection? selection}) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
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

  String _triggerId(Trigger trigger) {
    return trigger.map(
      area: (value) => value.id,
      object: (value) => value.id,
      auto: (value) => value.id,
      moveComplete: (value) => value.id,
    );
  }

  Future<Directory> _defaultProjectDir() async {
    final home = Platform.environment['HOME'];
    final basePath = home == null || home.isEmpty
        ? Directory.current.path
        : p.join(home, 'Documents');
    return Directory(p.join(basePath, 'Deltarune Studio', 'Demo.drs'));
  }

  Future<File> _settingsFile() async {
    final home = Platform.environment['HOME'];
    final appData = Platform.environment['APPDATA'];
    final configHome = Platform.environment['XDG_CONFIG_HOME'];
    final basePath = Platform.isWindows && appData != null && appData.isNotEmpty
        ? appData
        : Platform.isMacOS && home != null && home.isNotEmpty
        ? p.join(home, 'Library', 'Application Support')
        : configHome != null && configHome.isNotEmpty
        ? configHome
        : home != null && home.isNotEmpty
        ? p.join(home, '.config')
        : Directory.current.path;
    final directory = Directory(p.join(basePath, 'Deltarune Studio'));
    await directory.create(recursive: true);
    return File(p.join(directory.path, _settingsFileName));
  }

  Future<String?> _readLastProjectPath() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        return null;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) {
        return null;
      }
      final path = json[_lastProjectPathKey];
      if (path is! String || path.isEmpty) {
        return null;
      }
      return path;
    } on Object {
      return null;
    }
  }

  Future<void> _writeLastProjectPath(Directory directory) async {
    final file = await _settingsFile();
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      encoder.convert({_lastProjectPathKey: directory.path}),
      flush: true,
    );
  }

  Future<void> _clearLastProjectPath() async {
    try {
      final file = await _settingsFile();
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      // Best effort only; a bad preference should never block app startup.
    }
  }
}

final class Offset2D {
  const Offset2D(this.x, this.y);

  final double x;
  final double y;

  double distanceTo(double otherX, double otherY) {
    final dx = x - otherX;
    final dy = y - otherY;
    return math.sqrt(dx * dx + dy * dy);
  }
}

final class _HistoryEntry {
  const _HistoryEntry({
    required this.project,
    required this.selection,
    required this.clipboardObjects,
  });

  final StudioProject project;
  final EditorSelection? selection;
  final List<SceneObject> clipboardObjects;
}

final class _PastedObject {
  const _PastedObject({required this.object, this.trigger, this.chain});

  final SceneObject object;
  final Trigger? trigger;
  final EventChain? chain;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
