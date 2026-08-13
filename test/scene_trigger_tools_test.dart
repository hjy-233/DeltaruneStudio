import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/project/scene_trigger_tools.dart';
import 'package:deltarune_studio/project/path_node_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'snaps eight-way nodes to the nearest diagonal or cardinal direction',
    () {
      const anchor = PathNode(id: 'anchor', x: 0, y: 0);
      final snapped = snapNodeToDirection(
        anchor: anchor,
        node: const PathNode(id: 'node', x: 100, y: 90),
        mode: MovementMode.eightWay,
      );

      expect(snapped.x, closeTo(snapped.y, 0.001));
      expect(snapped.x, greaterThan(0));
    },
  );

  test(
    'syncs path node trigger links when nodes enter or leave trigger points',
    () {
      const moveEvent = StudioEvent.characterMove(
        id: 'event_move',
        characterObjectId: 'object_kris',
        path: MovementPath(
          nodes: [
            PathNode(id: 'node_start', x: 0, y: 0),
            PathNode(id: 'node_inside', x: 110, y: 110),
            PathNode(
              id: 'node_outside',
              x: 240,
              y: 240,
              triggerId: 'trigger_door',
            ),
          ],
        ),
      );
      final scene = Scene(
        id: 'scene_main',
        name: 'Main Canvas',
        objects: const [
          SceneObject.triggerPoint(
            id: 'object_trigger',
            name: 'Door',
            triggerId: 'trigger_door',
            transform: Transform2D(x: 100, y: 100, width: 22, height: 22),
          ),
        ],
        triggers: const [
          Trigger.area(
            id: 'trigger_door',
            name: 'Door',
            eventChainId: 'chain_door',
          ),
        ],
        eventChains: const [
          EventChain(id: 'chain_move', name: 'Move', events: [moveEvent]),
          EventChain(id: 'chain_door', name: 'Door', events: []),
        ],
        interestPoints: const [],
        cameraPolicy: const CameraPolicy.focus(
          target: FocusTarget.point(x: 0, y: 0),
        ),
      );

      final synced = syncPathNodeTriggerLinks(scene);
      final move = synced.eventChains.first.events.single as CharacterMoveEvent;

      expect(move.path.nodes[0].triggerId, isNull);
      expect(move.path.nodes[1].triggerId, 'trigger_door');
      expect(move.path.nodes[2].triggerId, isNull);
    },
  );

  test(
    'keeps scene instance unchanged when trigger links are already current',
    () {
      final scene = Scene(
        id: 'scene_main',
        name: 'Main Canvas',
        objects: const [],
        triggers: const [],
        eventChains: const [],
        interestPoints: const [],
        cameraPolicy: const CameraPolicy.focus(
          target: FocusTarget.point(x: 0, y: 0),
        ),
      );

      expect(identical(syncPathNodeTriggerLinks(scene), scene), isTrue);
    },
  );
}
