import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/project_controller.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class SceneSidebar extends ConsumerStatefulWidget {
  const SceneSidebar({required this.ready, super.key});

  final StudioReady ready;

  @override
  ConsumerState<SceneSidebar> createState() => _SceneSidebarState();
}

class _SceneSidebarState extends ConsumerState<SceneSidebar> {
  String _builtInQuery = '';

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(icon: const Icon(Icons.layers), text: l10n.canvasObjects),
                Tab(icon: const Icon(Icons.image), text: l10n.assets),
                Tab(icon: const Icon(Icons.people), text: l10n.characters),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ObjectTab(ready: ready),
                  _ResourceTab(
                    ready: ready,
                    builtInQuery: _builtInQuery,
                    onBuiltInQueryChanged: (value) =>
                        setState(() => _builtInQuery = value),
                  ),
                  _CharacterTab(ready: ready),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectTab extends ConsumerWidget {
  const _ObjectTab({required this.ready});

  final StudioReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _SidebarSectionHeader(icon: Icons.layers, label: l10n.canvasObjects),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _SmallAction(
              icon: Icons.meeting_room,
              label: l10n.room,
              onPressed: controller.addRoomBackground,
            ),
            _SmallAction(
              icon: Icons.person_add,
              label: l10n.actor,
              onPressed: controller.addCharacterInstance,
            ),
            _SmallAction(
              icon: Icons.radio_button_checked,
              label: l10n.trigger,
              onPressed: controller.addTriggerPoint,
            ),
            _SmallAction(
              icon: Icons.wallpaper,
              label: l10n.import,
              onPressed: controller.importBackground,
            ),
            _SmallAction(
              icon: Icons.category,
              label: l10n.prop,
              onPressed: controller.importProp,
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final object in ready.currentScene.objects.reversed)
          ListTile(
            dense: true,
            selected: ready.selection.objectIds.contains(object.objectId),
            leading: Icon(_objectIcon(object)),
            title: Text(_objectName(object), overflow: TextOverflow.ellipsis),
            subtitle: Text(_objectKind(l10n, object)),
            onTap: () => controller.selectObject(object.objectId),
          ),
      ],
    );
  }
}

class _ResourceTab extends ConsumerWidget {
  const _ResourceTab({
    required this.ready,
    required this.builtInQuery,
    required this.onBuiltInQueryChanged,
  });

  final StudioReady ready;
  final String builtInQuery;
  final ValueChanged<String> onBuiltInQueryChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _SidebarSectionHeader(
                  icon: Icons.folder,
                  label: l10n.assets,
                ),
              ),
              PopupMenuButton<void Function()>(
                tooltip: l10n.importAsset,
                icon: const Icon(Icons.add),
                onSelected: (action) => action(),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: controller.importBackground,
                    child: Text(l10n.importBackground),
                  ),
                  PopupMenuItem(
                    value: controller.importProp,
                    child: Text(l10n.importProp),
                  ),
                  PopupMenuItem(
                    value: controller.importCharacterAsset,
                    child: Text(l10n.importCharacterAsset),
                  ),
                  PopupMenuItem(
                    value: controller.importAudio,
                    child: Text(l10n.importAudio),
                  ),
                  PopupMenuItem(
                    value: controller.importVideo,
                    child: const Text('导入视频'),
                  ),
                  PopupMenuItem(
                    value: controller.importDialoguePortrait,
                    child: const Text('导入对话头像'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: ready.project.assets.isEmpty
                ? Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      l10n.noImportedAssets,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                : ListView.builder(
                    key: const PageStorageKey('imported_asset_list'),
                    itemCount: ready.project.assets.length,
                    itemBuilder: (context, index) {
                      final asset = ready.project.assets[index];
                      final selected =
                          ready.selection is AssetSelection &&
                          (ready.selection as AssetSelection).assetId ==
                              asset.id;
                      return ListTile(
                        dense: true,
                        selected: selected,
                        leading: asset.kind == AssetKind.audio
                            ? IconButton(
                                tooltip: l10n.playSound,
                                icon: const Icon(Icons.music_note),
                                onPressed: () => ref
                                    .read(previewControllerProvider.notifier)
                                    .previewAudioAsset(ready, asset.id),
                              )
                            : _ImportedAssetThumbnail(
                                asset: asset,
                                projectDirectory: ready.projectDirectory,
                              ),
                        title: Text(
                          asset.originalName,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(_assetSubtitle(l10n, ready, asset)),
                        onTap: () => controller.applyExistingAsset(asset.id),
                      );
                    },
                  ),
          ),
          const Divider(height: 20),
          Expanded(
            flex: 3,
            child: _BuiltInAssetSection(
              ready: ready,
              query: builtInQuery,
              onQueryChanged: onBuiltInQueryChanged,
              onAdd: controller.addBuiltInAsset,
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterTab extends ConsumerWidget {
  const _CharacterTab({required this.ready});

  final StudioReady ready;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(studioControllerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: _SidebarSectionHeader(
                icon: Icons.people,
                label: l10n.characters,
              ),
            ),
            IconButton(
              tooltip: l10n.addActor,
              onPressed: controller.addCharacterDefinition,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final character in ready.project.characters)
          ListTile(
            dense: true,
            selected:
                ready.selection is CharacterSelection &&
                (ready.selection as CharacterSelection).characterId ==
                    character.id,
            leading: const Icon(Icons.person),
            title: Text(character.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              l10n.expressionsCount(character.expressions.length),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => controller.selectCharacter(character.id),
          ),
      ],
    );
  }
}

class _BuiltInAssetSection extends ConsumerWidget {
  const _BuiltInAssetSection({
    required this.ready,
    required this.query,
    required this.onQueryChanged,
    required this.onAdd,
  });

  final StudioReady ready;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<BuiltInAsset> onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final library = ref.watch(builtInAssetLibraryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.builtInAssets, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 18),
            labelText: l10n.searchBuiltIns,
            border: const OutlineInputBorder(),
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 8),
        Expanded(
          child: library.when(
            data: (value) {
              final matches = value.search(query);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value.missingExternalDirectory)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '内置资源目录缺失：请把 drs_builtin 放到 app 同目录。',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.orange),
                      ),
                    ),
                  Text(
                    l10n.builtInAssetsCount(
                      matches.length,
                      value.assets.length,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      key: const PageStorageKey('built_in_asset_list'),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final asset = matches[index];
                        return ListTile(
                          dense: true,
                          leading: asset.kind == AssetKind.audio
                              ? IconButton(
                                  tooltip: l10n.playSound,
                                  icon: const Icon(Icons.music_note),
                                  onPressed: () => ref
                                      .read(previewControllerProvider.notifier)
                                      .previewAudioAssetId(ready, asset.id),
                                )
                              : _BuiltInAssetThumbnail(asset: asset),
                          title: Text(
                            asset.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${asset.kind.name} · ${asset.sourcePath}',
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: l10n.addBuiltInAsset,
                            icon: const Icon(Icons.add),
                            onPressed: () => onAdd(asset),
                          ),
                        );
                      },
                    ),
                  ),
                  if (matches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.noImportedAssets,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(8),
              child: LinearProgressIndicator(),
            ),
            error: (error, _) =>
                Text('$error', style: const TextStyle(color: Colors.orange)),
          ),
        ),
      ],
    );
  }
}

class _SidebarSectionHeader extends StatelessWidget {
  const _SidebarSectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

IconData _objectIcon(SceneObject object) {
  return object.map(
    characterInstance: (_) => Icons.person,
    prop: (_) => Icons.category,
    background: (_) => Icons.wallpaper,
    triggerPoint: (_) => Icons.radio_button_checked,
    triggerArea: (_) => Icons.radio_button_checked,
  );
}

String _objectKind(AppLocalizations l10n, SceneObject object) {
  return object.map(
    characterInstance: (_) => l10n.character,
    prop: (_) => l10n.prop,
    background: (_) => l10n.background,
    triggerPoint: (_) => l10n.triggerPoint,
    triggerArea: (_) => l10n.triggerPoint,
  );
}

String _objectName(SceneObject object) {
  return object.map(
    characterInstance: (value) => value.name,
    prop: (value) => value.name,
    background: (value) => value.name,
    triggerPoint: (value) => value.name,
    triggerArea: (value) => value.name,
  );
}

String _assetSubtitle(
  AppLocalizations l10n,
  StudioReady ready,
  AssetRef asset,
) {
  final directory = ready.projectDirectory;
  final missing =
      directory != null &&
      !File(p.join(directory.path, asset.relativePath)).existsSync();
  if (kIsWeb && asset.dataUri != null) {
    return asset.kind.name;
  }
  return missing ? '${asset.kind.name} · ${l10n.missing}' : asset.kind.name;
}

class _ImportedAssetThumbnail extends StatelessWidget {
  const _ImportedAssetThumbnail({
    required this.asset,
    required this.projectDirectory,
  });

  final AssetRef asset;
  final Directory? projectDirectory;

  @override
  Widget build(BuildContext context) {
    final directory = projectDirectory;
    if (asset.kind == AssetKind.audio || asset.kind == AssetKind.video) {
      return _FallbackThumbnail(kind: asset.kind);
    }
    if (asset.dataUri != null) {
      return _ThumbnailFrame(
        child: Image.memory(
          _bytesFromDataUri(asset.dataUri!),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
          cacheWidth: 88,
          errorBuilder: (_, _, _) => _FallbackThumbnail(kind: asset.kind),
        ),
      );
    }
    if (directory == null) {
      return _FallbackThumbnail(kind: asset.kind);
    }
    final file = File(p.join(directory.path, asset.relativePath));
    if (!file.existsSync()) {
      return _FallbackThumbnail(kind: asset.kind);
    }
    return _ThumbnailFrame(
      child: Image.file(
        file,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.none,
        cacheWidth: 88,
        errorBuilder: (_, _, _) => _FallbackThumbnail(kind: asset.kind),
      ),
    );
  }
}

class _BuiltInAssetThumbnail extends StatelessWidget {
  const _BuiltInAssetThumbnail({required this.asset});

  final BuiltInAsset asset;

  @override
  Widget build(BuildContext context) {
    if (asset.kind == AssetKind.audio || asset.kind == AssetKind.video) {
      return _FallbackThumbnail(kind: asset.kind);
    }
    return _ThumbnailFrame(
      child: kIsWeb
          ? Image.asset(
              asset.assetPath,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              cacheWidth: 88,
              errorBuilder: (_, _, _) => _FallbackThumbnail(kind: asset.kind),
            )
          : Image.file(
              File(asset.resolvedPath),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              cacheWidth: 88,
              errorBuilder: (_, _, _) => _FallbackThumbnail(kind: asset.kind),
            ),
    );
  }
}

class _ThumbnailFrame extends StatelessWidget {
  const _ThumbnailFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.hardEdge,
      child: child,
    );
  }
}

Uint8List _bytesFromDataUri(String dataUri) {
  final comma = dataUri.indexOf(',');
  if (comma < 0) {
    return Uint8List(0);
  }
  return base64Decode(dataUri.substring(comma + 1));
}

class _FallbackThumbnail extends StatelessWidget {
  const _FallbackThumbnail({required this.kind});

  final AssetKind kind;

  @override
  Widget build(BuildContext context) {
    return _ThumbnailFrame(
      child: Icon(
        _assetIcon(kind),
        size: 22,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  IconData _assetIcon(AssetKind kind) {
    return switch (kind) {
      AssetKind.background => Icons.wallpaper,
      AssetKind.character => Icons.person_pin,
      AssetKind.audio => Icons.music_note,
      AssetKind.prop => Icons.category,
      AssetKind.dialoguePortrait => Icons.account_box,
      AssetKind.video => Icons.movie,
    };
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
