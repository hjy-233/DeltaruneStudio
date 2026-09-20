import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/domain/project_settings.dart';
import 'package:deltarune_studio/editor/project_feature_strings.dart';
import 'package:deltarune_studio/l10n/generated/app_localizations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

class ProjectSettingsDialog extends StatefulWidget {
  const ProjectSettingsDialog({super.key, required this.manifest});

  final ProjectManifest manifest;

  @override
  State<ProjectSettingsDialog> createState() => _ProjectSettingsDialogState();
}

class _ProjectSettingsDialogState extends State<ProjectSettingsDialog> {
  late ProjectGameSettings _game = widget.manifest.gameSettings;
  late ProjectExportSettings _export = widget.manifest.exportSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final strings = ProjectFeatureStrings.of(context);
    return AlertDialog(
      title: Text(strings.projectSettings),
      content: SizedBox(
        width: 620,
        height: 560,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: strings.gameSettings),
                  Tab(text: strings.exportSettings),
                ],
              ),
              Expanded(
                child: TabBarView(children: [_gameTab(l10n), _exportTab(l10n)]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            widget.manifest.copyWith(
              gameSettings: _game,
              exportSettings: _export,
            ),
          ),
          child: Text(l10n.saveProject),
        ),
      ],
    );
  }

  Widget _gameTab(AppLocalizations l10n) {
    final strings = ProjectFeatureStrings.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sizeRow(
          strings.viewportSize,
          _game.viewportWidth,
          _game.viewportHeight,
          (value) =>
              setState(() => _game = _game.copyWith(viewportWidth: value)),
          (value) =>
              setState(() => _game = _game.copyWith(viewportHeight: value)),
        ),
        const SizedBox(height: 16),
        _sizeRow(
          strings.windowSize,
          _game.windowWidth,
          _game.windowHeight,
          (value) => setState(() => _game = _game.copyWith(windowWidth: value)),
          (value) =>
              setState(() => _game = _game.copyWith(windowHeight: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.startFullscreen),
          value: _game.startFullscreen,
          onChanged: (value) =>
              setState(() => _game = _game.copyWith(startFullscreen: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.pixelPerfect),
          value: _game.pixelPerfect,
          onChanged: (value) =>
              setState(() => _game = _game.copyWith(pixelPerfect: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.enableWasd),
          value: _game.enableWasd,
          onChanged: (value) =>
              setState(() => _game = _game.copyWith(enableWasd: value)),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(strings.enableArrowKeys),
          value: _game.enableArrowKeys,
          onChanged: (value) =>
              setState(() => _game = _game.copyWith(enableArrowKeys: value)),
        ),
        DropdownButtonFormField<int>(
          initialValue: _game.defaultSaveSlot,
          decoration: InputDecoration(labelText: strings.defaultSaveSlot),
          items: [
            for (var slot = 1; slot <= 3; slot++)
              DropdownMenuItem(value: slot, child: Text('$slot')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _game = _game.copyWith(defaultSaveSlot: value));
            }
          },
        ),
      ],
    );
  }

  Widget _exportTab(AppLocalizations l10n) {
    final strings = ProjectFeatureStrings.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _textSetting(
          strings.bundleIdentifier,
          _export.bundleIdentifier,
          (value) => _export = _export.copyWith(bundleIdentifier: value.trim()),
        ),
        const SizedBox(height: 12),
        _textSetting(
          strings.version,
          _export.version,
          (value) => _export = _export.copyWith(version: value.trim()),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _export.defaultTarget,
          decoration: InputDecoration(labelText: strings.defaultExportTarget),
          items: [
            DropdownMenuItem(value: 'macOS', child: Text(l10n.exportMacOS)),
            DropdownMenuItem(value: 'windows', child: Text(l10n.exportWindows)),
            DropdownMenuItem(value: 'linux', child: Text(l10n.exportLinux)),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() => _export = _export.copyWith(defaultTarget: value));
            }
          },
        ),
        const SizedBox(height: 12),
        _pathSetting(strings.gameIcon, _export.iconPath, _chooseIcon),
        const SizedBox(height: 12),
        _pathSetting(
          strings.exportDirectory,
          _export.outputDirectory,
          _chooseDirectory,
        ),
      ],
    );
  }

  Widget _sizeRow(
    String label,
    int width,
    int height,
    ValueChanged<int> onWidthChanged,
    ValueChanged<int> onHeightChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _integerField('W', width, onWidthChanged)),
            const SizedBox(width: 12),
            Expanded(child: _integerField('H', height, onHeightChanged)),
          ],
        ),
      ],
    );
  }

  Widget _integerField(String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: '$value',
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null && parsed > 0) onChanged(parsed);
      },
    );
  }

  Widget _textSetting(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
    );
  }

  Widget _pathSetting(String label, String value, VoidCallback choose) {
    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(labelText: label),
            child: Text(
              value.isEmpty ? AppLocalizations.of(context)!.none : value,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: ProjectFeatureStrings.of(context).choose,
          onPressed: choose,
          icon: const Icon(Icons.folder_open),
        ),
      ],
    );
  }

  Future<void> _chooseIcon() async {
    final result = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Image', extensions: ['png', 'svg']),
      ],
    );
    if (result != null && mounted) {
      setState(() => _export = _export.copyWith(iconPath: result.path));
    }
  }

  Future<void> _chooseDirectory() async {
    final result = await getDirectoryPath();
    if (result != null && mounted) {
      setState(() => _export = _export.copyWith(outputDirectory: result));
    }
  }
}
