import 'dart:convert';
import 'dart:io';

import 'project_manifest.dart';
import 'package:path/path.dart' as p;

class ProjectRepository {
  Future<ProjectDocument> create({
    required String parentPath,
    required String name,
  }) async {
    final folderName = _slugify(name);
    final projectDirectory = Directory(p.join(parentPath, folderName));
    if (await projectDirectory.exists()) {
      throw StateError(
        'Project folder already exists: ${projectDirectory.path}',
      );
    }
    await _createProjectDirectories(projectDirectory);
    final manifest = ProjectManifest(
      formatVersion: 1,
      id: folderName,
      name: name.trim(),
      mainScene: 'scenes/main/scene.json',
    );
    final scene = const ProjectScene(id: 'main', name: 'Main');
    final document = ProjectDocument(
      manifest: manifest,
      mainScene: scene,
      path: projectDirectory.path,
    );
    await _writeProjectFiles(document);
    return document;
  }

  Future<ProjectDocument> open(String path) async {
    final projectDirectory = Directory(path);
    final manifestFile = File(p.join(projectDirectory.path, 'project.json'));
    if (!await manifestFile.exists()) {
      throw const FormatException('project.json was not found.');
    }
    final manifest = ProjectManifest.fromJson(
      jsonDecode(await manifestFile.readAsString()) as Map<String, dynamic>,
    );
    final sceneFile = File(p.join(projectDirectory.path, manifest.mainScene));
    final scene = sceneFile.existsSync()
        ? ProjectScene.fromJson(
            jsonDecode(await sceneFile.readAsString()) as Map<String, dynamic>,
          )
        : const ProjectScene(id: 'main', name: 'Main');
    return ProjectDocument(
      manifest: manifest,
      mainScene: scene,
      path: projectDirectory.path,
    );
  }

  Future<void> save(ProjectDocument document) {
    return _writeProjectFiles(document);
  }

  Future<void> _createProjectDirectories(Directory root) async {
    for (final path in [
      'resources/backgrounds',
      'resources/characters',
      'resources/portraits',
      'resources/audio',
      'resources/video',
      'resources/props',
      'scenes/main',
      'characters',
      'scripts/manual',
      'scripts/generated',
      'visual_scripts',
      'settings',
      '.build/godot',
    ]) {
      await Directory(p.join(root.path, path)).create(recursive: true);
    }
  }

  Future<void> _writeProjectFiles(ProjectDocument document) async {
    final root = Directory(document.path);
    await _writeJson(
      File(p.join(root.path, 'project.json')),
      document.manifest.toJson(),
    );
    await _writeJson(
      File(p.join(root.path, document.manifest.mainScene)),
      document.mainScene.toJson(),
    );
  }

  Future<void> _writeJson(File file, Map<String, dynamic> json) async {
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
    );
    if (await file.exists()) {
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  String _slugify(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    return normalized.trim().isEmpty ? 'project' : normalized.trim();
  }
}
