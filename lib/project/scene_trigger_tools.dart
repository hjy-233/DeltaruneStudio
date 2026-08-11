import 'dart:math' as math;

import 'package:deltarune_studio/domain/studio_models.dart';

const _triggerPadding = 10.0;

String triggerIdOf(Trigger trigger) {
  return trigger.map(
    area: (value) => value.id,
    object: (value) => value.id,
    auto: (value) => value.id,
    moveComplete: (value) => value.id,
  );
}

bool isTriggerSceneObject(SceneObject object) {
  return triggerIdForSceneObject(object) != null;
}

String? triggerIdForSceneObject(SceneObject object) {
  return object.maybeMap(
    triggerPoint: (value) => value.triggerId,
    triggerArea: (value) => value.triggerId,
    orElse: () => null,
  );
}

Scene syncPathNodeTriggerLinks(Scene scene) {
  var changed = false;
  final eventChains = scene.eventChains.map((chain) {
    final events = chain.events.map((event) {
      if (event is! CharacterMoveEvent) {
        return event;
      }
      final nodes = event.path.nodes.map((node) {
        final triggerId = nearestTriggerIdForPathNode(scene, node);
        if (triggerId == node.triggerId) {
          return node;
        }
        changed = true;
        return node.copyWith(triggerId: triggerId);
      }).toList();
      return event.copyWith(path: event.path.copyWith(nodes: nodes));
    }).toList();
    return chain.copyWith(events: events);
  }).toList();

  if (!changed) {
    return scene;
  }
  return scene.copyWith(eventChains: eventChains);
}

String? nearestTriggerIdForPathNode(Scene scene, PathNode node) {
  String? nearestTriggerId;
  var nearestDistance = double.infinity;
  for (final object in scene.objects) {
    final triggerId = triggerIdForSceneObject(object);
    if (triggerId == null) {
      continue;
    }
    final transform = object.objectTransform;
    final left = transform.x - _triggerPadding;
    final top = transform.y - _triggerPadding;
    final right =
        transform.x + transform.width * transform.scale + _triggerPadding;
    final bottom =
        transform.y + transform.height * transform.scale + _triggerPadding;
    final inside =
        node.x >= left && node.x <= right && node.y >= top && node.y <= bottom;
    final centerX = (left + right) / 2;
    final centerY = (top + bottom) / 2;
    final dx = centerX - node.x;
    final dy = centerY - node.y;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (inside && distance < nearestDistance) {
      nearestTriggerId = triggerId;
      nearestDistance = distance;
    }
  }
  return nearestTriggerId;
}
