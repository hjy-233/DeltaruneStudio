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

  Future<ProjectDocument> importAsset(
    ProjectDocument document, {
    required String sourcePath,
    required String type,
  }) {
    return Future.error(
      UnsupportedError('Resource import is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> addRoom(ProjectDocument document, String name) {
    return Future.error(
      UnsupportedError('Room creation is not available on the web yet.'),
    );
  }
}
