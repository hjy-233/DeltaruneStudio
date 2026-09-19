import 'dart:io';

import 'package:deltarune_studio/project/project_character.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/project/project_manifest.dart';
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

    final reopened = await repository.open(created.path);
    expect(reopened.manifest.name, '教堂暗世界');
    expect(reopened.manifest.mainScene, 'scenes/main/scene.json');
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
}
