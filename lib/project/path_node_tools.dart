import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/runtime/movement_path_geometry.dart';

List<PathNode> normalizeOrthogonalPathNodes(
  List<PathNode> nodes,
  String changedId, [
  MovementMode mode = MovementMode.fourWay,
]) {
  if (mode == MovementMode.free) {
    return nodes;
  }
  if (nodes.length < 2) {
    return nodes;
  }
  final normalized = [...nodes];
  final index = normalized.indexWhere((node) => node.id == changedId);
  if (index < 0) {
    return normalized;
  }
  if (index > 0) {
    normalized[index] = snapNodeToDirection(
      anchor: normalized[index - 1],
      node: normalized[index],
      mode: mode,
    );
  } else {
    normalized[index] = snapNodeToDirection(
      anchor: normalized[1],
      node: normalized[index],
      mode: mode,
    );
  }
  if (index + 1 < normalized.length) {
    normalized[index + 1] = snapNodeToDirection(
      anchor: normalized[index],
      node: normalized[index + 1],
      mode: mode,
    );
  }
  return normalized;
}

List<PathNode> normalizeMovementPathNodes(
  List<PathNode> nodes,
  MovementMode mode,
) {
  if (nodes.length < 2 || mode == MovementMode.free) {
    return nodes;
  }
  final normalized = [nodes.first];
  for (final node in nodes.skip(1)) {
    normalized.add(
      snapNodeToDirection(anchor: normalized.last, node: node, mode: mode),
    );
  }
  return normalized;
}

PathNode snapNodeToOrthogonal({
  required PathNode anchor,
  required PathNode node,
}) {
  return snapNodeToDirection(
    anchor: anchor,
    node: node,
    mode: MovementMode.fourWay,
  );
}

PathNode snapNodeToDirection({
  required PathNode anchor,
  required PathNode node,
  required MovementMode mode,
}) {
  final delta = snapDelta(node.x - anchor.x, node.y - anchor.y, mode);
  return node.copyWith(x: anchor.x + delta.dx, y: anchor.y + delta.dy);
}
