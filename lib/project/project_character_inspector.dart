import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'project_asset_thumbnail.dart';
import 'project_character.dart';
import 'project_manifest.dart';

class ProjectCharacterInspector extends StatelessWidget {
  const ProjectCharacterInspector({
    super.key,
    required this.document,
    required this.character,
    required this.onChanged,
    required this.onDelete,
  });

  final ProjectDocument document;
  final ProjectCharacterFile character;
  final ValueChanged<ProjectCharacterFile> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final definition = character.definition;
    final frameAssets = document.assets
        .where((asset) => asset.type == 'characters')
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.characterProperties,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _textField(
          key: ValueKey('${character.path}:name'),
          label: l10n.name,
          value: definition.name,
          onSubmitted: (value) =>
              _update(definition.copyWith(name: value.trim())),
        ),
        const SizedBox(height: 12),
        _readOnly(context, l10n.characterId, definition.id),
        _readOnly(context, l10n.path, character.path),
        const SizedBox(height: 12),
        Text(l10n.defaultSize, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:width'),
                label: l10n.width,
                value: definition.defaultWidth,
                onSubmitted: (value) =>
                    _update(definition.copyWith(defaultWidth: value)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:height'),
                label: l10n.height,
                value: definition.defaultHeight,
                onSubmitted: (value) =>
                    _update(definition.copyWith(defaultHeight: value)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _numberField(
          key: ValueKey('${character.path}:speed'),
          label: l10n.moveSpeed,
          value: definition.moveSpeed,
          onSubmitted: (value) =>
              _update(definition.copyWith(moveSpeed: value)),
        ),
        const SizedBox(height: 16),
        Text(l10n.collisionBox, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _collisionEditor(context, definition),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.animations,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l10n.addAnimation,
              onPressed: () => _addAnimation(definition),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        for (final animation in definition.animations)
          _animationEditor(context, definition, animation, frameAssets),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: Text(l10n.delete),
        ),
      ],
    );
  }

  Widget _collisionEditor(
    BuildContext context,
    ProjectCharacterDefinition definition,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final collision = definition.collision;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:collisionX'),
                label: 'X',
                value: collision.x,
                onSubmitted: (value) => _update(
                  definition.copyWith(collision: collision.copyWith(x: value)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:collisionY'),
                label: 'Y',
                value: collision.y,
                onSubmitted: (value) => _update(
                  definition.copyWith(collision: collision.copyWith(y: value)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:collisionWidth'),
                label: l10n.width,
                value: collision.width,
                onSubmitted: (value) => _update(
                  definition.copyWith(
                    collision: collision.copyWith(width: value),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _numberField(
                key: ValueKey('${character.path}:collisionHeight'),
                label: l10n.height,
                value: collision.height,
                onSubmitted: (value) => _update(
                  definition.copyWith(
                    collision: collision.copyWith(height: value),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _animationEditor(
    BuildContext context,
    ProjectCharacterDefinition definition,
    ProjectCharacterAnimation animation,
    List<ProjectAsset> frameAssets,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return ExpansionTile(
      key: PageStorageKey(animation.id),
      tilePadding: EdgeInsets.zero,
      title: Text(
        '${animation.name} · ${_directionLabel(l10n, animation.direction)}',
      ),
      children: [
        _textField(
          key: ValueKey('${animation.id}:name'),
          label: l10n.name,
          value: animation.name,
          onSubmitted: (value) => _replaceAnimation(
            definition,
            animation.copyWith(name: value.trim()),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: animation.direction,
          decoration: InputDecoration(labelText: l10n.direction),
          items: [
            for (final direction in const ['up', 'down', 'left', 'right'])
              DropdownMenuItem(
                value: direction,
                child: Text(_directionLabel(l10n, direction)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              _replaceAnimation(
                definition,
                animation.copyWith(direction: value),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        _numberField(
          key: ValueKey('${animation.id}:fps'),
          label: l10n.framesPerSecond,
          value: animation.fps,
          onSubmitted: (value) =>
              _replaceAnimation(definition, animation.copyWith(fps: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.loop),
          value: animation.loop,
          onChanged: (value) =>
              _replaceAnimation(definition, animation.copyWith(loop: value)),
        ),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(labelText: l10n.addFrame),
          items: frameAssets
              .map(
                (asset) => DropdownMenuItem(
                  value: asset.path,
                  child: Text(asset.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(growable: false),
          onChanged: (path) {
            if (path != null) {
              _replaceAnimation(
                definition,
                animation.copyWith(frames: [...animation.frames, path]),
              );
            }
          },
        ),
        for (var index = 0; index < animation.frames.length; index++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: ProjectAssetThumbnail(
              path: '${document.path}/${animation.frames[index]}',
            ),
            title: Text(
              animation.frames[index].split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              tooltip: l10n.delete,
              onPressed: () {
                final frames = [...animation.frames]..removeAt(index);
                _replaceAnimation(
                  definition,
                  animation.copyWith(frames: frames),
                );
              },
              icon: const Icon(Icons.close),
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              _update(
                definition.copyWith(
                  animations: definition.animations
                      .where((item) => item.id != animation.id)
                      .toList(growable: false),
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteAnimation),
          ),
        ),
      ],
    );
  }

  void _addAnimation(ProjectCharacterDefinition definition) {
    final animation = ProjectCharacterAnimation(
      id: const Uuid().v4(),
      name: 'animation',
      direction: 'down',
    );
    _update(
      definition.copyWith(animations: [...definition.animations, animation]),
    );
  }

  void _replaceAnimation(
    ProjectCharacterDefinition definition,
    ProjectCharacterAnimation animation,
  ) {
    _update(
      definition.copyWith(
        animations: definition.animations
            .map((item) => item.id == animation.id ? animation : item)
            .toList(growable: false),
      ),
    );
  }

  void _update(ProjectCharacterDefinition definition) {
    onChanged(character.copyWith(definition: definition));
  }

  Widget _textField({
    required Key key,
    required String label,
    required String value,
    required ValueChanged<String> onSubmitted,
  }) {
    return TextFormField(
      key: key,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _numberField({
    required Key key,
    required String label,
    required double value,
    required ValueChanged<double> onSubmitted,
  }) {
    return TextFormField(
      key: key,
      initialValue: value.toStringAsFixed(1),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (text) {
        final parsed = double.tryParse(text);
        if (parsed != null) {
          onSubmitted(parsed);
        }
      },
    );
  }

  Widget _readOnly(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 2),
          SelectableText(value),
        ],
      ),
    );
  }

  String _directionLabel(AppLocalizations l10n, String direction) {
    return switch (direction) {
      'up' => l10n.directionUp,
      'left' => l10n.directionLeft,
      'right' => l10n.directionRight,
      _ => l10n.directionDown,
    };
  }
}
