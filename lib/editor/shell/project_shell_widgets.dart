part of 'project_shell.dart';

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
    required this.selectedAssetPath,
    required this.selectedCharacterPath,
    required this.onRoomSelected,
    required this.onNewRoom,
    required this.onAssetSelected,
    required this.onImportAsset,
    required this.onAssetContextMenu,
    required this.onFolderContextMenu,
    required this.onRoomContextMenu,
    required this.onCharacterSelected,
    required this.onNewCharacter,
  });

  final ProjectDocument document;
  final String? activePath;
  final String? selectedAssetPath;
  final String? selectedCharacterPath;
  final ValueChanged<String> onRoomSelected;
  final VoidCallback onNewRoom;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;
  final void Function(ProjectAsset, Offset) onAssetContextMenu;
  final void Function(String, Offset) onFolderContextMenu;
  final void Function(ProjectRoom, Offset) onRoomContextMenu;
  final ValueChanged<ProjectCharacterFile> onCharacterSelected;
  final VoidCallback onNewCharacter;

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
                ProjectResourceBrowser(
                  document: document,
                  title: l10n.resourcesTab,
                  selectedAssetPath: selectedAssetPath,
                  onAssetSelected: onAssetSelected,
                  onImportAsset: onImportAsset,
                  onAssetContextMenu: onAssetContextMenu,
                  onFolderContextMenu: onFolderContextMenu,
                ),
                ProjectCharacterBrowser(
                  characters: document.characters,
                  selectedPath: selectedCharacterPath,
                  onSelected: onCharacterSelected,
                  onAdd: onNewCharacter,
                ),
                _RoomTab(
                  document: document,
                  activePath: activePath,
                  onSelected: onRoomSelected,
                  onNewRoom: onNewRoom,
                  onContextMenu: onRoomContextMenu,
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.entryScript),
          subtitle: Text(document.manifest.entryScript),
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
    required this.onContextMenu,
  });

  final ProjectDocument document;
  final String? activePath;
  final ValueChanged<String> onSelected;
  final VoidCallback onNewRoom;
  final void Function(ProjectRoom, Offset) onContextMenu;

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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: ProjectFeatureStrings.of(context).roomGraph,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => ProjectRoomGraphDialog(
                    document: document,
                    onRoomSelected: onSelected,
                  ),
                ),
                icon: const Icon(Icons.account_tree_outlined),
              ),
              IconButton(
                tooltip: l10n.newRoom,
                onPressed: onNewRoom,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        for (final room in rooms)
          GestureDetector(
            onSecondaryTapUp: (details) =>
                onContextMenu(room, details.globalPosition),
            child: ListTile(
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
