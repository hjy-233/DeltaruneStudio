import 'dart:io';

import 'package:deltarune_studio/data/project_repository.dart';
import 'package:deltarune_studio/domain/project_settings.dart';
import 'package:deltarune_studio/godot/godot_build_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'prepares a generated Godot project without changing the source layout',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'deltarune-studio-godot-',
      );
      addTearDown(() => temporaryDirectory.delete(recursive: true));

      final repository = ProjectRepository();
      var source = await repository.create(
        parentPath: temporaryDirectory.path,
        name: 'Sample Game',
      );
      source = await repository.addCharacter(source, 'Kris');
      source = source.copyWith(
        manifest: source.manifest.copyWith(
          gameSettings: const ProjectGameSettings(
            viewportWidth: 320,
            viewportHeight: 240,
            windowWidth: 1280,
            windowHeight: 960,
            startFullscreen: true,
          ),
          exportSettings: const ProjectExportSettings(
            bundleIdentifier: 'studio.deltarune.sample',
            version: '2.0.0',
          ),
        ),
      );
      expect(Directory('${source.path}/.build').existsSync(), isFalse);

      final result = await GodotBuildService().prepare(source);

      expect(File('${result.directory}/project.godot').existsSync(), isTrue);
      expect(
        await File('${result.directory}/project.godot').readAsString(),
        contains('config/name="Sample Game"'),
      );
      final projectSettings = await File(
        '${result.directory}/project.godot',
      ).readAsString();
      expect(projectSettings, contains('window/size/viewport_width=320'));
      expect(projectSettings, contains('window/size/mode=3'));
      expect(File('${result.directory}/runtime/main.gd').existsSync(), isTrue);
      expect(File('${result.directory}/runtime/drs.gd').existsSync(), isTrue);
      expect(
        File('${result.directory}/runtime/debug_overlay.gd').existsSync(),
        isTrue,
      );
      expect(
        File('${result.directory}/runtime/variable_debugger.gd').existsSync(),
        isTrue,
      );
      expect(
        File('${result.directory}/export_presets.cfg').existsSync(),
        isTrue,
      );
      expect(
        await File('${result.directory}/export_presets.cfg').readAsString(),
        contains('application/bundle_identifier="studio.deltarune.sample"'),
      );
      expect(
        await File('${result.directory}/export_presets.cfg').readAsString(),
        contains('include_filter="*.json,*.png'),
      );
      expect(
        File(
          '${result.directory}/runtime/dialogue/light_world.png',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/runtime/dialogue/dark_world.png',
        ).existsSync(),
        isTrue,
      );
      final runtimeApi = await File(
        '${result.directory}/runtime/drs.gd',
      ).readAsString();
      final runtimeMain = await File(
        '${result.directory}/runtime/main.gd',
      ).readAsString();
      expect(runtimeMain, contains('"width": _view_size.x'));
      expect(runtimeMain, contains('"height": _view_size.y'));
      expect(runtimeApi, contains('ResourceLoader.exists(resource_path)'));
      expect(runtimeMain, contains('character.position = _rect_center(spawn)'));
      for (final method in [
        'enable_player_control',
        'set_expression',
        'follow',
        'camera_follow',
        'camera_shake',
        'register_interactable',
        'set_door_enabled',
        'say_dark',
        'say_portrait',
        'choice',
        'set_flag',
        'set_value',
        'show_image',
        'flash',
        'crossfade_bgm',
        'play_sound_at',
        'save_game',
        'load_game',
        'has_save',
        'delete_save',
      ]) {
        expect(runtimeApi, contains('func $method'));
      }
      expect(
        File('${result.directory}/drs_project/project.json').existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/drs_project/characters/kris/character.json',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${result.directory}/drs_project/scripts/manual/main.gd',
        ).existsSync(),
        isTrue,
      );
      expect(
        File('${source.path}/scenes/main/scene.json').existsSync(),
        isTrue,
      );
    },
  );
}
