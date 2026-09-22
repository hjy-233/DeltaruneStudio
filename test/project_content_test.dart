import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:deltarune_studio/data/project_repository.dart';
import 'package:deltarune_studio/data/project_asset_geometry.dart';
import 'package:deltarune_studio/domain/project_character.dart';
import 'package:deltarune_studio/domain/project_content.dart';
import 'package:deltarune_studio/domain/project_manifest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('scene content fields survive a JSON round trip', () {
    const object = ProjectSceneObject(
      id: 'sign',
      type: 'prop',
      name: 'Sign',
      asset: 'resources/props/sign.png',
      x: 96,
      y: 128,
      zIndex: 2,
      collision: ProjectCollisionBox(x: -8, y: -12, width: 16, height: 24),
      interaction: ProjectInteraction(
        enabled: true,
        distance: 64,
        prompt: 'Read',
        functionName: 'read_sign',
        once: true,
      ),
    );
    const scene = ProjectScene(
      id: 'main',
      name: 'Main',
      objects: [object],
      tileMap: ProjectTileMap(
        tileWidth: 16,
        tileHeight: 16,
        cells: [
          ProjectTileCell(
            column: 2,
            row: 3,
            kind: 'wall',
            asset: 'resources/props/tile.png',
          ),
          ProjectTileCell(column: 2, row: 3, kind: 'collision'),
        ],
      ),
    );

    final reopened = ProjectScene.fromJson(scene.toJson());

    expect(reopened.tileMap.tileWidth, 16);
    expect(reopened.tileMap.cells, hasLength(2));
    expect(reopened.objects.single.collision?.height, 24);
    expect(reopened.objects.single.interaction.functionName, 'read_sign');
    expect(reopened.objects.single.interaction.once, isTrue);
  });

  test('prefabs and localized dialogues persist as readable files', () async {
    final parent = await Directory.systemTemp.createTemp('drs_content_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    var document = await repository.create(
      parentPath: parent.path,
      name: 'Content Test',
    );
    document = await repository.savePrefab(
      document,
      name: 'Reusable Sign',
      object: const ProjectSceneObject(
        id: 'source',
        type: 'prop',
        name: 'Sign',
        asset: 'resources/props/sign.png',
        x: 10,
        y: 20,
        zIndex: 1,
      ),
    );
    document = await repository.createDialogue(document, 'intro_01');
    final dialogue = document.dialogues.single.copyWith(
      style: 'dark',
      portrait: 'resources/portraits/ralsei.png',
      sound: 'resources/audio/text.wav',
      translations: const {'en': '* Hello.', 'zh': '* 你好。'},
    );
    document = await repository.saveDialogue(document, dialogue);

    final reopened = await repository.open(document.path);

    expect(reopened.prefabs.single.name, 'Reusable Sign');
    expect(reopened.dialogues.single.translations['zh'], '* 你好。');
    expect(
      await File(p.join(document.path, 'prefabs/reusable_sign.json')).exists(),
      isTrue,
    );
    expect(
      await File(p.join(document.path, 'dialogues/intro_01.json')).exists(),
      isTrue,
    );
  });

  test('opaque image pixels define the default prop collision', () async {
    final directory = await Directory.systemTemp.createTemp('drs_alpha_');
    addTearDown(() => directory.delete(recursive: true));
    final path = p.join(directory.path, 'alpha.png');
    await _writeOpaqueImage(path);

    final collision = await readOpaqueCollisionBox(path);

    expect(collision, isNotNull);
    expect(collision!.x, -2);
    expect(collision.y, -3);
    expect(collision.width, 3);
    expect(collision.height, 4);
  });

  test('opening a v2 scene adds and persists prop collisions', () async {
    final parent = await Directory.systemTemp.createTemp('drs_collision_');
    addTearDown(() => parent.delete(recursive: true));
    final repository = ProjectRepository();
    final created = await repository.create(
      parentPath: parent.path,
      name: 'Collision Migration',
    );
    const assetPath = 'resources/props/sign.png';
    await _writeOpaqueImage(p.join(created.path, assetPath));
    const oldScene = ProjectScene(
      formatVersion: 2,
      id: 'main',
      name: 'Main',
      objects: [
        ProjectSceneObject(
          id: 'sign',
          type: 'prop',
          name: 'Sign',
          asset: assetPath,
          x: 100,
          y: 100,
          zIndex: 1,
        ),
      ],
    );
    await repository.save(created.copyWith(mainScene: oldScene));

    final reopened = await repository.open(created.path);

    expect(reopened.mainScene.formatVersion, 3);
    expect(reopened.mainScene.objects.single.collision?.width, 3);
    expect(reopened.mainScene.objects.single.collision?.height, 4);
    final sceneFile = File(p.join(created.path, created.manifest.mainScene));
    final saved = jsonDecode(await sceneFile.readAsString());
    expect(saved['formatVersion'], 3);
    expect(saved['objects'][0]['collision']['width'], 3.0);
  });
}

Future<void> _writeOpaqueImage(String path) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(2, 1, 3, 4),
    Paint()..color = Colors.white,
  );
  final image = await recorder.endRecording().toImage(8, 8);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).parent.create(recursive: true);
  await File(path).writeAsBytes(bytes!.buffer.asUint8List());
  image.dispose();
}
