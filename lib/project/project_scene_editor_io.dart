import 'dart:io';

import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'project_character.dart';
import 'project_manifest.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
                    aspectRatio: 4 / 3,
                    child: ColoredBox(
                      color: Colors.black,
                      child: LayoutBuilder(
                        builder: (context, constraints) => _SceneCanvas(
                          document: widget.document,
                          selectedId: _selectedId,
                          scale: constraints.maxWidth / 640,
                          onSelect: _select,
                          onMove: _moveObject,
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
                        ? Center(child: Text(l10n.selectObject))
                        : SingleChildScrollView(
                            child: _ObjectInspector(
                              object: selected,
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
    final object = ProjectSceneObject(
      id: const Uuid().v4(),
      type: type,
      name: type[0].toUpperCase() + type.substring(1),
      asset: '',
      x: 320,
      y: 240,
      zIndex: _scene.objects.length,
    );
    _selectedId = object.id;
    _emit(_scene.copyWith(objects: [..._scene.objects, object]));
  }

  void _moveObject(String id, Offset delta) {
    final object = _findObject(id);
    if (object == null) {
      return;
    }
    _updateObject(
      object.copyWith(x: object.x + delta.dx, y: object.y + delta.dy),
    );
  }

  void _updateObject(ProjectSceneObject updated) {
    final objects = _scene.objects
        .map((object) => object.id == updated.id ? updated : object)
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
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () => onAdd('background'),
          icon: const Icon(Icons.image),
          label: const Text('Add background'),
        ),
        FilledButton.icon(
          onPressed: () => onAdd('character'),
          icon: const Icon(Icons.person),
          label: const Text('Add character'),
        ),
        FilledButton.icon(
          onPressed: () => onAdd('prop'),
          icon: const Icon(Icons.category),
          label: const Text('Add prop'),
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
  });

  final ProjectDocument document;
  final String? selectedId;
  final double scale;
  final ValueChanged<String?> onSelect;
  final void Function(String id, Offset delta) onMove;

  @override
  Widget build(BuildContext context) {
    final objects = [...document.mainScene.objects]
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
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
              child: _DraggableObject(
                object: object,
                visual: _resolveObjectVisual(document, object),
                rootPath: document.path,
                scale: scale,
                selected: selectedId == object.id,
                onTap: () => onSelect(object.id),
                onMove: (delta) => onMove(object.id, delta / scale),
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
    required this.onTap,
    required this.onMove,
  });

  final ProjectSceneObject object;
  final _ResolvedObjectVisual visual;
  final String rootPath;
  final double scale;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;

  @override
  Widget build(BuildContext context) {
    final file = File('$rootPath/${visual.assetPath}');
    final child = file.existsSync()
        ? SizedBox(
            width: visual.width > 0 ? visual.width * scale : null,
            height: visual.height > 0 ? visual.height * scale : null,
            child: Image.file(
              file,
              fit: visual.width > 0 || visual.height > 0
                  ? BoxFit.fill
                  : BoxFit.none,
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
      onPanUpdate: object.locked ? null : (details) => onMove(details.delta),
      child: DecoratedBox(
        decoration: selected
            ? BoxDecoration(border: Border.all(color: Colors.amber, width: 2))
            : const BoxDecoration(),
        child: child,
      ),
    );
  }
}

class _ObjectInspector extends StatelessWidget {
  const _ObjectInspector({
    required this.object,
    required this.assets,
    required this.characters,
    required this.onChanged,
    required this.onDelete,
  });

  final ProjectSceneObject object;
  final List<ProjectAsset> assets;
  final List<ProjectCharacterFile> characters;
  final ValueChanged<ProjectSceneObject> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
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
          DropdownButtonFormField<String>(
            initialValue: object.asset.isEmpty ? null : object.asset,
            decoration: const InputDecoration(labelText: 'Resource'),
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
              'Name',
              object.name,
              (value) => onChanged(object.copyWith(name: value)),
            ),
          ),
          SizedBox(
            width: 300,
            child: _textField(
              'Asset path',
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
              'Layer',
              object.zIndex.toDouble(),
              (value) => onChanged(object.copyWith(zIndex: value.toInt())),
            ),
          ),
          SizedBox(
            width: 100,
            child: _numberField(
              'Width',
              object.width,
              (value) => onChanged(object.copyWith(width: value)),
            ),
          ),
          SizedBox(
            width: 100,
            child: _numberField(
              'Height',
              object.height,
              (value) => onChanged(object.copyWith(height: value)),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Locked'),
            value: object.locked,
            onChanged: (value) => onChanged(object.copyWith(locked: value)),
          ),
          FilledButton.tonalIcon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
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
