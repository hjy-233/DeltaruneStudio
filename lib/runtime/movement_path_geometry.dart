import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';

({double x, double y}) movementTarget(
  double startX,
  double startY,
  PathNode target,
  MovementMode mode,
) {
  if (mode == MovementMode.free) {
    return (x: target.x, y: target.y);
  }
  final dx = target.x - startX;
  final dy = target.y - startY;
  final snapped = snapDelta(dx, dy, mode);
  return (x: startX + snapped.dx, y: startY + snapped.dy);
}

({double dx, double dy}) snapDelta(double dx, double dy, MovementMode mode) {
  if (mode == MovementMode.free || (dx == 0 && dy == 0)) {
    return (dx: dx, dy: dy);
  }
  final distance = math.max(dx.abs(), dy.abs()).toDouble();
  if (mode == MovementMode.fourWay) {
    return dx.abs() >= dy.abs()
        ? (dx: dx.sign * distance, dy: 0)
        : (dx: 0, dy: dy.sign * distance);
  }
  final angle = math.atan2(dy, dx);
  final octant = (angle / (math.pi / 4)).round();
  final snappedAngle = octant * math.pi / 4;
  return (
    dx: math.cos(snappedAngle) * distance,
    dy: math.sin(snappedAngle) * distance,
  );
}

Direction movementDirection(
  double dx,
  double dy,
  MovementMode mode,
  int segmentIndex,
) {
  if (mode == MovementMode.eightWay && dx != 0 && dy != 0) {
    // Pick one cardinal animation deterministically. The path remains diagonal.
    return segmentIndex.isEven
        ? (dx.abs() >= dy.abs()
              ? (dx >= 0 ? Direction.right : Direction.left)
              : (dy >= 0 ? Direction.down : Direction.up))
        : (dy.abs() >= dx.abs()
              ? (dy >= 0 ? Direction.down : Direction.up)
              : (dx >= 0 ? Direction.right : Direction.left));
  }
  if (dx.abs() >= dy.abs()) {
    return dx >= 0 ? Direction.right : Direction.left;
  }
  return dy >= 0 ? Direction.down : Direction.up;
}

double movementDistance(
  double startX,
  double startY,
  double endX,
  double endY,
) {
  return math.sqrt(math.pow(endX - startX, 2) + math.pow(endY - startY, 2));
}
