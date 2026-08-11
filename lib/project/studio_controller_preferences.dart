part of 'project_controller.dart';

extension StudioControllerPreferenceActions on StudioController {
  Future<Directory> _defaultProjectDir() async {
    final home = Platform.environment['HOME'];
    final basePath = home == null || home.isEmpty
        ? Directory.current.path
        : p.join(home, 'Documents');
    return Directory(p.join(basePath, 'Deltarune Studio', 'Demo.drs'));
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
    await file.writeAsString(
      encoder.convert({StudioController._lastProjectPathKey: directory.path}),
      flush: true,
    );
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
