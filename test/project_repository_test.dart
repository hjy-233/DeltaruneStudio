import 'dart:io';

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
}
