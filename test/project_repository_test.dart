import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/project_repository.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('migrates v1 trigger areas to unlocked trigger points', () {
    final raw =
        jsonDecode('''
{
  "schemaVersion": 1,
  "id": "project_old",
  "name": "Old",
  "currentSceneId": "scene_main",
  "scenes": [
    {
      "id": "scene_main",
      "name": "Main Canvas",
      "objects": [
        {
          "type": "triggerArea",
          "id": "object_trigger",
          "name": "Door",
          "triggerId": "trigger_door",
          "transform": {"x": 10, "y": 20, "width": 100, "height": 50, "scale": 1, "rotation": 0}
        },
        {
          "type": "characterInstance",
          "id": "object_kris",
          "name": "Kris",
          "characterId": "character_kris",
          "transform": {"x": 0, "y": 0, "width": 48, "height": 64, "scale": 1, "rotation": 0},
          "facing": "down"
        }
      ],
      "triggers": [
        {"type": "area", "id": "trigger_door", "name": "Door", "eventChainId": "chain_door"}
      ],
      "eventChains": [
        {"id": "chain_door", "name": "Door", "events": []}
      ],
      "interestPoints": [],
      "cameraPolicy": {"type": "followPlayer", "playerObjectId": "object_kris"}
    }
  ],
  "characters": [
    {"id": "character_kris", "name": "Kris", "animations": [], "expressions": [], "movement": {}}
  ],
  "assets": []
}
''')
            as Map<String, dynamic>;

    final migrated = ProjectRepository().migrateProjectForOpen(
      StudioProject.fromJson(raw),
    );

    expect(migrated.schemaVersion, 4);
    expect(migrated.editorLayout.leftSidebarWidth, 220);
    expect(migrated.editorLayout.rightSidebarWidth, 280);
    expect(migrated.editorLayout.bottomPanelHeight, 300);
    expect(migrated.settings.language, AppLanguage.system);
    expect(migrated.settings.englishDialogueTypewriterByWord, isTrue);
    expect(
      migrated.scenes.single.eventChains.single.triggerMode,
      EventChainTriggerMode.triggerPoint,
    );
    final triggerObject = migrated.scenes.single.objects.first;
    expect(triggerObject, isA<TriggerPointObject>());
    expect(triggerObject.objectTransform.width, 22);
    expect(triggerObject.objectTransform.height, 22);
    expect(
      triggerObject.map(
        characterInstance: (value) => value.locked,
        prop: (value) => value.locked,
        background: (value) => value.locked,
        triggerPoint: (value) => value.locked,
        triggerArea: (value) => value.locked,
      ),
      isFalse,
    );
    final character = migrated.scenes.single.objects.last;
    expect(
      character.map(
        characterInstance: (value) => value.locked,
        prop: (value) => value.locked,
        background: (value) => value.locked,
        triggerPoint: (value) => value.locked,
        triggerArea: (value) => value.locked,
      ),
      isFalse,
    );
  });

  test('migrates character events away from non-character object ids', () {
    final project = StudioProject(
      id: 'project_bad_move',
      name: 'Bad Move',
      currentSceneId: 'scene_main',
      scenes: const [
        Scene(
          id: 'scene_main',
          name: 'Main Canvas',
          objects: [
            SceneObject.background(
              id: 'object_room',
              name: 'Room',
              assetId: 'asset_room',
              transform: Transform2D(x: 0, y: 0, width: 640, height: 480),
            ),
            SceneObject.characterInstance(
              id: 'object_ralsei',
              name: 'Ralsei',
              characterId: 'character_ralsei',
              transform: Transform2D(x: 120, y: 180),
              facing: Direction.down,
            ),
          ],
          triggers: [],
          eventChains: [
            EventChain(
              id: 'chain_move',
              name: 'Move',
              events: [
                StudioEvent.characterMove(
                  id: 'event_move',
                  characterObjectId: 'object_room',
                  path: MovementPath(
                    nodes: [
                      PathNode(id: 'node_start', x: 0, y: 0),
                      PathNode(id: 'node_end', x: 100, y: 0),
                    ],
                  ),
                ),
              ],
            ),
          ],
          interestPoints: [],
          cameraPolicy: CameraPolicy.focus(
            target: FocusTarget.point(x: 0, y: 0),
          ),
        ),
      ],
      characters: const [],
      assets: const [],
    );

    final migrated = ProjectRepository().migrateProjectForOpen(project);
    final event = migrated.scenes.single.eventChains.single.events.single;

    expect(event, isA<CharacterMoveEvent>());
    expect((event as CharacterMoveEvent).characterObjectId, 'object_ralsei');
  });

  test('video event serializes and contributes timeline duration', () {
    const video = StudioEvent.videoPlay(
      id: 'event_video',
      assetId: 'asset_video',
      duration: 4.5,
    );
    final decoded = StudioEvent.fromJson(video.toJson());
    expect(decoded, isA<VideoPlayEvent>());
    expect((decoded as VideoPlayEvent).duration, 4.5);

    final scene = Scene(
      id: 'scene_main',
      name: 'Main Canvas',
      objects: const [],
      triggers: const [],
      eventChains: const [
        EventChain(id: 'chain_main', name: 'Main', events: [video]),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.focus(
        target: FocusTarget.point(x: 0, y: 0),
      ),
    );
    final project = StudioProject(
      id: 'project_test',
      name: 'Test',
      currentSceneId: scene.id,
      scenes: [scene],
      characters: const [],
      assets: const [
        AssetRef(
          id: 'asset_video',
          kind: AssetKind.video,
          relativePath: 'assets/video/test.mp4',
          originalName: 'test.mp4',
        ),
      ],
    );
    final plan = TimelinePlan(project: project, scene: scene, chain: null);
    expect(plan.duration, closeTo(4.5, 0.001));
    expect(plan.evaluate(1).activeVideo?.assetId, 'asset_video');
  });

  test('asset byte import can preserve a known asset id', () async {
    final directory = await Directory.systemTemp.createTemp('drs_repo_test_');
    addTearDown(() async {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    });

    final asset = await ProjectRepository().importAssetBytes(
      projectDirectory: directory,
      bytes: [1, 2, 3],
      kind: AssetKind.character,
      originalName: 'kris.png',
      id: 'asset_kris',
    );

    expect(asset.id, 'asset_kris');
    expect(asset.relativePath, contains('asset_kris_kris.png'));
    expect(
      await File('${directory.path}/${asset.relativePath}').exists(),
      isTrue,
    );
  });
}
