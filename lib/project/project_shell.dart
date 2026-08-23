import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:deltarune_studio/project/project_manifest.dart';
import 'package:deltarune_studio/project/godot_build_service.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ProjectShell extends StatefulWidget {
  const ProjectShell({super.key});

  @override
  State<ProjectShell> createState() => _ProjectShellState();
}

class _ProjectShellState extends State<ProjectShell> {
  final ProjectRepository _repository = ProjectRepository();
  final GodotBuildService _godotBuildService = GodotBuildService();
  ProjectDocument? _document;
  String? _message;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final document = _document;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.newProject,
            onPressed: _busy ? null : _createProject,
            icon: const Icon(Icons.create_new_folder),
          ),
          IconButton(
            tooltip: l10n.openProject,
            onPressed: _busy ? null : _openProject,
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            tooltip: l10n.saveProject,
            onPressed: document == null || _busy ? null : _saveProject,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            tooltip: l10n.buildAndRun,
            onPressed: document == null || _busy ? null : _buildAndRun,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: document == null
                ? _EmptyProjectView(
                    busy: _busy,
                    onCreate: _createProject,
                    onOpen: _openProject,
                  )
                : _ProjectOverview(document: document),
          ),
        ),
      ),
      bottomNavigationBar: _message == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_message!, textAlign: TextAlign.center),
              ),
            ),
    );
  }

  Future<void> _createProject() async {
    final l10n = AppLocalizations.of(context)!;
    final name = await _askProjectName();
    if (!mounted || name == null) {
      return;
    }
    final parentPath = await getDirectoryPath();
    if (!mounted || parentPath == null) {
      return;
    }
    await _run(
      () => _repository.create(parentPath: parentPath, name: name),
      success: (document) => l10n.projectCreated(document.path),
    );
  }

  Future<void> _openProject() async {
    final l10n = AppLocalizations.of(context)!;
    final path = await getDirectoryPath();
    if (!mounted || path == null) {
      return;
    }
    await _run(
      () => _repository.open(path),
      success: (document) => l10n.projectOpened(document.manifest.name),
    );
  }

  Future<void> _saveProject() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    await _run(() async {
      await _repository.save(document);
      return document;
    }, success: (_) => l10n.projectSaved);
  }

  Future<void> _buildAndRun() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _godotBuildService.buildAndRun(document);
      if (mounted) {
        setState(() => _message = l10n.godotStarted);
      }
    } on Object catch (error) {
      if (mounted) {
        final message = error is StateError ? error.message : error.toString();
        setState(() => _message = message);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _run(
    Future<ProjectDocument> Function() action, {
    required String Function(ProjectDocument document) success,
  }) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final document = await action();
      if (!mounted) {
        return;
      }
      setState(() {
        _document = document;
        _message = success(document);
      });
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = error.toString());
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<String?> _askProjectName() {
    final controller = TextEditingController(text: 'My Game');
    return showDialog<String>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(l10n.newProject),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.projectName),
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyProjectView extends StatelessWidget {
  const _EmptyProjectView({
    required this.busy,
    required this.onCreate,
    required this.onOpen,
  });

  final bool busy;
  final VoidCallback onCreate;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.folder_copy_outlined, size: 64),
        const SizedBox(height: 20),
        Text(l10n.noProject, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          children: [
            FilledButton.icon(
              onPressed: busy ? null : onCreate,
              icon: const Icon(Icons.create_new_folder),
              label: Text(l10n.newProject),
            ),
            OutlinedButton.icon(
              onPressed: busy ? null : onOpen,
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.openProject),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProjectOverview extends StatelessWidget {
  const _ProjectOverview({required this.document});

  final ProjectDocument document;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          document.manifest.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(document.path),
        const SizedBox(height: 32),
        Text(
          l10n.projectStructure,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        const _StructureRow(icon: Icons.image, label: 'resources/'),
        const _StructureRow(icon: Icons.map, label: 'scenes/main/scene.json'),
        const _StructureRow(icon: Icons.people, label: 'characters/'),
        const _StructureRow(icon: Icons.code, label: 'scripts/manual/'),
        const _StructureRow(icon: Icons.account_tree, label: 'visual_scripts/'),
        const _StructureRow(icon: Icons.build, label: '.build/godot/'),
      ],
    );
  }
}

class _StructureRow extends StatelessWidget {
  const _StructureRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(dense: true, leading: Icon(icon), title: Text(label));
  }
}
