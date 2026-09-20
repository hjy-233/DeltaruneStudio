part of 'project_shell.dart';

extension _ProjectShellSettingsActions on _ProjectShellState {
  Future<void> _loadRecentProjects() async {
    final paths = await _recentProjectsStore.load();
    if (mounted) {
      _setShellState(() {
        _recentProjects
          ..clear()
          ..addAll(paths);
      });
    }
  }

  void _rememberProject(String path) {
    _recentProjects.remove(path);
    _recentProjects.insert(0, path);
    if (_recentProjects.length > 8) {
      _recentProjects.removeLast();
    }
    unawaited(_recentProjectsStore.save(_recentProjects));
  }

  Future<void> _showProjectSettings() async {
    final document = _document;
    if (document == null) return;
    final manifest = await showDialog<ProjectManifest>(
      context: context,
      builder: (context) => ProjectSettingsDialog(manifest: document.manifest),
    );
    if (manifest == null || !mounted) return;
    final updated = document.copyWith(manifest: manifest);
    _setShellState(() => _document = updated);
    await _repository.save(updated);
  }
}
