// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'studio_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudioProject _$StudioProjectFromJson(Map<String, dynamic> json) =>
    _StudioProject(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 4,
      id: json['id'] as String,
      name: json['name'] as String,
      currentSceneId: json['currentSceneId'] as String,
      scenes: (json['scenes'] as List<dynamic>)
          .map((e) => Scene.fromJson(e as Map<String, dynamic>))
          .toList(),
      characters: (json['characters'] as List<dynamic>)
          .map((e) => Character.fromJson(e as Map<String, dynamic>))
          .toList(),
      assets: (json['assets'] as List<dynamic>)
          .map((e) => AssetRef.fromJson(e as Map<String, dynamic>))
          .toList(),
      editorLayout: json['editorLayout'] == null
          ? const EditorLayout()
          : EditorLayout.fromJson(json['editorLayout'] as Map<String, dynamic>),
      settings: json['settings'] == null
          ? const EditorSettings()
          : EditorSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StudioProjectToJson(_StudioProject instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'id': instance.id,
      'name': instance.name,
      'currentSceneId': instance.currentSceneId,
      'scenes': instance.scenes,
      'characters': instance.characters,
      'assets': instance.assets,
      'editorLayout': instance.editorLayout,
      'settings': instance.settings,
    };

_EditorLayout _$EditorLayoutFromJson(Map<String, dynamic> json) =>
    _EditorLayout(
      leftSidebarWidth: (json['leftSidebarWidth'] as num?)?.toDouble() ?? 220,
      rightSidebarWidth: (json['rightSidebarWidth'] as num?)?.toDouble() ?? 280,
      bottomPanelHeight: (json['bottomPanelHeight'] as num?)?.toDouble() ?? 300,
      timelinePixelsPerSecond:
          (json['timelinePixelsPerSecond'] as num?)?.toDouble() ?? 100,
      timelineTrackHeight:
          (json['timelineTrackHeight'] as num?)?.toDouble() ?? 66,
    );

Map<String, dynamic> _$EditorLayoutToJson(_EditorLayout instance) =>
    <String, dynamic>{
      'leftSidebarWidth': instance.leftSidebarWidth,
      'rightSidebarWidth': instance.rightSidebarWidth,
      'bottomPanelHeight': instance.bottomPanelHeight,
      'timelinePixelsPerSecond': instance.timelinePixelsPerSecond,
      'timelineTrackHeight': instance.timelineTrackHeight,
    };

_EditorSettings _$EditorSettingsFromJson(Map<String, dynamic> json) =>
    _EditorSettings(
      language:
          $enumDecodeNullable(_$AppLanguageEnumMap, json['language']) ??
          AppLanguage.system,
      englishDialogueTypewriterByWord:
          json['englishDialogueTypewriterByWord'] as bool? ?? true,
      characterLibraryScope:
          $enumDecodeNullable(
            _$CharacterLibraryScopeEnumMap,
            json['characterLibraryScope'],
          ) ??
          CharacterLibraryScope.global,
    );

Map<String, dynamic> _$EditorSettingsToJson(
  _EditorSettings instance,
) => <String, dynamic>{
  'language': _$AppLanguageEnumMap[instance.language]!,
  'englishDialogueTypewriterByWord': instance.englishDialogueTypewriterByWord,
  'characterLibraryScope':
      _$CharacterLibraryScopeEnumMap[instance.characterLibraryScope]!,
};

const _$AppLanguageEnumMap = {
  AppLanguage.system: 'system',
  AppLanguage.english: 'english',
  AppLanguage.chinese: 'chinese',
};

const _$CharacterLibraryScopeEnumMap = {
  CharacterLibraryScope.global: 'global',
  CharacterLibraryScope.project: 'project',
};

_AssetRef _$AssetRefFromJson(Map<String, dynamic> json) => _AssetRef(
  id: json['id'] as String,
  kind: $enumDecode(
    _$AssetKindEnumMap,
    json['kind'],
    unknownValue: AssetKind.prop,
  ),
  relativePath: json['relativePath'] as String,
  originalName: json['originalName'] as String,
  dataUri: json['dataUri'] as String?,
);

Map<String, dynamic> _$AssetRefToJson(_AssetRef instance) => <String, dynamic>{
  'id': instance.id,
  'kind': _$AssetKindEnumMap[instance.kind]!,
  'relativePath': instance.relativePath,
  'originalName': instance.originalName,
  'dataUri': instance.dataUri,
};

const _$AssetKindEnumMap = {
  AssetKind.background: 'background',
  AssetKind.character: 'character',
  AssetKind.audio: 'audio',
  AssetKind.prop: 'prop',
  AssetKind.dialoguePortrait: 'dialoguePortrait',
  AssetKind.video: 'video',
};

_Scene _$SceneFromJson(Map<String, dynamic> json) => _Scene(
  id: json['id'] as String,
  name: json['name'] as String,
  backgroundAssetId: json['backgroundAssetId'] as String?,
  objects: (json['objects'] as List<dynamic>)
      .map((e) => SceneObject.fromJson(e as Map<String, dynamic>))
      .toList(),
  triggers: (json['triggers'] as List<dynamic>)
      .map((e) => Trigger.fromJson(e as Map<String, dynamic>))
      .toList(),
  eventChains: (json['eventChains'] as List<dynamic>)
      .map((e) => EventChain.fromJson(e as Map<String, dynamic>))
      .toList(),
  interestPoints: (json['interestPoints'] as List<dynamic>)
      .map((e) => InterestPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  cameraPolicy: CameraPolicy.fromJson(
    json['cameraPolicy'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SceneToJson(_Scene instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'backgroundAssetId': instance.backgroundAssetId,
  'objects': instance.objects,
  'triggers': instance.triggers,
  'eventChains': instance.eventChains,
  'interestPoints': instance.interestPoints,
  'cameraPolicy': instance.cameraPolicy,
};

CharacterInstanceObject _$CharacterInstanceObjectFromJson(
  Map<String, dynamic> json,
) => CharacterInstanceObject(
  id: json['id'] as String,
  name: json['name'] as String,
  characterId: json['characterId'] as String,
  transform: Transform2D.fromJson(json['transform'] as Map<String, dynamic>),
  facing: $enumDecode(_$DirectionEnumMap, json['facing']),
  initialExpression: json['initialExpression'] as String?,
  activity: json['activity'] == null
      ? null
      : ActivityProfile.fromJson(json['activity'] as Map<String, dynamic>),
  locked: json['locked'] as bool? ?? false,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CharacterInstanceObjectToJson(
  CharacterInstanceObject instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'characterId': instance.characterId,
  'transform': instance.transform,
  'facing': _$DirectionEnumMap[instance.facing]!,
  'initialExpression': instance.initialExpression,
  'activity': instance.activity,
  'locked': instance.locked,
  'type': instance.$type,
};

const _$DirectionEnumMap = {
  Direction.up: 'up',
  Direction.down: 'down',
  Direction.left: 'left',
  Direction.right: 'right',
};

PropSceneObject _$PropSceneObjectFromJson(Map<String, dynamic> json) =>
    PropSceneObject(
      id: json['id'] as String,
      name: json['name'] as String,
      assetId: json['assetId'] as String,
      transform: Transform2D.fromJson(
        json['transform'] as Map<String, dynamic>,
      ),
      interactable: json['interactable'] as bool? ?? false,
      locked: json['locked'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PropSceneObjectToJson(PropSceneObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'assetId': instance.assetId,
      'transform': instance.transform,
      'interactable': instance.interactable,
      'locked': instance.locked,
      'type': instance.$type,
    };

BackgroundObject _$BackgroundObjectFromJson(Map<String, dynamic> json) =>
    BackgroundObject(
      id: json['id'] as String,
      name: json['name'] as String,
      assetId: json['assetId'] as String,
      transform: Transform2D.fromJson(
        json['transform'] as Map<String, dynamic>,
      ),
      locked: json['locked'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$BackgroundObjectToJson(BackgroundObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'assetId': instance.assetId,
      'transform': instance.transform,
      'locked': instance.locked,
      'type': instance.$type,
    };

TriggerPointObject _$TriggerPointObjectFromJson(Map<String, dynamic> json) =>
    TriggerPointObject(
      id: json['id'] as String,
      name: json['name'] as String,
      triggerId: json['triggerId'] as String,
      transform: Transform2D.fromJson(
        json['transform'] as Map<String, dynamic>,
      ),
      locked: json['locked'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TriggerPointObjectToJson(TriggerPointObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'triggerId': instance.triggerId,
      'transform': instance.transform,
      'locked': instance.locked,
      'type': instance.$type,
    };

TriggerAreaObject _$TriggerAreaObjectFromJson(Map<String, dynamic> json) =>
    TriggerAreaObject(
      id: json['id'] as String,
      name: json['name'] as String,
      triggerId: json['triggerId'] as String,
      transform: Transform2D.fromJson(
        json['transform'] as Map<String, dynamic>,
      ),
      locked: json['locked'] as bool? ?? false,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$TriggerAreaObjectToJson(TriggerAreaObject instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'triggerId': instance.triggerId,
      'transform': instance.transform,
      'locked': instance.locked,
      'type': instance.$type,
    };

_Transform2D _$Transform2DFromJson(Map<String, dynamic> json) => _Transform2D(
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num?)?.toDouble() ?? 48,
  height: (json['height'] as num?)?.toDouble() ?? 64,
  scale: (json['scale'] as num?)?.toDouble() ?? 1,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$Transform2DToJson(_Transform2D instance) =>
    <String, dynamic>{
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'scale': instance.scale,
      'rotation': instance.rotation,
    };

_Character _$CharacterFromJson(Map<String, dynamic> json) => _Character(
  id: json['id'] as String,
  name: json['name'] as String,
  animations: (json['animations'] as List<dynamic>)
      .map((e) => AnimationClip.fromJson(e as Map<String, dynamic>))
      .toList(),
  expressions: (json['expressions'] as List<dynamic>)
      .map((e) => CharacterExpression.fromJson(e as Map<String, dynamic>))
      .toList(),
  movement: CharacterMovementProfile.fromJson(
    json['movement'] as Map<String, dynamic>,
  ),
  defaultTransform: json['defaultTransform'] == null
      ? const Transform2D(x: 180, y: 180)
      : Transform2D.fromJson(json['defaultTransform'] as Map<String, dynamic>),
  defaultFacing:
      $enumDecodeNullable(_$DirectionEnumMap, json['defaultFacing']) ??
      Direction.down,
  defaultExpressionId: json['defaultExpressionId'] as String?,
);

Map<String, dynamic> _$CharacterToJson(_Character instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'animations': instance.animations,
      'expressions': instance.expressions,
      'movement': instance.movement,
      'defaultTransform': instance.defaultTransform,
      'defaultFacing': _$DirectionEnumMap[instance.defaultFacing]!,
      'defaultExpressionId': instance.defaultExpressionId,
    };

_AnimationClip _$AnimationClipFromJson(Map<String, dynamic> json) =>
    _AnimationClip(
      id: json['id'] as String,
      name: json['name'] as String,
      assetId: json['assetId'] as String,
      direction: $enumDecodeNullable(_$DirectionEnumMap, json['direction']),
      framesPerSecond: (json['framesPerSecond'] as num?)?.toDouble() ?? 8,
    );

Map<String, dynamic> _$AnimationClipToJson(_AnimationClip instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'assetId': instance.assetId,
      'direction': _$DirectionEnumMap[instance.direction],
      'framesPerSecond': instance.framesPerSecond,
    };

_CharacterExpression _$CharacterExpressionFromJson(Map<String, dynamic> json) =>
    _CharacterExpression(
      id: json['id'] as String,
      name: json['name'] as String,
      assetId: json['assetId'] as String?,
      direction: $enumDecodeNullable(_$DirectionEnumMap, json['direction']),
      assetIds:
          (json['assetIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      framesPerSecond: (json['framesPerSecond'] as num?)?.toDouble() ?? 6,
      loop: json['loop'] as bool? ?? true,
    );

Map<String, dynamic> _$CharacterExpressionToJson(
  _CharacterExpression instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'assetId': instance.assetId,
  'direction': _$DirectionEnumMap[instance.direction],
  'assetIds': instance.assetIds,
  'framesPerSecond': instance.framesPerSecond,
  'loop': instance.loop,
};

_CharacterMovementProfile _$CharacterMovementProfileFromJson(
  Map<String, dynamic> json,
) => _CharacterMovementProfile(
  defaultSpeed: (json['defaultSpeed'] as num?)?.toDouble() ?? 320,
  defaultShake: (json['defaultShake'] as num?)?.toDouble() ?? 16,
);

Map<String, dynamic> _$CharacterMovementProfileToJson(
  _CharacterMovementProfile instance,
) => <String, dynamic>{
  'defaultSpeed': instance.defaultSpeed,
  'defaultShake': instance.defaultShake,
};

_MovementPath _$MovementPathFromJson(Map<String, dynamic> json) =>
    _MovementPath(
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => PathNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      speed: (json['speed'] as num?)?.toDouble() ?? 320,
      shake: (json['shake'] as num?)?.toDouble() ?? 0,
      mode:
          $enumDecodeNullable(_$MovementModeEnumMap, json['mode']) ??
          MovementMode.fourWay,
    );

Map<String, dynamic> _$MovementPathToJson(_MovementPath instance) =>
    <String, dynamic>{
      'nodes': instance.nodes,
      'speed': instance.speed,
      'shake': instance.shake,
      'mode': _$MovementModeEnumMap[instance.mode]!,
    };

const _$MovementModeEnumMap = {
  MovementMode.fourWay: 'fourWay',
  MovementMode.eightWay: 'eightWay',
  MovementMode.free: 'free',
};

_PathNode _$PathNodeFromJson(Map<String, dynamic> json) => _PathNode(
  id: json['id'] as String,
  name: json['name'] as String? ?? 'Node',
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  waitSeconds: (json['waitSeconds'] as num?)?.toDouble(),
  triggerId: json['triggerId'] as String?,
);

Map<String, dynamic> _$PathNodeToJson(_PathNode instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'x': instance.x,
  'y': instance.y,
  'waitSeconds': instance.waitSeconds,
  'triggerId': instance.triggerId,
};

_ActivityProfile _$ActivityProfileFromJson(Map<String, dynamic> json) =>
    _ActivityProfile(
      zoneId: json['zoneId'] as String,
      level: (json['level'] as num?)?.toInt() ?? 50,
      idleBias: (json['idleBias'] as num?)?.toDouble() ?? 0.5,
      interestBias: (json['interestBias'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$ActivityProfileToJson(_ActivityProfile instance) =>
    <String, dynamic>{
      'zoneId': instance.zoneId,
      'level': instance.level,
      'idleBias': instance.idleBias,
      'interestBias': instance.interestBias,
    };

_InterestPoint _$InterestPointFromJson(Map<String, dynamic> json) =>
    _InterestPoint(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: json['kind'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );

Map<String, dynamic> _$InterestPointToJson(_InterestPoint instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': instance.kind,
      'x': instance.x,
      'y': instance.y,
    };

AreaTrigger _$AreaTriggerFromJson(Map<String, dynamic> json) => AreaTrigger(
  id: json['id'] as String,
  name: json['name'] as String,
  eventChainId: json['eventChainId'] as String,
  linkedTriggerId: json['linkedTriggerId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AreaTriggerToJson(AreaTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'eventChainId': instance.eventChainId,
      'linkedTriggerId': instance.linkedTriggerId,
      'type': instance.$type,
    };

ObjectTrigger _$ObjectTriggerFromJson(Map<String, dynamic> json) =>
    ObjectTrigger(
      id: json['id'] as String,
      name: json['name'] as String,
      objectId: json['objectId'] as String,
      eventChainId: json['eventChainId'] as String,
      linkedTriggerId: json['linkedTriggerId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$ObjectTriggerToJson(ObjectTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'objectId': instance.objectId,
      'eventChainId': instance.eventChainId,
      'linkedTriggerId': instance.linkedTriggerId,
      'type': instance.$type,
    };

AutoTrigger _$AutoTriggerFromJson(Map<String, dynamic> json) => AutoTrigger(
  id: json['id'] as String,
  name: json['name'] as String,
  eventChainId: json['eventChainId'] as String,
  linkedTriggerId: json['linkedTriggerId'] as String?,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$AutoTriggerToJson(AutoTrigger instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'eventChainId': instance.eventChainId,
      'linkedTriggerId': instance.linkedTriggerId,
      'type': instance.$type,
    };

MoveCompleteTrigger _$MoveCompleteTriggerFromJson(Map<String, dynamic> json) =>
    MoveCompleteTrigger(
      id: json['id'] as String,
      name: json['name'] as String,
      targetObjectId: json['targetObjectId'] as String,
      eventChainId: json['eventChainId'] as String,
      linkedTriggerId: json['linkedTriggerId'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$MoveCompleteTriggerToJson(
  MoveCompleteTrigger instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetObjectId': instance.targetObjectId,
  'eventChainId': instance.eventChainId,
  'linkedTriggerId': instance.linkedTriggerId,
  'type': instance.$type,
};

_EventChain _$EventChainFromJson(Map<String, dynamic> json) => _EventChain(
  id: json['id'] as String,
  name: json['name'] as String,
  triggerMode:
      $enumDecodeNullable(
        _$EventChainTriggerModeEnumMap,
        json['triggerMode'],
      ) ??
      EventChainTriggerMode.always,
  startTime: (json['startTime'] as num?)?.toDouble() ?? 0,
  events: (json['events'] as List<dynamic>)
      .map((e) => StudioEvent.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EventChainToJson(_EventChain instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'triggerMode': _$EventChainTriggerModeEnumMap[instance.triggerMode]!,
      'startTime': instance.startTime,
      'events': instance.events,
    };

const _$EventChainTriggerModeEnumMap = {
  EventChainTriggerMode.triggerPoint: 'triggerPoint',
  EventChainTriggerMode.always: 'always',
  EventChainTriggerMode.scheduled: 'scheduled',
};

CharacterMoveEvent _$CharacterMoveEventFromJson(Map<String, dynamic> json) =>
    CharacterMoveEvent(
      id: json['id'] as String,
      characterObjectId: json['characterObjectId'] as String,
      path: MovementPath.fromJson(json['path'] as Map<String, dynamic>),
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$CharacterMoveEventToJson(CharacterMoveEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'characterObjectId': instance.characterObjectId,
      'path': instance.path,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

CharacterWaitEvent _$CharacterWaitEventFromJson(Map<String, dynamic> json) =>
    CharacterWaitEvent(
      id: json['id'] as String,
      duration: (json['duration'] as num?)?.toDouble() ?? 1,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$CharacterWaitEventToJson(CharacterWaitEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

CharacterChangeExpressionEvent _$CharacterChangeExpressionEventFromJson(
  Map<String, dynamic> json,
) => CharacterChangeExpressionEvent(
  id: json['id'] as String,
  characterObjectId: json['characterObjectId'] as String,
  expressionId: json['expressionId'] as String,
  duration: (json['duration'] as num?)?.toDouble() ?? 1,
  scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CharacterChangeExpressionEventToJson(
  CharacterChangeExpressionEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'characterObjectId': instance.characterObjectId,
  'expressionId': instance.expressionId,
  'duration': instance.duration,
  'scheduleStart': instance.scheduleStart,
  'type': instance.$type,
};

CharacterStartFollowEvent _$CharacterStartFollowEventFromJson(
  Map<String, dynamic> json,
) => CharacterStartFollowEvent(
  id: json['id'] as String,
  followerObjectId: json['followerObjectId'] as String,
  leaderObjectId: json['leaderObjectId'] as String,
  distance: (json['distance'] as num?)?.toDouble() ?? 48,
  scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CharacterStartFollowEventToJson(
  CharacterStartFollowEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'followerObjectId': instance.followerObjectId,
  'leaderObjectId': instance.leaderObjectId,
  'distance': instance.distance,
  'scheduleStart': instance.scheduleStart,
  'type': instance.$type,
};

CharacterStopFollowEvent _$CharacterStopFollowEventFromJson(
  Map<String, dynamic> json,
) => CharacterStopFollowEvent(
  id: json['id'] as String,
  followerObjectId: json['followerObjectId'] as String,
  scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CharacterStopFollowEventToJson(
  CharacterStopFollowEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'followerObjectId': instance.followerObjectId,
  'scheduleStart': instance.scheduleStart,
  'type': instance.$type,
};

DialogueSayEvent _$DialogueSayEventFromJson(Map<String, dynamic> json) =>
    DialogueSayEvent(
      id: json['id'] as String,
      text: json['text'] as String,
      portraitAssetId: json['portraitAssetId'] as String?,
      textSoundAssetId: json['textSoundAssetId'] as String?,
      style:
          $enumDecodeNullable(_$DialogueStyleEnumMap, json['style']) ??
          DialogueStyle.regular,
      duration: (json['duration'] as num?)?.toDouble() ?? 2,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$DialogueSayEventToJson(DialogueSayEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'portraitAssetId': instance.portraitAssetId,
      'textSoundAssetId': instance.textSoundAssetId,
      'style': _$DialogueStyleEnumMap[instance.style]!,
      'duration': instance.duration,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

const _$DialogueStyleEnumMap = {
  DialogueStyle.regular: 'regular',
  DialogueStyle.darkWorld: 'darkWorld',
};

CameraFollowEvent _$CameraFollowEventFromJson(Map<String, dynamic> json) =>
    CameraFollowEvent(
      id: json['id'] as String,
      targetObjectId: json['targetObjectId'] as String,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$CameraFollowEventToJson(CameraFollowEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'targetObjectId': instance.targetObjectId,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

CameraFocusEvent _$CameraFocusEventFromJson(Map<String, dynamic> json) =>
    CameraFocusEvent(
      id: json['id'] as String,
      target: FocusTarget.fromJson(json['target'] as Map<String, dynamic>),
      duration: (json['duration'] as num?)?.toDouble() ?? 0.5,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$CameraFocusEventToJson(CameraFocusEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'target': instance.target,
      'duration': instance.duration,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

SceneFadeEvent _$SceneFadeEventFromJson(Map<String, dynamic> json) =>
    SceneFadeEvent(
      id: json['id'] as String,
      mode: $enumDecode(_$FadeModeEnumMap, json['mode']),
      duration: (json['duration'] as num?)?.toDouble() ?? 0.8,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$SceneFadeEventToJson(SceneFadeEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mode': _$FadeModeEnumMap[instance.mode]!,
      'duration': instance.duration,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

const _$FadeModeEnumMap = {FadeMode.in_: 'in_', FadeMode.out: 'out'};

SceneChangeEvent _$SceneChangeEventFromJson(Map<String, dynamic> json) =>
    SceneChangeEvent(
      id: json['id'] as String,
      sceneId: json['sceneId'] as String,
      entryPointId: json['entryPointId'] as String?,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$SceneChangeEventToJson(SceneChangeEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sceneId': instance.sceneId,
      'entryPointId': instance.entryPointId,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

AudioPlayBgmEvent _$AudioPlayBgmEventFromJson(Map<String, dynamic> json) =>
    AudioPlayBgmEvent(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AudioPlayBgmEventToJson(AudioPlayBgmEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

AudioPlaySoundEvent _$AudioPlaySoundEventFromJson(Map<String, dynamic> json) =>
    AudioPlaySoundEvent(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$AudioPlaySoundEventToJson(
  AudioPlaySoundEvent instance,
) => <String, dynamic>{
  'id': instance.id,
  'assetId': instance.assetId,
  'scheduleStart': instance.scheduleStart,
  'type': instance.$type,
};

VideoPlayEvent _$VideoPlayEventFromJson(Map<String, dynamic> json) =>
    VideoPlayEvent(
      id: json['id'] as String,
      assetId: json['assetId'] as String,
      duration: (json['duration'] as num?)?.toDouble() ?? 3,
      fit:
          $enumDecodeNullable(_$VideoFitModeEnumMap, json['fit']) ??
          VideoFitMode.contain,
      scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$VideoPlayEventToJson(VideoPlayEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetId': instance.assetId,
      'duration': instance.duration,
      'fit': _$VideoFitModeEnumMap[instance.fit]!,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

const _$VideoFitModeEnumMap = {VideoFitMode.contain: 'contain'};

OverlayShowEvent _$OverlayShowEventFromJson(
  Map<String, dynamic> json,
) => OverlayShowEvent(
  id: json['id'] as String,
  space:
      $enumDecodeNullable(_$OverlaySpaceEnumMap, json['space']) ??
      OverlaySpace.camera,
  contentKind:
      $enumDecodeNullable(_$OverlayContentKindEnumMap, json['contentKind']) ??
      OverlayContentKind.image,
  assetId: json['assetId'] as String?,
  text: json['text'] as String?,
  color: json['color'] as String? ?? '#FFFFFFFF',
  textStyle: json['textStyle'] == null
      ? const OverlayTextStyle()
      : OverlayTextStyle.fromJson(json['textStyle'] as Map<String, dynamic>),
  anchor:
      $enumDecodeNullable(_$OverlayAnchorEnumMap, json['anchor']) ??
      OverlayAnchor.center,
  transform: json['transform'] == null
      ? const Transform2D(x: 0, y: 0, width: 160, height: 90)
      : Transform2D.fromJson(json['transform'] as Map<String, dynamic>),
  opacity: (json['opacity'] as num?)?.toDouble() ?? 1,
  rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
  zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
  boundObjectId: json['boundObjectId'] as String?,
  fadeIn: (json['fadeIn'] as num?)?.toDouble() ?? 0,
  fadeOut: (json['fadeOut'] as num?)?.toDouble() ?? 0,
  duration: (json['duration'] as num?)?.toDouble() ?? 2,
  videoFallbackDuration:
      (json['videoFallbackDuration'] as num?)?.toDouble() ?? 3,
  scheduleStart: (json['scheduleStart'] as num?)?.toDouble() ?? 0,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$OverlayShowEventToJson(OverlayShowEvent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'space': _$OverlaySpaceEnumMap[instance.space]!,
      'contentKind': _$OverlayContentKindEnumMap[instance.contentKind]!,
      'assetId': instance.assetId,
      'text': instance.text,
      'color': instance.color,
      'textStyle': instance.textStyle,
      'anchor': _$OverlayAnchorEnumMap[instance.anchor]!,
      'transform': instance.transform,
      'opacity': instance.opacity,
      'rotation': instance.rotation,
      'zIndex': instance.zIndex,
      'boundObjectId': instance.boundObjectId,
      'fadeIn': instance.fadeIn,
      'fadeOut': instance.fadeOut,
      'duration': instance.duration,
      'videoFallbackDuration': instance.videoFallbackDuration,
      'scheduleStart': instance.scheduleStart,
      'type': instance.$type,
    };

const _$OverlaySpaceEnumMap = {
  OverlaySpace.camera: 'camera',
  OverlaySpace.world: 'world',
  OverlaySpace.fullscreen: 'fullscreen',
};

const _$OverlayContentKindEnumMap = {
  OverlayContentKind.image: 'image',
  OverlayContentKind.video: 'video',
  OverlayContentKind.text: 'text',
  OverlayContentKind.color: 'color',
};

const _$OverlayAnchorEnumMap = {
  OverlayAnchor.topLeft: 'topLeft',
  OverlayAnchor.topCenter: 'topCenter',
  OverlayAnchor.topRight: 'topRight',
  OverlayAnchor.centerLeft: 'centerLeft',
  OverlayAnchor.center: 'center',
  OverlayAnchor.centerRight: 'centerRight',
  OverlayAnchor.bottomLeft: 'bottomLeft',
  OverlayAnchor.bottomCenter: 'bottomCenter',
  OverlayAnchor.bottomRight: 'bottomRight',
};

FollowPlayerCameraPolicy _$FollowPlayerCameraPolicyFromJson(
  Map<String, dynamic> json,
) => FollowPlayerCameraPolicy(
  playerObjectId: json['playerObjectId'] as String,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$FollowPlayerCameraPolicyToJson(
  FollowPlayerCameraPolicy instance,
) => <String, dynamic>{
  'playerObjectId': instance.playerObjectId,
  'type': instance.$type,
};

FocusCameraPolicy _$FocusCameraPolicyFromJson(Map<String, dynamic> json) =>
    FocusCameraPolicy(
      target: FocusTarget.fromJson(json['target'] as Map<String, dynamic>),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$FocusCameraPolicyToJson(FocusCameraPolicy instance) =>
    <String, dynamic>{'target': instance.target, 'type': instance.$type};

ObjectFocusTarget _$ObjectFocusTargetFromJson(Map<String, dynamic> json) =>
    ObjectFocusTarget(
      objectId: json['objectId'] as String,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$ObjectFocusTargetToJson(ObjectFocusTarget instance) =>
    <String, dynamic>{'objectId': instance.objectId, 'type': instance.$type};

PointFocusTarget _$PointFocusTargetFromJson(Map<String, dynamic> json) =>
    PointFocusTarget(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$PointFocusTargetToJson(PointFocusTarget instance) =>
    <String, dynamic>{'x': instance.x, 'y': instance.y, 'type': instance.$type};
