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
  const ProjectScene({required this.id, required this.name, this.background});

  final String id;
  final String name;
  final String? background;

  factory ProjectScene.fromJson(Map<String, dynamic> json) {
    return ProjectScene(
      id: json['id'] as String? ?? 'main',
      name: json['name'] as String? ?? 'Main',
      background: json['background'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formatVersion': 1,
      'id': id,
      'name': name,
      'background': background,
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
