import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/studio_state.dart';
import 'package:deltarune_studio/runtime/runtime_world.dart';
import 'package:deltarune_studio/shared_render/studio_rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats manual dialogue lines with one bullet per logical line', () {
    expect(
      dialogueTextWithLineBullets('Hello world\nSecond line'),
      '* Hello world\n* Second line',
    );
  });

  test('clips dialogue text by visible character count before formatting', () {
    const dialogue = DialogueBoxState(
      text: 'Hello\nWorld',
      style: DialogueStyle.darkWorld,
      visibleCharacters: 7,
    );

    expect(visibleDialogueText(dialogue), 'Hello\nW');
    expect(
      dialogueTextWithLineBullets(visibleDialogueText(dialogue)),
      '* Hello\n* W',
    );
  });

  test('moving character animation overrides the current expression frame', () {
    const character = Character(
      id: 'character_ralsei',
      name: 'Ralsei',
      animations: [
        AnimationClip(
          id: 'walk_down_0',
          name: 'Walk Down 0',
          assetId: 'asset_walk_down_0',
          direction: Direction.down,
        ),
        AnimationClip(
          id: 'walk_down_1',
          name: 'Walk Down 1',
          assetId: 'asset_walk_down_1',
          direction: Direction.down,
        ),
      ],
      expressions: [
        CharacterExpression(
          id: 'smile',
          name: 'Smile',
          assetIds: ['asset_expression_0'],
        ),
      ],
      movement: CharacterMovementProfile(),
    );
    const object = SceneObject.characterInstance(
      id: 'object_ralsei',
      name: 'Ralsei',
      characterId: 'character_ralsei',
      transform: Transform2D(x: 0, y: 0),
      facing: Direction.down,
      initialExpression: 'smile',
    );
    final ready = StudioReady(
      project: StudioProject(
        id: 'project_test',
        name: 'Test',
        currentSceneId: 'scene_main',
        scenes: const [
          Scene(
            id: 'scene_main',
            name: 'Main Canvas',
            objects: [object],
            triggers: [],
            eventChains: [],
            interestPoints: [],
            cameraPolicy: CameraPolicy.focus(
              target: FocusTarget.point(x: 0, y: 0),
            ),
          ),
        ],
        characters: const [character],
        assets: const [],
      ),
      projectDirectory: null,
    );
    final runtimeObject = RuntimeObject.fromSceneObject(
      object,
    ).copyWith(isMoving: true);

    expect(
      imageAssetIdForObject(
        ready: ready,
        object: object,
        runtimeObject: runtimeObject,
        currentTime: 0,
      ),
      'asset_walk_down_0',
    );
  });

  test(
    'stopped character keeps the standing movement pose over expression',
    () {
      const character = Character(
        id: 'character_ralsei',
        name: 'Ralsei',
        animations: [],
        expressions: [
          CharacterExpression(
            id: 'smile',
            name: 'Smile',
            assetIds: ['asset_expression_0'],
          ),
        ],
        movement: CharacterMovementProfile(),
      );
      const object = SceneObject.characterInstance(
        id: 'object_ralsei',
        name: 'Ralsei',
        characterId: 'character_ralsei',
        transform: Transform2D(x: 0, y: 0),
        facing: Direction.down,
        initialExpression: 'smile',
      );
      final ready = StudioReady(
        project: StudioProject(
          id: 'project_test',
          name: 'Test',
          currentSceneId: 'scene_main',
          scenes: const [
            Scene(
              id: 'scene_main',
              name: 'Main Canvas',
              objects: [object],
              triggers: [],
              eventChains: [],
              interestPoints: [],
              cameraPolicy: CameraPolicy.focus(
                target: FocusTarget.point(x: 0, y: 0),
              ),
            ),
          ],
          characters: const [character],
          assets: const [],
        ),
        projectDirectory: null,
      );
      final runtimeObject = RuntimeObject.fromSceneObject(
        object,
      ).copyWith(isMoving: false, movementPoseAssetId: 'asset_walk_down_0');

      expect(
        imageAssetIdForObject(
          ready: ready,
          object: object,
          runtimeObject: runtimeObject,
          currentTime: 10,
        ),
        'asset_walk_down_0',
      );
    },
  );

  test('active expression override is drawn over movement pose', () {
    const character = Character(
      id: 'character_ralsei',
      name: 'Ralsei',
      animations: [],
      expressions: [
        CharacterExpression(
          id: 'smile',
          name: 'Smile',
          assetIds: ['asset_expression_0'],
        ),
      ],
      movement: CharacterMovementProfile(),
    );
    const object = SceneObject.characterInstance(
      id: 'object_ralsei',
      name: 'Ralsei',
      characterId: 'character_ralsei',
      transform: Transform2D(x: 0, y: 0),
      facing: Direction.down,
      initialExpression: 'idle',
    );
    final ready = StudioReady(
      project: StudioProject(
        id: 'project_test',
        name: 'Test',
        currentSceneId: 'scene_main',
        scenes: const [
          Scene(
            id: 'scene_main',
            name: 'Main Canvas',
            objects: [object],
            triggers: [],
            eventChains: [],
            interestPoints: [],
            cameraPolicy: CameraPolicy.focus(
              target: FocusTarget.point(x: 0, y: 0),
            ),
          ),
        ],
        characters: const [character],
        assets: const [],
      ),
      projectDirectory: null,
    );
    final runtimeObject = RuntimeObject.fromSceneObject(object).copyWith(
      expressionId: 'smile',
      expressionOverrideActive: true,
      isMoving: false,
      movementPoseAssetId: 'asset_walk_down_0',
    );

    expect(
      imageAssetIdForObject(
        ready: ready,
        object: object,
        runtimeObject: runtimeObject,
        currentTime: 10,
      ),
      'asset_expression_0',
    );
  });
}
