import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProjectRoomLayerInspector extends StatelessWidget {
  const ProjectRoomLayerInspector({
    super.key,
    required this.scene,
    required this.onChanged,
  });

  final ProjectScene scene;
  final ValueChanged<ProjectScene> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layers = [...scene.layers]
      ..sort((a, b) => a.order.compareTo(b.order));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.layers,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: l10n.newLayer,
              onPressed: () => _addLayer(l10n.newLayer),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (var index = 0; index < layers.length; index++)
          _LayerTile(
            key: ValueKey(layers[index].id),
            layer: layers[index],
            canMoveUp: index > 0,
            canMoveDown: index < layers.length - 1,
            canDelete: layers.length > 1,
            onChanged: _replaceLayer,
            onMoveUp: () => _moveLayer(layers, index, -1),
            onMoveDown: () => _moveLayer(layers, index, 1),
            onDelete: () => _deleteLayer(layers[index]),
          ),
      ],
    );
  }

  void _addLayer(String name) {
    final id = 'layer_${const Uuid().v4().substring(0, 8)}';
    final layer = ProjectSceneLayer(
      id: id,
      name: '$name ${scene.layers.length + 1}',
      order: scene.layers.length,
    );
    onChanged(scene.copyWith(layers: [...scene.layers, layer]));
  }

  void _replaceLayer(ProjectSceneLayer updated) {
    onChanged(
      scene.copyWith(
        layers: scene.layers
            .map((layer) => layer.id == updated.id ? updated : layer)
            .toList(growable: false),
      ),
    );
  }

  void _moveLayer(List<ProjectSceneLayer> ordered, int index, int direction) {
    final target = index + direction;
    final moved = [...ordered];
    final layer = moved.removeAt(index);
    moved.insert(target, layer);
    onChanged(
      scene.copyWith(
        layers: [
          for (var position = 0; position < moved.length; position++)
            moved[position].copyWith(order: position),
        ],
      ),
    );
  }

  void _deleteLayer(ProjectSceneLayer layer) {
    final remaining = scene.layers
        .where((item) => item.id != layer.id)
        .toList(growable: false);
    final fallback = remaining.reduce((a, b) => a.order < b.order ? a : b);
    onChanged(
      scene.copyWith(
        layers: remaining,
        objects: scene.objects
            .map(
              (object) => object.layerId == layer.id
                  ? object.copyWith(layerId: fallback.id)
                  : object,
            )
            .toList(growable: false),
      ),
    );
  }
}

class _LayerTile extends StatelessWidget {
  const _LayerTile({
    super.key,
    required this.layer,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.canDelete,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final ProjectSceneLayer layer;
  final bool canMoveUp;
  final bool canMoveDown;
  final bool canDelete;
  final ValueChanged<ProjectSceneLayer> onChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextFormField(
              key: ValueKey('${layer.id}:${layer.name}'),
              initialValue: layer.name,
              decoration: InputDecoration(labelText: l10n.name),
              onFieldSubmitted: (value) {
                final name = value.trim();
                if (name.isNotEmpty) {
                  onChanged(layer.copyWith(name: name));
                }
              },
            ),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.visible,
                  onPressed: () =>
                      onChanged(layer.copyWith(visible: !layer.visible)),
                  icon: Icon(
                    layer.visible ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
                IconButton(
                  tooltip: l10n.locked,
                  onPressed: () =>
                      onChanged(layer.copyWith(locked: !layer.locked)),
                  icon: Icon(layer.locked ? Icons.lock : Icons.lock_open),
                ),
                const Spacer(),
                IconButton(
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  tooltip: l10n.delete,
                  onPressed: canDelete ? onDelete : null,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
