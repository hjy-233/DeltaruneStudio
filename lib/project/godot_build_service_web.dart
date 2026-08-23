import 'project_manifest.dart';

class GodotBuildResult {
  const GodotBuildResult({required this.directory, required this.godotPath});

  final String directory;
  final String? godotPath;
}

class GodotBuildService {
  Future<GodotBuildResult> prepare(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Godot desktop builds are not available on the web.'),
    );
  }

  Future<void> buildAndRun(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Godot desktop builds are not available on the web.'),
    );
  }
}
