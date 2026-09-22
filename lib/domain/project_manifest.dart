import 'project_character.dart';
import 'project_content.dart';
import 'project_settings.dart';

const defaultProjectSceneLayers = [
  ProjectSceneLayer(id: 'background', name: 'Background', order: 0),
  ProjectSceneLayer(id: 'objects', name: 'Objects', order: 1),
  ProjectSceneLayer(id: 'characters', name: 'Characters', order: 2),
  ProjectSceneLayer(id: 'foreground', name: 'Foreground', order: 3),
];

const defaultEntryScript = 'scripts/manual/main.gd';

class ProjectSceneLayer {
  const ProjectSceneLayer({
    required this.id,
    required this.name,
    required this.order,
    this.visible = true,
    this.locked = false,
  });

  final String id;
  final String name;
  final int order;
  final bool visible;
  final bool locked;

  factory ProjectSceneLayer.fromJson(Map<String, dynamic> json) {
    return ProjectSceneLayer(
      id: json['id'] as String? ?? 'layer',
      name: json['name'] as String? ?? 'Layer',
      order: (json['order'] as num?)?.toInt() ?? 0,
      visible: json['visible'] as bool? ?? true,
      locked: json['locked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'order': order,
    'visible': visible,
    'locked': locked,
  };

  ProjectSceneLayer copyWith({
    String? name,
    int? order,
    bool? visible,
    bool? locked,
  }) {
    return ProjectSceneLayer(
      id: id,
      name: name ?? this.name,
      order: order ?? this.order,
      visible: visible ?? this.visible,
      locked: locked ?? this.locked,
    );
  }
}

class ProjectLayout {
  const ProjectLayout({this.sidebarWidth = 230, this.inspectorWidth = 300});

  final double sidebarWidth;
  final double inspectorWidth;

  factory ProjectLayout.fromJson(Map<String, dynamic>? json) {
    return ProjectLayout(
      sidebarWidth: (json?['sidebarWidth'] as num?)?.toDouble() ?? 230,
      inspectorWidth: (json?['inspectorWidth'] as num?)?.toDouble() ?? 300,
    );
  }

  Map<String, dynamic> toJson() => {
    'sidebarWidth': sidebarWidth,
    'inspectorWidth': inspectorWidth,
  };

  ProjectLayout copyWith({double? sidebarWidth, double? inspectorWidth}) {
    return ProjectLayout(
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      inspectorWidth: inspectorWidth ?? this.inspectorWidth,
    );
  }
}

class ProjectAsset {
  const ProjectAsset({
    required this.path,
    required this.name,
    required this.type,
  });

  final String path;
  final String name;
  final String type;
}

class ProjectManifest {
  const ProjectManifest({
    required this.formatVersion,
    required this.id,
    required this.name,
    required this.mainScene,
    this.rooms = const [],
    this.layout = const ProjectLayout(),
    this.entryScript = defaultEntryScript,
    this.gameSettings = const ProjectGameSettings(),
    this.exportSettings = const ProjectExportSettings(),
  });

  final int formatVersion;
  final String id;
  final String name;
  final String mainScene;
  final List<String> rooms;
  final ProjectLayout layout;
  final String entryScript;
  final ProjectGameSettings gameSettings;
  final ProjectExportSettings exportSettings;

  factory ProjectManifest.fromJson(Map<String, dynamic> json) {
    return ProjectManifest(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 1,
      id: json['id'] as String? ?? 'project',
      name: json['name'] as String? ?? 'Untitled Project',
      mainScene: json['mainScene'] as String? ?? 'scenes/main/scene.json',
      rooms: (json['rooms'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      layout: ProjectLayout.fromJson(json['layout'] as Map<String, dynamic>?),
      entryScript: json['entryScript'] as String? ?? defaultEntryScript,
      gameSettings: ProjectGameSettings.fromJson(
        json['gameSettings'] as Map<String, dynamic>?,
      ),
      exportSettings: ProjectExportSettings.fromJson(
        json['exportSettings'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'id': id,
      'name': name,
      'mainScene': mainScene,
      'rooms': rooms.isEmpty ? [mainScene] : rooms,
      'layout': layout.toJson(),
      'entryScript': entryScript,
      'gameSettings': gameSettings.toJson(),
      'exportSettings': exportSettings.toJson(),
    };
  }

  ProjectManifest copyWith({
    List<String>? rooms,
    ProjectLayout? layout,
    String? entryScript,
    ProjectGameSettings? gameSettings,
    ProjectExportSettings? exportSettings,
  }) {
    return ProjectManifest(
      formatVersion: formatVersion,
      id: id,
      name: name,
      mainScene: mainScene,
      rooms: rooms ?? this.rooms,
      layout: layout ?? this.layout,
      entryScript: entryScript ?? this.entryScript,
      gameSettings: gameSettings ?? this.gameSettings,
      exportSettings: exportSettings ?? this.exportSettings,
    );
  }
}

class ProjectScene {
  const ProjectScene({
    this.formatVersion = 3,
    required this.id,
    required this.name,
    this.background,
    this.objects = const [],
    this.layers = defaultProjectSceneLayers,
    this.tileMap = const ProjectTileMap(),
  });

  final int formatVersion;
  final String id;
  final String name;
  final String? background;
  final List<ProjectSceneObject> objects;
  final List<ProjectSceneLayer> layers;
  final ProjectTileMap tileMap;

  ProjectScene copyWith({
    int? formatVersion,
    String? id,
    String? name,
    String? background,
    bool clearBackground = false,
    List<ProjectSceneObject>? objects,
    List<ProjectSceneLayer>? layers,
    ProjectTileMap? tileMap,
  }) {
    return ProjectScene(
      formatVersion: formatVersion ?? this.formatVersion,
      id: id ?? this.id,
      name: name ?? this.name,
      background: clearBackground ? null : background ?? this.background,
      objects: objects ?? this.objects,
      layers: layers ?? this.layers,
      tileMap: tileMap ?? this.tileMap,
    );
  }

  factory ProjectScene.fromJson(Map<String, dynamic> json) {
    return ProjectScene(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 1,
      id: json['id'] as String? ?? 'main',
      name: json['name'] as String? ?? 'Main',
      background: json['background'] as String?,
      objects: (json['objects'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProjectSceneObject.fromJson)
          .toList(growable: false),
      layers: _sceneLayersFromJson(json['layers']),
      tileMap: ProjectTileMap.fromJson(
        json['tileMap'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'id': id,
      'name': name,
      'background': background,
      'objects': objects.map((object) => object.toJson()).toList(),
      'layers': layers.map((layer) => layer.toJson()).toList(),
      'tileMap': tileMap.toJson(),
      'triggers': <Object?>[],
      'eventChains': <Object?>[],
    };
  }
}

class ProjectSceneObject {
  const ProjectSceneObject({
    required this.id,
    required this.type,
    required this.name,
    required this.asset,
    required this.x,
    required this.y,
    required this.zIndex,
    this.width = -1,
    this.height = -1,
    this.locked = false,
    this.characterPath = '',
    this.layerId = 'objects',
    this.targetRoomPath = '',
    this.targetSpawnId = '',
    this.facing = 'down',
    this.defaultSpawn = false,
    this.saveSlot = 1,
    this.transitionColor = '#FF000000',
    this.fadeOutSeconds = 0.15,
    this.fadeInSeconds = 0.15,
    this.collision,
    this.interaction = const ProjectInteraction(),
  });

  final String id;
  final String type;
  final String name;
  final String asset;
  final double x;
  final double y;
  final int zIndex;
  final double width;
  final double height;
  final bool locked;
  final String characterPath;
  final String layerId;
  final String targetRoomPath;
  final String targetSpawnId;
  final String facing;
  final bool defaultSpawn;
  final int saveSlot;
  final String transitionColor;
  final double fadeOutSeconds;
  final double fadeInSeconds;
  final ProjectCollisionBox? collision;
  final ProjectInteraction interaction;

  ProjectSceneObject copyWith({
    String? id,
    String? type,
    String? name,
    String? asset,
    double? x,
    double? y,
    int? zIndex,
    double? width,
    double? height,
    bool? locked,
    String? characterPath,
    String? layerId,
    String? targetRoomPath,
    String? targetSpawnId,
    String? facing,
    bool? defaultSpawn,
    int? saveSlot,
    String? transitionColor,
    double? fadeOutSeconds,
    double? fadeInSeconds,
    ProjectCollisionBox? collision,
    bool clearCollision = false,
    ProjectInteraction? interaction,
  }) {
    return ProjectSceneObject(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      asset: asset ?? this.asset,
      x: x ?? this.x,
      y: y ?? this.y,
      zIndex: zIndex ?? this.zIndex,
      width: width ?? this.width,
      height: height ?? this.height,
      locked: locked ?? this.locked,
      characterPath: characterPath ?? this.characterPath,
      layerId: layerId ?? this.layerId,
      targetRoomPath: targetRoomPath ?? this.targetRoomPath,
      targetSpawnId: targetSpawnId ?? this.targetSpawnId,
      facing: facing ?? this.facing,
      defaultSpawn: defaultSpawn ?? this.defaultSpawn,
      saveSlot: saveSlot ?? this.saveSlot,
      transitionColor: transitionColor ?? this.transitionColor,
      fadeOutSeconds: fadeOutSeconds ?? this.fadeOutSeconds,
      fadeInSeconds: fadeInSeconds ?? this.fadeInSeconds,
      collision: clearCollision ? null : collision ?? this.collision,
      interaction: interaction ?? this.interaction,
    );
  }

  factory ProjectSceneObject.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'prop';
    return ProjectSceneObject(
      id: json['id'] as String? ?? 'object',
      type: type,
      name: json['name'] as String? ?? 'Object',
      asset: json['asset'] as String? ?? json['resource'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 320,
      y: (json['y'] as num?)?.toDouble() ?? 240,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? -1,
      height: (json['height'] as num?)?.toDouble() ?? -1,
      locked: json['locked'] as bool? ?? false,
      characterPath: json['character'] as String? ?? '',
      layerId: json['layer'] as String? ?? _defaultLayerForType(type),
      targetRoomPath: json['targetRoom'] as String? ?? '',
      targetSpawnId: json['targetSpawn'] as String? ?? '',
      facing: json['facing'] as String? ?? 'down',
      defaultSpawn: json['defaultSpawn'] as bool? ?? false,
      saveSlot: ((json['saveSlot'] as num?)?.toInt() ?? 1).clamp(1, 3),
      transitionColor: json['transitionColor'] as String? ?? '#FF000000',
      fadeOutSeconds: (json['fadeOutSeconds'] as num?)?.toDouble() ?? 0.15,
      fadeInSeconds: (json['fadeInSeconds'] as num?)?.toDouble() ?? 0.15,
      collision: json['collision'] is Map<String, dynamic>
          ? ProjectCollisionBox.fromJson(
              json['collision'] as Map<String, dynamic>,
            )
          : null,
      interaction: ProjectInteraction.fromJson(
        json['interaction'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'asset': asset,
      'x': x,
      'y': y,
      'zIndex': zIndex,
      'width': width,
      'height': height,
      'locked': locked,
      if (characterPath.isNotEmpty) 'character': characterPath,
      'layer': layerId,
      if (targetRoomPath.isNotEmpty) 'targetRoom': targetRoomPath,
      if (targetSpawnId.isNotEmpty) 'targetSpawn': targetSpawnId,
      if (type == 'spawn') 'facing': facing,
      if (type == 'spawn') 'defaultSpawn': defaultSpawn,
      if (type == 'savePoint') 'saveSlot': saveSlot,
      if (type == 'door') 'transitionColor': transitionColor,
      if (type == 'door') 'fadeOutSeconds': fadeOutSeconds,
      if (type == 'door') 'fadeInSeconds': fadeInSeconds,
      if (collision != null) 'collision': collision!.toJson(),
      if (interaction.enabled) 'interaction': interaction.toJson(),
    };
  }
}

class ProjectPrefab {
  const ProjectPrefab({
    required this.path,
    required this.id,
    required this.name,
    required this.object,
  });

  final String path;
  final String id;
  final String name;
  final ProjectSceneObject object;

  factory ProjectPrefab.fromJson(String path, Map<String, dynamic> json) {
    return ProjectPrefab(
      path: path,
      id: json['id'] as String? ?? 'prefab',
      name: json['name'] as String? ?? 'Prefab',
      object: ProjectSceneObject.fromJson(
        json['object'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'formatVersion': 1,
    'id': id,
    'name': name,
    'object': object.toJson(),
  };
}

String _defaultLayerForType(String type) {
  return switch (type) {
    'background' => 'background',
    'character' => 'characters',
    _ => 'objects',
  };
}

List<ProjectSceneLayer> _sceneLayersFromJson(Object? value) {
  final layers = (value as List<dynamic>? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(ProjectSceneLayer.fromJson)
      .toList(growable: false);
  return layers.isEmpty ? defaultProjectSceneLayers : layers;
}

class ProjectDocument {
  const ProjectDocument({
    required this.manifest,
    required this.mainScene,
    required this.path,
    this.rooms = const [],
    this.assets = const [],
    this.resourceFolders = const [],
    this.characters = const [],
    this.prefabs = const [],
    this.dialogues = const [],
  });

  final ProjectManifest manifest;
  final ProjectScene mainScene;
  final String path;
  final List<ProjectRoom> rooms;
  final List<ProjectAsset> assets;
  final List<String> resourceFolders;
  final List<ProjectCharacterFile> characters;
  final List<ProjectPrefab> prefabs;
  final List<ProjectDialogue> dialogues;

  ProjectDocument copyWith({
    ProjectManifest? manifest,
    ProjectScene? mainScene,
    List<ProjectRoom>? rooms,
    List<ProjectAsset>? assets,
    List<String>? resourceFolders,
    List<ProjectCharacterFile>? characters,
    List<ProjectPrefab>? prefabs,
    List<ProjectDialogue>? dialogues,
  }) {
    return ProjectDocument(
      manifest: manifest ?? this.manifest,
      mainScene: mainScene ?? this.mainScene,
      path: path,
      rooms: rooms ?? this.rooms,
      assets: assets ?? this.assets,
      resourceFolders: resourceFolders ?? this.resourceFolders,
      characters: characters ?? this.characters,
      prefabs: prefabs ?? this.prefabs,
      dialogues: dialogues ?? this.dialogues,
    );
  }
}

class ProjectRoom {
  const ProjectRoom({required this.path, required this.scene});

  final String path;
  final ProjectScene scene;

  ProjectRoom copyWith({ProjectScene? scene}) {
    return ProjectRoom(path: path, scene: scene ?? this.scene);
  }
}
