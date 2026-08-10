import 'package:deltarune_studio/domain/studio_models.dart';

sealed class EditorSelection {
  const EditorSelection();

  const factory EditorSelection.object(String objectId) = ObjectSelection;
  const factory EditorSelection.objects(List<String> objectIds) =
      ObjectMultiSelection;
  const factory EditorSelection.trigger(String triggerId) = TriggerSelection;
  const factory EditorSelection.eventChain(String chainId) =
      EventChainSelection;
  const factory EditorSelection.event(String chainId, String eventId) =
      EventSelection;
  const factory EditorSelection.pathNode(
    String chainId,
    String eventId,
    String nodeId,
  ) = PathNodeSelection;
  const factory EditorSelection.asset(String assetId) = AssetSelection;
  const factory EditorSelection.character(String characterId) =
      CharacterSelection;
}

final class ObjectSelection extends EditorSelection {
  const ObjectSelection(this.objectId);
  final String objectId;
}

final class ObjectMultiSelection extends EditorSelection {
  const ObjectMultiSelection(this.objectIds);
  final List<String> objectIds;
}

final class TriggerSelection extends EditorSelection {
  const TriggerSelection(this.triggerId);
  final String triggerId;
}

final class EventChainSelection extends EditorSelection {
  const EventChainSelection(this.chainId);
  final String chainId;
}

final class EventSelection extends EditorSelection {
  const EventSelection(this.chainId, this.eventId);
  final String chainId;
  final String eventId;
}

final class PathNodeSelection extends EditorSelection {
  const PathNodeSelection(this.chainId, this.eventId, this.nodeId);
  final String chainId;
  final String eventId;
  final String nodeId;
}

final class AssetSelection extends EditorSelection {
  const AssetSelection(this.assetId);
  final String assetId;
}

final class CharacterSelection extends EditorSelection {
  const CharacterSelection(this.characterId);
  final String characterId;
}

extension EditorSelectionLookup on EditorSelection? {
  String? get objectId => switch (this) {
    ObjectSelection(:final objectId) => objectId,
    ObjectMultiSelection(:final objectIds) =>
      objectIds.length == 1 ? objectIds.single : null,
    _ => null,
  };

  List<String> get objectIds => switch (this) {
    ObjectSelection(:final objectId) => [objectId],
    ObjectMultiSelection(:final objectIds) => objectIds,
    _ => const [],
  };

  String? get chainId => switch (this) {
    EventChainSelection(:final chainId) => chainId,
    EventSelection(:final chainId) => chainId,
    PathNodeSelection(:final chainId) => chainId,
    _ => null,
  };

  String? get eventId => switch (this) {
    EventSelection(:final eventId) => eventId,
    PathNodeSelection(:final eventId) => eventId,
    _ => null,
  };

  bool selectsPathNode(PathNode node) => switch (this) {
    PathNodeSelection(:final nodeId) => nodeId == node.id,
    _ => false,
  };
}
