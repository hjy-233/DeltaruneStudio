import 'dart:convert';
import 'dart:io';

import 'package:deltarune_studio/domain/studio_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final builtInAssetLibraryProvider = FutureProvider<BuiltInAssetLibrary>((
  ref,
) async {
  return BuiltInAssetLibrary.load();
});

final class BuiltInAssetLibrary {
  const BuiltInAssetLibrary(this.assets);

  final List<BuiltInAsset> assets;

  static Future<BuiltInAssetLibrary> load() async {
    final root = await _builtInRoot();
    final jsonText = await File(
      p.join(root.path, 'deltarune_manifest.json'),
    ).readAsString();
    final items = jsonDecode(jsonText) as List<dynamic>;
    return BuiltInAssetLibrary(
      items
          .map(
            (item) =>
                BuiltInAsset.fromJson(item as Map<String, dynamic>, root: root),
          )
          .toList(growable: false),
    );
  }

  static Future<Directory> _builtInRoot() async {
    final executable = File(Platform.resolvedExecutable).parent;
    final candidates = [
      Directory(
        p.normalize(p.join(executable.path, '..', 'Resources', 'builtin')),
      ),
      Directory(
        p.normalize(p.join(executable.path, '..', '..', '..', 'builtin')),
      ),
      Directory(p.join(executable.path, 'data', 'builtin')),
      Directory(p.normalize(p.join(executable.path, '..', 'data', 'builtin'))),
      Directory(p.join(executable.path, 'builtin')),
      Directory(p.join(Directory.current.path, 'assets', 'builtin')),
    ];
    for (final candidate in candidates) {
      if (await File(
        p.join(candidate.path, 'deltarune_manifest.json'),
      ).exists()) {
        return candidate;
      }
    }
    return candidates.last;
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
    required Directory root,
  }) {
    final assetPath = json['assetPath'] as String;
    final relativePath = assetPath.startsWith('assets/builtin/')
        ? assetPath.substring('assets/builtin/'.length)
        : assetPath;
    return BuiltInAsset(
      id: json['id'] as String,
      name: json['name'] as String,
      kind: AssetKind.values.byName(json['kind'] as String),
      assetPath: assetPath,
      sourcePath: json['sourcePath'] as String,
      resolvedPath: p.join(root.path, relativePath),
    );
  }
}
