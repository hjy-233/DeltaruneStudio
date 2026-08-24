import 'dart:async';

import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_manifest.dart';
import 'package:deltarune_studio/project/godot_build_service.dart';
import 'package:deltarune_studio/project/project_asset_thumbnail.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/project/project_scene_editor.dart';
import 'package:deltarune_studio/project/recent_projects.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

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
                onRoomSelected: _selectRoom,
                onNewRoom: _newRoom,
                onSceneChanged: _updateScene,
                onSelectionChanged: (id) => _selectedObjectId = id,
                onAssetSelected: _replaceSelectedAsset,
                onImportAsset: _importAsset,
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

  Future<void> _importAsset(String type) async {
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
      () =>
          _repository.importAsset(document, sourcePath: file.path, type: type),
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
                  ? object.copyWith(asset: asset.path, width: -1, height: -1)
                  : object,
            )
            .toList(growable: false),
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
    setState(() => _activeRoomPath = path);
  }

  Future<void> _run(
    Future<ProjectDocument> Function() action, {
    required String Function(ProjectDocument document) success,
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
        _activeRoomPath = document.manifest.mainScene;
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

class _EmptyProjectView extends StatelessWidget {
  const _EmptyProjectView({
    required this.busy,
    required this.onCreate,
    required this.onOpen,
  });

  final bool busy;
  final VoidCallback onCreate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.folder_copy_outlined, size: 64),
        const SizedBox(height: 20),
        Text(l10n.noProject, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: busy ? null : onCreate,
              icon: const Icon(Icons.create_new_folder),
              label: Text(l10n.newProject),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : onOpen,
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.openProject),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectOverview extends StatefulWidget {
  const _ProjectOverview({
    required this.document,
    required this.activeRoomPath,
    required this.onRoomSelected,
    required this.onNewRoom,
    required this.onSceneChanged,
    required this.onSelectionChanged,
    required this.onAssetSelected,
    required this.onImportAsset,
    required this.onLayoutChanged,
  });

  final ProjectDocument document;
  final String? activeRoomPath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;
  final ValueChanged<ProjectScene> onSceneChanged;
  final ValueChanged<String?> onSelectionChanged;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;
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
                  onRoomSelected: widget.onRoomSelected,
                  onNewRoom: widget.onNewRoom,
                  onAssetSelected: widget.onAssetSelected,
                  onImportAsset: widget.onImportAsset,
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
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider({required this.onDrag});

  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: const SizedBox(
          width: 12,
          child: Center(child: VerticalDivider(width: 1, thickness: 1)),
        ),
      ),
    );
  }
}

class _WorkspaceSidebar extends StatelessWidget {
  const _WorkspaceSidebar({
    required this.document,
    required this.activePath,
    required this.onRoomSelected,
    required this.onNewRoom,
    required this.onAssetSelected,
    required this.onImportAsset,
  });

  final ProjectDocument document;
  final String? activePath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: false,
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                icon: const Icon(Icons.folder_copy_outlined),
                text: l10n.projectTab,
              ),
              Tab(
                icon: const Icon(Icons.image_outlined),
                text: l10n.resourcesTab,
              ),
              Tab(
                icon: const Icon(Icons.people_outline),
                text: l10n.charactersTab,
              ),
              Tab(
                icon: const Icon(Icons.meeting_room_outlined),
                text: l10n.roomsTab,
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ProjectTab(document: document),
                _ResourceTab(
                  document: document,
                  title: l10n.resourcesTab,
                  onAssetSelected: onAssetSelected,
                  onImportAsset: onImportAsset,
                ),
                _ResourceTab(
                  document: document,
                  title: l10n.charactersTab,
                  typeFilter: 'characters',
                  onAssetSelected: onAssetSelected,
                  onImportAsset: onImportAsset,
                ),
                _RoomTab(
                  document: document,
                  activePath: activePath,
                  onSelected: onRoomSelected,
                  onNewRoom: onNewRoom,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectTab extends StatelessWidget {
  const _ProjectTab({required this.document});

  final ProjectDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.games_outlined),
          title: Text(document.manifest.name),
          subtitle: Text(l10n.projectTab),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.projectPath),
          subtitle: Text(document.path),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.sceneFolder),
          subtitle: Text(document.manifest.mainScene),
        ),
      ],
    );
  }
}

class _ResourceTab extends StatefulWidget {
  const _ResourceTab({
    required this.document,
    required this.title,
    required this.onAssetSelected,
    required this.onImportAsset,
    this.typeFilter,
  });

  final ProjectDocument document;
  final String title;
  final String? typeFilter;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;

  @override
  State<_ResourceTab> createState() => _ResourceTabState();
}

class _ResourceTabState extends State<_ResourceTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final query = _query.trim().toLowerCase();
    final assets = widget.document.assets
        .where(
          (asset) =>
              widget.typeFilter == null || asset.type == widget.typeFilter,
        )
        .where(
          (asset) =>
              query.isEmpty ||
              asset.name.toLowerCase().contains(query) ||
              asset.path.toLowerCase().contains(query),
        )
        .toList(growable: false);
    final groupedAssets = <String, List<ProjectAsset>>{};
    for (final asset in assets) {
      groupedAssets.putIfAbsent(asset.type, () => []).add(asset);
    }
    final groups = groupedAssets.keys.toList()..sort();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: l10n.searchResources,
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              IconButton(
                tooltip: l10n.importResource,
                icon: const Icon(Icons.add),
                onPressed: () => _chooseImportType(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: groups.isEmpty ? 1 : groups.length,
            itemBuilder: (context, index) {
              if (groups.isEmpty) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_open_outlined),
                  title: Text(widget.title),
                  subtitle: Text(l10n.noResources),
                );
              }
              final group = groups[index];
              final groupAssets = groupedAssets[group]!;
              return ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(left: 12),
                leading: const Icon(Icons.folder_outlined),
                title: Text(group),
                subtitle: Text('${groupAssets.length}'),
                children: [
                  for (final asset in groupAssets)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ProjectAssetThumbnail(
                        path: '${widget.document.path}/${asset.path}',
                      ),
                      title: Text(
                        asset.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(_assetSubpath(asset)),
                      onTap: () => widget.onAssetSelected(asset),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _assetSubpath(ProjectAsset asset) {
    final prefix = 'resources/${asset.type}/';
    return asset.path.startsWith(prefix)
        ? asset.path.substring(prefix.length)
        : asset.path;
  }

  Future<void> _chooseImportType(BuildContext context) async {
    final type =
        widget.typeFilter ??
        await showDialog<String>(
          context: context,
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return SimpleDialog(
              title: Text(l10n.selectResourceType),
              children: [
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'backgrounds'),
                  child: Text(l10n.backgroundResources),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'characters'),
                  child: Text(l10n.characterResources),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'props'),
                  child: Text(l10n.propResources),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'audio'),
                  child: Text(l10n.audioResources),
                ),
                SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, 'video'),
                  child: Text(l10n.videoResources),
                ),
              ],
            );
          },
        );
    if (type != null && mounted) {
      widget.onImportAsset(type);
    }
  }
}

class _RoomTab extends StatelessWidget {
  const _RoomTab({
    required this.document,
    required this.activePath,
    required this.onSelected,
    required this.onNewRoom,
  });

  final ProjectDocument document;
  final String? activePath;
  final ValueChanged<String> onSelected;
  final VoidCallback onNewRoom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rooms = document.rooms.isEmpty
        ? [
            ProjectRoom(
              path: document.manifest.mainScene,
              scene: document.mainScene,
            ),
          ]
        : document.rooms;
    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        ListTile(
          title: Text(l10n.roomsTab),
          trailing: IconButton(
            tooltip: l10n.newRoom,
            onPressed: onNewRoom,
            icon: const Icon(Icons.add),
          ),
        ),
        for (final room in rooms)
          ListTile(
            dense: true,
            selected: room.path == activePath,
            leading: const Icon(Icons.meeting_room_outlined),
            title: Text(room.scene.name),
            subtitle: Text(
              room.path,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => onSelected(room.path),
          ),
      ],
    );
  }
}

class _RecentProjectsDrawer extends StatelessWidget {
  const _RecentProjectsDrawer({required this.paths, required this.onOpen});

  final List<String> paths;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text('Recent Projects', style: TextStyle(fontSize: 18)),
          ),
          if (paths.isEmpty)
            const ListTile(title: Text('No recent projects'))
          else
            for (final path in paths)
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(path.split('/').last),
                subtitle: Text(
                  path,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => onOpen(path),
              ),
        ],
      ),
    );
  }
}
