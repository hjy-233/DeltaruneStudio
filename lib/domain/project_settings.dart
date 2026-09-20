class ProjectGameSettings {
  const ProjectGameSettings({
    this.viewportWidth = 640,
    this.viewportHeight = 480,
    this.windowWidth = 960,
    this.windowHeight = 720,
    this.startFullscreen = false,
    this.pixelPerfect = true,
    this.defaultSaveSlot = 1,
    this.enableWasd = true,
    this.enableArrowKeys = true,
  });

  final int viewportWidth;
  final int viewportHeight;
  final int windowWidth;
  final int windowHeight;
  final bool startFullscreen;
  final bool pixelPerfect;
  final int defaultSaveSlot;
  final bool enableWasd;
  final bool enableArrowKeys;

  factory ProjectGameSettings.fromJson(Map<String, dynamic>? json) {
    int positive(String key, int fallback) {
      return ((json?[key] as num?)?.toInt() ?? fallback).clamp(1, 16384);
    }

    return ProjectGameSettings(
      viewportWidth: positive('viewportWidth', 640),
      viewportHeight: positive('viewportHeight', 480),
      windowWidth: positive('windowWidth', 960),
      windowHeight: positive('windowHeight', 720),
      startFullscreen: json?['startFullscreen'] as bool? ?? false,
      pixelPerfect: json?['pixelPerfect'] as bool? ?? true,
      defaultSaveSlot: ((json?['defaultSaveSlot'] as num?)?.toInt() ?? 1).clamp(
        1,
        3,
      ),
      enableWasd: json?['enableWasd'] as bool? ?? true,
      enableArrowKeys: json?['enableArrowKeys'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'viewportWidth': viewportWidth,
    'viewportHeight': viewportHeight,
    'windowWidth': windowWidth,
    'windowHeight': windowHeight,
    'startFullscreen': startFullscreen,
    'pixelPerfect': pixelPerfect,
    'defaultSaveSlot': defaultSaveSlot,
    'enableWasd': enableWasd,
    'enableArrowKeys': enableArrowKeys,
  };

  ProjectGameSettings copyWith({
    int? viewportWidth,
    int? viewportHeight,
    int? windowWidth,
    int? windowHeight,
    bool? startFullscreen,
    bool? pixelPerfect,
    int? defaultSaveSlot,
    bool? enableWasd,
    bool? enableArrowKeys,
  }) {
    return ProjectGameSettings(
      viewportWidth: viewportWidth ?? this.viewportWidth,
      viewportHeight: viewportHeight ?? this.viewportHeight,
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
      startFullscreen: startFullscreen ?? this.startFullscreen,
      pixelPerfect: pixelPerfect ?? this.pixelPerfect,
      defaultSaveSlot: defaultSaveSlot ?? this.defaultSaveSlot,
      enableWasd: enableWasd ?? this.enableWasd,
      enableArrowKeys: enableArrowKeys ?? this.enableArrowKeys,
    );
  }
}

class ProjectExportSettings {
  const ProjectExportSettings({
    this.bundleIdentifier = '',
    this.version = '1.0.0',
    this.iconPath = '',
    this.defaultTarget = 'macOS',
    this.outputDirectory = '',
  });

  final String bundleIdentifier;
  final String version;
  final String iconPath;
  final String defaultTarget;
  final String outputDirectory;

  factory ProjectExportSettings.fromJson(Map<String, dynamic>? json) {
    return ProjectExportSettings(
      bundleIdentifier: json?['bundleIdentifier'] as String? ?? '',
      version: json?['version'] as String? ?? '1.0.0',
      iconPath: json?['iconPath'] as String? ?? '',
      defaultTarget: _normalizeTarget(
        json?['defaultTarget'] as String? ?? 'macOS',
      ),
      outputDirectory: json?['outputDirectory'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'bundleIdentifier': bundleIdentifier,
    'version': version,
    'iconPath': iconPath,
    'defaultTarget': defaultTarget,
    'outputDirectory': outputDirectory,
  };

  ProjectExportSettings copyWith({
    String? bundleIdentifier,
    String? version,
    String? iconPath,
    String? defaultTarget,
    String? outputDirectory,
  }) {
    return ProjectExportSettings(
      bundleIdentifier: bundleIdentifier ?? this.bundleIdentifier,
      version: version ?? this.version,
      iconPath: iconPath ?? this.iconPath,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      outputDirectory: outputDirectory ?? this.outputDirectory,
    );
  }
}

String _normalizeTarget(String value) {
  return switch (value.toLowerCase()) {
    'windows' => 'windows',
    'linux' => 'linux',
    _ => 'macOS',
  };
}
