import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';

StudioEvent defaultMoveEvent(String? objectId) {
  return StudioEvent.characterMove(
    id: StudioIds.event(),
    characterObjectId: objectId ?? '',
    path: MovementPath(
      nodes: [
        const PathNode(id: 'path_a', name: 'Start', x: 120, y: 180),
        const PathNode(id: 'path_b', name: 'Node 2', x: 240, y: 180),
        const PathNode(id: 'path_c', name: 'Node 3', x: 240, y: 120),
      ],
      speed: 320,
      shake: 12,
    ),
  );
}
