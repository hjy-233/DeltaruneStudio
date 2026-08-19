import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/core/studio_id.dart';
import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:path/path.dart' as p;

final class ProjectRepository {
  static const projectFileName = 'project.json';

  Future<StudioProject> createDefaultProject(String name) async {
    final playerId = StudioIds.object();
    final walkChainId = StudioIds.chain();
    final doorChainId = StudioIds.chain();
    final canvasSceneId = StudioIds.scene();
    final krisId = StudioIds.character();
    final doorATriggerId = StudioIds.trigger();
    final doorBTriggerId = StudioIds.trigger();

    return StudioProject(
      schemaVersion: 4,
      id: 'project_${StudioIds.scene()}',
      name: name,
      currentSceneId: canvasSceneId,
      assets: const [],
      characters: [
        Character(
          id: krisId,
          name: 'Kris',
          animations: const [],
          expressions: const [
            CharacterExpression(id: 'idle', name: 'Idle'),
            CharacterExpression(id: 'talk', name: 'Talk'),
          ],
          movement: const CharacterMovementProfile(
            defaultSpeed: 320,
            defaultShake: 12,
          ),
          defaultTransform: const Transform2D(x: 180, y: 180),
          defaultFacing: Direction.down,
          defaultExpressionId: 'idle',
        ),
      ],
      scenes: [
        Scene(
          id: canvasSceneId,
          name: 'Main Canvas',
          objects: [
            const SceneObject.background(
              id: 'obj_demo_room',
              name: 'Room',
              assetId: '',
              transform: Transform2D(x: 40, y: 40, width: 360, height: 220),
            ),
            SceneObject.characterInstance(
              id: playerId,
              name: 'Kris',
              characterId: krisId,
              transform: const Transform2D(x: 120, y: 180),
              facing: Direction.down,
              initialExpression: 'idle',
            ),
            SceneObject.triggerPoint(
              id: StudioIds.object(),
              name: 'Door A',
              triggerId: doorATriggerId,
              transform: const Transform2D(
                x: 280,
                y: 116,
                width: 22,
                height: 22,
              ),
            ),
            SceneObject.triggerPoint(
              id: StudioIds.object(),
              name: 'Door B',
              triggerId: doorBTriggerId,
              transform: const Transform2D(
                x: 56,
                y: 216,
                width: 22,
                height: 22,
              ),
            ),
          ],
          triggers: [
            Trigger.area(
              id: doorATriggerId,
              name: 'Door A',
              eventChainId: doorChainId,
              linkedTriggerId: doorBTriggerId,
            ),
            Trigger.area(
              id: doorBTriggerId,
              name: 'Door B',
              eventChainId: doorChainId,
              linkedTriggerId: doorATriggerId,
            ),
          ],
          eventChains: [
            EventChain(
              id: walkChainId,
              name: 'Walk to Door',
              triggerMode: EventChainTriggerMode.always,
              events: [
                StudioEvent.characterMove(
                  id: StudioIds.event(),
                  characterObjectId: playerId,
                  path: MovementPath(
                    nodes: [
                      const PathNode(
                        id: 'path_start',
                        name: 'Start',
                        x: 120,
                        y: 180,
                      ),
                      const PathNode(
                        id: 'path_mid',
                        name: 'Door Approach',
                        x: 280,
                        y: 180,
                      ),
                      PathNode(
                        id: 'path_door',
                        name: 'Door A',
                        x: 280,
                        y: 116,
                        triggerId: doorATriggerId,
                      ),
                    ],
                    speed: 320,
                    shake: 12,
                  ),
                ),
              ],
            ),
            EventChain(
              id: doorChainId,
              name: 'Door Trigger',
              triggerMode: EventChainTriggerMode.triggerPoint,
              events: const [],
            ),
          ],
          interestPoints: const [
            InterestPoint(
              id: 'ip_window',
              name: 'Window',
              kind: 'window',
              x: 320,
              y: 96,
            ),
          ],
          cameraPolicy: CameraPolicy.followPlayer(playerObjectId: playerId),
        ),
      ],
    );
  }

  Future<void> saveProject({
    required Directory directory,
    required StudioProject project,
  }) async {
    await _ensureProjectLayout(directory);
    final file = File(p.join(directory.path, projectFileName));
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(project.toJson()), flush: true);
  }

  Future<void> copyProjectPayload({
    required Directory sourceDirectory,
    required Directory targetDirectory,
  }) async {
    await _ensureProjectLayout(targetDirectory);
    for (final name in ['assets', 'settings', 'scenes', 'characters']) {
      final source = Directory(p.join(sourceDirectory.path, name));
      if (!await source.exists()) {
        continue;
      }
      final target = Directory(p.join(targetDirectory.path, name));
      await _copyDirectory(source, target);
    }
  }

  Future<StudioProject> openProject(Directory directory) async {
    final file = File(p.join(directory.path, projectFileName));
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return _migrateProject(StudioProject.fromJson(json));
  }

  StudioProject migrateProjectForOpen(StudioProject project) {
    return _migrateProject(project);
  }

  StudioProject _migrateProject(StudioProject project) {
    return project.copyWith(
      schemaVersion: 4,
      scenes: [for (final scene in project.scenes) _migrateScene(scene)],
    );
  }

  Scene _migrateScene(Scene scene) {
    final triggeredChainIds = {
      for (final trigger in scene.triggers) _eventChainIdForTrigger(trigger),
    }..remove('');
    final migratedObjects = [
      for (final object in scene.objects) _migrateSceneObject(object),
    ];
    return scene.copyWith(
      objects: migratedObjects,
      eventChains: [
        for (final chain in scene.eventChains)
          _migrateEventChain(
            chain,
            migratedObjects,
            triggeredChainIds.contains(chain.id),
          ),
      ],
    );
  }

  EventChain _migrateEventChain(
    EventChain chain,
    List<SceneObject> objects,
    bool isTriggerPointChain,
  ) {
    final mode = isTriggerPointChain
        ? EventChainTriggerMode.triggerPoint
        : chain.triggerMode;
    return chain.copyWith(
      triggerMode: mode,
      events: [for (final event in chain.events) _migrateEvent(event, objects)],
    );
  }

  StudioEvent _migrateEvent(StudioEvent event, List<SceneObject> objects) {
    final firstCharacterId = _characterObjectIdAt(objects, 0);
    final secondCharacterId = _characterObjectIdAt(objects, 1);
    String? validCharacterId(String id, {int fallbackIndex = 0}) {
      if (_isCharacterObjectId(objects, id)) {
        return id;
      }
      return _characterObjectIdAt(objects, fallbackIndex) ?? firstCharacterId;
    }

    return event.map(
      characterMove: (value) {
        final id = validCharacterId(value.characterObjectId);
        return id == null ? value : value.copyWith(characterObjectId: id);
      },
      characterChangeExpression: (value) {
        final id = validCharacterId(value.characterObjectId);
        return id == null ? value : value.copyWith(characterObjectId: id);
      },
      characterStartFollow: (value) {
        final followerId = validCharacterId(value.followerObjectId);
        final leaderId = validCharacterId(
          value.leaderObjectId,
          fallbackIndex: secondCharacterId == null ? 0 : 1,
        );
        if (followerId == null || leaderId == null) {
          return value;
        }
        return value.copyWith(
          followerObjectId: followerId,
          leaderObjectId: leaderId,
        );
      },
      characterStopFollow: (value) {
        final id = validCharacterId(value.followerObjectId);
        return id == null ? value : value.copyWith(followerObjectId: id);
      },
      cameraFollow: (value) {
        final id = validCharacterId(value.targetObjectId);
        return id == null ? value : value.copyWith(targetObjectId: id);
      },
      characterWait: (value) => value,
      dialogueSay: (value) => value,
      cameraFocus: (value) => value,
      sceneFade: (value) => value,
      sceneChange: (value) => value,
      audioPlayBgm: (value) => value,
      audioPlaySound: (value) => value,
      videoPlay: (value) => value,
      overlayShow: (value) => value,
    );
  }

  bool _isCharacterObjectId(List<SceneObject> objects, String id) {
    return objects.any(
      (object) => object.objectId == id && object is CharacterInstanceObject,
    );
  }

  String? _characterObjectIdAt(List<SceneObject> objects, int index) {
    var seen = 0;
    for (final object in objects) {
      if (object is! CharacterInstanceObject) {
        continue;
      }
      if (seen == index) {
        return object.id;
      }
      seen += 1;
    }
    return null;
  }

  String _eventChainIdForTrigger(Trigger trigger) {
    return trigger.map(
      area: (value) => value.eventChainId,
      object: (value) => value.eventChainId,
      auto: (value) => value.eventChainId,
      moveComplete: (value) => value.eventChainId,
    );
  }

  SceneObject _migrateSceneObject(SceneObject object) {
    return object.maybeMap(
      triggerArea: (value) {
        const width = 22.0;
        const height = 22.0;
        final centerX =
            value.transform.x +
            value.transform.width * value.transform.scale / 2;
        final centerY =
            value.transform.y +
            value.transform.height * value.transform.scale / 2;
        return SceneObject.triggerPoint(
          id: value.id,
          name: value.name,
          triggerId: value.triggerId,
          transform: value.transform.copyWith(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height,
            scale: 1,
          ),
          locked: value.locked,
        );
      },
      orElse: () => object,
    );
  }

  Future<AssetRef> importAsset({
    required Directory projectDirectory,
    required File source,
    required AssetKind kind,
  }) async {
    await _ensureProjectLayout(projectDirectory);
    final id = StudioIds.asset();
    final originalName = p.basename(source.path);
    final targetDirectory = Directory(
      p.join(projectDirectory.path, 'assets', _folderForKind(kind)),
    );
    await targetDirectory.create(recursive: true);
    final targetPath = p.join(targetDirectory.path, '${id}_$originalName');
    await source.copy(targetPath);
    return AssetRef(
      id: id,
      kind: kind,
      originalName: originalName,
      relativePath: p.relative(targetPath, from: projectDirectory.path),
    );
  }

  Future<AssetRef> importAssetBytes({
    required Directory projectDirectory,
    required List<int> bytes,
    required AssetKind kind,
    required String originalName,
    String? id,
  }) async {
    await _ensureProjectLayout(projectDirectory);
    final assetId = id ?? StudioIds.asset();
    final targetDirectory = Directory(
      p.join(projectDirectory.path, 'assets', _folderForKind(kind)),
    );
    await targetDirectory.create(recursive: true);
    final safeName = originalName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final targetPath = p.join(targetDirectory.path, '${assetId}_$safeName');
    await File(targetPath).writeAsBytes(bytes, flush: true);
    return AssetRef(
      id: assetId,
      kind: kind,
      originalName: originalName,
      relativePath: p.relative(targetPath, from: projectDirectory.path),
    );
  }

  Future<void> _ensureProjectLayout(Directory directory) async {
    await directory.create(recursive: true);
    for (final path in [
      'scenes',
      'characters',
      'assets/backgrounds',
      'assets/characters',
      'assets/dialogue_portraits',
      'assets/audio',
      'assets/props',
      'settings',
    ]) {
      await Directory(p.join(directory.path, path)).create(recursive: true);
    }
  }

  Future<void> _copyDirectory(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list(recursive: false)) {
      final targetPath = p.join(target.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(targetPath));
      } else if (entity is File) {
        await File(targetPath).parent.create(recursive: true);
        await entity.copy(targetPath);
      }
    }
  }

  String _folderForKind(AssetKind kind) {
    return switch (kind) {
      AssetKind.background => 'backgrounds',
      AssetKind.character => 'characters',
      AssetKind.audio => 'audio',
      AssetKind.prop => 'props',
      AssetKind.dialoguePortrait => 'dialogue_portraits',
      AssetKind.video => 'video',
    };
  }
}
