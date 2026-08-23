import 'dart:async';

import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_manifest.dart';
import 'package:deltarune_studio/project/godot_build_service.dart';
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: document == null
                ? _EmptyProjectView(
                    busy: _busy,
                    onCreate: _createProject,
                    onOpen: _openProject,
                  )
                : _ProjectOverview(
                    document: document,
                    activeRoomPath: _activeRoomPath,
                    onRoomSelected: _selectRoom,
                    onNewRoom: _newRoom,
                    onSceneChanged: _updateScene,
                  ),
          ),
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
  });

  final ProjectDocument document;
  final String? activeRoomPath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;
  final ValueChanged<ProjectScene> onSceneChanged;

  @override
  State<_ProjectOverview> createState() => _ProjectOverviewState();
}

class _ProjectOverviewState extends State<_ProjectOverview> {
  double _sidebarWidth = 230;

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
        SizedBox(
          height: 620,
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
                ),
              ),
              _PanelDivider(
                onDrag: (delta) => setState(
                  () => _sidebarWidth = (_sidebarWidth + delta).clamp(180, 360),
                ),
              ),
              Expanded(
                child: ProjectSceneEditor(
                  document: _roomDocument(document, widget.activeRoomPath),
                  onChanged: widget.onSceneChanged,
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
  });

  final ProjectDocument document;
  final String? activePath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
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
                _ResourceTab(title: l10n.resourcesTab, folder: 'resources/'),
                _ResourceTab(title: l10n.charactersTab, folder: 'characters/'),
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

class _ResourceTab extends StatelessWidget {
  const _ResourceTab({required this.title, required this.folder});

  final String title;
  final String folder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_outlined),
          title: Text(title),
          subtitle: Text(l10n.projectStructure),
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_open_outlined),
          title: Text(folder),
          subtitle: Text(l10n.resourceBrowserNextStep),
        ),
      ],
    );
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
