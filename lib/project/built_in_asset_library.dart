import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final builtInAssetLibraryProvider = FutureProvider<BuiltInAssetLibrary>((
  ref,
) async {
  return BuiltInAssetLibrary.load();
});

final class BuiltInAssetLibrary {
  const BuiltInAssetLibrary(
    this.assets, {
    this.missingExternalDirectory = false,
    this.rootPath,
  });

  final List<BuiltInAsset> assets;
  final bool missingExternalDirectory;
  final String? rootPath;

  static Future<BuiltInAssetLibrary> load() async {
    if (kIsWeb) {
      final jsonText = await rootBundle.loadString(
        'assets/builtin/deltarune_manifest.json',
      );
      final items = jsonDecode(jsonText) as List<dynamic>;
      final portraitItems = await _loadBundledManifest(
        'assets/dialogue/portraits/manifest.json',
      );
      final soundItems = await _loadBundledManifest(
        'assets/dialogue/sound/manifest.json',
      );
      return BuiltInAssetLibrary(
        [
          ...items.map(
            (item) =>
                BuiltInAsset.fromJson(item as Map<String, dynamic>, root: null),
          ),
          ...portraitItems.map(
            (item) => BuiltInAsset.fromJson(item, root: null),
          ),
          ...soundItems.map((item) => BuiltInAsset.fromJson(item, root: null)),
        ].toList(growable: false),
      );
    }
    final root = await _builtInRoot();
    if (root == null) {
      return const BuiltInAssetLibrary([], missingExternalDirectory: true);
    }
    final jsonText = await File(
      p.join(root.path, 'deltarune_manifest.json'),
    ).readAsString();
    final items = jsonDecode(jsonText) as List<dynamic>;
    final portraitItems = await _loadExternalManifest(
      root,
      'dialogue/portraits/manifest.json',
    );
    final soundItems = await _loadExternalManifest(
      root,
      'dialogue/sound/manifest.json',
    );
    return BuiltInAssetLibrary(
      [
        ...items.map(
          (item) =>
              BuiltInAsset.fromJson(item as Map<String, dynamic>, root: root),
        ),
        ...portraitItems.map((item) => BuiltInAsset.fromJson(item, root: root)),
        ...soundItems.map((item) => BuiltInAsset.fromJson(item, root: root)),
      ].toList(growable: false),
      rootPath: root.path,
    );
  }

  static Future<List<Map<String, dynamic>>> _loadBundledManifest(
    String path,
  ) async {
    try {
      final jsonText = await rootBundle.loadString(path);
      final items = jsonDecode(jsonText) as List<dynamic>;
      return items.cast<Map<String, dynamic>>();
    } on Object {
      final file = File(p.join(Directory.current.path, path));
      if (!await file.exists()) {
        return const [];
      }
      final items = jsonDecode(await file.readAsString()) as List<dynamic>;
      return items.cast<Map<String, dynamic>>();
    }
  }

  static Future<List<Map<String, dynamic>>> _loadExternalManifest(
    Directory root,
    String relativePath,
  ) async {
    final file = File(p.join(root.path, relativePath));
    if (!await file.exists()) {
      return const [];
    }
    final items = jsonDecode(await file.readAsString()) as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }

  static Future<Directory?> _builtInRoot() async {
    final executable = File(Platform.resolvedExecutable).parent;
    final appSibling = _macAppSiblingRoot(executable.path);
    final candidates = [
      ?appSibling,
      Directory(p.join(executable.path, 'drs_builtin')),
      Directory(p.normalize(p.join(executable.path, '..', 'drs_builtin'))),
      Directory(p.join(Directory.current.path, 'drs_builtin')),
    ];
    for (final candidate in candidates) {
      if (await File(
        p.join(candidate.path, 'deltarune_manifest.json'),
      ).exists()) {
        return candidate;
      }
    }
    return null;
  }

  static Directory? _macAppSiblingRoot(String executableDirectoryPath) {
    final segments = p.split(executableDirectoryPath);
    final appIndex = segments.lastIndexWhere(
      (segment) => segment.endsWith('.app'),
    );
    if (appIndex < 0) {
      return null;
    }
    final appParent = p.joinAll(segments.take(appIndex));
    return Directory(p.join(appParent, 'drs_builtin'));
  }

  List<BuiltInAsset> search(String query, {int limit = 200}) {
    final normalized = query.trim().toLowerCase();
    final matches = normalized.isEmpty
        ? assets
        : assets.where((asset) {
            return asset.name.toLowerCase().contains(normalized) ||
                asset.sourcePath.toLowerCase().contains(normalized);
          });
    return matches.take(limit).toList(growable: false);
  }
}

final class BuiltInAsset {
  const BuiltInAsset({
    required this.id,
    required this.name,
    required this.kind,
    required this.assetPath,
    required this.sourcePath,
    required this.resolvedPath,
  });

  final String id;
  final String name;
  final AssetKind kind;
  final String assetPath;
  final String sourcePath;
  final String resolvedPath;

  factory BuiltInAsset.fromJson(
    Map<String, dynamic> json, {
    required Directory? root,
  }) {
    final assetPath = json['assetPath'] as String;
    final relativePath = assetPath.startsWith('assets/builtin/')
        ? assetPath.substring('assets/builtin/'.length)
        : assetPath.startsWith('assets/')
        ? assetPath.substring('assets/'.length)
        : assetPath;
    final sourcePath = json['sourcePath'] as String;
    final originalKind = AssetKind.values.byName(json['kind'] as String);
    final kind =
        originalKind == AssetKind.character &&
            (sourcePath.toLowerCase().contains('/portraits/') ||
                sourcePath.toLowerCase().contains('spr_face'))
        ? AssetKind.dialoguePortrait
        : originalKind;
    return BuiltInAsset(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: kind,
      assetPath: assetPath,
      sourcePath: sourcePath,
      resolvedPath: root == null
          ? p.join(Directory.current.path, assetPath)
          : p.join(root.path, relativePath),
    );
  }
}
