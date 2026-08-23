import 'dart:io';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'project_manifest.dart';

class ProjectSceneEditor extends StatefulWidget {
  const ProjectSceneEditor({
    super.key,
    required this.document,
    required this.onChanged,
  });

  final ProjectDocument document;
  final ValueChanged<ProjectScene> onChanged;

  @override
  State<ProjectSceneEditor> createState() => _ProjectSceneEditorState();
}

class _ProjectSceneEditorState extends State<ProjectSceneEditor> {
  String? _selectedId;

  ProjectScene get _scene => widget.document.mainScene;

  @override
  Widget build(BuildContext context) {
    final selected = _selectedObject;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EditorToolbar(onAdd: _addObject),
        const SizedBox(height: 8),
        AspectRatio(
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
        const SizedBox(height: 12),
        if (selected == null)
          const Text('Select an object to edit its properties.')
        else
          _ObjectInspector(
            object: selected,
            onChanged: _updateObject,
            onDelete: () => _deleteObject(selected.id),
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
    required this.rootPath,
    required this.scale,
    required this.selected,
    required this.onTap,
    required this.onMove,
  });

  final ProjectSceneObject object;
  final String rootPath;
  final double scale;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<Offset> onMove;

  @override
  Widget build(BuildContext context) {
    final file = File('$rootPath/${object.asset}');
    final child = file.existsSync()
        ? Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: Image.file(file, filterQuality: FilterQuality.none),
          )
        : Container(
            padding: const EdgeInsets.all(6),
            color: Colors.red.withValues(alpha: 0.7),
            child: Text(object.name, style: const TextStyle(fontSize: 11)),
          );
    return GestureDetector(
      onTap: onTap,
      onPanStart: (_) => onTap(),
      onPanUpdate: (details) => onMove(details.delta),
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
    required this.onChanged,
    required this.onDelete,
  });

  final ProjectSceneObject object;
  final ValueChanged<ProjectSceneObject> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
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
            FilledButton.tonalIcon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        ),
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
