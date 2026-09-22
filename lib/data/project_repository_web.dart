import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_content.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';

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
    String? destinationPath,
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

  Future<ProjectDocument> addCharacter(ProjectDocument document, String name) {
    return Future.error(
      UnsupportedError('Character editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> saveCharacter(
    ProjectDocument document,
    ProjectCharacterFile character,
  ) {
    return Future.error(
      UnsupportedError('Character editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deleteCharacter(
    ProjectDocument document,
    ProjectCharacterFile character,
  ) {
    return Future.error(
      UnsupportedError('Character editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> renameRoom(
    ProjectDocument document,
    String roomPath,
    String name,
  ) {
    return Future.error(
      UnsupportedError('Room editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deleteRoom(
    ProjectDocument document,
    String roomPath,
  ) {
    return Future.error(
      UnsupportedError('Room deletion is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> renameAsset(
    ProjectDocument document,
    ProjectAsset asset,
    String name,
  ) {
    return Future.error(
      UnsupportedError('Resource editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deleteAsset(
    ProjectDocument document,
    ProjectAsset asset,
  ) {
    return Future.error(
      UnsupportedError('Resource deletion is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> createResourceFolder(
    ProjectDocument document,
    String parentPath,
    String name,
  ) {
    return Future.error(
      UnsupportedError('Resource folders are not available on the web yet.'),
    );
  }

  Future<ProjectDocument> renameResourceFolder(
    ProjectDocument document,
    String folderPath,
    String name,
  ) {
    return Future.error(
      UnsupportedError('Resource folders are not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deleteResourceFolder(
    ProjectDocument document,
    String folderPath,
  ) {
    return Future.error(
      UnsupportedError('Resource folders are not available on the web yet.'),
    );
  }

  Future<ProjectDocument> savePrefab(
    ProjectDocument document, {
    required String name,
    required ProjectSceneObject object,
  }) {
    return Future.error(
      UnsupportedError('Prefab editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deletePrefab(
    ProjectDocument document,
    ProjectPrefab prefab,
  ) {
    return Future.error(
      UnsupportedError('Prefab editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> createDialogue(ProjectDocument document, String id) {
    return Future.error(
      UnsupportedError('Dialogue editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> saveDialogue(
    ProjectDocument document,
    ProjectDialogue dialogue,
  ) {
    return Future.error(
      UnsupportedError('Dialogue editing is not available on the web yet.'),
    );
  }

  Future<ProjectDocument> deleteDialogue(
    ProjectDocument document,
    ProjectDialogue dialogue,
  ) {
    return Future.error(
      UnsupportedError('Dialogue editing is not available on the web yet.'),
    );
  }
}
