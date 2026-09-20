import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

import 'package:deltarune_studio/domain/project_manifest.dart';

import 'godot_build_models.dart';

class GodotBuildResult {
  const GodotBuildResult({required this.directory, required this.godotPath});

  final String directory;
  final String? godotPath;
}

class GodotBuildService {
  Future<GodotBuildResult> prepare(ProjectDocument document) async {
    await _validateProject(document);
    final template = await _findTemplate();
    final output = Directory(p.join(document.path, '.build', 'godot'));
    if (await output.exists()) {
      await output.delete(recursive: true);
    }
    if (template != null) {
      await _copyDirectory(template, output);
    } else {
      await _copyBundledTemplate(output);
    }
    await _copyProjectData(document, output);
    await _personalizeProject(output, document);
    return GodotBuildResult(
      directory: output.path,
      godotPath: await _findGodotExecutable(),
    );
  }

  Future<GodotRunSession> buildAndRun(ProjectDocument document) async {
    final result = await prepare(document);
    final godot = result.godotPath;
    if (godot == null) {
      throw StateError(
        'Godot was not found in the standard installation locations.',
      );
    }
    final process = await Process.start(godot, ['--path', result.directory]);
    return _IoGodotRunSession(process);
  }

  Future<void> exportProject(
    ProjectDocument document,
    GodotExportTarget target,
    String outputPath, {
    void Function(String line)? onOutput,
  }) async {
    final result = await prepare(document);
    final godot = result.godotPath;
    if (godot == null) {
      throw StateError(
        'Godot was not found in the standard installation locations.',
      );
    }
    final process = await Process.start(godot, [
      '--headless',
      '--path',
      result.directory,
      '--export-release',
      target.preset,
      outputPath,
    ]);
    final lines = <String>[];
    void collect(String line) {
      lines.add(line);
      onOutput?.call(line);
    }

    await Future.wait([
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach(collect),
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .forEach(collect),
    ]);
    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      final detail = lines.length > 20
          ? lines.sublist(lines.length - 20).join('\n')
          : lines.join('\n');
      throw StateError('Godot export failed ($exitCode).\n$detail');
    }
  }

  Future<Directory?> _findTemplate() async {
    final candidates = [
      Directory(p.join(Directory.current.path, 'runtime', 'godot_template')),
      Directory(
        p.join(
          File(Platform.resolvedExecutable).parent.path,
          'runtime',
          'godot_template',
        ),
      ),
    ];
    for (final candidate in candidates) {
      if (await File(p.join(candidate.path, 'project.godot')).exists()) {
        return candidate;
      }
    }
    return null;
  }

  Future<String?> _findGodotExecutable() async {
    final candidates = _installedGodotCandidates();
    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        return candidate;
      }
    }
    for (final command in _pathCommands()) {
      if (await _commandExists(command)) {
        return command;
      }
    }
    return null;
  }

  List<String> _installedGodotCandidates() {
    final environment = Platform.environment;
    final home = environment['HOME'];
    final userProfile = environment['USERPROFILE'];
    final localAppData = environment['LOCALAPPDATA'];
    final programFiles = environment['PROGRAMFILES'];
    final candidates = <String>[];
    if (Platform.isMacOS) {
      candidates.addAll([
        '/Applications/Godot.app/Contents/MacOS/Godot',
        '/Applications/Godot_mono.app/Contents/MacOS/Godot',
      ]);
    }
    if (Platform.isWindows) {
      candidates.addAll([
        if (programFiles != null) p.join(programFiles, 'Godot', 'Godot.exe'),
        if (localAppData != null) p.join(localAppData, 'Godot', 'Godot.exe'),
        if (userProfile != null)
          p.join(userProfile, 'scoop', 'apps', 'godot', 'current', 'Godot.exe'),
      ]);
    }
    if (Platform.isLinux) {
      candidates.addAll([
        '/usr/bin/godot',
        '/usr/local/bin/godot',
        '/snap/bin/godot',
        '/var/lib/flatpak/exports/bin/org.godotengine.Godot',
        if (home != null) ...[
          p.join(home, '.local', 'bin', 'godot'),
          p.join(home, 'Applications', 'Godot', 'Godot'),
          p.join(home, 'Godot', 'Godot'),
        ],
      ]);
    }
    return candidates;
  }

  List<String> _pathCommands() {
    if (Platform.isWindows) {
      return ['godot.exe', 'godot4.exe'];
    }
    if (Platform.isLinux) {
      return ['godot', 'godot4'];
    }
    return const [];
  }

  Future<bool> _commandExists(String command) async {
    final result = await Process.run(Platform.isWindows ? 'where' : 'which', [
      command,
    ]);
    return result.exitCode == 0;
  }

  Future<void> _copyProjectData(
    ProjectDocument document,
    Directory output,
  ) async {
    final source = Directory(document.path);
    final target = Directory(p.join(output.path, 'drs_project'));
    await target.create(recursive: true);
    for (final name in [
      'project.json',
      'resources',
      'scenes',
      'characters',
      'scripts',
      'visual_scripts',
      'settings',
    ]) {
      final item = File(p.join(source.path, name));
      if (await item.exists()) {
        await item.copy(p.join(target.path, name));
        continue;
      }
      final directory = Directory(p.join(source.path, name));
      if (await directory.exists()) {
        await _copyDirectory(directory, Directory(p.join(target.path, name)));
      }
    }
  }

  Future<void> _personalizeProject(
    Directory output,
    ProjectDocument document,
  ) async {
    final name = document.manifest.name;
    final game = document.manifest.gameSettings;
    final export = document.manifest.exportSettings;
    final projectFile = File(p.join(output.path, 'project.godot'));
    final safeName = name
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll(RegExp(r'[\r\n]+'), ' ');
    if (await projectFile.exists()) {
      final source = await projectFile.readAsString();
      var personalized = source.replaceFirst(
        'config/name="Deltarune Studio Game"',
        'config/name="$safeName"',
      );
      personalized = personalized
          .replaceFirst(
            'window/size/viewport_width=640',
            'window/size/viewport_width=${game.viewportWidth}',
          )
          .replaceFirst(
            'window/size/viewport_height=480',
            'window/size/viewport_height=${game.viewportHeight}',
          )
          .replaceFirst(
            'window/size/window_width_override=960',
            'window/size/window_width_override=${game.windowWidth}',
          )
          .replaceFirst(
            'window/size/window_height_override=720',
            'window/size/window_height_override=${game.windowHeight}',
          )
          .replaceFirst(
            'window/stretch/mode="canvas_items"',
            'window/stretch/mode="${game.pixelPerfect ? 'canvas_items' : 'viewport'}"\nwindow/size/mode=${game.startFullscreen ? 3 : 0}',
          );
      await projectFile.writeAsString(personalized);
    }

    final presetFile = File(p.join(output.path, 'export_presets.cfg'));
    if (!await presetFile.exists()) {
      return;
    }
    final bundleSuffix = name.toLowerCase().replaceAll(
      RegExp('[^a-z0-9]+'),
      '',
    );
    final bundleIdentifier = export.bundleIdentifier.trim().isNotEmpty
        ? export.bundleIdentifier.trim()
        : 'com.deltarunestudio.${bundleSuffix.isEmpty ? 'game' : bundleSuffix}';
    var presetSource = await presetFile.readAsString();
    final iconPath = await _copyExportIcon(output, export.iconPath);
    presetSource = presetSource.replaceAll(
      'application/icon=""',
      'application/icon="$iconPath"\napplication/version="${export.version}"',
    );
    await presetFile.writeAsString(
      presetSource.replaceFirst(
        'application/bundle_identifier="com.deltarunestudio.game"',
        'application/bundle_identifier="$bundleIdentifier"',
      ),
    );
  }

  Future<String> _copyExportIcon(Directory output, String sourcePath) async {
    if (sourcePath.trim().isEmpty) return '';
    final source = File(sourcePath);
    if (!await source.exists()) return '';
    final extension = p.extension(source.path).toLowerCase();
    final target = File(
      p.join(output.path, 'runtime', 'export_icon$extension'),
    );
    await target.parent.create(recursive: true);
    await source.copy(target.path);
    return 'res://runtime/${p.basename(target.path)}';
  }

  Future<void> _copyBundledTemplate(Directory output) async {
    const files = [
      'project.godot',
      'export_presets.cfg',
      'runtime/main.tscn',
      'runtime/main.gd',
      'runtime/drs.gd',
      'runtime/debug_overlay.gd',
      'runtime/variable_debugger.gd',
      'runtime/dialogue/light_world.png',
      'runtime/dialogue/dark_world.png',
    ];
    try {
      for (final relativePath in files) {
        final data = await rootBundle.load(
          'runtime/godot_template/$relativePath',
        );
        final target = File(p.join(output.path, relativePath));
        await target.parent.create(recursive: true);
        await target.writeAsBytes(data.buffer.asUint8List());
      }
    } on Object catch (error) {
      throw StateError('Godot runtime template is unavailable: $error');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list()) {
      final name = p.basename(entity.path);
      if (name == '.godot' ||
          name == '.DS_Store' ||
          name.endsWith('.uid') ||
          name.endsWith('.import')) {
        continue;
      }
      final destination = p.join(target.path, p.basename(entity.path));
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(destination));
      } else if (entity is File) {
        await entity.copy(destination);
      }
    }
  }

  Future<void> _validateProject(ProjectDocument document) async {
    final root = p.normalize(document.path);
    final scriptPath = p.normalize(
      p.join(document.path, document.manifest.entryScript),
    );
    if (!p.isWithin(root, scriptPath)) {
      throw StateError('Entry script must be inside the project folder.');
    }
    if (!await File(scriptPath).exists()) {
      throw StateError(
        'Entry script was not found: ${document.manifest.entryScript}',
      );
    }
  }
}

class _IoGodotRunSession implements GodotRunSession {
  _IoGodotRunSession(this.process) {
    final controller = StreamController<String>();
    var openStreams = 2;
    void bind(Stream<List<int>> source) {
      source
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            controller.add,
            onError: controller.addError,
            onDone: () {
              openStreams -= 1;
              if (openStreams == 0) {
                unawaited(controller.close());
              }
            },
          );
    }

    bind(process.stdout);
    bind(process.stderr);
    output = controller.stream;
  }

  final Process process;

  @override
  late final Stream<String> output;

  @override
  Future<int> get exitCode => process.exitCode;

  @override
  Future<void> stop() async {
    process.kill();
    await process.exitCode;
  }
}
