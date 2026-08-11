part of 'preview_controller.dart';

String? triggerAtPoint(Scene scene, double x, double y) {
  for (final object in scene.objects) {
    final triggerId = object.maybeMap(
      triggerPoint: (value) => value.triggerId,
      triggerArea: (value) => value.triggerId,
      orElse: () => null,
    );
    if (triggerId == null) {
      continue;
    }
    final transform = object.objectTransform;
    final rect = RectLike(
      transform.x,
      transform.y,
      transform.width * transform.scale,
      transform.height * transform.scale,
    ).inflate(10);
    if (rect.contains(x, y)) {
      return triggerId;
    }
  }
  return null;
}

String? linkedTriggerId(Scene scene, String? triggerId) {
  if (triggerId == null) {
    return null;
  }
  for (final trigger in scene.triggers) {
    final match = trigger.map(
      area: (value) => value.id == triggerId ? value.linkedTriggerId : null,
      object: (value) => value.id == triggerId ? value.linkedTriggerId : null,
      auto: (value) => value.id == triggerId ? value.linkedTriggerId : null,
      moveComplete: (value) =>
          value.id == triggerId ? value.linkedTriggerId : null,
    );
    if (match != null) {
      return match;
    }
  }
  return null;
}

EventChain? triggerChain(Scene scene, String? triggerId) {
  if (triggerId == null) {
    return null;
  }
  for (final trigger in scene.triggers) {
    final chainId = trigger.map(
      area: (value) => value.id == triggerId ? value.eventChainId : null,
      object: (value) => value.id == triggerId ? value.eventChainId : null,
      auto: (value) => value.id == triggerId ? value.eventChainId : null,
      moveComplete: (value) =>
          value.id == triggerId ? value.eventChainId : null,
    );
    if (chainId == null || chainId.isEmpty) {
      continue;
    }
    for (final chain in scene.eventChains) {
      if (chain.id == chainId &&
          chain.triggerMode == EventChainTriggerMode.triggerPoint) {
        return chain;
      }
    }
  }
  return null;
}

DoorDestination? triggerObjectPosition(Scene scene, String? triggerId) {
  if (triggerId == null) {
    return null;
  }
  for (final object in scene.objects) {
    final objectTriggerId = object.maybeMap(
      triggerPoint: (value) => value.triggerId,
      triggerArea: (value) => value.triggerId,
      orElse: () => null,
    );
    if (objectTriggerId == triggerId) {
      final transform = object.objectTransform;
      return DoorDestination(transform.x, transform.y);
    }
  }
  return null;
}
