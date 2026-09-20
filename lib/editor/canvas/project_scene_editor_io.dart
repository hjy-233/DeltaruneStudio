import 'dart:io';

import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/panels/project_room_layer_inspector.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ProjectSceneEditor extends StatefulWidget {
  const ProjectSceneEditor({
    super.key,
    required this.document,
    required this.onChanged,
    required this.onSelectionChanged,
    required this.inspectorWidth,
    required this.onInspectorWidthChanged,
    this.externalInspector,
    this.externalSelectionKey,
  });

  final ProjectDocument document;
  final ValueChanged<ProjectScene> onChanged;
  final ValueChanged<String?> onSelectionChanged;
  final double inspectorWidth;
  final ValueChanged<double> onInspectorWidthChanged;
  final Widget? externalInspector;
  final String? externalSelectionKey;

  @override
  State<ProjectSceneEditor> createState() => _ProjectSceneEditorState();
}

class _ProjectSceneEditorState extends State<ProjectSceneEditor> {
  String? _selectedId;
  ProjectScene get _scene => widget.document.mainScene;

  @override
  void didUpdateWidget(covariant ProjectSceneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalSelectionKey != null &&
        widget.externalSelectionKey != oldWidget.externalSelectionKey) {
      _selectedId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedObject;
    final game = widget.document.manifest.gameSettings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditorToolbar(onAdd: _addObject),
        const SizedBox(height: 8),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: game.viewportWidth / game.viewportHeight,
                    child: ColoredBox(
                      color: Colors.black,
                      child: LayoutBuilder(
                        builder: (context, constraints) => _SceneCanvas(
                          document: widget.document,
                          selectedId: _selectedId,
                          scale: constraints.maxWidth / game.viewportWidth,
                          onSelect: _select,
                          onMove: _moveObject,
                          onResize: _resizeObject,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _EditorPanelDivider(
                onDrag: (delta) => widget.onInspectorWidthChanged(
                  (widget.inspectorWidth - delta)
                      .clamp(240.0, 420.0)
                      .toDouble(),
                ),
              ),
              SizedBox(
                width: widget.inspectorWidth,
                child:
                    widget.externalInspector ??
                    (selected == null
                        ? ProjectRoomLayerInspector(
                            scene: _scene,
                            onChanged: _emit,
                          )
                        : SingleChildScrollView(
                            child: _ObjectInspector(
                              object: selected,
                              document: widget.document,
                              assets: widget.document.assets,
                              characters: widget.document.characters,
                              onChanged: _updateObject,
                              onDelete: () => _deleteObject(selected.id),
                            ),
                          )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ProjectSceneObject? get _selectedObject {
    for (final object in _scene.objects) {
      if (object.id == _selectedId) {
        return object;
      }
    }
    return null;
  }

  void _select(String? id) {
    setState(() => _selectedId = id);
    widget.onSelectionChanged(id);
  }

  void _addObject(String type) {
    final l10n = AppLocalizations.of(context)!;
    final dimensions = switch (type) {
      'collision' => const Size(128, 64),
      'door' => const Size(32, 48),
      'savePoint' => const Size(28, 28),
      'spawn' => const Size(16, 16),
      _ => const Size(-1, -1),
    };
    final object = ProjectSceneObject(
      id: const Uuid().v4(),
      type: type,
      name: _defaultObjectName(l10n, type),
      asset: '',
      x: widget.document.manifest.gameSettings.viewportWidth / 2,
      y: widget.document.manifest.gameSettings.viewportHeight / 2,
      zIndex: _scene.objects.length,
      width: dimensions.width,
      height: dimensions.height,
      layerId: _layerIdForType(type),
      defaultSpawn:
          type == 'spawn' && !_scene.objects.any((item) => item.defaultSpawn),
    );
    _selectedId = object.id;
    _emit(_scene.copyWith(objects: [..._scene.objects, object]));
  }

  void _moveObject(String id, Offset delta) {
    final object = _findObject(id);
    if (object == null || _layerLocked(object.layerId)) {
      return;
    }
    _updateObject(
      object.copyWith(x: object.x + delta.dx, y: object.y + delta.dy),
    );
  }

  void _resizeObject(String id, Offset delta) {
    final object = _findObject(id);
    if (object == null || object.locked || _layerLocked(object.layerId)) return;
    _updateObject(
      object.copyWith(
        width: (object.width + delta.dx).clamp(4.0, 4096.0),
        height: (object.height + delta.dy).clamp(4.0, 4096.0),
      ),
    );
  }

  void _updateObject(ProjectSceneObject updated) {
    final objects = _scene.objects
        .map((object) {
          if (object.id == updated.id) {
            return updated;
          }
          if (updated.type == 'spawn' &&
              updated.defaultSpawn &&
              object.type == 'spawn') {
            return object.copyWith(defaultSpawn: false);
          }
          return object;
        })
        .toList(growable: false);
    _emit(_scene.copyWith(objects: objects));
  }

  void _deleteObject(String id) {
    _emit(
      _scene.copyWith(
        objects: _scene.objects.where((object) => object.id != id).toList(),
      ),
    );
    setState(() => _selectedId = null);
  }

  ProjectSceneObject? _findObject(String id) {
    for (final object in _scene.objects) {
      if (object.id == id) {
        return object;
      }
    }
    return null;
  }

  bool _layerLocked(String id) {
    for (final layer in _scene.layers) {
      if (layer.id == id) {
        return layer.locked;
      }
    }
    return false;
  }

  String _layerIdForType(String type) {
    final preferred = _defaultLayerId(type);
    if (_scene.layers.any((layer) => layer.id == preferred)) {
      return preferred;
    }
    return _scene.layers.isEmpty ? preferred : _scene.layers.first.id;
  }

  void _emit(ProjectScene scene) {
    widget.onChanged(scene);
    setState(() {});
  }
}

class _EditorPanelDivider extends StatelessWidget {
  const _EditorPanelDivider({required this.onDrag});

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

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () => onAdd('background'),
          icon: const Icon(Icons.image),
          label: Text(l10n.addBackground),
        ),
        FilledButton.icon(
          onPressed: () => onAdd('character'),
          icon: const Icon(Icons.person),
          label: Text(l10n.addCharacter),
        ),
        FilledButton.icon(
          onPressed: () => onAdd('prop'),
          icon: const Icon(Icons.category),
          label: Text(l10n.addProp),
        ),
        OutlinedButton.icon(
          onPressed: () => onAdd('collision'),
          icon: const Icon(Icons.crop_square),
          label: Text(l10n.addCollision),
        ),
        OutlinedButton.icon(
          onPressed: () => onAdd('spawn'),
          icon: const Icon(Icons.place_outlined),
          label: Text(l10n.addSpawn),
        ),
        OutlinedButton.icon(
          onPressed: () => onAdd('door'),
          icon: const Icon(Icons.meeting_room_outlined),
          label: Text(l10n.addDoor),
        ),
        OutlinedButton.icon(
          onPressed: () => onAdd('savePoint'),
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.addSavePoint),
        ),
      ],
    );
  }
}

class _SceneCanvas extends StatelessWidget {
  const _SceneCanvas({
    required this.document,
    required this.selectedId,
    required this.scale,
    required this.onSelect,
    required this.onMove,
    required this.onResize,
  });

  final ProjectDocument document;
  final String? selectedId;
  final double scale;
  final ValueChanged<String?> onSelect;
  final void Function(String id, Offset delta) onMove;
  final void Function(String id, Offset delta) onResize;

  @override
  Widget build(BuildContext context) {
    final layerOrder = {
      for (final layer in document.mainScene.layers) layer.id: layer.order,
    };
    final hiddenLayers = document.mainScene.layers
        .where((layer) => !layer.visible)
        .map((layer) => layer.id)
        .toSet();
    final lockedLayers = document.mainScene.layers
        .where((layer) => layer.locked)
        .map((layer) => layer.id)
        .toSet();
    final objects =
        document.mainScene.objects
            .where((object) => !hiddenLayers.contains(object.layerId))
            .toList()
          ..sort((a, b) {
            final layerComparison = (layerOrder[a.layerId] ?? 0).compareTo(
              layerOrder[b.layerId] ?? 0,
            );
            return layerComparison != 0
                ? layerComparison
                : a.zIndex.compareTo(b.zIndex);
          });
    return GestureDetector(
      onTap: () => onSelect(null),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (document.mainScene.background != null)
            Positioned.fill(child: _image(document.mainScene.background!)),
          for (final object in objects)
            Positioned(
              left: object.x * scale,
              top: object.y * scale,
              child: FractionalTranslation(
                key: ValueKey('scene-object-${object.id}-anchor'),
                translation: _isEditorMarker(object.type)
                    ? Offset.zero
                    : const Offset(-0.5, -0.5),
                child: _DraggableObject(
                  object: object,
                  visual: _resolveObjectVisual(document, object),
                  rootPath: document.path,
                  scale: scale,
                  selected: selectedId == object.id,
                  layerLocked: lockedLayers.contains(object.layerId),
                  onTap: () => onSelect(object.id),
                  onMove: (delta) => onMove(object.id, delta / scale),
                  onResize: (delta) => onResize(object.id, delta / scale),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _image(String relativePath) {
    final file = File('${document.path}/$relativePath');
    return file.existsSync()
        ? Image.file(file, fit: BoxFit.fill, filterQuality: FilterQuality.none)
        : const Center(
            child: Text(
              'Missing background',
              style: TextStyle(color: Colors.red),
            ),
          );
  }
}

class _DraggableObject extends StatelessWidget {
  const _DraggableObject({
    required this.object,
    required this.visual,
    required this.rootPath,
    required this.scale,
    required this.selected,
    required this.layerLocked,
    required this.onTap,
    required this.onMove,
    required this.onResize,
  });

  final ProjectSceneObject object;
  final _ResolvedObjectVisual visual;
  final String rootPath;
  final double scale;
  final bool selected;
  final bool layerLocked;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;
  final ValueChanged<Offset> onResize;

  @override
  Widget build(BuildContext context) {
    if (_isEditorMarker(object.type)) {
      return _marker(context);
    }
    final file = File('$rootPath/${visual.assetPath}');
    final hasExplicitSize = visual.width > 0 || visual.height > 0;
    final child = file.existsSync()
        ? SizedBox(
            width: visual.width > 0 ? visual.width * scale : null,
            height: visual.height > 0 ? visual.height * scale : null,
            child: Image.file(
              file,
              scale: hasExplicitSize ? 1 : 1 / scale,
              fit: hasExplicitSize ? BoxFit.fill : BoxFit.none,
              filterQuality: FilterQuality.none,
            ),
          )
        : Container(
            padding: const EdgeInsets.all(6),
            color: Colors.red.withValues(alpha: 0.7),
            child: Text(object.name, style: const TextStyle(fontSize: 11)),
          );
    return GestureDetector(
      onTap: onTap,
      onPanStart: (_) => onTap(),
      onPanUpdate: object.locked || layerLocked
          ? null
          : (details) => onMove(details.delta),
      child: DecoratedBox(
        decoration: selected
            ? BoxDecoration(border: Border.all(color: Colors.amber, width: 2))
            : const BoxDecoration(),
        child: child,
      ),
    );
  }

  Widget _marker(BuildContext context) {
    final color = switch (object.type) {
      'collision' => Colors.cyan,
      'spawn' => Colors.greenAccent,
      'savePoint' => Colors.amber,
      _ => Colors.orange,
    };
    final width = (visual.width > 0 ? visual.width : 24) * scale;
    final height = (visual.height > 0 ? visual.height : 24) * scale;
    final locked = object.locked || layerLocked;
    return SizedBox(
      width: width.clamp(14, double.infinity),
      height: height.clamp(14, double.infinity),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap,
              onPanStart: (_) => onTap(),
              onPanUpdate: locked ? null : (details) => onMove(details.delta),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  border: Border.all(
                    color: selected ? Colors.amber : color,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Icon(_markerIcon(object.type), color: color, size: 16),
              ),
            ),
          ),
          if (selected && !locked)
            Positioned(
              right: -5,
              bottom: -5,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeDownRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) => onResize(details.delta),
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ObjectInspector extends StatelessWidget {
  const _ObjectInspector({
    required this.object,
    required this.document,
    required this.assets,
    required this.characters,
    required this.onChanged,
    required this.onDelete,
  });

  final ProjectSceneObject object;
  final ProjectDocument document;
  final List<ProjectAsset> assets;
  final List<ProjectCharacterFile> characters;
  final ValueChanged<ProjectSceneObject> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final marker = _isEditorMarker(object.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 300,
            child: DropdownButtonFormField<String>(
              initialValue:
                  document.mainScene.layers.any(
                    (layer) => layer.id == object.layerId,
                  )
                  ? object.layerId
                  : document.mainScene.layers.isEmpty
                  ? null
                  : document.mainScene.layers.first.id,
              decoration: InputDecoration(labelText: l10n.layer),
              items: document.mainScene.layers
                  .map(
                    (layer) => DropdownMenuItem(
                      value: layer.id,
                      child: Text(layer.name),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onChanged(object.copyWith(layerId: value));
                }
              },
            ),
          ),
          if (object.type == 'character')
            DropdownButtonFormField<String>(
              initialValue:
                  characters.any(
                    (character) => character.path == object.characterPath,
                  )
                  ? object.characterPath
                  : null,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.characterDefinition,
              ),
              items: [
                DropdownMenuItem<String>(
                  value: '',
                  child: Text(AppLocalizations.of(context)!.none),
                ),
                for (final character in characters)
                  DropdownMenuItem<String>(
                    value: character.path,
                    child: Text(
                      character.definition.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => onChanged(
                object.copyWith(
                  characterPath: value ?? '',
                  asset: value == null || value.isEmpty ? object.asset : '',
                  width: -1,
                  height: -1,
                ),
              ),
            ),
          if (!marker)
            DropdownButtonFormField<String>(
              initialValue: object.asset.isEmpty ? null : object.asset,
              decoration: InputDecoration(labelText: l10n.resource),
              items: assets
                  .map(
                    (asset) => DropdownMenuItem<String>(
                      value: asset.path,
                      child: Text(asset.name, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onChanged(
                    object.copyWith(
                      asset: value,
                      width: -1,
                      height: -1,
                      characterPath: object.type == 'character'
                          ? ''
                          : object.characterPath,
                    ),
                  );
                }
              },
            ),
          SizedBox(
            width: 180,
            child: _textField(
              l10n.name,
              object.name,
              (value) => onChanged(object.copyWith(name: value)),
            ),
          ),
          if (!marker)
            SizedBox(
              width: 300,
              child: _textField(
                l10n.assetPath,
                object.asset,
                (value) => onChanged(object.copyWith(asset: value)),
              ),
            ),
          SizedBox(
            width: 100,
            child: _numberField(
              'X',
              object.x,
              (value) => onChanged(object.copyWith(x: value)),
            ),
          ),
          if (object.type == 'spawn') ..._spawnFields(context),
          if (object.type == 'door') ..._doorFields(context),
          if (object.type == 'savePoint') ..._savePointFields(context),
          SizedBox(
            width: 100,
            child: _numberField(
              'Y',
              object.y,
              (value) => onChanged(object.copyWith(y: value)),
            ),
          ),
          SizedBox(
            width: 100,
            child: _numberField(
              l10n.order,
              object.zIndex.toDouble(),
              (value) => onChanged(object.copyWith(zIndex: value.toInt())),
            ),
          ),
          SizedBox(
            width: 100,
            child: _numberField(
              l10n.width,
              object.width,
              (value) => onChanged(object.copyWith(width: value)),
            ),
          ),
          SizedBox(
            width: 100,
            child: _numberField(
              l10n.height,
              object.height,
              (value) => onChanged(object.copyWith(height: value)),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.locked),
            value: object.locked,
            onChanged: (value) => onChanged(object.copyWith(locked: value)),
          ),
          FilledButton.tonalIcon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            label: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  List<Widget> _spawnFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SizedBox(
        width: 180,
        child: DropdownButtonFormField<String>(
          initialValue: object.facing,
          decoration: InputDecoration(labelText: l10n.spawnFacing),
          items: [
            for (final direction in const ['up', 'down', 'left', 'right'])
              DropdownMenuItem(
                value: direction,
                child: Text(_directionLabel(l10n, direction)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(object.copyWith(facing: value));
            }
          },
        ),
      ),
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.defaultSpawn),
        value: object.defaultSpawn,
        onChanged: (value) => onChanged(object.copyWith(defaultSpawn: value)),
      ),
    ];
  }

  List<Widget> _doorFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targetRoom = _roomByPath(object.targetRoomPath);
    final spawnPoints =
        targetRoom?.scene.objects
            .where((item) => item.type == 'spawn')
            .toList(growable: false) ??
        const <ProjectSceneObject>[];
    return [
      SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          initialValue:
              document.rooms.any((room) => room.path == object.targetRoomPath)
              ? object.targetRoomPath
              : null,
          decoration: InputDecoration(labelText: l10n.targetRoom),
          items: document.rooms
              .map(
                (room) => DropdownMenuItem(
                  value: room.path,
                  child: Text(room.scene.name),
                ),
              )
              .toList(growable: false),
          onChanged: (value) => onChanged(
            object.copyWith(targetRoomPath: value ?? '', targetSpawnId: ''),
          ),
        ),
      ),
      SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          initialValue:
              spawnPoints.any((spawn) => spawn.id == object.targetSpawnId)
              ? object.targetSpawnId
              : null,
          decoration: InputDecoration(labelText: l10n.targetSpawn),
          items: spawnPoints
              .map(
                (spawn) =>
                    DropdownMenuItem(value: spawn.id, child: Text(spawn.name)),
              )
              .toList(growable: false),
          onChanged: spawnPoints.isEmpty
              ? null
              : (value) =>
                    onChanged(object.copyWith(targetSpawnId: value ?? '')),
        ),
      ),
      if (targetRoom != null && spawnPoints.isEmpty)
        Text(l10n.noSpawnPoints, style: const TextStyle(color: Colors.orange)),
      SizedBox(
        width: 180,
        child: _textField(
          l10n.transitionColor,
          object.transitionColor,
          (value) => onChanged(object.copyWith(transitionColor: value)),
        ),
      ),
      SizedBox(
        width: 140,
        child: _numberField(
          l10n.fadeOutSeconds,
          object.fadeOutSeconds,
          (value) => onChanged(object.copyWith(fadeOutSeconds: value)),
        ),
      ),
      SizedBox(
        width: 140,
        child: _numberField(
          l10n.fadeInSeconds,
          object.fadeInSeconds,
          (value) => onChanged(object.copyWith(fadeInSeconds: value)),
        ),
      ),
    ];
  }

  List<Widget> _savePointFields(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      SizedBox(
        width: 180,
        child: DropdownButtonFormField<int>(
          initialValue: object.saveSlot,
          decoration: InputDecoration(labelText: l10n.saveSlot),
          items: [
            for (var slot = 1; slot <= 3; slot++)
              DropdownMenuItem(value: slot, child: Text(slot.toString())),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(object.copyWith(saveSlot: value));
            }
          },
        ),
      ),
    ];
  }

  ProjectRoom? _roomByPath(String path) {
    for (final room in document.rooms) {
      if (room.path == path) {
        return room;
      }
    }
    return null;
  }

  Widget _textField(
    String label,
    String value,
    ValueChanged<String> onSubmitted,
  ) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onFieldSubmitted: onSubmitted,
    );
  }

  Widget _numberField(
    String label,
    double value,
    ValueChanged<double> onSubmitted,
  ) {
    return TextFormField(
      initialValue: value.toStringAsFixed(1),
      decoration: InputDecoration(labelText: label),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onFieldSubmitted: (text) => onSubmitted(double.tryParse(text) ?? value),
    );
  }
}

class _ResolvedObjectVisual {
  const _ResolvedObjectVisual({
    required this.assetPath,
    required this.width,
    required this.height,
  });

  final String assetPath;
  final double width;
  final double height;
}

_ResolvedObjectVisual _resolveObjectVisual(
  ProjectDocument document,
  ProjectSceneObject object,
) {
  ProjectCharacterDefinition? definition;
  if (object.type == 'character' && object.characterPath.isNotEmpty) {
    for (final character in document.characters) {
      if (character.path == object.characterPath) {
        definition = character.definition;
        break;
      }
    }
  }
  final frame = definition == null ? null : _previewFrame(definition);
  return _ResolvedObjectVisual(
    assetPath: frame ?? object.asset,
    width: object.width > 0
        ? object.width
        : definition?.defaultWidth ?? object.width,
    height: object.height > 0
        ? object.height
        : definition?.defaultHeight ?? object.height,
  );
}

String? _previewFrame(ProjectCharacterDefinition definition) {
  for (final preferredName in const ['idle', 'walk']) {
    for (final animation in definition.animations) {
      if (animation.name == preferredName &&
          animation.direction == 'down' &&
          animation.frames.isNotEmpty) {
        return animation.frames.first;
      }
    }
  }
  for (final animation in definition.animations) {
    if (animation.direction == 'down' && animation.frames.isNotEmpty) {
      return animation.frames.first;
    }
  }
  for (final animation in definition.animations) {
    if (animation.frames.isNotEmpty) {
      return animation.frames.first;
    }
  }
  return null;
}

bool _isEditorMarker(String type) {
  return type == 'collision' ||
      type == 'spawn' ||
      type == 'door' ||
      type == 'savePoint';
}

IconData _markerIcon(String type) {
  return switch (type) {
    'collision' => Icons.crop_square,
    'spawn' => Icons.place,
    'savePoint' => Icons.save_outlined,
    _ => Icons.meeting_room,
  };
}

String _defaultLayerId(String type) {
  return switch (type) {
    'background' => 'background',
    'character' => 'characters',
    _ => 'objects',
  };
}

String _defaultObjectName(AppLocalizations l10n, String type) {
  return switch (type) {
    'background' => l10n.backgroundResources,
    'character' => l10n.characterDefaultName,
    'prop' => l10n.propResources,
    'collision' => l10n.collisionRegion,
    'spawn' => l10n.spawnPoint,
    'door' => l10n.doorConnection,
    'savePoint' => l10n.savePoint,
    _ => type,
  };
}

String _directionLabel(AppLocalizations l10n, String direction) {
  return switch (direction) {
    'up' => l10n.directionUp,
    'left' => l10n.directionLeft,
    'right' => l10n.directionRight,
    _ => l10n.directionDown,
  };
}
