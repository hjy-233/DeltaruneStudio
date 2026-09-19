import 'dart:async';

import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_character.dart';
import 'package:deltarune_studio/project/project_character_browser.dart';
import 'package:deltarune_studio/project/project_character_inspector.dart';
import 'package:deltarune_studio/project/project_manifest.dart';
import 'package:deltarune_studio/project/godot_build_service.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/project/project_resource_browser.dart';
import 'package:deltarune_studio/project/project_scene_editor.dart';
import 'package:deltarune_studio/project/project_selection_inspector.dart';
import 'package:deltarune_studio/project/recent_projects.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

part 'project_shell_widgets.dart';
part 'project_shell_character_actions.dart';

class ProjectShell extends StatefulWidget {
  const ProjectShell({super.key});

  @override
  State<ProjectShell> createState() => _ProjectShellState();
}

class _ProjectShellState extends State<ProjectShell> {
  final ProjectRepository _repository = ProjectRepository();
  final GodotBuildService _godotBuildService = GodotBuildService();
  final RecentProjectsStore _recentProjectsStore = RecentProjectsStore();
  ProjectDocument? _document;
  String? _activeRoomPath;
  String? _selectedObjectId;
  String? _selectedAssetPath;
  String? _selectedRoomPath;
  String? _selectedCharacterPath;
  final List<String> _recentProjects = [];
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadRecentProjects();
  }

  Future<void> _loadRecentProjects() async {
    final paths = await _recentProjectsStore.load();
    if (mounted) {
      setState(() {
        _recentProjects
          ..clear()
          ..addAll(paths);
      });
    }
  }

  void _rememberProject(String path) {
    _recentProjects.remove(path);
    _recentProjects.insert(0, path);
    if (_recentProjects.length > 8) {
      _recentProjects.removeLast();
    }
    unawaited(_recentProjectsStore.save(_recentProjects));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final document = _document;
    return Scaffold(
      drawer: _RecentProjectsDrawer(
        paths: _recentProjects,
        onOpen: _openRecentProject,
      ),
      appBar: AppBar(
        title: Builder(
          builder: (context) => InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: Scaffold.of(context).openDrawer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(l10n.appTitle),
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.newProject,
            onPressed: _busy ? null : _createProject,
            icon: const Icon(Icons.create_new_folder),
          ),
          IconButton(
            tooltip: l10n.openProject,
            onPressed: _busy ? null : _openProject,
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            tooltip: l10n.saveProject,
            onPressed: document == null || _busy ? null : _saveProject,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            tooltip: l10n.buildAndRun,
            onPressed: document == null || _busy ? null : _buildAndRun,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: document == null
            ? Center(
                child: _EmptyProjectView(
                  busy: _busy,
                  onCreate: _createProject,
                  onOpen: _openProject,
                ),
              )
            : _ProjectOverview(
                document: document,
                activeRoomPath: _activeRoomPath,
                selectedAssetPath: _selectedAssetPath,
                selectedRoomPath: _selectedRoomPath,
                selectedCharacterPath: _selectedCharacterPath,
                onRoomSelected: _selectRoom,
                onNewRoom: _newRoom,
                onSceneChanged: _updateScene,
                onSelectionChanged: _selectObject,
                onAssetSelected: _selectAsset,
                onImportAsset: _importAsset,
                onAssetContextMenu: _showAssetContextMenu,
                onFolderContextMenu: _showFolderContextMenu,
                onRoomContextMenu: _showRoomContextMenu,
                onAssetRenamed: _renameAssetTo,
                onAssetDeleted: _deleteAsset,
                onRoomRenamed: _renameRoomTo,
                onRoomDeleted: _deleteRoom,
                onRoomBackgroundChanged: _changeRoomBackground,
                onCharacterSelected: _selectCharacter,
                onNewCharacter: _newCharacter,
                onCharacterChanged: _saveCharacter,
                onCharacterDeleted: _deleteCharacter,
                onLayoutChanged: _updateLayout,
              ),
      ),
      bottomNavigationBar: _message == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_message!, textAlign: TextAlign.center),
              ),
            ),
    );
  }

  Future<void> _createProject() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await _askProjectName();
    if (!mounted || name == null) {
      return;
    }
    final parentPath = await getDirectoryPath();
    if (!mounted || parentPath == null) {
      return;
    }
    await _run(
      () => _repository.create(parentPath: parentPath, name: name),
      success: (document) => l10n.projectCreated(document.path),
    );
  }

  Future<void> _openProject() async {
    final l10n = AppLocalizations.of(context)!;
    final path = await getDirectoryPath();
    if (!mounted || path == null) {
      return;
    }
    await _run(
      () => _repository.open(path),
      success: (document) => l10n.projectOpened(document.manifest.name),
    );
  }

  Future<void> _openRecentProject(String path) async {
    Navigator.of(context).pop();
    await _openAtPath(path);
  }

  Future<void> _openAtPath(String path) async {
    final l10n = AppLocalizations.of(context)!;
    await _run(
      () => _repository.open(path),
      success: (document) => l10n.projectOpened(document.manifest.name),
    );
  }

  Future<void> _saveProject() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _run(() async {
      await _repository.save(document);
      return document;
    }, success: (_) => l10n.projectSaved);
  }

  Future<void> _importAsset(String type, {String? destinationPath}) async {
    final document = _document;
    if (document == null) {
      return;
    }
    final file = await openFile();
    if (!mounted || file == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _run(
      () => _repository.importAsset(
        document,
        sourcePath: file.path,
        type: type,
        destinationPath: destinationPath,
      ),
      preserveActiveRoom: true,
      success: (_) => l10n.resourceImported(file.name),
    );
  }

  Future<void> _newRoom() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final name = await _askRoomName();
    if (!mounted || name == null) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final updated = await _repository.addRoom(document, name);
      if (mounted) {
        setState(() {
          _document = updated;
          _activeRoomPath = updated.rooms.last.path;
          _message = AppLocalizations.of(context)!.roomCreated(name);
        });
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _message = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _showAssetContextMenu(
    ProjectAsset asset,
    Offset position,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
        PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
      ],
    );
    if (!mounted) {
      return;
    }
    if (action == 'rename') {
      final name = await _askValue(l10n.renameResource, asset.name);
      if (name != null) {
        await _renameAssetTo(asset, name);
      }
    } else if (action == 'delete') {
      await _deleteAsset(asset);
    }
  }

  Future<void> _showFolderContextMenu(
    String folderPath,
    Offset position,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nested = p.split(p.normalize(folderPath)).length > 2;
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(value: 'new', child: Text(l10n.newFolder)),
        PopupMenuItem(value: 'import', child: Text(l10n.importHere)),
        if (nested) PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
        if (nested) PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
      ],
    );
    if (action == null || !mounted) {
      return;
    }
    final parts = p.split(p.normalize(folderPath));
    final type = parts.length > 1 ? parts[1] : '';
    if (action == 'import') {
      await _importAsset(type, destinationPath: folderPath);
    } else if (action == 'new') {
      final name = await _askValue(l10n.newFolder, l10n.newFolder);
      if (name == null) {
        return;
      }
      await _run(
        () => _repository.createResourceFolder(_document!, folderPath, name),
        preserveActiveRoom: true,
        success: (_) => l10n.folderCreated,
      );
    } else if (action == 'rename') {
      final name = await _askValue(l10n.renameFolder, p.basename(folderPath));
      if (name == null) {
        return;
      }
      await _run(
        () => _repository.renameResourceFolder(_document!, folderPath, name),
        preserveActiveRoom: true,
        success: (_) => l10n.folderRenamed,
      );
    } else if (action == 'delete') {
      final confirmed = await _confirm(
        l10n.deleteQuestion(p.basename(folderPath)),
      );
      if (confirmed != true) {
        return;
      }
      await _run(
        () => _repository.deleteResourceFolder(_document!, folderPath),
        preserveActiveRoom: true,
        success: (_) => l10n.folderDeleted,
      );
    }
  }

  Future<void> _showRoomContextMenu(ProjectRoom room, Offset position) async {
    final l10n = AppLocalizations.of(context)!;
    final items = <PopupMenuEntry<String>>[
      PopupMenuItem(value: 'rename', child: Text(l10n.rename)),
    ];
    if (room.path != _document?.manifest.mainScene) {
      items.add(PopupMenuItem(value: 'delete', child: Text(l10n.delete)));
    }
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: items,
    );
    if (!mounted) {
      return;
    }
    if (action == 'rename') {
      final name = await _askValue(l10n.renameRoom, room.scene.name);
      if (name != null) {
        await _renameRoomTo(room, name);
      }
    } else if (action == 'delete') {
      await _deleteRoom(room);
    }
  }

  Future<void> _renameAssetTo(ProjectAsset asset, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == asset.name) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final parent = p.dirname(asset.path);
    await _run(
      () => _repository.renameAsset(_document!, asset, trimmed),
      preserveActiveRoom: true,
      success: (_) {
        _selectedAssetPath = p.join(parent, trimmed);
        return l10n.resourceRenamed;
      },
    );
  }

  Future<void> _deleteAsset(ProjectAsset asset) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(l10n.deleteQuestion(asset.name));
    if (confirmed != true) {
      return;
    }
    await _run(
      () => _repository.deleteAsset(_document!, asset),
      preserveActiveRoom: true,
      success: (_) {
        if (_selectedAssetPath == asset.path) {
          _selectedAssetPath = null;
        }
        return l10n.resourceDeleted;
      },
    );
  }

  Future<void> _renameRoomTo(ProjectRoom room, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == room.scene.name) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _run(
      () => _repository.renameRoom(_document!, room.path, trimmed),
      preserveActiveRoom: true,
      success: (_) => l10n.roomRenamed,
    );
  }

  Future<void> _deleteRoom(ProjectRoom room) async {
    final document = _document;
    if (document == null || room.path == document.manifest.mainScene) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await _confirm(l10n.deleteQuestion(room.scene.name));
    if (confirmed != true) {
      return;
    }
    await _run(
      () => _repository.deleteRoom(document, room.path),
      preserveActiveRoom: true,
      success: (_) {
        _activeRoomPath = document.manifest.mainScene;
        _selectedRoomPath = document.manifest.mainScene;
        return l10n.roomDeleted;
      },
    );
  }

  Future<String?> _askValue(String title, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirm(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _buildAndRun() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _godotBuildService.buildAndRun(document);
      if (mounted) {
        setState(() => _message = l10n.godotStarted);
      }
    } on Object catch (error) {
      if (mounted) {
        final message = error is StateError ? error.message : error.toString();
        setState(() => _message = message);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _updateScene(ProjectScene scene) {
    final document = _document;
    if (document == null) {
      return;
    }
    final roomPath = _activeRoomPath ?? document.manifest.mainScene;
    final rooms = document.rooms.isEmpty
        ? [ProjectRoom(path: roomPath, scene: scene)]
        : document.rooms
              .map(
                (room) =>
                    room.path == roomPath ? room.copyWith(scene: scene) : room,
              )
              .toList(growable: false);
    setState(() {
      _document = document.copyWith(
        mainScene: roomPath == document.manifest.mainScene
            ? scene
            : document.mainScene,
        rooms: rooms,
      );
      _message = 'Scene changed. Save to write it to disk.';
    });
  }

  void _replaceSelectedAsset(ProjectAsset asset) {
    final document = _document;
    final selectedId = _selectedObjectId;
    if (document == null) {
      return;
    }
    final roomPath = _activeRoomPath ?? document.manifest.mainScene;
    final current = _sceneFor(document, roomPath);
    if (selectedId == null && asset.type == 'backgrounds') {
      _updateScene(current.copyWith(background: asset.path));
      return;
    }
    if (selectedId == null) {
      return;
    }
    ProjectSceneObject? selected;
    for (final object in current.objects) {
      if (object.id == selectedId) {
        selected = object;
        break;
      }
    }
    if (selected == null) {
      return;
    }
    _updateScene(
      current.copyWith(
        objects: current.objects
            .map(
              (object) => object.id == selectedId
                  ? object.copyWith(
                      asset: asset.path,
                      width: -1,
                      height: -1,
                      characterPath: object.type == 'character'
                          ? ''
                          : object.characterPath,
                    )
                  : object,
            )
            .toList(growable: false),
      ),
    );
  }

  void _selectAsset(ProjectAsset asset) {
    if (_selectedObjectId != null) {
      _replaceSelectedAsset(asset);
      return;
    }
    if (asset.type == 'backgrounds') {
      _replaceSelectedAsset(asset);
    }
    setState(() {
      _selectedAssetPath = asset.path;
      _selectedRoomPath = null;
      _selectedCharacterPath = null;
    });
  }

  void _selectObject(String? id) {
    setState(() {
      _selectedObjectId = id;
      _selectedAssetPath = null;
      _selectedRoomPath = null;
      _selectedCharacterPath = null;
    });
  }

  void _changeRoomBackground(ProjectRoom room, String? assetPath) {
    _activeRoomPath = room.path;
    _updateScene(
      room.scene.copyWith(
        background: assetPath,
        clearBackground: assetPath == null,
      ),
    );
  }

  void _updateLayout(ProjectLayout layout) {
    final document = _document;
    if (document == null) {
      return;
    }
    setState(() {
      _document = document.copyWith(
        manifest: document.manifest.copyWith(layout: layout),
      );
    });
  }

  ProjectScene _sceneFor(ProjectDocument document, String roomPath) {
    if (roomPath == document.manifest.mainScene || document.rooms.isEmpty) {
      return document.mainScene;
    }
    for (final room in document.rooms) {
      if (room.path == roomPath) {
        return room.scene;
      }
    }
    return document.mainScene;
  }

  void _selectRoom(String path) {
    setState(() {
      _activeRoomPath = path;
      _selectedRoomPath = path;
      _selectedAssetPath = null;
      _selectedObjectId = null;
      _selectedCharacterPath = null;
    });
  }

  void _selectCharacterState(ProjectCharacterFile character) {
    setState(() {
      _selectedCharacterPath = character.path;
      _selectedAssetPath = null;
      _selectedRoomPath = null;
      _selectedObjectId = null;
    });
  }

  Future<void> _run(
    Future<ProjectDocument> Function() action, {
    required String Function(ProjectDocument document) success,
    bool preserveActiveRoom = false,
  }) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final document = await action();
      if (!mounted) {
        return;
      }
      setState(() {
        _document = document;
        if (!preserveActiveRoom) {
          _activeRoomPath = document.manifest.mainScene;
          _selectedObjectId = null;
          _selectedAssetPath = null;
          _selectedRoomPath = null;
          _selectedCharacterPath = null;
        }
        _rememberProject(document.path);
        _message = success(document);
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<String?> _askProjectName() {
    final controller = TextEditingController(text: 'My Game');
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.newProject),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.projectName),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        );
      },
    );
  }

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
              if (value.isNotEmpty) {
                Navigator.of(context).pop(value);
              }
            },
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
  }
}

class _ProjectOverview extends StatefulWidget {
  const _ProjectOverview({
    required this.document,
    required this.activeRoomPath,
    required this.selectedAssetPath,
    required this.selectedRoomPath,
    required this.selectedCharacterPath,
    required this.onRoomSelected,
    required this.onNewRoom,
    required this.onSceneChanged,
    required this.onSelectionChanged,
    required this.onAssetSelected,
    required this.onImportAsset,
    required this.onAssetContextMenu,
    required this.onFolderContextMenu,
    required this.onRoomContextMenu,
    required this.onAssetRenamed,
    required this.onAssetDeleted,
    required this.onRoomRenamed,
    required this.onRoomDeleted,
    required this.onRoomBackgroundChanged,
    required this.onCharacterSelected,
    required this.onNewCharacter,
    required this.onCharacterChanged,
    required this.onCharacterDeleted,
    required this.onLayoutChanged,
  });

  final ProjectDocument document;
  final String? activeRoomPath;
  final String? selectedAssetPath;
  final String? selectedRoomPath;
  final String? selectedCharacterPath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;
  final ValueChanged<ProjectScene> onSceneChanged;
  final ValueChanged<String?> onSelectionChanged;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;
  final void Function(ProjectAsset, Offset) onAssetContextMenu;
  final void Function(String, Offset) onFolderContextMenu;
  final void Function(ProjectRoom, Offset) onRoomContextMenu;
  final Future<void> Function(ProjectAsset, String) onAssetRenamed;
  final Future<void> Function(ProjectAsset) onAssetDeleted;
  final Future<void> Function(ProjectRoom, String) onRoomRenamed;
  final Future<void> Function(ProjectRoom) onRoomDeleted;
  final void Function(ProjectRoom, String?) onRoomBackgroundChanged;
  final ValueChanged<ProjectCharacterFile> onCharacterSelected;
  final VoidCallback onNewCharacter;
  final ValueChanged<ProjectCharacterFile> onCharacterChanged;
  final ValueChanged<ProjectCharacterFile> onCharacterDeleted;
  final ValueChanged<ProjectLayout> onLayoutChanged;

  @override
  State<_ProjectOverview> createState() => _ProjectOverviewState();
}

class _ProjectOverviewState extends State<_ProjectOverview> {
  late double _sidebarWidth = widget.document.manifest.layout.sidebarWidth;

  @override
  void didUpdateWidget(covariant _ProjectOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.manifest.layout.sidebarWidth !=
        widget.document.manifest.layout.sidebarWidth) {
      _sidebarWidth = widget.document.manifest.layout.sidebarWidth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.manifest.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(document.path),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _sidebarWidth,
                child: _WorkspaceSidebar(
                  document: document,
                  activePath: widget.activeRoomPath,
                  selectedAssetPath: widget.selectedAssetPath,
                  selectedCharacterPath: widget.selectedCharacterPath,
                  onRoomSelected: widget.onRoomSelected,
                  onNewRoom: widget.onNewRoom,
                  onAssetSelected: widget.onAssetSelected,
                  onImportAsset: widget.onImportAsset,
                  onAssetContextMenu: widget.onAssetContextMenu,
                  onFolderContextMenu: widget.onFolderContextMenu,
                  onRoomContextMenu: widget.onRoomContextMenu,
                  onCharacterSelected: widget.onCharacterSelected,
                  onNewCharacter: widget.onNewCharacter,
                ),
              ),
              _PanelDivider(
                onDrag: (delta) => setState(() {
                  final width = (_sidebarWidth + delta)
                      .clamp(180.0, 360.0)
                      .toDouble();
                  _sidebarWidth = width;
                  widget.onLayoutChanged(
                    document.manifest.layout.copyWith(sidebarWidth: width),
                  );
                }),
              ),
              Expanded(
                child: ProjectSceneEditor(
                  document: _roomDocument(document, widget.activeRoomPath),
                  onChanged: widget.onSceneChanged,
                  onSelectionChanged: widget.onSelectionChanged,
                  inspectorWidth: document.manifest.layout.inspectorWidth,
                  onInspectorWidthChanged: (width) => widget.onLayoutChanged(
                    document.manifest.layout.copyWith(inspectorWidth: width),
                  ),
                  externalInspector: _externalInspector(document),
                  externalSelectionKey: _externalSelectionKey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ProjectDocument _roomDocument(ProjectDocument document, String? path) {
    if (path == null || path == document.manifest.mainScene) {
      return document;
    }
    final room = document.rooms.firstWhere(
      (room) => room.path == path,
      orElse: () => ProjectRoom(path: path, scene: document.mainScene),
    );
    return document.copyWith(mainScene: room.scene);
  }

  String? get _externalSelectionKey {
    if (widget.selectedCharacterPath != null) {
      return 'character:${widget.selectedCharacterPath}';
    }
    if (widget.selectedAssetPath != null) {
      return 'asset:${widget.selectedAssetPath}';
    }
    if (widget.selectedRoomPath != null) {
      return 'room:${widget.selectedRoomPath}';
    }
    return null;
  }

  Widget? _externalInspector(ProjectDocument document) {
    final characterPath = widget.selectedCharacterPath;
    if (characterPath != null) {
      for (final character in document.characters) {
        if (character.path == characterPath) {
          return ProjectCharacterInspector(
            document: document,
            character: character,
            onChanged: widget.onCharacterChanged,
            onDelete: () => widget.onCharacterDeleted(character),
          );
        }
      }
    }
    final assetPath = widget.selectedAssetPath;
    if (assetPath != null) {
      ProjectAsset? selected;
      for (final asset in document.assets) {
        if (asset.path == assetPath) {
          selected = asset;
          break;
        }
      }
      if (selected != null) {
        final asset = selected;
        return ProjectAssetInspector(
          document: document,
          asset: asset,
          onRename: (name) => widget.onAssetRenamed(asset, name),
          onDelete: () => widget.onAssetDeleted(asset),
        );
      }
    }
    final roomPath = widget.selectedRoomPath;
    if (roomPath != null) {
      ProjectRoom? selected;
      for (final room in document.rooms) {
        if (room.path == roomPath) {
          selected = room;
          break;
        }
      }
      if (selected != null) {
        final room = selected;
        return ProjectRoomInspector(
          document: document,
          room: room,
          onRename: (name) => widget.onRoomRenamed(room, name),
          onBackgroundChanged: (path) =>
              widget.onRoomBackgroundChanged(room, path),
          onDelete: room.path == document.manifest.mainScene
              ? null
              : () => widget.onRoomDeleted(room),
        );
      }
    }
    return null;
  }
}
