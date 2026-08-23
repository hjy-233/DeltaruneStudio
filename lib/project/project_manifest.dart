class ProjectManifest {
  const ProjectManifest({
    required this.formatVersion,
    required this.id,
    required this.name,
    required this.mainScene,
  });

  final int formatVersion;
  final String id;
  final String name;
  final String mainScene;

  factory ProjectManifest.fromJson(Map<String, dynamic> json) {
    return ProjectManifest(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 1,
      id: json['id'] as String? ?? 'project',
      name: json['name'] as String? ?? 'Untitled Project',
      mainScene: json['mainScene'] as String? ?? 'scenes/main/scene.json',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'id': id,
      'name': name,
      'mainScene': mainScene,
    };
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
  });

  final String id;
  final String type;
  final String name;
  final String asset;
  final double x;
  final double y;
  final int zIndex;

  ProjectSceneObject copyWith({
    String? type,
    String? name,
    String? asset,
    double? x,
    double? y,
    int? zIndex,
  }) {
    return ProjectSceneObject(
      id: id,
      type: type ?? this.type,
      name: name ?? this.name,
      asset: asset ?? this.asset,
      x: x ?? this.x,
      y: y ?? this.y,
      zIndex: zIndex ?? this.zIndex,
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
    };
  }
}

class ProjectDocument {
  const ProjectDocument({
    required this.manifest,
    required this.mainScene,
    required this.path,
  });

  final ProjectManifest manifest;
  final ProjectScene mainScene;
  final String path;
}
