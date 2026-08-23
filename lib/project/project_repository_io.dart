import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'project_manifest.dart';

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
      rooms: const ['scenes/main/scene.json'],
    );
    final scene = const ProjectScene(id: 'main', name: 'Main');
    final document = ProjectDocument(
      manifest: manifest,
      mainScene: scene,
      path: projectDirectory.path,
      rooms: [ProjectRoom(path: manifest.mainScene, scene: scene)],
      assets: const [],
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
    final roomPaths = manifest.rooms.isEmpty
        ? [manifest.mainScene]
        : manifest.rooms;
    final rooms = <ProjectRoom>[];
    for (final roomPath in roomPaths) {
      rooms.add(
        ProjectRoom(
          path: roomPath,
          scene: await _readScene(projectDirectory, roomPath),
        ),
      );
    }
    final scene = rooms
        .firstWhere(
          (room) => room.path == manifest.mainScene,
          orElse: () => rooms.first,
        )
        .scene;
    return ProjectDocument(
      manifest: manifest,
      mainScene: scene,
      path: projectDirectory.path,
      rooms: rooms,
      assets: await _readAssets(projectDirectory),
    );
  }

  Future<void> save(ProjectDocument document) {
    return _writeProjectFiles(document);
  }

  Future<ProjectDocument> addRoom(ProjectDocument document, String name) async {
    final roomId = _slugify(name).toLowerCase();
    final roomPath = 'scenes/$roomId/room.json';
    if (document.rooms.any((room) => room.path == roomPath)) {
      throw StateError('Room already exists: $roomId');
    }
    final room = ProjectRoom(
      path: roomPath,
      scene: ProjectScene(id: roomId, name: name.trim()),
    );
    await Directory(
      p.join(document.path, 'scenes', roomId),
    ).create(recursive: true);
    final existingRoomPaths = document.manifest.rooms.isEmpty
        ? [document.manifest.mainScene]
        : document.manifest.rooms;
    final updated = document.copyWith(
      manifest: document.manifest.copyWith(
        rooms: [...existingRoomPaths, roomPath],
      ),
      rooms: [...document.rooms, room],
    );
    await _writeProjectFiles(updated);
    return updated;
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
    for (final room in document.rooms) {
      if (room.path == document.manifest.mainScene) {
        continue;
      }
      await _writeJson(File(p.join(root.path, room.path)), room.scene.toJson());
    }
  }

  Future<ProjectScene> _readScene(Directory root, String roomPath) async {
    final file = File(p.join(root.path, roomPath));
    if (!await file.exists()) {
      return const ProjectScene(id: 'room', name: 'Room');
    }
    final json = jsonDecode(await file.readAsString());
    return ProjectScene.fromJson(json as Map<String, dynamic>);
  }

  Future<List<ProjectAsset>> _readAssets(Directory root) async {
    final resources = Directory(p.join(root.path, 'resources'));
    if (!await resources.exists()) {
      return const [];
    }
    final assets = <ProjectAsset>[];
    await for (final entity in resources.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) {
        continue;
      }
      final relative = p.relative(entity.path, from: root.path);
      final parts = p.split(relative);
      final type = parts.length > 1 ? parts[1] : 'other';
      assets.add(
        ProjectAsset(path: relative, name: p.basename(entity.path), type: type),
      );
    }
    assets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return assets;
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
