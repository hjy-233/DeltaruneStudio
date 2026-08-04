import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'move node touching trigger point schedules trigger sound immediately',
    () {
      const characterObjectId = 'object_kris';
      const triggerId = 'trigger_area';
      const soundChainId = 'chain_sound';
      const soundEventId = 'event_sound';
      final scene = Scene(
        id: 'scene_main',
        name: 'Main Canvas',
        objects: const [
          SceneObject.characterInstance(
            id: characterObjectId,
            name: 'Kris',
            characterId: 'character_kris',
            transform: Transform2D(x: 0, y: 0),
            facing: Direction.right,
          ),
          SceneObject.triggerPoint(
            id: 'object_trigger_point',
            name: 'Trigger Point',
            triggerId: triggerId,
            transform: Transform2D(x: 8, y: -4, width: 8, height: 8),
          ),
        ],
        triggers: const [
          Trigger.area(
            id: triggerId,
            name: 'Trigger Point',
            eventChainId: soundChainId,
          ),
        ],
        eventChains: const [
          EventChain(
            id: 'chain_walk',
            name: 'Walk',
            events: [
              StudioEvent.characterMove(
                id: 'event_walk',
                characterObjectId: characterObjectId,
                path: MovementPath(
                  speed: 10,
                  nodes: [
                    PathNode(id: 'node_start', x: 0, y: 0),
                    PathNode(id: 'node_trigger', x: 10, y: 0),
                  ],
                ),
              ),
            ],
          ),
          EventChain(
            id: soundChainId,
            name: 'Sound',
            events: [
              StudioEvent.audioPlaySound(
                id: soundEventId,
                assetId: 'asset_sound',
              ),
            ],
          ),
        ],
        interestPoints: const [],
        cameraPolicy: const CameraPolicy.followPlayer(
          playerObjectId: characterObjectId,
        ),
      );
      final project = StudioProject(
        schemaVersion: 1,
        id: 'project_test',
        name: 'Test',
        currentSceneId: scene.id,
        scenes: [scene],
        characters: const [
          Character(
            id: 'character_kris',
            name: 'Kris',
            animations: [],
            expressions: [],
            movement: CharacterMovementProfile(),
          ),
        ],
        assets: const [
          AssetRef(
            id: 'asset_sound',
            kind: AssetKind.audio,
            relativePath: 'assets/audio/sound.wav',
            originalName: 'sound.wav',
          ),
        ],
      );

      final plan = TimelinePlan(project: project, scene: scene, chain: null);

      expect(plan.audioCues, hasLength(1));
      expect(plan.audioCues.single.event, isA<AudioPlaySoundEvent>());
      expect(plan.audioCues.single.event.eventId, soundEventId);
      expect(plan.audioCues.single.time, closeTo(1, 0.001));
    },
  );
}
