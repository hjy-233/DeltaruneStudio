part of 'project_shell.dart';

extension _ProjectShellRuntimeActions on _ProjectShellState {
  Future<void> _buildAndRun() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    _setShellState(() {
      _busy = true;
      _message = null;
    });
    try {
      await _repository.save(document);
      await _stopRunSession();
      _runtimeLogs.value = [];
      final session = await _godotBuildService.buildAndRun(document);
      _runSession = session;
      _runLogSubscription = session.output.listen(
        _appendRuntimeLog,
        onError: (Object error) => _appendRuntimeLog(error.toString()),
      );
      unawaited(
        session.exitCode.then((code) {
          _appendRuntimeLog(l10n.runtimeExited(code));
          if (_runSession == session) {
            _runSession = null;
          }
        }),
      );
      if (mounted) {
        _setShellState(() => _message = l10n.godotStarted);
      }
    } on Object catch (error) {
      if (mounted) {
        final message = error is StateError ? error.message : error.toString();
        _setShellState(() => _message = message);
      }
    } finally {
      if (mounted) {
        _setShellState(() => _busy = false);
      }
    }
  }

  void _appendRuntimeLog(String line) {
    if (!mounted) {
      return;
    }
    final next = [..._runtimeLogs.value, line];
    if (next.length > 1000) {
      next.removeRange(0, next.length - 1000);
    }
    _runtimeLogs.value = next;
  }

  Future<void> _stopRunSession() async {
    await _runLogSubscription?.cancel();
    _runLogSubscription = null;
    final session = _runSession;
    _runSession = null;
    if (session != null) {
      await session.stop();
    }
  }

  Future<void> _showRuntimeConsole() {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.runtimeConsole),
        content: SizedBox(
          width: 760,
          height: 420,
          child: ValueListenableBuilder<List<String>>(
            valueListenable: _runtimeLogs,
            builder: (context, lines, _) => DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final line = lines[index];
                  final isError =
                      line.contains('ERROR') ||
                      line.contains('SCRIPT ERROR') ||
                      line.contains('WARNING');
                  return SelectableText(
                    line,
                    style: TextStyle(
                      color: isError ? Colors.orangeAccent : Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _runtimeLogs.value = [],
            child: Text(l10n.clear),
          ),
          TextButton(
            onPressed: () => unawaited(_stopRunSession()),
            child: Text(l10n.stopRuntime),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGame() async {
    final document = _document;
    if (document == null) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final preferredTarget = _exportTargetFromName(
      document.manifest.exportSettings.defaultTarget,
    );
    final targets = [
      preferredTarget,
      ...GodotExportTarget.values.where((item) => item != preferredTarget),
    ];
    final target = await showDialog<GodotExportTarget>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.exportTarget),
        children: [
          for (final target in targets)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, target),
              child: Text(_exportTargetLabel(l10n, target)),
            ),
        ],
      ),
    );
    if (target == null || !mounted) {
      return;
    }
    final location = await getSaveLocation(
      initialDirectory: document.manifest.exportSettings.outputDirectory.isEmpty
          ? null
          : document.manifest.exportSettings.outputDirectory,
      suggestedName: '${document.manifest.name}.${target.extension}',
      acceptedTypeGroups: [
        XTypeGroup(label: target.preset, extensions: [target.extension]),
      ],
    );
    if (location == null || !mounted) {
      return;
    }
    _setShellState(() {
      _busy = true;
      _message = null;
    });
    _runtimeLogs.value = [];
    try {
      final exportSettings = document.manifest.exportSettings.copyWith(
        defaultTarget: target.name,
        outputDirectory: p.dirname(location.path),
      );
      final updated = document.copyWith(
        manifest: document.manifest.copyWith(exportSettings: exportSettings),
      );
      _setShellState(() => _document = updated);
      await _repository.save(updated);
      await _godotBuildService.exportProject(
        updated,
        target,
        location.path,
        onOutput: _appendRuntimeLog,
      );
      if (mounted) {
        _setShellState(() => _message = l10n.exportCompleted(location.path));
      }
    } on Object catch (error) {
      _appendRuntimeLog(error.toString());
      if (mounted) {
        final message = error is StateError ? error.message : error.toString();
        _setShellState(() => _message = message);
        await _showRuntimeConsole();
      }
    } finally {
      if (mounted) {
        _setShellState(() => _busy = false);
      }
    }
  }

  GodotExportTarget _exportTargetFromName(String name) {
    return GodotExportTarget.values.firstWhere(
      (target) => target.name == name,
      orElse: () => GodotExportTarget.macOS,
    );
  }

  String _exportTargetLabel(AppLocalizations l10n, GodotExportTarget target) {
    return switch (target) {
      GodotExportTarget.macOS => l10n.exportMacOS,
      GodotExportTarget.windows => l10n.exportWindows,
      GodotExportTarget.linux => l10n.exportLinux,
    };
  }
}
