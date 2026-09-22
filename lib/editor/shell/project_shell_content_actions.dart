part of 'project_shell.dart';

extension _ProjectShellContentActions on _ProjectShellState {
  Future<String?> _askRoomName() {
    final controller = TextEditingController(text: 'New Room');
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newRoom),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.of(context).pop(value);
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrefabLibrary() async {
    final document = _document;
    if (document == null) return;
    final prefab = await showDialog<ProjectPrefab>(
      context: context,
      builder: (context) => ProjectPrefabLibrary(
        document: document,
        selectedObject: _selectedObject(document),
        onSave: (name, object) async {
          final updated = await _repository.savePrefab(
            _document!,
            name: name,
            object: object,
          );
          if (mounted) _setShellState(() => _document = updated);
          return updated;
        },
        onDelete: (prefab) async {
          final updated = await _repository.deletePrefab(_document!, prefab);
          if (mounted) _setShellState(() => _document = updated);
          return updated;
        },
      ),
    );
    if (prefab == null || !mounted) return;
    _insertPrefab(prefab);
  }

  Future<void> _showDialogueEditor() async {
    final document = _document;
    if (document == null) return;
    await showDialog<void>(
      context: context,
      builder: (context) => ProjectDialogueEditor(
        document: document,
        onCreate: (id) =>
            _persistContent(() => _repository.createDialogue(_document!, id)),
        onSave: (dialogue) => _persistContent(
          () => _repository.saveDialogue(_document!, dialogue),
        ),
        onDelete: (dialogue) => _persistContent(
          () => _repository.deleteDialogue(_document!, dialogue),
        ),
      ),
    );
  }

  Future<ProjectDocument> _persistContent(
    Future<ProjectDocument> Function() action,
  ) async {
    final updated = await action();
    if (mounted) {
      _setShellState(() => _document = updated);
      _scheduleHotReload();
    }
    return updated;
  }

  ProjectSceneObject? _selectedObject(ProjectDocument document) {
    final id = _selectedObjectId;
    if (id == null) return null;
    final scene = _sceneFor(
      document,
      _activeRoomPath ?? document.manifest.mainScene,
    );
    for (final object in scene.objects) {
      if (object.id == id) return object;
    }
    return null;
  }

  void _insertPrefab(ProjectPrefab prefab) {
    final document = _document;
    if (document == null) return;
    final roomPath = _activeRoomPath ?? document.manifest.mainScene;
    final scene = _sceneFor(document, roomPath);
    final game = document.manifest.gameSettings;
    final object = prefab.object.copyWith(
      id: const Uuid().v4(),
      name: prefab.name,
      x: game.viewportWidth / 2,
      y: game.viewportHeight / 2,
      zIndex: scene.objects.length,
    );
    _selectedObjectId = object.id;
    _updateScene(scene.copyWith(objects: [...scene.objects, object]));
  }

  void _scheduleHotReload() {
    _hotReloadTimer?.cancel();
    _hotReloadTimer = Timer(const Duration(milliseconds: 300), () async {
      final document = _document;
      if (document == null) return;
      try {
        await _repository.save(document);
        final reloaded = await _godotBuildService.syncHotReload(document);
        if (reloaded && mounted) {
          _setShellState(
            () => _message = ProjectFeatureStrings.of(context).hotReloaded,
          );
        }
      } on Object catch (error) {
        if (mounted) _setShellState(() => _message = error.toString());
      }
    });
  }
}
