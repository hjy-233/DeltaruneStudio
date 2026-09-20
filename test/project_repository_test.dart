import 'dart:io';

import 'package:deltarune_studio/data/project_repository.dart';
import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:deltarune_studio/domain/project_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('creates and reopens a human-readable project folder', () async {
    final parent = await Directory.systemTemp.createTemp('drs_step1_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();

    final created = await repository.create(
      parentPath: parent.path,
      name: '教堂暗世界',
    );

    expect(p.basename(created.path), '教堂暗世界');
    expect(await File(p.join(created.path, 'project.json')).exists(), isTrue);
    expect(
      await File(p.join(created.path, 'scenes/main/scene.json')).exists(),
      isTrue,
    );
    expect(
      await Directory(p.join(created.path, 'resources/characters')).exists(),
      isTrue,
    );
    expect(created.manifest.formatVersion, 2);
    expect(created.manifest.entryScript, 'scripts/manual/main.gd');
    expect(
      await File(p.join(created.path, 'scripts/manual/main.gd')).exists(),
      isTrue,
    );

    final reopened = await repository.open(created.path);
    expect(reopened.manifest.name, '教堂暗世界');
    expect(reopened.manifest.mainScene, 'scenes/main/scene.json');
    expect(reopened.manifest.entryScript, 'scripts/manual/main.gd');
    expect(reopened.mainScene.id, 'main');
  });

  test('preserves scene objects when saving and reopening', () async {
    final parent = await Directory.systemTemp.createTemp('drs_scene_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Object Test',
    );
    final object = const ProjectSceneObject(
      id: 'kris',
      type: 'character',
      name: 'Kris',
      asset: 'resources/characters/kris.svg',
      x: 320,
      y: 340,
      zIndex: 10,
    );
    final updated = ProjectDocument(
      manifest: created.manifest,
      mainScene: ProjectScene(
        id: created.mainScene.id,
        name: created.mainScene.name,
        background: 'resources/backgrounds/atrium.svg',
        objects: [object],
      ),
      path: created.path,
    );

    await repository.save(updated);
    final reopened = await repository.open(created.path);

    expect(reopened.mainScene.background, 'resources/backgrounds/atrium.svg');
    expect(reopened.mainScene.objects.single.asset, object.asset);
    expect(reopened.mainScene.objects.single.x, 320);
  });

  test('persists game and export settings', () async {
    final parent = await Directory.systemTemp.createTemp('drs_settings_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Settings Test',
    );
    final updated = created.copyWith(
      manifest: created.manifest.copyWith(
        gameSettings: const ProjectGameSettings(
          viewportWidth: 320,
          viewportHeight: 240,
          windowWidth: 1280,
          windowHeight: 960,
          startFullscreen: true,
          enableWasd: false,
        ),
        exportSettings: const ProjectExportSettings(
          bundleIdentifier: 'studio.deltarune.test',
          version: '2.3.0',
          defaultTarget: 'linux',
          outputDirectory: '/tmp/exports',
        ),
      ),
    );

    await repository.save(updated);
    final reopened = await repository.open(created.path);

    expect(reopened.manifest.gameSettings.viewportWidth, 320);
    expect(reopened.manifest.gameSettings.startFullscreen, isTrue);
    expect(reopened.manifest.gameSettings.enableWasd, isFalse);
    expect(
      reopened.manifest.exportSettings.bundleIdentifier,
      'studio.deltarune.test',
    );
    expect(reopened.manifest.exportSettings.defaultTarget, 'linux');
  });

  test('renaming a resource updates scene references', () async {
    final parent = await Directory.systemTemp.createTemp('drs_resource_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Resource Test',
    );
    const oldPath = 'resources/characters/kris.png';
    const newPath = 'resources/characters/kris_idle.png';
    await File(p.join(created.path, oldPath)).writeAsBytes([1, 2, 3]);
    final object = const ProjectSceneObject(
      id: 'kris',
      type: 'character',
      name: 'Kris',
      asset: oldPath,
      x: 0,
      y: 0,
      zIndex: 0,
    );
    final document = created.copyWith(
      mainScene: created.mainScene.copyWith(
        background: oldPath,
        objects: [object],
      ),
      assets: [
        const ProjectAsset(path: oldPath, name: 'kris.png', type: 'characters'),
      ],
    );

    final renamed = await repository.renameAsset(
      document,
      document.assets.single,
      'kris_idle.png',
    );

    expect(await File(p.join(created.path, newPath)).exists(), isTrue);
    expect(renamed.mainScene.background, newPath);
    expect(renamed.mainScene.objects.single.asset, newPath);
    final reopened = await repository.open(created.path);
    expect(reopened.mainScene.background, newPath);
    expect(reopened.mainScene.objects.single.asset, newPath);
  });

  test('creates, renames, and deletes empty resource folders', () async {
    final parent = await Directory.systemTemp.createTemp('drs_folder_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Folder Test',
    );

    final withFolder = await repository.createResourceFolder(
      created,
      'resources/characters',
      'Kris Frames',
    );

    expect(
      await Directory(
        p.join(created.path, 'resources/characters/Kris Frames'),
      ).exists(),
      isTrue,
    );
    expect(
      withFolder.resourceFolders,
      contains('resources/characters/Kris Frames'),
    );

    final renamed = await repository.renameResourceFolder(
      withFolder,
      'resources/characters/Kris Frames',
      'Heroes',
    );
    expect(
      await Directory(
        p.join(created.path, 'resources/characters/Heroes'),
      ).exists(),
      isTrue,
    );
    expect(renamed.resourceFolders, contains('resources/characters/Heroes'));

    final deleted = await repository.deleteResourceFolder(
      renamed,
      'resources/characters/Heroes',
    );
    expect(
      await Directory(
        p.join(created.path, 'resources/characters/Heroes'),
      ).exists(),
      isFalse,
    );
    expect(
      deleted.resourceFolders,
      isNot(contains('resources/characters/Heroes')),
    );
  });

  test('renaming a resource folder updates persisted references', () async {
    final parent = await Directory.systemTemp.createTemp('drs_folder_ref_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Folder Reference Test',
    );
    final withFolder = await repository.createResourceFolder(
      created,
      'resources/characters',
      'Kris',
    );
    const oldPath = 'resources/characters/Kris/idle.png';
    await File(p.join(created.path, oldPath)).writeAsBytes([1, 2, 3]);
    final document = withFolder.copyWith(
      mainScene: withFolder.mainScene.copyWith(
        objects: const [
          ProjectSceneObject(
            id: 'kris',
            type: 'character',
            name: 'Kris',
            asset: oldPath,
            x: 0,
            y: 0,
            zIndex: 0,
          ),
        ],
      ),
    );

    final renamed = await repository.renameResourceFolder(
      document,
      'resources/characters/Kris',
      'Heroes',
    );

    const newPath = 'resources/characters/Heroes/idle.png';
    expect(renamed.mainScene.objects.single.asset, newPath);
    expect(await File(p.join(created.path, newPath)).exists(), isTrue);
    final reopened = await repository.open(created.path);
    expect(reopened.mainScene.objects.single.asset, newPath);
  });

  test(
    'persists human-readable character definitions and references',
    () async {
      final parent = await Directory.systemTemp.createTemp('drs_character_');
      addTearDown(() => parent.delete(recursive: true));
      final repository = ProjectRepository();
      var document = await repository.create(
        parentPath: parent.path,
        name: 'Character Test',
      );
      document = await repository.addCharacter(document, 'Kris');
      final character = document.characters.single;
      final edited = character.copyWith(
        definition: character.definition.copyWith(
          defaultWidth: 40,
          defaultHeight: 56,
          moveSpeed: 192,
          collision: const ProjectCollisionBox(
            x: -9,
            y: 10,
            width: 18,
            height: 14,
          ),
          animations: [
            const ProjectCharacterAnimation(
              id: 'walk_down',
              name: 'walk',
              direction: 'down',
              fps: 6,
              frames: ['resources/characters/kris_down_0.png'],
            ),
          ],
        ),
      );
      document = await repository.saveCharacter(document, edited);
      final scene = document.mainScene.copyWith(
        objects: [
          ProjectSceneObject(
            id: 'kris',
            type: 'character',
            name: 'Kris',
            asset: '',
            characterPath: edited.path,
            x: 320,
            y: 240,
            zIndex: 1,
          ),
        ],
      );
      document = document.copyWith(
        mainScene: scene,
        rooms: [ProjectRoom(path: document.manifest.mainScene, scene: scene)],
      );
      await repository.save(document);

      final config = await File(
        p.join(document.path, edited.path),
      ).readAsString();
      expect(config, contains('"moveSpeed": 192.0'));
      expect(config, contains('"walk_down"'));

      final reopened = await repository.open(document.path);
      expect(reopened.characters.single.definition.defaultWidth, 40);
      expect(reopened.characters.single.definition.collision.height, 14);
      expect(reopened.characters.single.definition.animations.single.fps, 6);
      expect(reopened.mainScene.objects.single.characterPath, edited.path);
    },
  );

  test('renaming a character frame updates its definition', () async {
    final parent = await Directory.systemTemp.createTemp('drs_character_ref_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    var document = await repository.create(
      parentPath: parent.path,
      name: 'Character Frame Test',
    );
    document = await repository.addCharacter(document, 'Susie');
    const oldPath = 'resources/characters/susie_down.png';
    await File(p.join(document.path, oldPath)).writeAsBytes([1, 2, 3]);
    final character = document.characters.single;
    document = await repository.saveCharacter(
      document.copyWith(
        assets: const [
          ProjectAsset(
            path: oldPath,
            name: 'susie_down.png',
            type: 'characters',
          ),
        ],
      ),
      character.copyWith(
        definition: character.definition.copyWith(
          animations: const [
            ProjectCharacterAnimation(
              id: 'walk_down',
              name: 'walk',
              direction: 'down',
              frames: [oldPath],
            ),
          ],
        ),
      ),
    );

    final renamed = await repository.renameAsset(
      document,
      document.assets.single,
      'susie_idle.png',
    );

    expect(
      renamed.characters.single.definition.animations.single.frames.single,
      'resources/characters/susie_idle.png',
    );
    final reopened = await repository.open(document.path);
    expect(
      reopened.characters.single.definition.animations.single.frames.single,
      'resources/characters/susie_idle.png',
    );
  });

  test('persists room layers, collisions, spawn points, and doors', () async {
    final parent = await Directory.systemTemp.createTemp('drs_room_data_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    var document = await repository.create(
      parentPath: parent.path,
      name: 'Room Data Test',
    );
    document = await repository.addRoom(document, 'Hall');
    final hall = document.rooms.last;
    final mainScene = document.mainScene.copyWith(
      layers: const [
        ProjectSceneLayer(id: 'floor', name: 'Floor', order: 0),
        ProjectSceneLayer(id: 'actors', name: 'Actors', order: 1),
      ],
      objects: [
        const ProjectSceneObject(
          id: 'wall',
          type: 'collision',
          name: 'North wall',
          asset: '',
          x: 0,
          y: 0,
          zIndex: 0,
          width: 640,
          height: 32,
          layerId: 'floor',
        ),
        const ProjectSceneObject(
          id: 'entry',
          type: 'spawn',
          name: 'Entry',
          asset: '',
          x: 320,
          y: 400,
          zIndex: 1,
          layerId: 'actors',
          facing: 'up',
          defaultSpawn: true,
        ),
        ProjectSceneObject(
          id: 'hall_door',
          type: 'door',
          name: 'Hall Door',
          asset: '',
          x: 300,
          y: 0,
          zIndex: 2,
          width: 40,
          height: 32,
          layerId: 'actors',
          targetRoomPath: hall.path,
          targetSpawnId: 'hall_entry',
          transitionColor: '#FF201040',
          fadeOutSeconds: 0.3,
          fadeInSeconds: 0.4,
        ),
        const ProjectSceneObject(
          id: 'save_2',
          type: 'savePoint',
          name: 'Save Point',
          asset: '',
          x: 280,
          y: 360,
          zIndex: 3,
          width: 28,
          height: 28,
          layerId: 'actors',
          saveSlot: 2,
        ),
      ],
    );
    document = document.copyWith(
      mainScene: mainScene,
      rooms: document.rooms
          .map(
            (room) => room.path == document.manifest.mainScene
                ? room.copyWith(scene: mainScene)
                : room,
          )
          .toList(growable: false),
    );
    await repository.save(document);

    final reopened = await repository.open(document.path);
    expect(reopened.mainScene.layers.map((layer) => layer.id), [
      'floor',
      'actors',
    ]);
    expect(reopened.mainScene.objects[0].type, 'collision');
    expect(reopened.mainScene.objects[1].defaultSpawn, isTrue);
    expect(reopened.mainScene.objects[1].facing, 'up');
    expect(reopened.mainScene.objects[2].targetRoomPath, hall.path);
    expect(reopened.mainScene.objects[2].targetSpawnId, 'hall_entry');
    expect(reopened.mainScene.objects[2].transitionColor, '#FF201040');
    expect(reopened.mainScene.objects[2].fadeOutSeconds, 0.3);
    expect(reopened.mainScene.objects[2].fadeInSeconds, 0.4);
    expect(reopened.mainScene.objects[3].type, 'savePoint');
    expect(reopened.mainScene.objects[3].saveSlot, 2);
  });

  test('old rooms receive default layers', () {
    final scene = ProjectScene.fromJson(const {
      'id': 'legacy',
      'name': 'Legacy Room',
      'objects': <Map<String, dynamic>>[],
    });

    expect(scene.layers, hasLength(4));
    expect(scene.layers.first.id, 'background');
  });

  test('does not delete a room targeted by a door', () async {
    final parent = await Directory.systemTemp.createTemp('drs_door_ref_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    var document = await repository.create(
      parentPath: parent.path,
      name: 'Door Reference Test',
    );
    document = await repository.addRoom(document, 'Hall');
    final hall = document.rooms.last;
    final mainScene = document.mainScene.copyWith(
      objects: [
        ProjectSceneObject(
          id: 'hall_door',
          type: 'door',
          name: 'Hall Door',
          asset: '',
          x: 0,
          y: 0,
          zIndex: 0,
          targetRoomPath: hall.path,
        ),
      ],
    );
    document = document.copyWith(
      mainScene: mainScene,
      rooms: document.rooms
          .map(
            (room) => room.path == document.manifest.mainScene
                ? room.copyWith(scene: mainScene)
                : room,
          )
          .toList(growable: false),
    );

    expect(
      () => repository.deleteRoom(document, hall.path),
      throwsA(isA<StateError>()),
    );
  });
}
