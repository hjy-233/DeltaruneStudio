part of 'project_controller.dart';

extension StudioControllerPreferenceActions on StudioController {
  Future<File> _characterLibraryFile() async {
    final settings = await _settingsFile();
    return File(p.join(settings.parent.path, 'characters.json'));
  }

  Future<Directory> _characterLibraryAssetDirectory() async {
    final settings = await _settingsFile();
    return Directory(p.join(settings.parent.path, 'character_assets'));
  }

  Future<StudioProject> _loadGlobalCharacters(
    StudioProject project, {
    bool seedIfMissing = true,
    Directory? projectDirectory,
  }) async {
    if (project.settings.characterLibraryScope !=
        CharacterLibraryScope.global) {
      return project;
    }
    if (kIsWeb) {
      final encoded = readWebCharacterLibraryCookie();
      if (encoded != null && encoded.isNotEmpty) {
        try {
          final decoded = jsonDecode(encoded);
          final package = _decodeGlobalCharacterPackage(decoded);
          if (package.characters.isNotEmpty) {
            return project.copyWith(
              characters: package.characters,
              assets: _mergeAssets(project.assets, package.assets),
            );
          }
        } on Object {
          return project;
        }
      }
      if (seedIfMissing) {
        _writeWebCharacterPackage(project, const []);
      }
      return project;
    }
    try {
      final file = await _characterLibraryFile();
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        final package = _decodeGlobalCharacterPackage(decoded);
        if (package.characters.isNotEmpty) {
          final importedAssets = await _importGlobalCharacterAssets(
            package.assets,
            projectDirectory,
          );
          return project.copyWith(
            characters: package.characters,
            assets: _mergeAssets(project.assets, importedAssets),
          );
        }
      }
      if (seedIfMissing) {
        await _writeGlobalCharacterPackage(project, projectDirectory);
      }
    } on Object {
      return project;
    }
    return project;
  }

  Future<void> _saveGlobalCharactersIfNeeded(
    StudioProject project, {
    Directory? projectDirectory,
  }) async {
    if (project.settings.characterLibraryScope !=
        CharacterLibraryScope.global) {
      return;
    }
    if (kIsWeb) {
      _writeWebCharacterPackage(project, _characterAssets(project));
      return;
    }
    await _writeGlobalCharacterPackage(project, projectDirectory);
  }

  void _writeWebCharacterPackage(StudioProject project, List<AssetRef> assets) {
    const encoder = JsonEncoder();
    writeWebCharacterLibraryCookie(
      encoder.convert(_globalCharacterPackageJson(project.characters, assets)),
    );
  }

  Future<void> _writeGlobalCharacterPackage(
    StudioProject project,
    Directory? projectDirectory,
  ) async {
    final file = await _characterLibraryFile();
    final assets = await _copyCharacterAssetsToGlobalLibrary(
      project,
      projectDirectory,
    );
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      encoder.convert(_globalCharacterPackageJson(project.characters, assets)),
      flush: true,
    );
  }

  Map<String, Object?> _globalCharacterPackageJson(
    List<Character> characters,
    List<AssetRef> assets,
  ) {
    return {
      'version': 2,
      'characters': [for (final character in characters) character.toJson()],
      'assets': [for (final asset in assets) asset.toJson()],
    };
  }

  ({List<Character> characters, List<AssetRef> assets})
  _decodeGlobalCharacterPackage(Object? decoded) {
    if (decoded is List) {
      return (
        characters: [
          for (final item in decoded)
            if (item is Map<String, dynamic>) Character.fromJson(item),
        ],
        assets: const <AssetRef>[],
      );
    }
    if (decoded is Map<String, dynamic>) {
      final rawCharacters = decoded['characters'];
      final rawAssets = decoded['assets'];
      return (
        characters: [
          if (rawCharacters is List)
            for (final item in rawCharacters)
              if (item is Map<String, dynamic>) Character.fromJson(item),
        ],
        assets: [
          if (rawAssets is List)
            for (final item in rawAssets)
              if (item is Map<String, dynamic>) AssetRef.fromJson(item),
        ],
      );
    }
    return (characters: const <Character>[], assets: const <AssetRef>[]);
  }

  List<AssetRef> _characterAssets(StudioProject project) {
    final ids = _characterAssetIds(project.characters);
    return [
      for (final asset in project.assets)
        if (ids.contains(asset.id)) asset,
    ];
  }

  Set<String> _characterAssetIds(List<Character> characters) {
    return {
      for (final character in characters)
        for (final animation in character.animations)
          if (animation.assetId.isNotEmpty) animation.assetId,
      for (final character in characters)
        for (final expression in character.expressions) ...[
          if (expression.assetId != null && expression.assetId!.isNotEmpty)
            expression.assetId!,
          ...expression.assetIds.where((id) => id.isNotEmpty),
        ],
    };
  }

  List<AssetRef> _mergeAssets(
    List<AssetRef> existing,
    List<AssetRef> incoming,
  ) {
    final seen = {for (final asset in existing) asset.id};
    return [
      ...existing,
      for (final asset in incoming)
        if (seen.add(asset.id)) asset,
    ];
  }

  Future<List<AssetRef>> _copyCharacterAssetsToGlobalLibrary(
    StudioProject project,
    Directory? projectDirectory,
  ) async {
    final assets = _characterAssets(project);
    if (projectDirectory == null) {
      return [
        for (final asset in assets)
          if (asset.dataUri != null && asset.dataUri!.isNotEmpty) asset,
      ];
    }
    final directory = await _characterLibraryAssetDirectory();
    await directory.create(recursive: true);
    final copied = <AssetRef>[];
    for (final asset in assets) {
      final dataUri = asset.dataUri;
      if (dataUri != null && dataUri.isNotEmpty) {
        copied.add(asset);
        continue;
      }
      final source = File(p.join(projectDirectory.path, asset.relativePath));
      if (!await source.exists()) {
        continue;
      }
      final targetPath = p.join(
        directory.path,
        '${asset.id}_${asset.originalName}',
      );
      await source.copy(targetPath);
      copied.add(
        asset.copyWith(
          relativePath: p.relative(targetPath, from: directory.path),
          dataUri: null,
        ),
      );
    }
    return copied;
  }

  Future<List<AssetRef>> _importGlobalCharacterAssets(
    List<AssetRef> assets,
    Directory? projectDirectory,
  ) async {
    if (kIsWeb || projectDirectory == null) {
      return assets;
    }
    final globalDirectory = await _characterLibraryAssetDirectory();
    final imported = <AssetRef>[];
    for (final asset in assets) {
      if (asset.dataUri != null && asset.dataUri!.isNotEmpty) {
        imported.add(asset);
        continue;
      }
      final source = File(p.join(globalDirectory.path, asset.relativePath));
      if (!await source.exists()) {
        continue;
      }
      final target = await _repository.importAssetBytes(
        projectDirectory: projectDirectory,
        bytes: await source.readAsBytes(),
        kind: asset.kind,
        originalName: asset.originalName,
        id: asset.id,
      );
      imported.add(target);
    }
    return imported;
  }

  Future<StudioProject> _materializeDataUriAssets(
    StudioProject project,
    Directory directory,
  ) async {
    final assets = <AssetRef>[];
    for (final asset in project.assets) {
      final dataUri = asset.dataUri;
      if (dataUri == null || dataUri.isEmpty) {
        assets.add(asset);
        continue;
      }
      final bytes = _bytesFromDataUri(dataUri);
      final materialized = await _repository.importAssetBytes(
        projectDirectory: directory,
        bytes: bytes,
        kind: asset.kind,
        originalName: asset.originalName,
        id: asset.id,
      );
      assets.add(materialized);
    }
    return project.copyWith(assets: assets);
  }

  List<int> _bytesFromDataUri(String dataUri) {
    final comma = dataUri.indexOf(',');
    if (comma < 0) {
      return const [];
    }
    return base64Decode(dataUri.substring(comma + 1));
  }

  Future<File> _settingsFile() async {
    final home = Platform.environment['HOME'];
    final appData = Platform.environment['APPDATA'];
    final configHome = Platform.environment['XDG_CONFIG_HOME'];
    final basePath = Platform.isWindows && appData != null && appData.isNotEmpty
        ? appData
        : Platform.isMacOS && home != null && home.isNotEmpty
        ? p.join(home, 'Library', 'Application Support')
        : configHome != null && configHome.isNotEmpty
        ? configHome
        : home != null && home.isNotEmpty
        ? p.join(home, '.config')
        : Directory.current.path;
    final directory = Directory(p.join(basePath, 'Deltarune Studio'));
    await directory.create(recursive: true);
    return File(p.join(directory.path, StudioController._settingsFileName));
  }

  Future<String?> _readLastProjectPath() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        return null;
      }
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) {
        return null;
      }
      final path = json[StudioController._lastProjectPathKey];
      if (path is! String || path.isEmpty) {
        return null;
      }
      return path;
    } on Object {
      return null;
    }
  }

  Future<void> _writeLastProjectPath(Directory directory) async {
    final file = await _settingsFile();
    const encoder = JsonEncoder.withIndent('  ');
    final preferences = await _readAppPreferences();
    preferences[StudioController._lastProjectPathKey] = directory.path;
    await file.writeAsString(encoder.convert(preferences), flush: true);
  }

  Future<bool> _readRestoreLastProject() async {
    final preferences = await _readAppPreferences();
    final value = preferences['restoreLastProject'];
    return value is bool ? value : true;
  }

  Future<void> _writeRestoreLastProject(bool value) async {
    final file = await _settingsFile();
    const encoder = JsonEncoder.withIndent('  ');
    final preferences = await _readAppPreferences();
    preferences['restoreLastProject'] = value;
    await file.writeAsString(encoder.convert(preferences), flush: true);
  }

  Future<Map<String, dynamic>> _readAppPreferences() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        return <String, dynamic>{};
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
    } on Object {
      // A corrupt preference file should fall back to defaults.
    }
    return <String, dynamic>{};
  }

  Future<void> _clearLastProjectPath() async {
    try {
      final file = await _settingsFile();
      if (await file.exists()) {
        await file.delete();
      }
    } on Object {
      // Best effort only; a bad preference should never block app startup.
    }
  }
}
