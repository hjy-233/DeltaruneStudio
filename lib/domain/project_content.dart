class ProjectInteraction {
  const ProjectInteraction({
    this.enabled = false,
    this.distance = 48,
    this.prompt = '',
    this.functionName = '',
    this.once = false,
    this.requireFacing = false,
  });

  final bool enabled;
  final double distance;
  final String prompt;
  final String functionName;
  final bool once;
  final bool requireFacing;

  factory ProjectInteraction.fromJson(Map<String, dynamic>? json) {
    return ProjectInteraction(
      enabled: json?['enabled'] as bool? ?? false,
      distance: (json?['distance'] as num?)?.toDouble() ?? 48,
      prompt: json?['prompt'] as String? ?? '',
      functionName: json?['function'] as String? ?? '',
      once: json?['once'] as bool? ?? false,
      requireFacing: json?['requireFacing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'distance': distance,
    'prompt': prompt,
    'function': functionName,
    'once': once,
    'requireFacing': requireFacing,
  };

  ProjectInteraction copyWith({
    bool? enabled,
    double? distance,
    String? prompt,
    String? functionName,
    bool? once,
    bool? requireFacing,
  }) {
    return ProjectInteraction(
      enabled: enabled ?? this.enabled,
      distance: distance ?? this.distance,
      prompt: prompt ?? this.prompt,
      functionName: functionName ?? this.functionName,
      once: once ?? this.once,
      requireFacing: requireFacing ?? this.requireFacing,
    );
  }
}

class ProjectTileCell {
  const ProjectTileCell({
    required this.column,
    required this.row,
    required this.kind,
    this.asset = '',
  });

  final int column;
  final int row;
  final String kind;
  final String asset;

  factory ProjectTileCell.fromJson(Map<String, dynamic> json) {
    return ProjectTileCell(
      column: (json['column'] as num?)?.toInt() ?? 0,
      row: (json['row'] as num?)?.toInt() ?? 0,
      kind: json['kind'] as String? ?? 'ground',
      asset: json['asset'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'column': column,
    'row': row,
    'kind': kind,
    if (asset.isNotEmpty) 'asset': asset,
  };
}

class ProjectTileMap {
  const ProjectTileMap({
    this.tileWidth = 32,
    this.tileHeight = 32,
    this.cells = const [],
  });

  final double tileWidth;
  final double tileHeight;
  final List<ProjectTileCell> cells;

  factory ProjectTileMap.fromJson(Map<String, dynamic>? json) {
    return ProjectTileMap(
      tileWidth: (json?['tileWidth'] as num?)?.toDouble() ?? 32,
      tileHeight: (json?['tileHeight'] as num?)?.toDouble() ?? 32,
      cells: (json?['cells'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProjectTileCell.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
    'tileWidth': tileWidth,
    'tileHeight': tileHeight,
    'cells': cells.map((cell) => cell.toJson()).toList(growable: false),
  };

  ProjectTileMap copyWith({
    double? tileWidth,
    double? tileHeight,
    List<ProjectTileCell>? cells,
  }) {
    return ProjectTileMap(
      tileWidth: tileWidth ?? this.tileWidth,
      tileHeight: tileHeight ?? this.tileHeight,
      cells: cells ?? this.cells,
    );
  }
}

class ProjectDialogue {
  const ProjectDialogue({
    required this.path,
    required this.id,
    required this.translations,
    this.style = 'light',
    this.portrait = '',
    this.sound = '',
    this.charactersPerSecond = 40,
  });

  final String path;
  final String id;
  final Map<String, String> translations;
  final String style;
  final String portrait;
  final String sound;
  final double charactersPerSecond;

  factory ProjectDialogue.fromJson(String path, Map<String, dynamic> json) {
    final translations = <String, String>{};
    final raw = json['translations'];
    if (raw is Map<String, dynamic>) {
      for (final entry in raw.entries) {
        if (entry.value is String) {
          translations[entry.key] = entry.value as String;
        }
      }
    }
    return ProjectDialogue(
      path: path,
      id: json['id'] as String? ?? 'dialogue',
      translations: translations,
      style: json['style'] as String? ?? 'light',
      portrait: json['portrait'] as String? ?? '',
      sound: json['sound'] as String? ?? '',
      charactersPerSecond:
          (json['charactersPerSecond'] as num?)?.toDouble() ?? 40,
    );
  }

  Map<String, dynamic> toJson() => {
    'formatVersion': 1,
    'id': id,
    'style': style,
    'portrait': portrait,
    'sound': sound,
    'charactersPerSecond': charactersPerSecond,
    'translations': translations,
  };

  ProjectDialogue copyWith({
    Map<String, String>? translations,
    String? style,
    String? portrait,
    String? sound,
    double? charactersPerSecond,
  }) {
    return ProjectDialogue(
      path: path,
      id: id,
      translations: translations ?? this.translations,
      style: style ?? this.style,
      portrait: portrait ?? this.portrait,
      sound: sound ?? this.sound,
      charactersPerSecond: charactersPerSecond ?? this.charactersPerSecond,
    );
  }
}
