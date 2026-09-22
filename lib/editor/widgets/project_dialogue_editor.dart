import 'package:deltarune_studio/domain/project_content.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ProjectDialogueEditor extends StatefulWidget {
  const ProjectDialogueEditor({
    super.key,
    required this.document,
    required this.onCreate,
    required this.onSave,
    required this.onDelete,
  });

  final ProjectDocument document;
  final Future<ProjectDocument> Function(String) onCreate;
  final Future<ProjectDocument> Function(ProjectDialogue) onSave;
  final Future<ProjectDocument> Function(ProjectDialogue) onDelete;

  @override
  State<ProjectDialogueEditor> createState() => _ProjectDialogueEditorState();
}

class _ProjectDialogueEditorState extends State<ProjectDialogueEditor> {
  late ProjectDocument _document = widget.document;
  ProjectDialogue? _selected;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    return Dialog(
      child: SizedBox(
        width: 980,
        height: 680,
        child: Row(
          children: [
            SizedBox(
              width: 260,
              child: Column(
                children: [
                  ListTile(
                    title: Text(strings.dialogues),
                    trailing: IconButton(
                      onPressed: _busy ? null : _create,
                      icon: const Icon(Icons.add),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final dialogue in _document.dialogues)
                          ListTile(
                            selected: dialogue.path == _selected?.path,
                            title: Text(dialogue.id),
                            subtitle: Text(dialogue.style),
                            onTap: () => setState(() => _selected = dialogue),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _selected == null
                  ? Center(child: Text(strings.dialogueId))
                  : _DialogueForm(
                      key: ValueKey(_selected!.path),
                      document: _document,
                      dialogue: _selected!,
                      busy: _busy,
                      onSave: _save,
                      onDelete: _delete,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final id = await _askId();
    if (id == null || id.isEmpty) return;
    await _run(() => widget.onCreate(id), selectLast: true);
  }

  Future<void> _save(ProjectDialogue dialogue) async {
    await _run(() => widget.onSave(dialogue), selectedPath: dialogue.path);
  }

  Future<void> _delete(ProjectDialogue dialogue) async {
    await _run(() => widget.onDelete(dialogue));
  }

  Future<void> _run(
    Future<ProjectDocument> Function() action, {
    bool selectLast = false,
    String? selectedPath,
  }) async {
    setState(() => _busy = true);
    try {
      final result = await action();
      if (!mounted) return;
      setState(() {
        _document = result;
        _selected = selectLast && result.dialogues.isNotEmpty
            ? result.dialogues.last
            : result.dialogues
                  .where((item) => item.path == selectedPath)
                  .firstOrNull;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askId() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ProjectFeatureStrings.of(context).newDialogue),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: ProjectFeatureStrings.of(context).dialogueId,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(ProjectFeatureStrings.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(ProjectFeatureStrings.of(context).apply),
          ),
        ],
      ),
    );
  }
}

class _DialogueForm extends StatefulWidget {
  const _DialogueForm({
    super.key,
    required this.document,
    required this.dialogue,
    required this.busy,
    required this.onSave,
    required this.onDelete,
  });

  final ProjectDocument document;
  final ProjectDialogue dialogue;
  final bool busy;
  final ValueChanged<ProjectDialogue> onSave;
  final ValueChanged<ProjectDialogue> onDelete;

  @override
  State<_DialogueForm> createState() => _DialogueFormState();
}

class _DialogueFormState extends State<_DialogueForm> {
  late String _style = widget.dialogue.style;
  late String _portrait = widget.dialogue.portrait;
  late String _sound = widget.dialogue.sound;
  late final TextEditingController _english = TextEditingController(
    text: widget.dialogue.translations['en'] ?? '',
  );
  late final TextEditingController _chinese = TextEditingController(
    text: widget.dialogue.translations['zh'] ?? '',
  );

  @override
  void dispose() {
    _english.dispose();
    _chinese.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ProjectFeatureStrings.of(context);
    final portraits = widget.document.assets
        .where((asset) => asset.type == 'portraits')
        .toList(growable: false);
    final sounds = widget.document.assets
        .where((asset) => asset.type == 'audio')
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(widget.dialogue.id, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _style,
          decoration: InputDecoration(labelText: strings.dialogueStyle),
          items: const [
            DropdownMenuItem(value: 'light', child: Text('Light World')),
            DropdownMenuItem(value: 'dark', child: Text('Dark World')),
          ],
          onChanged: (value) => setState(() => _style = value ?? 'light'),
        ),
        const SizedBox(height: 12),
        _assetPicker(strings.portrait, _portrait, portraits, (value) {
          setState(() => _portrait = value);
        }),
        const SizedBox(height: 12),
        _assetPicker(strings.dialogueSound, _sound, sounds, (value) {
          setState(() => _sound = value);
        }),
        const SizedBox(height: 12),
        TextField(
          controller: _english,
          maxLines: 6,
          decoration: InputDecoration(labelText: strings.textEnglish),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _chinese,
          maxLines: 6,
          decoration: InputDecoration(labelText: strings.textChinese),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            FilledButton.icon(
              onPressed: widget.busy ? null : () => widget.onSave(_value),
              icon: const Icon(Icons.save_outlined),
              label: Text(strings.apply),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.busy
                  ? null
                  : () => widget.onDelete(widget.dialogue),
              icon: const Icon(Icons.delete_outline),
              label: Text(strings.erase),
            ),
          ],
        ),
      ],
    );
  }

  Widget _assetPicker(
    String label,
    String value,
    List<ProjectAsset> assets,
    ValueChanged<String> onChanged,
  ) {
    final paths = assets.map((item) => item.path).toSet();
    return DropdownButtonFormField<String>(
      initialValue: paths.contains(value) ? value : '',
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: '', child: Text('None')),
        for (final asset in assets)
          DropdownMenuItem(
            value: asset.path,
            child: Text(asset.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (next) => onChanged(next ?? ''),
    );
  }

  ProjectDialogue get _value => widget.dialogue.copyWith(
    style: _style,
    portrait: _portrait,
    sound: _sound,
    translations: {'en': _english.text, 'zh': _chinese.text},
  );
}
