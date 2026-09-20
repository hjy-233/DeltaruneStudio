import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/widgets/project_audit_dialog.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:deltarune_studio/editor/widgets/project_asset_thumbnail.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class ProjectResourceBrowser extends StatefulWidget {
  const ProjectResourceBrowser({
    super.key,
    required this.document,
    required this.title,
    required this.onAssetSelected,
    required this.onImportAsset,
    required this.onAssetContextMenu,
    required this.onFolderContextMenu,
    this.typeFilter,
    this.selectedAssetPath,
  });

  final ProjectDocument document;
  final String title;
  final String? typeFilter;
  final String? selectedAssetPath;
  final ValueChanged<ProjectAsset> onAssetSelected;
  final ValueChanged<String> onImportAsset;
  final void Function(ProjectAsset, Offset) onAssetContextMenu;
  final void Function(String, Offset) onFolderContextMenu;

  @override
  State<ProjectResourceBrowser> createState() => _ProjectResourceBrowserState();
}

class _ProjectResourceBrowserState extends State<ProjectResourceBrowser> {
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
        .toList(growable: false);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.searchResources,
                    isDense: true,
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              IconButton(
                tooltip: ProjectFeatureStrings.of(context).resourceAudit,
                icon: const Icon(Icons.fact_check_outlined),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) =>
                      ProjectAuditDialog(document: widget.document),
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
          child: query.isEmpty
              ? _folderTree(assets)
              : _searchResults(assets, query),
        ),
      ],
    );
  }

  Widget _folderTree(List<ProjectAsset> assets) {
    final basePath = widget.typeFilter == null
        ? 'resources'
        : p.join('resources', widget.typeFilter);
    final root = _ResourceFolderNode(path: basePath, name: widget.title);
    for (final folderPath in widget.document.resourceFolders) {
      if (folderPath == basePath || !p.isWithin(basePath, folderPath)) {
        continue;
      }
      root.addFolder(folderPath);
    }
    for (final asset in assets) {
      if (p.isWithin(basePath, asset.path)) {
        root.addAsset(asset);
      }
    }
    if (root.folders.isEmpty && root.assets.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noResources));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      children: [
        for (final folder in root.sortedFolders) _folderTile(folder, 0),
        for (final asset in root.sortedAssets) _assetTile(asset, 0),
      ],
    );
  }

  Widget _folderTile(_ResourceFolderNode folder, int depth) {
    return GestureDetector(
      onSecondaryTapUp: (details) =>
          widget.onFolderContextMenu(folder.path, details.globalPosition),
      child: ExpansionTile(
        key: PageStorageKey(folder.path),
        tilePadding: EdgeInsets.only(left: depth * 12.0),
        childrenPadding: EdgeInsets.zero,
        leading: const Icon(Icons.folder_outlined),
        title: Text(folder.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        children: [
          for (final child in folder.sortedFolders)
            _folderTile(child, depth + 1),
          for (final asset in folder.sortedAssets) _assetTile(asset, depth + 1),
        ],
      ),
    );
  }

  Widget _searchResults(List<ProjectAsset> assets, String query) {
    final matches = assets
        .where(
          (asset) =>
              asset.name.toLowerCase().contains(query) ||
              asset.path.toLowerCase().contains(query),
        )
        .toList(growable: false);
    if (matches.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noResources));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: matches.length,
      itemBuilder: (context, index) => _assetTile(matches[index], 0),
    );
  }

  Widget _assetTile(ProjectAsset asset, int depth) {
    return GestureDetector(
      onSecondaryTapUp: (details) =>
          widget.onAssetContextMenu(asset, details.globalPosition),
      child: ListTile(
        dense: true,
        selected: widget.selectedAssetPath == asset.path,
        contentPadding: EdgeInsets.only(left: depth * 12.0),
        leading: ProjectAssetThumbnail(
          path: '${widget.document.path}/${asset.path}',
        ),
        title: Text(asset.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          asset.path,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () => widget.onAssetSelected(asset),
      ),
    );
  }

  Future<void> _chooseImportType(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final type =
        widget.typeFilter ??
        await showDialog<String>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(l10n.selectResourceType),
            children: [
              _typeOption(context, 'backgrounds', l10n.backgroundResources),
              _typeOption(context, 'characters', l10n.characterResources),
              _typeOption(context, 'portraits', l10n.portraitResources),
              _typeOption(context, 'props', l10n.propResources),
              _typeOption(context, 'audio', l10n.audioResources),
              _typeOption(context, 'video', l10n.videoResources),
            ],
          ),
        );
    if (type != null && mounted) {
      widget.onImportAsset(type);
    }
  }

  Widget _typeOption(BuildContext context, String type, String label) {
    return SimpleDialogOption(
      onPressed: () => Navigator.pop(context, type),
      child: Text(label),
    );
  }
}

class _ResourceFolderNode {
  _ResourceFolderNode({required this.path, required this.name});

  final String path;
  final String name;
  final Map<String, _ResourceFolderNode> folders = {};
  final List<ProjectAsset> assets = [];

  List<_ResourceFolderNode> get sortedFolders {
    return folders.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  List<ProjectAsset> get sortedAssets {
    return [...assets]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  void addFolder(String folderPath) {
    final relative = p.relative(folderPath, from: path);
    if (relative == '.') {
      return;
    }
    var current = this;
    for (final part in p.split(relative)) {
      final childPath = p.join(current.path, part);
      current = current.folders.putIfAbsent(
        part,
        () => _ResourceFolderNode(path: childPath, name: part),
      );
    }
  }

  void addAsset(ProjectAsset asset) {
    final directoryPath = p.dirname(asset.path);
    if (directoryPath == path) {
      assets.add(asset);
      return;
    }
    addFolder(directoryPath);
    var current = this;
    for (final part in p.split(p.relative(directoryPath, from: path))) {
      current = current.folders[part]!;
    }
    current.assets.add(asset);
  }
}
