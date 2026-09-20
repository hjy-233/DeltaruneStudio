class ProjectCharacterDefinition {
  const ProjectCharacterDefinition({
    required this.id,
    required this.name,
    this.formatVersion = 1,
    this.defaultWidth = 32,
    this.defaultHeight = 48,
    this.moveSpeed = 160,
    this.collision = const ProjectCollisionBox(
      x: -10,
      y: 8,
      width: 20,
      height: 12,
    ),
    this.animations = const [],
  });

  final int formatVersion;
  final String id;
  final String name;
  final double defaultWidth;
  final double defaultHeight;
  final double moveSpeed;
  final ProjectCollisionBox collision;
  final List<ProjectCharacterAnimation> animations;

  factory ProjectCharacterDefinition.fromJson(Map<String, dynamic> json) {
    return ProjectCharacterDefinition(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 1,
      id: json['id'] as String? ?? 'character',
      name: json['name'] as String? ?? 'Character',
      defaultWidth: (json['defaultWidth'] as num?)?.toDouble() ?? 32,
      defaultHeight: (json['defaultHeight'] as num?)?.toDouble() ?? 48,
      moveSpeed: (json['moveSpeed'] as num?)?.toDouble() ?? 160,
      collision: ProjectCollisionBox.fromJson(
        json['collision'] as Map<String, dynamic>?,
      ),
      animations: (json['animations'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProjectCharacterAnimation.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'formatVersion': formatVersion,
    'id': id,
    'name': name,
    'defaultWidth': defaultWidth,
    'defaultHeight': defaultHeight,
    'moveSpeed': moveSpeed,
    'collision': collision.toJson(),
    'animations': animations.map((item) => item.toJson()).toList(),
  };

  ProjectCharacterDefinition copyWith({
    String? name,
    double? defaultWidth,
    double? defaultHeight,
    double? moveSpeed,
    ProjectCollisionBox? collision,
    List<ProjectCharacterAnimation>? animations,
  }) {
    return ProjectCharacterDefinition(
      formatVersion: formatVersion,
      id: id,
      name: name ?? this.name,
      defaultWidth: defaultWidth ?? this.defaultWidth,
      defaultHeight: defaultHeight ?? this.defaultHeight,
      moveSpeed: moveSpeed ?? this.moveSpeed,
      collision: collision ?? this.collision,
      animations: animations ?? this.animations,
    );
  }
}

class ProjectCollisionBox {
  const ProjectCollisionBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  factory ProjectCollisionBox.fromJson(Map<String, dynamic>? json) {
    return ProjectCollisionBox(
      x: (json?['x'] as num?)?.toDouble() ?? -10,
      y: (json?['y'] as num?)?.toDouble() ?? 8,
      width: (json?['width'] as num?)?.toDouble() ?? 20,
      height: (json?['height'] as num?)?.toDouble() ?? 12,
    );
  }

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  ProjectCollisionBox copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
  }) {
    return ProjectCollisionBox(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class ProjectCharacterAnimation {
  const ProjectCharacterAnimation({
    required this.id,
    required this.name,
    required this.direction,
    this.fps = 8,
    this.loop = true,
    this.frames = const [],
  });

  final String id;
  final String name;
  final String direction;
  final double fps;
  final bool loop;
  final List<String> frames;

  factory ProjectCharacterAnimation.fromJson(Map<String, dynamic> json) {
    return ProjectCharacterAnimation(
      id: json['id'] as String? ?? 'animation',
      name: json['name'] as String? ?? 'walk',
      direction: json['direction'] as String? ?? 'down',
      fps: (json['fps'] as num?)?.toDouble() ?? 8,
      loop: json['loop'] as bool? ?? true,
      frames: (json['frames'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'direction': direction,
    'fps': fps,
    'loop': loop,
    'frames': frames,
  };

  ProjectCharacterAnimation copyWith({
    String? name,
    String? direction,
    double? fps,
    bool? loop,
    List<String>? frames,
  }) {
    return ProjectCharacterAnimation(
      id: id,
      name: name ?? this.name,
      direction: direction ?? this.direction,
      fps: fps ?? this.fps,
      loop: loop ?? this.loop,
      frames: frames ?? this.frames,
    );
  }
}

class ProjectCharacterFile {
  const ProjectCharacterFile({required this.path, required this.definition});

  final String path;
  final ProjectCharacterDefinition definition;

  ProjectCharacterFile copyWith({ProjectCharacterDefinition? definition}) {
    return ProjectCharacterFile(
      path: path,
      definition: definition ?? this.definition,
    );
  }
}
