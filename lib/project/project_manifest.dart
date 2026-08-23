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
  });

  final int formatVersion;
  final String id;
  final String name;
  final String mainScene;
  final List<String> rooms;
  final ProjectLayout layout;

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
    };
  }

  ProjectManifest copyWith({List<String>? rooms, ProjectLayout? layout}) {
    return ProjectManifest(
      formatVersion: formatVersion,
      id: id,
      name: name,
      mainScene: mainScene,
      rooms: rooms ?? this.rooms,
      layout: layout ?? this.layout,
    );
  }
}

class ProjectScene {
  const ProjectScene({
    required this.id,
    required this.name,
    this.background,
    this.objects = const [],
  });

  final String id;
  final String name;
  final String? background;
  final List<ProjectSceneObject> objects;

  ProjectScene copyWith({
    String? background,
    List<ProjectSceneObject>? objects,
  }) {
    return ProjectScene(
      id: id,
      name: name,
      background: background ?? this.background,
      objects: objects ?? this.objects,
    );
  }

  factory ProjectScene.fromJson(Map<String, dynamic> json) {
    return ProjectScene(
      id: json['id'] as String? ?? 'main',
      name: json['name'] as String? ?? 'Main',
      background: json['background'] as String?,
      objects: (json['objects'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProjectSceneObject.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': 1,
      'id': id,
      'name': name,
      'background': background,
      'objects': objects.map((object) => object.toJson()).toList(),
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

  ProjectSceneObject copyWith({
    String? type,
    String? name,
    String? asset,
    double? x,
    double? y,
    int? zIndex,
    double? width,
    double? height,
    bool? locked,
  }) {
    return ProjectSceneObject(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      asset: asset ?? this.asset,
      x: x ?? this.x,
      y: y ?? this.y,
      zIndex: zIndex ?? this.zIndex,
      width: width ?? this.width,
      height: height ?? this.height,
      locked: locked ?? this.locked,
    );
  }

  factory ProjectSceneObject.fromJson(Map<String, dynamic> json) {
    return ProjectSceneObject(
      id: json['id'] as String? ?? 'object',
      type: json['type'] as String? ?? 'prop',
      name: json['name'] as String? ?? 'Object',
      asset: json['asset'] as String? ?? json['resource'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 320,
      y: (json['y'] as num?)?.toDouble() ?? 240,
      zIndex: (json['zIndex'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toDouble() ?? -1,
      height: (json['height'] as num?)?.toDouble() ?? -1,
      locked: json['locked'] as bool? ?? false,
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
    };
  }
}

class ProjectDocument {
  const ProjectDocument({
    required this.manifest,
    required this.mainScene,
    required this.path,
    this.rooms = const [],
    this.assets = const [],
  });

  final ProjectManifest manifest;
  final ProjectScene mainScene;
  final String path;
  final List<ProjectRoom> rooms;
  final List<ProjectAsset> assets;

  ProjectDocument copyWith({
    ProjectManifest? manifest,
    ProjectScene? mainScene,
    List<ProjectRoom>? rooms,
    List<ProjectAsset>? assets,
  }) {
    return ProjectDocument(
      manifest: manifest ?? this.manifest,
      mainScene: mainScene ?? this.mainScene,
      path: path,
      rooms: rooms ?? this.rooms,
      assets: assets ?? this.assets,
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
