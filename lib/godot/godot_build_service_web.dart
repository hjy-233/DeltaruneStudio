import 'package:deltarune_studio/domain/project_manifest.dart';

import 'godot_build_models.dart';

class GodotBuildResult {
  const GodotBuildResult({required this.directory, required this.godotPath});

  final String directory;
  final String? godotPath;
}

class GodotBuildService {
  Future<GodotExportPreflight> preflight(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Godot desktop exports are not available on the web.'),
    );
  }

  Future<bool> syncHotReload(ProjectDocument document) async => false;

  Future<GodotBuildResult> prepare(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Godot desktop builds are not available on the web.'),
    );
  }

  Future<GodotRunSession> buildAndRun(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Godot desktop builds are not available on the web.'),
    );
  }

  Future<void> exportProject(
    ProjectDocument document,
    GodotExportTarget target,
    String outputPath, {
    void Function(String line)? onOutput,
  }) {
    return Future.error(
      UnsupportedError('Godot desktop exports are not available on the web.'),
    );
  }
}
