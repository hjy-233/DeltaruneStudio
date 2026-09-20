import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

class RecentProjectsStore {
  Future<List<String>> load() async {
    final file = _file;
    if (!await file.exists()) {
      return [];
    }
    try {
      final value = jsonDecode(await file.readAsString());
      return value is List ? value.whereType<String>().toList() : [];
    } on Object {
      return [];
    }
  }

  Future<void> save(List<String> paths) async {
    final file = _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(paths));
  }

  File get _file {
    final environment = Platform.environment;
    final home = environment['HOME'] ?? Directory.current.path;
    final root = Platform.isMacOS
        ? p.join(home, 'Library', 'Application Support')
        : Platform.isWindows
        ? environment['APPDATA'] ?? home
        : environment['XDG_CONFIG_HOME'] ?? p.join(home, '.config');
    return File(p.join(root, 'DeltaruneStudio', 'recent_projects.json'));
  }
}
