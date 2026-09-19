import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import 'project_asset_thumbnail.dart';
import 'project_manifest.dart';

class ProjectAssetInspector extends StatelessWidget {
  const ProjectAssetInspector({
    super.key,
    required this.document,
    required this.asset,
    required this.onRename,
    required this.onDelete,
  });

  final ProjectDocument document;
  final ProjectAsset asset;
  final ValueChanged<String> onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.resourceProperties,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: 96,
            height: 96,
            child: ProjectAssetThumbnail(
              path: '${document.path}/${asset.path}',
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey(asset.path),
          initialValue: asset.name,
          decoration: InputDecoration(labelText: l10n.name),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onRename,
        ),
        const SizedBox(height: 12),
        _ReadOnlyProperty(label: l10n.type, value: asset.type),
        _ReadOnlyProperty(label: l10n.path, value: asset.path),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.delete),
        ),
      ],
    );
  }
}

class ProjectRoomInspector extends StatelessWidget {
  const ProjectRoomInspector({
    super.key,
    required this.document,
    required this.room,
    required this.onRename,
    required this.onBackgroundChanged,
    required this.onDelete,
  });

  final ProjectDocument document;
  final ProjectRoom room;
  final ValueChanged<String> onRename;
  final ValueChanged<String?> onBackgroundChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backgrounds = document.assets
        .where((asset) => asset.type == 'backgrounds')
        .toList(growable: false);
    final backgroundPaths = backgrounds.map((asset) => asset.path).toSet();
    final selectedBackground = backgroundPaths.contains(room.scene.background)
        ? room.scene.background
        : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.roomProperties,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextFormField(
          key: ValueKey(room.path),
          initialValue: room.scene.name,
          decoration: InputDecoration(labelText: l10n.name),
          textInputAction: TextInputAction.done,
          onFieldSubmitted: onRename,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String?>(
          initialValue: selectedBackground,
          decoration: InputDecoration(labelText: l10n.backgroundResources),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(l10n.none)),
            for (final asset in backgrounds)
              DropdownMenuItem<String?>(
                value: asset.path,
                child: Text(
                  asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onBackgroundChanged,
        ),
        const SizedBox(height: 12),
        _ReadOnlyProperty(label: l10n.path, value: room.path),
        _ReadOnlyProperty(
          label: l10n.objectCount,
          value: '${room.scene.objects.length}',
        ),
        const SizedBox(height: 20),
        if (onDelete != null)
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.delete),
          ),
      ],
    );
  }
}

class _ReadOnlyProperty extends StatelessWidget {
  const _ReadOnlyProperty({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }
}
