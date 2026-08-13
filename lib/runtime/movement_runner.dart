import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:deltarune_studio/runtime/movement_path_geometry.dart';

final class MovementFrame {
  const MovementFrame({
    required this.x,
    required this.y,
    required this.facing,
    required this.progress,
  });

  final double x;
  final double y;
  final Direction facing;
  final double progress;
}

final class MovementRunner {
  Iterable<MovementFrame> framesFor(MovementPath path) sync* {
    if (path.nodes.length < 2) {
      return;
    }

    for (var index = 0; index < path.nodes.length - 1; index += 1) {
      final start = path.nodes[index];
      final end = path.nodes[index + 1];
      final target = movementTarget(start.x, start.y, end, path.mode);
      final dx = target.x - start.x;
      final dy = target.y - start.y;
      final distance = math.sqrt(dx * dx + dy * dy);
      final frameCount = math.max(1, (distance / path.speed * 60).round());
      final facing = movementDirection(dx, dy, path.mode, index);
      for (var frame = 1; frame <= frameCount; frame += 1) {
        final t = frame / frameCount;
        final eased = Curves.smoothStep(t);
        final offset = _deterministicShake(
          segmentIndex: index,
          t: eased,
          dx: dx,
          dy: dy,
          amount: path.shake,
        );
        yield MovementFrame(
          x: start.x + dx * eased + offset.$1,
          y: start.y + dy * eased + offset.$2,
          facing: facing,
          progress: (index + t) / (path.nodes.length - 1),
        );
      }
    }
  }

  (double, double) _deterministicShake({
    required int segmentIndex,
    required double t,
    required double dx,
    required double dy,
    required double amount,
  }) {
    if (amount <= 0) {
      return (0, 0);
    }
    final length = math.max(1, math.sqrt(dx * dx + dy * dy));
    final normalX = -dy / length;
    final normalY = dx / length;
    final wave = math.sin((t * math.pi * 2) + segmentIndex * 1.618);
    final envelope = math.sin(t * math.pi);
    final offset = wave * envelope * amount * 0.12;
    return (normalX * offset, normalY * offset);
  }
}

final class Curves {
  const Curves._();

  static double smoothStep(double t) => t * t * (3 - 2 * t);
}
