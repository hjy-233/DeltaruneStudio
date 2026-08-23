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
  const ProjectScene({required this.id, required this.name});

  final String id;
  final String name;

  factory ProjectScene.fromJson(Map<String, dynamic> json) {
    return ProjectScene(
      id: json['id'] as String? ?? 'main',
      name: json['name'] as String? ?? 'Main',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': 1,
      'id': id,
      'name': name,
      'objects': <Object?>[],
      'triggers': <Object?>[],
      'eventChains': <Object?>[],
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
