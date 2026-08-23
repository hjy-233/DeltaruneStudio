import 'project_manifest.dart';

class ProjectRepository {
  Future<ProjectDocument> create({
    required String parentPath,
    required String name,
  }) {
    return Future.error(
      UnsupportedError('Project folders are not available on the web yet.'),
    );
  }

  Future<ProjectDocument> open(String path) {
    return Future.error(
      UnsupportedError('Project folders are not available on the web yet.'),
    );
  }

  Future<void> save(ProjectDocument document) {
    return Future.error(
      UnsupportedError('Project folders are not available on the web yet.'),
    );
  }
}
