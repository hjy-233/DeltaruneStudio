import 'dart:io';
import 'dart:convert';

import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/editor/editor_selection.dart';
import 'package:deltarune_studio/project/built_in_asset_library.dart';
import 'package:deltarune_studio/project/path_node_tools.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/project/scene_trigger_tools.dart';
import 'package:deltarune_studio/project/studio_state.dart';
import 'package:deltarune_studio/project/web_project_download_stub.dart'
    if (dart.library.html) 'package:deltarune_studio/project/web_project_download_web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

export 'package:deltarune_studio/project/studio_state.dart';

part 'studio_controller_assets.dart';
part 'studio_controller_selection.dart';
part 'studio_controller_editing.dart';
part 'studio_controller_preferences.dart';

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

final studioControllerProvider =
    StateNotifierProvider<StudioController, StudioState>((ref) {
      return StudioController(ref.watch(projectRepositoryProvider));
    });

final class StudioController extends StateNotifier<StudioState> {
  StudioController(this._repository) : super(const StudioState.loading()) {
    openLastProjectOrCreateScratch();
  }

  final ProjectRepository _repository;
  final List<_HistoryEntry> _undoStack = [];
  final List<_HistoryEntry> _redoStack = [];
  bool _restoringHistory = false;

  static const _settingsFileName = 'settings.json';
  static const _lastProjectPathKey = 'lastProjectPath';

  StudioState get _controllerState => state;

  set _controllerState(StudioState value) => state = value;

  Future<void> openLastProjectOrCreateScratch() async {
    if (kIsWeb) {
      await createScratchProject();
      return;
    }
    final lastProjectPath = await _readLastProjectPath();
    if (lastProjectPath != null) {
      final directory = Directory(lastProjectPath);
      try {
        final project = await _repository.openProject(directory);
        _clearHistory();
        state = StudioState.ready(
          project: project,
          projectDirectory: directory,
          statusMessage: 'Opened last project ${directory.path}.',
        );
        return;
      } on Object {
        await _clearLastProjectPath();
      }
    }
    await createScratchProject();
  }

  Future<void> createScratchProject() async {
    final project = await _repository.createDefaultProject('Deltarune Studio');
    _clearHistory();
    state = StudioState.ready(project: project);
  }

  Future<void> newProject() => createScratchProject();

  Future<void> saveProject() async {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (kIsWeb) {
      const encoder = JsonEncoder.withIndent('  ');
      await downloadProjectJson(
        '${current.project.name}.drs.json',
        encoder.convert(current.project.toJson()),
      );
      state = current.copyWith(
        isDirty: false,
        statusMessage: 'Downloaded ${current.project.name}.drs.json.',
      );
      return;
    }
    final directory = current.projectDirectory ?? await _defaultProjectDir();
    await _repository.saveProject(
      directory: directory,
      project: current.project,
    );
    final latest = state.asReady ?? current;
    if (latest.project != current.project) {
      await _repository.saveProject(
        directory: directory,
        project: latest.project,
      );
    }
    state = latest.copyWith(
      projectDirectory: directory,
      isDirty: false,
      statusMessage: 'Saved to ${directory.path}.',
    );
    await _writeLastProjectPath(directory);
  }

  Future<void> saveProjectAs() async {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (kIsWeb) {
      await saveProject();
      return;
    }
    final path = await getSaveLocation(
      suggestedName: '${current.project.name}.drs',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Deltarune Studio Project', extensions: ['drs']),
      ],
    );
    if (path == null) {
      return;
    }
    final directoryPath = path.path.endsWith('.drs')
        ? path.path
        : '${path.path}.drs';
    final directory = Directory(directoryPath);
    await _repository.saveProject(
      directory: directory,
      project: current.project,
    );
    final latest = state.asReady ?? current;
    if (latest.project != current.project) {
      await _repository.saveProject(
        directory: directory,
        project: latest.project,
      );
    }
    state = latest.copyWith(
      projectDirectory: directory,
      isDirty: false,
      statusMessage: 'Saved to ${directory.path}.',
    );
    await _writeLastProjectPath(directory);
  }

  void updateEditorLayout(EditorLayout layout) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (current.project.editorLayout == layout) {
      return;
    }
    state = current.copyWith(
      project: current.project.copyWith(editorLayout: layout),
      isDirty: true,
    );
  }

  void updateEditorSettings(EditorSettings settings) {
    final current = state.asReady;
    if (current == null) {
      return;
    }
    if (current.project.settings == settings) {
      return;
    }
    _recordHistory(current);
    state = current.copyWith(
      project: current.project.copyWith(settings: settings),
      isDirty: true,
      statusMessage: 'Updated editor settings.',
    );
  }

  Future<void> openProject() async {
    if (kIsWeb) {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Deltarune Studio Project',
            extensions: ['json', 'drs'],
          ),
        ],
      );
      if (file == null) {
        return;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) {
        return;
      }
      state = StudioState.ready(
        project: _repository.migrateProjectForOpen(
          StudioProject.fromJson(json),
        ),
        statusMessage: 'Opened ${file.name}.',
      );
      _clearHistory();
      return;
    }
    final path = await getDirectoryPath(confirmButtonText: 'Open Project');
    if (path == null) {
      return;
    }
    final directory = Directory(path);
    final project = await _repository.openProject(directory);
    _clearHistory();
    state = StudioState.ready(project: project, projectDirectory: directory);
    await _writeLastProjectPath(directory);
  }
}

final class _HistoryEntry {
  const _HistoryEntry({
    required this.project,
    required this.selection,
    required this.clipboardObjects,
  });

  final StudioProject project;
  final EditorSelection? selection;
  final List<SceneObject> clipboardObjects;
}

final class _PastedObject {
  const _PastedObject({required this.object, this.trigger, this.chain});

  final SceneObject object;
  final Trigger? trigger;
  final EventChain? chain;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
