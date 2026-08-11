import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/runtime/preview_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  _timelineTests();
  _dialogueTests();
  _followTests();
  _expressionTests();
}

void _timelineTests() {
  _moveTriggerTimelineTests();
  _videoTimelineTests();
  _trackPositionTests();
}

void _trackPositionTests() {
  test('trigger chain track starts when the path reaches its trigger', () {
    const characterObjectId = 'object_character';
    const triggerObjectId = 'object_trigger';
    const triggerId = 'trigger_door';
    const moveChainId = 'chain_move';
    const dialogueChainId = 'chain_dialogue';
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
          id: triggerObjectId,
          name: 'Door',
          triggerId: triggerId,
          transform: Transform2D(x: 100, y: 0, width: 8, height: 8),
        ),
      ],
      triggers: const [
        Trigger.area(
          id: triggerId,
          name: 'Door',
          eventChainId: dialogueChainId,
        ),
      ],
      eventChains: const [
        EventChain(
          id: moveChainId,
          name: 'Move',
          events: [
            StudioEvent.characterMove(
              id: 'event_move',
              characterObjectId: characterObjectId,
              path: MovementPath(
                speed: 100,
                nodes: [
                  PathNode(id: 'node_start', x: 0, y: 0),
                  PathNode(id: 'node_door', x: 100, y: 0),
                ],
              ),
            ),
          ],
        ),
        EventChain(
          id: dialogueChainId,
          name: 'Door Dialogue',
          triggerMode: EventChainTriggerMode.triggerPoint,
          events: [
            StudioEvent.dialogueSay(
              id: 'event_dialogue',
              text: 'Door',
              duration: 2,
            ),
          ],
        ),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.focus(
        target: FocusTarget.point(x: 0, y: 0),
      ),
    );
    final project = StudioProject(
      schemaVersion: 2,
      id: 'project_test',
      name: 'Test',
      currentSceneId: scene.id,
      scenes: [scene],
      characters: const [],
      assets: const [],
    );
    final plan = TimelinePlan(
      project: project,
      scene: scene,
      chain: scene.eventChains.first,
    );
    final track = plan.tracks.firstWhere(
      (value) => value.chain.id == dialogueChainId,
    );

    expect(track.spans.single.start, closeTo(1, 0.001));
    expect(track.spans.single.end, closeTo(3, 0.001));
  });
}

void _moveTriggerTimelineTests() {
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
            triggerMode: EventChainTriggerMode.triggerPoint,
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

void _videoTimelineTests() {
  test(
    'character stops walking animation while a trigger chain is running',
    () {
      const characterObjectId = 'object_kris';
      const triggerId = 'trigger_dialogue';
      const dialogueChainId = 'chain_dialogue';
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
            name: 'Talk',
            triggerId: triggerId,
            transform: Transform2D(x: 10, y: 0, width: 8, height: 8),
          ),
        ],
        triggers: const [
          Trigger.area(
            id: triggerId,
            name: 'Talk',
            eventChainId: dialogueChainId,
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
            id: dialogueChainId,
            name: 'Dialogue',
            triggerMode: EventChainTriggerMode.triggerPoint,
            events: [
              StudioEvent.dialogueSay(
                id: 'event_dialogue',
                text: '...',
                textSoundAssetId: 'asset_text_sound',
                style: DialogueStyle.darkWorld,
                duration: 2,
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
        schemaVersion: 3,
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
            id: 'asset_text_sound',
            kind: AssetKind.audio,
            relativePath: 'assets/audio/text.wav',
            originalName: 'text.wav',
          ),
        ],
      );

      final plan = TimelinePlan(project: project, scene: scene, chain: null);
      final world = plan.evaluate(1.5);

      expect(plan.dialogueTypeCues, hasLength(3));
      expect(plan.dialogueTypeCues.first.assetId, 'asset_text_sound');
      expect(plan.dialogueTypeCues.first.time, closeTo(1 + 1 / 32, 0.001));
      expect(world.dialogue, isNotNull);
      expect(world.objects[characterObjectId]!.isMoving, isFalse);
      expect(plan.evaluate(3).dialogue, isNull);
    },
  );
}

void _dialogueTests() {
  test('final dialogue clears when its duration ends', () {
    final scene = Scene(
      id: 'scene_main',
      name: 'Main Canvas',
      objects: const [],
      triggers: const [],
      eventChains: const [
        EventChain(
          id: 'chain_dialogue',
          name: 'Dialogue',
          events: [
            StudioEvent.dialogueSay(
              id: 'event_dialogue',
              text: 'Line',
              style: DialogueStyle.darkWorld,
              duration: 1,
            ),
          ],
        ),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.focus(
        target: FocusTarget.point(x: 0, y: 0),
      ),
    );
    final project = StudioProject(
      schemaVersion: 2,
      id: 'project_test',
      name: 'Test',
      currentSceneId: scene.id,
      scenes: [scene],
      characters: const [],
      assets: const [],
    );
    final plan = TimelinePlan(
      project: project,
      scene: scene,
      chain: scene.eventChains.single,
    );

    expect(plan.evaluate(0.5).dialogue, isNotNull);
    expect(plan.evaluate(1).dialogue, isNull);
  });
}

void _followTests() {
  _basicFollowTests();
  _parallelFollowTests();
  _unevenFollowTests();
}

void _basicFollowTests() {
  test('character follow samples leader path at a fixed distance', () {
    const leaderObjectId = 'object_leader';
    const followerObjectId = 'object_follower';
    final scene = Scene(
      id: 'scene_main',
      name: 'Main Canvas',
      objects: const [
        SceneObject.characterInstance(
          id: leaderObjectId,
          name: 'Leader',
          characterId: 'character_kris',
          transform: Transform2D(x: 0, y: 0),
          facing: Direction.right,
        ),
        SceneObject.characterInstance(
          id: followerObjectId,
          name: 'Follower',
          characterId: 'character_kris',
          transform: Transform2D(x: -48, y: 0),
          facing: Direction.right,
        ),
      ],
      triggers: const [],
      eventChains: const [
        EventChain(
          id: 'chain_follow',
          name: 'Follow',
          events: [
            StudioEvent.characterStartFollow(
              id: 'event_follow',
              followerObjectId: followerObjectId,
              leaderObjectId: leaderObjectId,
              distance: 32,
            ),
            StudioEvent.characterMove(
              id: 'event_move',
              characterObjectId: leaderObjectId,
              path: MovementPath(
                speed: 320,
                nodes: [
                  PathNode(id: 'node_start', x: 0, y: 0),
                  PathNode(id: 'node_end', x: 320, y: 0),
                ],
              ),
            ),
          ],
        ),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.followPlayer(
        playerObjectId: leaderObjectId,
      ),
    );
    final project = StudioProject(
      schemaVersion: 2,
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
      assets: const [],
    );
    final plan = TimelinePlan(
      project: project,
      scene: scene,
      chain: scene.eventChains.single,
    );

    final movingWorld = plan.evaluate(0.6);
    expect(
      movingWorld.objects[leaderObjectId]!.transform.x,
      closeTo(160, 0.001),
    );
    expect(
      movingWorld.objects[followerObjectId]!.transform.x,
      closeTo(128, 0.001),
    );
    expect(movingWorld.objects[followerObjectId]!.isMoving, isTrue);

    final endWorld = plan.evaluate(plan.duration);
    expect(
      endWorld.objects[followerObjectId]!.transform.x,
      closeTo(288, 0.001),
    );
    expect(endWorld.objects[followerObjectId]!.isMoving, isFalse);
  });
}

void _parallelFollowTests() {
  test(
    'always chains evaluate in parallel so followers can start before moves',
    () {
      const leaderObjectId = 'object_leader';
      const followerObjectId = 'object_follower';
      final scene = Scene(
        id: 'scene_main',
        name: 'Main Canvas',
        objects: const [
          SceneObject.characterInstance(
            id: leaderObjectId,
            name: 'Leader',
            characterId: 'character_kris',
            transform: Transform2D(x: 0, y: 0),
            facing: Direction.right,
          ),
          SceneObject.characterInstance(
            id: followerObjectId,
            name: 'Follower',
            characterId: 'character_kris',
            transform: Transform2D(x: -48, y: 0),
            facing: Direction.right,
          ),
        ],
        triggers: const [],
        eventChains: const [
          EventChain(
            id: 'chain_move',
            name: 'Move',
            triggerMode: EventChainTriggerMode.always,
            events: [
              StudioEvent.characterMove(
                id: 'event_move',
                characterObjectId: leaderObjectId,
                path: MovementPath(
                  speed: 320,
                  nodes: [
                    PathNode(id: 'node_start', x: 0, y: 0),
                    PathNode(id: 'node_end', x: 320, y: 0),
                  ],
                ),
              ),
            ],
          ),
          EventChain(
            id: 'chain_follow',
            name: 'Follow',
            triggerMode: EventChainTriggerMode.always,
            events: [
              StudioEvent.characterStartFollow(
                id: 'event_follow',
                followerObjectId: followerObjectId,
                leaderObjectId: leaderObjectId,
                distance: 48,
              ),
            ],
          ),
        ],
        interestPoints: const [],
        cameraPolicy: const CameraPolicy.followPlayer(
          playerObjectId: leaderObjectId,
        ),
      );
      final project = StudioProject(
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
        assets: const [],
      );
      final plan = TimelinePlan(project: project, scene: scene, chain: null);

      final world = plan.evaluate(0.75);
      expect(plan.duration, closeTo(1, 0.001));
      expect(world.objects[leaderObjectId]!.transform.x, closeTo(240, 0.001));
      expect(world.objects[followerObjectId]!.transform.x, closeTo(192, 0.001));
      expect(world.objects[followerObjectId]!.isMoving, isTrue);
    },
  );
}

void _unevenFollowTests() {
  test('character follow uses traveled distance on uneven path segments', () {
    const leaderObjectId = 'object_leader';
    const followerObjectId = 'object_follower';
    final scene = Scene(
      id: 'scene_main',
      name: 'Main Canvas',
      objects: const [
        SceneObject.characterInstance(
          id: leaderObjectId,
          name: 'Leader',
          characterId: 'character_kris',
          transform: Transform2D(x: 0, y: 0),
          facing: Direction.right,
        ),
        SceneObject.characterInstance(
          id: followerObjectId,
          name: 'Follower',
          characterId: 'character_kris',
          transform: Transform2D(x: -48, y: 0),
          facing: Direction.right,
        ),
      ],
      triggers: const [],
      eventChains: const [
        EventChain(
          id: 'chain_move',
          name: 'Move',
          triggerMode: EventChainTriggerMode.always,
          events: [
            StudioEvent.characterMove(
              id: 'event_move',
              characterObjectId: leaderObjectId,
              path: MovementPath(
                speed: 320,
                nodes: [
                  PathNode(id: 'node_start', x: 0, y: 0),
                  PathNode(id: 'node_short', x: 64, y: 0),
                  PathNode(id: 'node_long', x: 704, y: 0),
                ],
              ),
            ),
          ],
        ),
        EventChain(
          id: 'chain_follow',
          name: 'Follow',
          triggerMode: EventChainTriggerMode.always,
          events: [
            StudioEvent.characterStartFollow(
              id: 'event_follow',
              followerObjectId: followerObjectId,
              leaderObjectId: leaderObjectId,
              distance: 48,
            ),
          ],
        ),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.followPlayer(
        playerObjectId: leaderObjectId,
      ),
    );
    final project = StudioProject(
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
      assets: const [],
    );
    final plan = TimelinePlan(project: project, scene: scene, chain: null);

    final world = plan.evaluate(1);
    expect(world.objects[leaderObjectId]!.transform.x, closeTo(320, 0.001));
    expect(world.objects[followerObjectId]!.transform.x, closeTo(272, 0.001));
    expect(world.objects[followerObjectId]!.isMoving, isTrue);
  });
}

void _expressionTests() {
  test('change expression plays for duration then restores previous state', () {
    const characterObjectId = 'object_kris';
    final scene = Scene(
      id: 'scene_main',
      name: 'Main Canvas',
      objects: const [
        SceneObject.characterInstance(
          id: characterObjectId,
          name: 'Kris',
          characterId: 'character_kris',
          transform: Transform2D(x: 0, y: 0),
          facing: Direction.down,
          initialExpression: 'idle',
        ),
      ],
      triggers: const [],
      eventChains: const [
        EventChain(
          id: 'chain_expression',
          name: 'Expression',
          events: [
            StudioEvent.characterChangeExpression(
              id: 'event_expression',
              characterObjectId: characterObjectId,
              expressionId: 'talk',
              duration: 1,
            ),
            StudioEvent.characterWait(id: 'event_wait', duration: 1),
          ],
        ),
      ],
      interestPoints: const [],
      cameraPolicy: const CameraPolicy.followPlayer(
        playerObjectId: characterObjectId,
      ),
    );
    final project = StudioProject(
      id: 'project_test',
      name: 'Test',
      currentSceneId: scene.id,
      scenes: [scene],
      characters: const [
        Character(
          id: 'character_kris',
          name: 'Kris',
          animations: [],
          expressions: [
            CharacterExpression(id: 'idle', name: 'Idle'),
            CharacterExpression(
              id: 'talk',
              name: 'Talk',
              assetIds: ['frame_a', 'frame_b'],
              framesPerSecond: 6,
            ),
          ],
          movement: CharacterMovementProfile(),
        ),
      ],
      assets: const [],
    );
    final plan = TimelinePlan(
      project: project,
      scene: scene,
      chain: scene.eventChains.single,
    );

    expect(plan.duration, closeTo(2, 0.001));
    expect(plan.evaluate(0.5).objects[characterObjectId]!.expressionId, 'talk');
    expect(plan.evaluate(1.2).objects[characterObjectId]!.expressionId, 'idle');
  });
}
