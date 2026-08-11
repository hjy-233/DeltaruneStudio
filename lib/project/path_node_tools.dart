import 'package:deltarune_studio/domain/studio_models.dart';

List<PathNode> normalizeOrthogonalPathNodes(
  List<PathNode> nodes,
  String changedId,
) {
  if (nodes.length < 2) {
    return nodes;
  }
  final normalized = [...nodes];
  final index = normalized.indexWhere((node) => node.id == changedId);
  if (index < 0) {
    return normalized;
  }
  if (index > 0) {
    normalized[index] = snapNodeToOrthogonal(
      anchor: normalized[index - 1],
      node: normalized[index],
    );
  } else {
    normalized[index] = snapNodeToOrthogonal(
      anchor: normalized[1],
      node: normalized[index],
    );
  }
  if (index + 1 < normalized.length) {
    normalized[index + 1] = snapNodeToOrthogonal(
      anchor: normalized[index],
      node: normalized[index + 1],
    );
  }
  return normalized;
}

PathNode snapNodeToOrthogonal({
  required PathNode anchor,
  required PathNode node,
}) {
  final dx = node.x - anchor.x;
  final dy = node.y - anchor.y;
  if (dx.abs() >= dy.abs()) {
    return node.copyWith(y: anchor.y);
  }
  return node.copyWith(x: anchor.x);
}
