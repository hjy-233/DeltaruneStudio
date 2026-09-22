import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:flutter/material.dart';

class ProjectPrefabLibrary extends StatefulWidget {
  const ProjectPrefabLibrary({
    super.key,
    required this.document,
    required this.selectedObject,
    required this.onSave,
    required this.onDelete,
  });

  final ProjectDocument document;
  final ProjectSceneObject? selectedObject;
  final Future<ProjectDocument> Function(String, ProjectSceneObject) onSave;
  final Future<ProjectDocument> Function(ProjectPrefab) onDelete;

  @override
  State<ProjectPrefabLibrary> createState() => _ProjectPrefabLibraryState();
}

class _ProjectPrefabLibraryState extends State<ProjectPrefabLibrary> {
  late ProjectDocument _document = widget.document;
  final _nameController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    return AlertDialog(
      title: Text(strings.prefabs),
      content: SizedBox(
        width: 620,
        height: 460,
        child: Column(
          children: [
            if (widget.selectedObject != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: strings.prefabs),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _busy ? null : _save,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: Text(strings.savePrefab),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _document.prefabs.isEmpty
                  ? Center(child: Text(strings.noReferences))
                  : ListView.builder(
                      itemCount: _document.prefabs.length,
                      itemBuilder: (context, index) {
                        final prefab = _document.prefabs[index];
                        return ListTile(
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(prefab.name),
                          subtitle: Text(prefab.object.type),
                          trailing: IconButton(
                            onPressed: _busy ? null : () => _delete(prefab),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          onTap: () => Navigator.pop(context, prefab),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final object = widget.selectedObject;
    final name = _nameController.text.trim();
    if (object == null || name.isEmpty) return;
    setState(() => _busy = true);
    try {
      final document = await widget.onSave(name, object);
      if (mounted) {
        setState(() {
          _document = document;
          _nameController.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(ProjectPrefab prefab) async {
    setState(() => _busy = true);
    try {
      final document = await widget.onDelete(prefab);
      if (mounted) setState(() => _document = document);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
