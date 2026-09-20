import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';

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
      formatVersion: 2,
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
      resourceFolders: const [
        'resources/backgrounds',
        'resources/characters',
        'resources/portraits',
        'resources/audio',
        'resources/video',
        'resources/props',
      ],
      characters: const [],
    );
    await _writeProjectFiles(document);
    await _ensureEntryScript(document);
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
      resourceFolders: await _readResourceFolders(projectDirectory),
      characters: await _readCharacters(projectDirectory),
    );
  }

  Future<void> save(ProjectDocument document) {
    return _writeProjectFiles(document);
  }

  Future<ProjectDocument> importAsset(
    ProjectDocument document, {
    required String sourcePath,
    required String type,
    String? destinationPath,
  }) async {
    const supportedTypes = {
      'backgrounds',
      'characters',
      'portraits',
      'props',
      'audio',
      'video',
    };
    if (!supportedTypes.contains(type)) {
      throw ArgumentError.value(type, 'type', 'Unsupported resource folder');
    }
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Resource file was not found: $sourcePath');
    }
    final targetDirectory = _resourceDirectory(
      document,
      destinationPath ?? p.join('resources', type),
    );
    final relativeTargetDirectory = p.relative(
      targetDirectory.path,
      from: document.path,
    );
    final targetParts = p.split(relativeTargetDirectory);
    if (targetParts.length < 2 || targetParts[1] != type) {
      throw ArgumentError.value(
        destinationPath,
        'destinationPath',
        'Destination must be inside resources/$type',
      );
    }
    await targetDirectory.create(recursive: true);
    final fileName = await _availableFileName(
      targetDirectory,
      p.basename(source.path),
    );
    final target = File(p.join(targetDirectory.path, fileName));
    if (p.normalize(source.path) != p.normalize(target.path)) {
      await source.copy(target.path);
    }
    return document.copyWith(
      assets: await _readAssets(Directory(document.path)),
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
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

  Future<ProjectDocument> addCharacter(
    ProjectDocument document,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Character name cannot be empty.');
    }
    final id = _identifier(trimmed);
    final characterPath = p.join('characters', id, 'character.json');
    if (document.characters.any((item) => item.path == characterPath)) {
      throw StateError('Character already exists: $id');
    }
    final animations = ['up', 'down', 'left', 'right']
        .map(
          (direction) => ProjectCharacterAnimation(
            id: 'walk_$direction',
            name: 'walk',
            direction: direction,
          ),
        )
        .toList(growable: false);
    final character = ProjectCharacterFile(
      path: characterPath,
      definition: ProjectCharacterDefinition(
        id: id,
        name: trimmed,
        animations: animations,
      ),
    );
    final updated = document.copyWith(
      characters: [...document.characters, character],
    );
    await _writeCharacter(document.path, character);
    return updated;
  }

  Future<ProjectDocument> saveCharacter(
    ProjectDocument document,
    ProjectCharacterFile character,
  ) async {
    if (!document.characters.any((item) => item.path == character.path)) {
      throw StateError('Character was not found: ${character.path}');
    }
    final updated = document.copyWith(
      characters: document.characters
          .map((item) => item.path == character.path ? character : item)
          .toList(growable: false),
    );
    await _writeCharacter(document.path, character);
    return updated;
  }

  Future<ProjectDocument> deleteCharacter(
    ProjectDocument document,
    ProjectCharacterFile character,
  ) async {
    for (final room in document.rooms) {
      if (room.scene.objects.any(
        (object) => object.characterPath == character.path,
      )) {
        throw StateError('Character is in use by room: ${room.scene.name}');
      }
    }
    final file = File(p.join(document.path, character.path));
    if (await file.exists()) {
      await file.delete();
    }
    if (await file.parent.exists() &&
        await file.parent.list(followLinks: false).isEmpty) {
      await file.parent.delete();
    }
    return document.copyWith(
      characters: document.characters
          .where((item) => item.path != character.path)
          .toList(growable: false),
    );
  }

  Future<ProjectDocument> renameRoom(
    ProjectDocument document,
    String roomPath,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Room name cannot be empty.');
    }
    final room = document.rooms.firstWhere(
      (item) => item.path == roomPath,
      orElse: () => throw StateError('Room was not found: $roomPath'),
    );
    final updatedRoom = room.copyWith(
      scene: room.scene.copyWith(name: trimmed),
    );
    final updated = document.copyWith(
      mainScene: roomPath == document.manifest.mainScene
          ? updatedRoom.scene
          : document.mainScene,
      rooms: document.rooms
          .map((item) => item.path == roomPath ? updatedRoom : item)
          .toList(growable: false),
    );
    await _writeProjectFiles(updated);
    return updated;
  }

  Future<ProjectDocument> deleteRoom(
    ProjectDocument document,
    String roomPath,
  ) async {
    if (roomPath == document.manifest.mainScene) {
      throw StateError('The main room cannot be deleted.');
    }
    if (!document.rooms.any((item) => item.path == roomPath)) {
      throw StateError('Room was not found: $roomPath');
    }
    for (final room in document.rooms) {
      if (room.scene.objects.any(
        (object) => object.type == 'door' && object.targetRoomPath == roomPath,
      )) {
        throw StateError('Room is connected from: ${room.scene.name}');
      }
    }
    final roomFile = File(p.join(document.path, roomPath));
    if (await roomFile.exists()) {
      await roomFile.delete();
    }
    final updatedRooms = document.rooms
        .where((item) => item.path != roomPath)
        .toList(growable: false);
    final updated = document.copyWith(
      manifest: document.manifest.copyWith(
        rooms: updatedRooms.map((item) => item.path).toList(growable: false),
      ),
      rooms: updatedRooms,
    );
    await _writeProjectFiles(updated);
    return updated;
  }

  Future<ProjectDocument> renameAsset(
    ProjectDocument document,
    ProjectAsset asset,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || p.basename(trimmed) != trimmed) {
      throw const FormatException('Resource name is invalid.');
    }
    final source = File(p.join(document.path, asset.path));
    if (!await source.exists()) {
      throw StateError('Resource was not found: ${asset.path}');
    }
    final target = File(p.join(source.parent.path, trimmed));
    if (p.normalize(source.path) != p.normalize(target.path) &&
        await target.exists()) {
      throw StateError('A resource with that name already exists.');
    }
    await source.rename(target.path);
    final targetPath = p.relative(target.path, from: document.path);
    final updated = _mapAssetReferences(
      document,
      (path) => path == asset.path ? targetPath : path,
    );
    final result = updated.copyWith(
      assets: await _readAssets(Directory(document.path)),
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
    await _writeProjectFiles(result);
    return result;
  }

  Future<ProjectDocument> deleteAsset(
    ProjectDocument document,
    ProjectAsset asset,
  ) async {
    for (final character in document.characters) {
      if (character.definition.animations.any(
        (animation) => animation.frames.contains(asset.path),
      )) {
        throw StateError(
          'Resource is in use by character: ${character.definition.name}',
        );
      }
    }
    for (final room in document.rooms) {
      if (room.scene.background == asset.path ||
          room.scene.objects.any((object) => object.asset == asset.path)) {
        throw StateError('Resource is in use by room: ${room.scene.name}');
      }
    }
    final file = File(p.join(document.path, asset.path));
    if (await file.exists()) {
      await file.delete();
    }
    return document.copyWith(
      assets: await _readAssets(Directory(document.path)),
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
  }

  Future<ProjectDocument> createResourceFolder(
    ProjectDocument document,
    String parentPath,
    String name,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || p.basename(trimmed) != trimmed) {
      throw const FormatException('Folder name is invalid.');
    }
    final parent = _resourceDirectory(document, parentPath);
    if (!await parent.exists()) {
      throw StateError('Resource folder was not found: $parentPath');
    }
    await Directory(p.join(parent.path, _slugify(trimmed))).create();
    return document.copyWith(
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
  }

  Future<ProjectDocument> renameResourceFolder(
    ProjectDocument document,
    String folderPath,
    String name,
  ) async {
    _requireNestedResourceFolder(folderPath);
    final trimmed = name.trim();
    if (trimmed.isEmpty || p.basename(trimmed) != trimmed) {
      throw const FormatException('Folder name is invalid.');
    }
    final source = _resourceDirectory(document, folderPath);
    if (!await source.exists()) {
      throw StateError('Resource folder was not found: $folderPath');
    }
    final target = Directory(p.join(source.parent.path, _slugify(trimmed)));
    if (p.normalize(source.path) != p.normalize(target.path) &&
        await target.exists()) {
      throw StateError('A folder with that name already exists.');
    }
    await source.rename(target.path);
    final targetPath = p.relative(target.path, from: document.path);
    final normalizedSource = p.normalize(folderPath);
    final updated = _mapAssetReferences(document, (path) {
      final normalizedPath = p.normalize(path);
      if (!p.isWithin(normalizedSource, normalizedPath)) {
        return path;
      }
      return p.join(
        targetPath,
        p.relative(normalizedPath, from: normalizedSource),
      );
    });
    final result = updated.copyWith(
      assets: await _readAssets(Directory(document.path)),
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
    await _writeProjectFiles(result);
    return result;
  }

  Future<ProjectDocument> deleteResourceFolder(
    ProjectDocument document,
    String folderPath,
  ) async {
    _requireNestedResourceFolder(folderPath);
    final folder = _resourceDirectory(document, folderPath);
    if (!await folder.exists()) {
      return document;
    }
    if (!await folder.list(followLinks: false).isEmpty) {
      throw StateError('Only empty resource folders can be deleted.');
    }
    await folder.delete();
    return document.copyWith(
      resourceFolders: await _readResourceFolders(Directory(document.path)),
    );
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

  Future<void> _ensureEntryScript(ProjectDocument document) async {
    final file = File(p.join(document.path, document.manifest.entryScript));
    if (await file.exists()) {
      return;
    }
    await file.parent.create(recursive: true);
    await file.writeAsString(
      'extends Node\n\n'
      '# Called automatically after the first room is ready.\n'
      'func run() -> void:\n'
      '\treturn\n',
    );
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
    for (final character in document.characters) {
      await _writeCharacter(document.path, character);
    }
  }

  Future<void> _writeCharacter(
    String projectPath,
    ProjectCharacterFile character,
  ) {
    return _writeJson(
      File(p.join(projectPath, character.path)),
      character.definition.toJson(),
    );
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
      if (parts.any((part) => part.startsWith('.') || part == '__MACOSX')) {
        continue;
      }
      final type = parts.length > 1 ? parts[1] : 'other';
      assets.add(
        ProjectAsset(path: relative, name: p.basename(entity.path), type: type),
      );
    }
    assets.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return assets;
  }

  Future<List<String>> _readResourceFolders(Directory root) async {
    final resources = Directory(p.join(root.path, 'resources'));
    if (!await resources.exists()) {
      return const [];
    }
    final folders = <String>[];
    await for (final entity in resources.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! Directory) {
        continue;
      }
      final relative = p.relative(entity.path, from: root.path);
      final parts = p.split(relative);
      if (parts.any((part) => part.startsWith('.') || part == '__MACOSX')) {
        continue;
      }
      folders.add(relative);
    }
    folders.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return folders;
  }

  Future<List<ProjectCharacterFile>> _readCharacters(Directory root) async {
    final directory = Directory(p.join(root.path, 'characters'));
    if (!await directory.exists()) {
      return const [];
    }
    final characters = <ProjectCharacterFile>[];
    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File || p.basename(entity.path) != 'character.json') {
        continue;
      }
      final relative = p.relative(entity.path, from: root.path);
      final json = jsonDecode(await entity.readAsString());
      if (json is! Map<String, dynamic>) {
        continue;
      }
      characters.add(
        ProjectCharacterFile(
          path: relative,
          definition: ProjectCharacterDefinition.fromJson(json),
        ),
      );
    }
    characters.sort(
      (a, b) => a.definition.name.toLowerCase().compareTo(
        b.definition.name.toLowerCase(),
      ),
    );
    return characters;
  }

  Directory _resourceDirectory(ProjectDocument document, String relativePath) {
    final root = p.normalize(p.join(document.path, 'resources'));
    final resolved = p.normalize(p.join(document.path, relativePath));
    if (resolved != root && !p.isWithin(root, resolved)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'Path must be inside the project resources directory',
      );
    }
    return Directory(resolved);
  }

  void _requireNestedResourceFolder(String folderPath) {
    if (p.split(p.normalize(folderPath)).length <= 2) {
      throw StateError('Built-in resource folders cannot be changed.');
    }
  }

  ProjectDocument _mapAssetReferences(
    ProjectDocument document,
    String Function(String path) transform,
  ) {
    ProjectScene updateScene(ProjectScene scene) {
      return scene.copyWith(
        background: scene.background == null
            ? null
            : transform(scene.background!),
        objects: scene.objects
            .map((object) => object.copyWith(asset: transform(object.asset)))
            .toList(growable: false),
      );
    }

    final mainScene = updateScene(document.mainScene);
    final rooms = document.rooms
        .map(
          (room) => room.copyWith(
            scene: room.path == document.manifest.mainScene
                ? mainScene
                : updateScene(room.scene),
          ),
        )
        .toList(growable: false);
    final characters = document.characters
        .map(
          (character) => character.copyWith(
            definition: character.definition.copyWith(
              animations: character.definition.animations
                  .map(
                    (animation) => animation.copyWith(
                      frames: animation.frames
                          .map(transform)
                          .toList(growable: false),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        )
        .toList(growable: false);
    return document.copyWith(
      mainScene: mainScene,
      rooms: rooms,
      characters: characters,
    );
  }

  Future<void> _writeJson(File file, Map<String, dynamic> json) async {
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      const JsonEncoder.withIndent('  ').convert(json),
    );
    if (await file.exists()) {
      await file.delete();
    }
    await temporary.rename(file.path);
  }

  Future<String> _availableFileName(Directory directory, String name) async {
    final extension = p.extension(name);
    final stem = p.basenameWithoutExtension(name);
    var candidate = name;
    var index = 2;
    while (await File(p.join(directory.path, candidate)).exists()) {
      candidate = '$stem ($index)$extension';
      index += 1;
    }
    return candidate;
  }

  String _slugify(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_');
    return normalized.trim().isEmpty ? 'project' : normalized.trim();
  }

  String _identifier(String value) {
    final slug = _slugify(value).replaceAll(RegExp(r'\s+'), '_').toLowerCase();
    return slug.isEmpty ? 'character' : slug;
  }
}
