import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'package:deltarune_studio/project/web_character_library_stub.dart'
    if (dart.library.html) 'package:deltarune_studio/project/web_character_library_web.dart';
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
  double _editorInsertionX = 240;
  double _editorInsertionY = 140;

  void setEditorInsertionPoint(double x, double y) {
    _editorInsertionX = x;
    _editorInsertionY = y;
  }

  Transform2D _atEditorCenter(Transform2D transform) {
    return transform.copyWith(
      x: _editorInsertionX - transform.width * transform.scale / 2,
      y: _editorInsertionY - transform.height * transform.scale / 2,
    );
  }

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
        final resolvedProject = await _loadGlobalCharacters(
          project,
          projectDirectory: directory,
        );
        _clearHistory();
        state = StudioState.ready(
          project: resolvedProject,
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
    final resolvedProject = await _loadGlobalCharacters(
      project,
      seedIfMissing: false,
    );
    _clearHistory();
    state = StudioState.ready(project: resolvedProject);
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
    if (current.projectDirectory == null) {
      await saveProjectAs();
      return;
    }
    await _saveGlobalCharactersIfNeeded(
      current.project,
      projectDirectory: current.projectDirectory,
    );
    final directory = current.projectDirectory!;
    final project = await _materializeDataUriAssets(current.project, directory);
    await _repository.saveProject(directory: directory, project: project);
    final afterMaterialize = current.copyWith(project: project);
    final latest = state.asReady ?? afterMaterialize;
    if (latest.project != project) {
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
    await _saveGlobalCharactersIfNeeded(
      current.project,
      projectDirectory: current.projectDirectory,
    );
    final directoryPath = path.path.endsWith('.drs')
        ? path.path
        : '${path.path}.drs';
    final directory = Directory(directoryPath);
    if (current.projectDirectory != null &&
        current.projectDirectory!.path != directory.path) {
      await _repository.copyProjectPayload(
        sourceDirectory: current.projectDirectory!,
        targetDirectory: directory,
      );
    }
    final project = await _materializeDataUriAssets(current.project, directory);
    await _repository.saveProject(directory: directory, project: project);
    final afterMaterialize = current.copyWith(project: project);
    final latest = state.asReady ?? afterMaterialize;
    if (latest.project != project) {
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

  Future<void> updateEditorSettings(EditorSettings settings) async {
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
    if (settings.characterLibraryScope == CharacterLibraryScope.global) {
      final latest = state.asReady ?? current;
      final resolved = await _loadGlobalCharacters(
        latest.project,
        projectDirectory: latest.projectDirectory,
      );
      final afterLoad = state.asReady;
      if (afterLoad != null && afterLoad.project.id == latest.project.id) {
        state = afterLoad.copyWith(project: resolved);
      }
    }
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
      final project = _repository.migrateProjectForOpen(
        StudioProject.fromJson(json),
      );
      state = StudioState.ready(
        project: await _loadGlobalCharacters(project),
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
    state = StudioState.ready(
      project: await _loadGlobalCharacters(
        project,
        projectDirectory: directory,
      ),
      projectDirectory: directory,
    );
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
